#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const ROOT_DIR = path.resolve(__dirname, "..");
const DEFAULT_CONFIG_PATH = path.join(__dirname, "dict_config.json");
const DEFAULT_GAME_INPUT_FILE = "util/text_dict_input.json";
const DEFAULT_GAME_OUTPUT_FILE = "src/generated/dict_text.asm";
const ASCII_TABLE_START = 0x20;
const ASCII_TABLE_SIZE = 0x40;
const TOKEN_PAGE_SPAN = 0x10;
const TOKEN_SUFFIX_CLASS_OFFSET = Object.freeze({
	none: 0x00,
	space: 0x10,
	period: 0x20,
	exclaim: 0x30,
	question: 0x40,
	sChar: 0x50,
	rChar: 0x60,
});

function fail(message) {
	console.error(`[ERROR] ${message}`);
	process.exit(1);
}

function info(message) {
	console.log(`[INFO] ${message}`);
}

function toHex(value, width = 2) {
	return value.toString(16).padStart(width, "0");
}

function parseNumber(value, fieldName) {
	if (typeof value === "number" && Number.isInteger(value)) {
		return value;
	}
	if (typeof value === "string") {
		const trimmed = value.trim().toLowerCase();
		if (/^0x[0-9a-f]+$/u.test(trimmed)) {
			return Number.parseInt(trimmed.slice(2), 16);
		}
		if (/^[0-9]+$/u.test(trimmed)) {
			return Number.parseInt(trimmed, 10);
		}
	}
	fail(`Invalid numeric value for "${fieldName}": ${JSON.stringify(value)}`);
}

function readJsonFile(filePath, label) {
	let raw = "";
	try {
		raw = fs.readFileSync(filePath, "utf8");
	} catch (error) {
		fail(`Unable to read ${label} at "${filePath}": ${error.message}`);
	}
	try {
		return JSON.parse(raw);
	} catch (error) {
		fail(`Invalid JSON in ${label} at "${filePath}": ${error.message}`);
	}
}

function ensureDirForFile(filePath) {
	fs.mkdirSync(path.dirname(filePath), { recursive: true });
}

function toAsmHexLines(bytes, indent = "\thex ", rowBytes = 16) {
	const lines = [];
	for (let i = 0; i < bytes.length; i += rowBytes) {
		const row = bytes.slice(i, i + rowBytes).map((b) => toHex(b)).join("");
		lines.push(`${indent}${row}`);
	}
	return lines.length === 0 ? [`${indent}`] : lines;
}

function toAsmHexLinesSplitAfterByte(bytes, splitByte, indent = "\thex ", fallbackRowBytes = 16) {
	const rows = splitBytesAfterByte(bytes, splitByte, fallbackRowBytes);
	return rows.map((row) => `${indent}${row.map((b) => toHex(b)).join("")}`);
}

function splitBytesAfterByte(bytes, splitByte, fallbackRowBytes = 16) {
	const lines = [];
	let current = [];
	for (const value of bytes) {
		current.push(value);
		if (value === splitByte) {
			lines.push(current);
			current = [];
		}
	}
	if (current.length > 0) {
		for (let i = 0; i < current.length; i += fallbackRowBytes) {
			lines.push(current.slice(i, i + fallbackRowBytes));
		}
	}
	return lines.length === 0 ? [[]] : lines;
}

function getTokenSuffixString(tokenClass) {
	if (tokenClass === 0) return "";
	if (tokenClass === 1) return "_";
	if (tokenClass === 2) return ".";
	if (tokenClass === 3) return "!";
	if (tokenClass === 4) return "?";
	if (tokenClass === 5) return "S";
	if (tokenClass === 6) return "R";
	return "";
}

function decodeRowUnitsFromPassageBytes(passageBytes, dictionaryWordByAddress, config) {
	const units = [];
	for (let i = 0; i < passageBytes.length; i++) {
		const byte = passageBytes[i];
		if (byte >= config.tokenHiByteMin && byte <= config.tokenHiByteMax && i + 1 < passageBytes.length) {
			const tokenLo = passageBytes[i + 1];
			const tokenDelta = byte - config.tokenHiByteMin;
			const tokenClass = tokenDelta >> 4;
			const pageOffset = tokenDelta & 0x0f;
			const dictAddr = (((config.dictionaryBaseAddress >> 8) + pageOffset) << 8) | tokenLo;
			const baseWord = dictionaryWordByAddress.get(dictAddr) || `<?>$${toHex(dictAddr, 4)}`;
			const commentText = `${baseWord}${getTokenSuffixString(tokenClass)}`;
			units.push({
				hex: `${toHex(byte)}${toHex(tokenLo)}`,
				comment: commentText,
				byteLength: 2,
				forcesLineBreak: false,
			});
			i += 1;
			continue;
		}

		if (byte >= 0x00 && byte <= 0x3f) {
			const ch = String.fromCharCode(byte + ASCII_TABLE_START);
			const shown = ch === " " ? "_" : ch;
			units.push({
				hex: toHex(byte),
				comment: `${shown} `,
				byteLength: 1,
				forcesLineBreak: false,
			});
			continue;
		}

		if (byte >= 0x40 && byte <= 0x7f) {
			const ch = String.fromCharCode((byte - 0x40) + ASCII_TABLE_START);
			const shown = ch === " " ? "_" : ch;
			units.push({
				hex: toHex(byte),
				comment: `${shown}_`,
				byteLength: 1,
				forcesLineBreak: false,
			});
			continue;
		}

		if (byte === config.newlineByte) {
			units.push({
				hex: toHex(byte),
				comment: "\\n",
				byteLength: 1,
				forcesLineBreak: true,
			});
			continue;
		}

		if (byte === config.endOfPassageByte) {
			units.push({
				hex: toHex(byte),
				comment: "\\p",
				byteLength: 1,
				forcesLineBreak: false,
			});
			continue;
		}

		units.push({
			hex: toHex(byte),
			comment: "??",
			byteLength: 1,
			forcesLineBreak: false,
		});
	}
	return units;
}

function splitUnitsIntoRows(units, maxBytesPerRow = 16) {
	const rows = [];
	let row = [];
	let byteBudget = 0;

	for (const unit of units) {
		if (row.length > 0 && byteBudget + unit.byteLength > maxBytesPerRow) {
			rows.push(row);
			row = [];
			byteBudget = 0;
		}
		row.push(unit);
		byteBudget += unit.byteLength;
		if (unit.forcesLineBreak) {
			rows.push(row);
			row = [];
			byteBudget = 0;
		}
	}

	if (row.length > 0) {
		rows.push(row);
	}
	return rows;
}

function renderAlignedRow(rowUnits) {
	const hexParts = [];
	const commentParts = [];
	for (const unit of rowUnits) {
		const width = Math.max(unit.hex.length, unit.comment.length);
		hexParts.push(unit.hex.padEnd(width, " "));
		commentParts.push(unit.comment.padEnd(width, " "));
	}
	return {
		commentLine: `\t;   ${commentParts.join(" ")}`,
		hexLine: `\thex ${hexParts.join(" ")}`,
	};
}

function sanitizeLabel(input) {
	return input.replace(/[^A-Za-z0-9_]/gu, "_");
}

function validateConfig(config, configPath) {
	if (!config || typeof config !== "object") {
		fail(`Config at "${configPath}" must be a JSON object.`);
	}

	const dictionaryBaseAddress = parseNumber(config.dictionaryBaseAddress, "dictionaryBaseAddress");
	const dictionaryMaxBytes = parseNumber(config.dictionaryMaxBytes, "dictionaryMaxBytes");
	const tokenHiByteMin = parseNumber(config.tokenHiByteMin, "tokenHiByteMin");
	const tokenHiByteMax = parseNumber(config.tokenHiByteMax, "tokenHiByteMax");

	if (dictionaryBaseAddress < 0 || dictionaryBaseAddress > 0xffff) {
		fail(`dictionaryBaseAddress out of range: ${toHex(dictionaryBaseAddress, 4)}`);
	}
	if (dictionaryMaxBytes <= 0 || dictionaryMaxBytes > 0x10000) {
		fail(`dictionaryMaxBytes out of range: ${dictionaryMaxBytes}`);
	}
	if (tokenHiByteMin < 0 || tokenHiByteMin > 0xff || tokenHiByteMax < 0 || tokenHiByteMax > 0xff) {
		fail("tokenHiByteMin/tokenHiByteMax must be in byte range 0x00-0xff.");
	}
	if (tokenHiByteMin > tokenHiByteMax) {
		fail("tokenHiByteMin must be <= tokenHiByteMax.");
	}
	if ((tokenHiByteMin & 0x0f) !== 0x00) {
		fail("tokenHiByteMin must be page-aligned (low nibble 0), e.g. $80.");
	}
	if (tokenHiByteMax !== tokenHiByteMin + 0x6f) {
		fail("tokenHiByteMax must equal tokenHiByteMin + $6f for none/space/period/!/ ?/S/R token classes.");
	}

	const controlBytes = config.controlBytes || {};
	const newlineByte = parseNumber(controlBytes.newline ?? "0xf0", "controlBytes.newline");
	const endOfPassageByte = parseNumber(controlBytes.endOfPassage ?? "0xf1", "controlBytes.endOfPassage");
	if (newlineByte < 0 || newlineByte > 0xff || endOfPassageByte < 0 || endOfPassageByte > 0xff) {
		fail("control bytes must be in range 0x00-0xff.");
	}

	const selection = config.selection || {};
	const minWordLength = parseNumber(selection.minWordLength ?? 5, "selection.minWordLength");
	const minFrequency = parseNumber(selection.minFrequency ?? 2, "selection.minFrequency");
	const maxEntries = parseNumber(selection.maxEntries ?? 512, "selection.maxEntries");

	if (minWordLength < 2 || minWordLength > 64) {
		fail("selection.minWordLength must be between 2 and 64.");
	}
	if (minFrequency < 2) {
		fail("selection.minFrequency must be >= 2.");
	}
	if (maxEntries < 1) {
		fail("selection.maxEntries must be >= 1.");
	}

	const dictionaryOutputFile = typeof config.dictionaryOutputFile === "string"
		? config.dictionaryOutputFile
		: "_common/generated/dictionary.asm";
	const gameInputFile = typeof config.gameInputFile === "string" && config.gameInputFile.trim()
		? config.gameInputFile.trim()
		: DEFAULT_GAME_INPUT_FILE;
	const gameOutputFile = typeof config.gameOutputFile === "string" && config.gameOutputFile.trim()
		? config.gameOutputFile.trim()
		: DEFAULT_GAME_OUTPUT_FILE;
	if (!Array.isArray(config.games) || config.games.length === 0) {
		fail("Config requires a non-empty games array.");
	}

	const games = config.games
		.filter((game) => game !== null && game !== undefined)
		.map((game, index) => {
			if (typeof game === "string" && game.trim()) {
				const gameDir = game.trim();
				const gameName = path.basename(gameDir);
				return {
					id: gameName,
					idLabel: sanitizeLabel(gameName),
					inputFile: path.resolve(ROOT_DIR, gameDir, gameInputFile),
					outputFile: path.resolve(ROOT_DIR, gameDir, gameOutputFile),
					gameDir: path.resolve(ROOT_DIR, gameDir),
				};
			}

			// Backward-compatible object support
			if (!game || typeof game !== "object") {
				fail(`games[${index}] must be a game directory string.`);
			}
			if (game.enabled === false) {
				return null;
			}
			if (typeof game.id !== "string" || !game.id.trim()) {
				fail(`games[${index}].id must be a non-empty string.`);
			}
			const gameDir = typeof game.gameDir === "string" && game.gameDir.trim()
				? game.gameDir.trim()
				: game.id.trim();
			return {
				id: game.id.trim(),
				idLabel: sanitizeLabel(game.id.trim()),
				inputFile: path.resolve(ROOT_DIR, gameDir, gameInputFile),
				outputFile: path.resolve(ROOT_DIR, gameDir, gameOutputFile),
				gameDir: path.resolve(ROOT_DIR, gameDir),
			};
		})
		.filter(Boolean);

	if (games.length === 0) {
		fail("All configured games are disabled. Enable at least one game.");
	}

	return {
		dictionaryBaseAddress,
		dictionaryMaxBytes,
		tokenHiByteMin,
		tokenHiByteMax,
		newlineByte,
		endOfPassageByte,
		minWordLength,
		minFrequency,
		maxEntries,
		dictionaryOutputFile: path.resolve(ROOT_DIR, dictionaryOutputFile),
		games,
	};
}

function buildExampleGameInput(gameId) {
	return {
		alphabet: {
			"0x08": " ",
			"0x50": "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-@.<>!?",
		},
		passages: {
			example_intro: `${gameId.toUpperCase()}\nADD YOUR PASSAGES HERE`,
		},
	};
}

function ensureGameInputFile(game) {
	if (fs.existsSync(game.inputFile)) {
		return;
	}
	ensureDirForFile(game.inputFile);
	const template = buildExampleGameInput(game.id);
	fs.writeFileSync(game.inputFile, `${JSON.stringify(template, null, "\t")}\n`, "utf8");
	info(`Created missing input template: ${path.relative(ROOT_DIR, game.inputFile)}`);
}

function registerGlyph(gameId, glyphToPattern, usedPatternToGlyph, glyph, patternId, sourceLabel) {
	if (patternId < 0 || patternId > 0xff) {
		fail(`Game "${gameId}" ${sourceLabel} uses out-of-range pattern id $${toHex(patternId)}.`);
	}
	if (patternId >= 0x80) {
		fail(`Game "${gameId}" ${sourceLabel} assigns pattern id $${toHex(patternId)} in forbidden range $80-$ff.`);
	}
	if (glyph.length !== 1) {
		fail(`Game "${gameId}" ${sourceLabel} glyph must be one character.`);
	}
	if (glyphToPattern.has(glyph)) {
		fail(`Game "${gameId}" duplicate glyph "${glyph}" in alphabet.`);
	}
	if (usedPatternToGlyph.has(patternId)) {
		fail(`Game "${gameId}" pattern id $${toHex(patternId)} already used by glyph "${usedPatternToGlyph.get(patternId)}".`);
	}
	glyphToPattern.set(glyph, patternId);
	usedPatternToGlyph.set(patternId, glyph);
}

function parseAlphabetFromCompactObject(gameId, alphabetObject) {
	if (!alphabetObject || typeof alphabetObject !== "object" || Array.isArray(alphabetObject)) {
		fail(`Game "${gameId}" alphabet must be an object like {"0x40":"ABC"} in compact mode.`);
	}
	const glyphToPattern = new Map();
	const usedPatternToGlyph = new Map();
	const definitions = [];

	for (const [key, glyphsValue] of Object.entries(alphabetObject)) {
		const startPatternId = parseNumber(key, `alphabet key "${key}"`);
		const glyphs = String(glyphsValue);
		if (glyphs.length === 0) {
			fail(`Game "${gameId}" alphabet key "${key}" has empty glyph string.`);
		}
		for (let i = 0; i < glyphs.length; i++) {
			const glyph = glyphs[i];
			const patternId = startPatternId + i;
			registerGlyph(gameId, glyphToPattern, usedPatternToGlyph, glyph, patternId, `alphabet["${key}"]`);
		}
		definitions.push({ type: "range", startPatternId, glyphs });
	}

	return { glyphToPattern, definitions };
}

function parseAlphabetFromLegacyArray(gameId, alphabetEntries) {
	if (!Array.isArray(alphabetEntries) || alphabetEntries.length === 0) {
		fail(`Game "${gameId}" must define a non-empty alphabet array.`);
	}
	const glyphToPattern = new Map();
	const usedPatternToGlyph = new Map();
	const definitions = [];

	alphabetEntries.forEach((entry, index) => {
		if (!entry || typeof entry !== "object") {
			fail(`Game "${gameId}" alphabet[${index}] must be an object.`);
		}
		if ("startPatternId" in entry && "glyphs" in entry) {
			const startPatternId = parseNumber(entry.startPatternId, `alphabet[${index}].startPatternId`);
			const glyphs = String(entry.glyphs);
			for (let i = 0; i < glyphs.length; i++) {
				registerGlyph(
					gameId,
					glyphToPattern,
					usedPatternToGlyph,
					glyphs[i],
					startPatternId + i,
					`alphabet[${index}] range`
				);
			}
			definitions.push({ type: "range", startPatternId, glyphs });
			return;
		}
		if ("patternId" in entry && "glyph" in entry) {
			const patternId = parseNumber(entry.patternId, `alphabet[${index}].patternId`);
			const glyph = String(entry.glyph);
			if (glyph.length !== 1) {
				fail(`Game "${gameId}" alphabet[${index}].glyph must be exactly one character.`);
			}
			registerGlyph(gameId, glyphToPattern, usedPatternToGlyph, glyph, patternId, `alphabet[${index}] explicit`);
			definitions.push({ type: "explicit", patternId, glyph });
			return;
		}
		fail(`Game "${gameId}" alphabet[${index}] must be either {startPatternId, glyphs} or {patternId, glyph}.`);
	});

	return { glyphToPattern, definitions };
}

function validateAlphabet(gameId, alphabetInput) {
	if (Array.isArray(alphabetInput)) {
		return parseAlphabetFromLegacyArray(gameId, alphabetInput);
	}
	return parseAlphabetFromCompactObject(gameId, alphabetInput);
}

function parsePassages(gameId, passagesInput) {
	const passages = [];

	if (Array.isArray(passagesInput)) {
		passagesInput.forEach((passage, index) => {
			if (!passage || typeof passage !== "object") {
				fail(`Game "${gameId}" passage[${index}] must be an object.`);
			}
			const id = typeof passage.id === "string" && passage.id.trim() ? passage.id.trim() : `passage_${index}`;
			if (!Array.isArray(passage.lines) || passage.lines.length === 0) {
				fail(`Game "${gameId}" passage "${id}" must include at least one line.`);
			}
			const lines = passage.lines.map((line, lineIndex) => {
				if (typeof line !== "string") {
					fail(`Game "${gameId}" passage "${id}" line ${lineIndex} is not a string.`);
				}
				return line;
			});
			passages.push({ id, lines });
		});
		return passages;
	}

	if (!passagesInput || typeof passagesInput !== "object") {
		fail(`Game "${gameId}" passages must be an object map or legacy array.`);
	}
	for (const [id, rawBlock] of Object.entries(passagesInput)) {
		if (typeof rawBlock !== "string") {
			fail(`Game "${gameId}" passage "${id}" must be a string in compact mode.`);
		}
		const lines = rawBlock.split("\n");
		if (lines.length === 0) {
			fail(`Game "${gameId}" passage "${id}" must include at least one line.`);
		}
		passages.push({ id, lines });
	}
	return passages;
}

function validateGameInput(game, payload) {
	if (!payload || typeof payload !== "object") {
		fail(`Game "${game.id}" input must be a JSON object.`);
	}

	const { glyphToPattern, definitions } = validateAlphabet(game.id, payload.alphabet);
	const passages = parsePassages(game.id, payload.passages);
	if (passages.length === 0) {
		fail(`Game "${game.id}" must define at least one passage.`);
	}

	return {
		gameId: game.id,
		gameLabel: game.idLabel,
		inputPath: game.inputFile,
		outputPath: game.outputFile,
		passages,
		alphabet: glyphToPattern,
		alphabetDefinitions: definitions,
	};
}

function getUndefinedGlyphs(game) {
	const undefined = new Map();
	for (const passage of game.passages) {
		for (let lineIndex = 0; lineIndex < passage.lines.length; lineIndex++) {
			const line = passage.lines[lineIndex];
			for (let col = 0; col < line.length; col++) {
				const glyph = line[col];
				const upperGlyph = glyph.toUpperCase();
				if (game.alphabet.has(glyph) || game.alphabet.has(upperGlyph)) {
					continue;
				}
				const key = `${glyph}`;
				if (!undefined.has(key)) {
					undefined.set(key, []);
				}
				undefined.get(key).push({
					passageId: passage.id,
					lineIndex,
					column: col,
				});
			}
		}
	}
	return undefined;
}

function extractWordStats(gamesPayload) {
	const stats = new Map();
	for (const game of gamesPayload) {
		for (const passage of game.passages) {
			for (const line of passage.lines) {
				const words = line.match(/[A-Za-z']+/gu) || [];
				for (const rawWord of words) {
					const normalized = rawWord.toLowerCase();
					if (!stats.has(normalized)) {
						stats.set(normalized, {
							normalized,
							sample: rawWord.toUpperCase(),
							count: 0,
							length: normalized.length,
						});
					}
					stats.get(normalized).count += 1;
				}
			}
		}
	}
	return stats;
}

function selectCandidates(wordStats, minWordLength, minFrequency, maxEntries) {
	const candidates = [];
	for (const stat of wordStats.values()) {
		if (stat.length < minWordLength || stat.count < minFrequency) {
			continue;
		}
		const score = (stat.length - 2) * (stat.count - 1);
		if (score <= 0) {
			continue;
		}
		candidates.push({
			word: stat.sample.toUpperCase(),
			normalized: stat.normalized,
			length: stat.length,
			count: stat.count,
			score,
		});
	}
	candidates.sort((a, b) => {
		if (b.score !== a.score) return b.score - a.score;
		if (b.count !== a.count) return b.count - a.count;
		return a.word.localeCompare(b.word);
	});
	return candidates.slice(0, maxEntries);
}

function packDictionary(candidates, config) {
	const dictStart = config.dictionaryBaseAddress;
	const dictLimit = dictStart + config.dictionaryMaxBytes;
	const baseHi = (dictStart >> 8) & 0xff;

	const entries = [];
	const byNormalized = new Map();
	let cursor = dictStart;

	for (const candidate of candidates) {
		const asciiBytes = Array.from(candidate.word).map((ch) => ch.charCodeAt(0) & 0x7f);
		const entryBytes = [asciiBytes.length, ...asciiBytes];
		const nextCursor = cursor + entryBytes.length;
		const addrHi = (cursor >> 8) & 0xff;
		const pageOffset = addrHi - baseHi;
		const tokenHi = config.tokenHiByteMin + pageOffset;

		if (nextCursor > dictLimit) continue;
		if (pageOffset < 0 || pageOffset >= TOKEN_PAGE_SPAN) continue;
		if (tokenHi < config.tokenHiByteMin || tokenHi > config.tokenHiByteMin + 0x0f) continue;

		const entry = {
			word: candidate.word,
			normalized: candidate.normalized,
			address: cursor,
			bytes: entryBytes,
			tokenHi,
			tokenLo: cursor & 0xff,
			count: candidate.count,
			score: candidate.score,
		};
		entries.push(entry);
		byNormalized.set(entry.normalized, entry);
		cursor = nextCursor;
	}

	const bytesUsed = cursor - dictStart;
	if (bytesUsed > config.dictionaryMaxBytes) {
		fail(`Dictionary overflow: used ${bytesUsed} bytes, max ${config.dictionaryMaxBytes}.`);
	}

	return {
		entries,
		byNormalized,
		bytesUsed,
		bytesRemaining: config.dictionaryMaxBytes - bytesUsed,
		endAddressExclusive: cursor,
	};
}

function mapGlyph(game, glyph, context) {
	let resolvedGlyph = glyph;
	if (!game.alphabet.has(resolvedGlyph)) {
		const upperGlyph = glyph.toUpperCase();
		if (game.alphabet.has(upperGlyph)) {
			resolvedGlyph = upperGlyph;
		} else {
			fail(`Unmapped glyph "${glyph}" in game "${game.gameId}", passage "${context.passageId}", line ${context.lineIndex}.`);
		}
	}

	const asciiCode = resolvedGlyph.charCodeAt(0);
	if (asciiCode < ASCII_TABLE_START || asciiCode >= ASCII_TABLE_START + ASCII_TABLE_SIZE) {
		fail(
			`Glyph "${resolvedGlyph}" in game "${game.gameId}" is outside supported text range $20-$5f for passage byte encoding.`
		);
	}

	// Uncompressed text bytes are ASCII offsets into the game alphabet table.
	return asciiCode - ASCII_TABLE_START;
}

function encodeLineToBytes(game, line, dictionaryMap, context, config) {
	const bytes = [];
	let replacedWords = 0;
	let replacedWordsWithTrailingSpace = 0;
	let replacedWordsWithTrailingPeriod = 0;
	let replacedWordsWithTrailingExclaim = 0;
	let replacedWordsWithTrailingQuestion = 0;
	let replacedWordsWithTrailingS = 0;
	let replacedWordsWithTrailingR = 0;
	let replacedCharsWithTrailingSpace = 0;
	let i = 0;

	while (i < line.length) {
		const ch = line[i];
		if (/[A-Za-z']/u.test(ch)) {
			let j = i + 1;
			while (j < line.length && /[A-Za-z']/u.test(line[j])) {
				j += 1;
			}
			const rawWord = line.slice(i, j);
			const dictEntry = dictionaryMap.get(rawWord.toLowerCase());
			if (dictEntry) {
				const hasTrailingSpace = j < line.length && line[j] === " ";
				const hasTrailingPeriod = j < line.length && line[j] === ".";
				const hasTrailingExclaim = j < line.length && line[j] === "!";
				const hasTrailingQuestion = j < line.length && line[j] === "?";
				const trailingSpaceTokenHi = dictEntry.tokenHi + TOKEN_SUFFIX_CLASS_OFFSET.space;
				const trailingPeriodTokenHi = dictEntry.tokenHi + TOKEN_SUFFIX_CLASS_OFFSET.period;
				const trailingExclaimTokenHi = dictEntry.tokenHi + TOKEN_SUFFIX_CLASS_OFFSET.exclaim;
				const trailingQuestionTokenHi = dictEntry.tokenHi + TOKEN_SUFFIX_CLASS_OFFSET.question;
				const canUseTrailingSpaceToken = hasTrailingSpace && trailingSpaceTokenHi <= config.tokenHiByteMax;
				const canUseTrailingPeriodToken = hasTrailingPeriod && trailingPeriodTokenHi <= config.tokenHiByteMax;
				const canUseTrailingExclaimToken = hasTrailingExclaim && trailingExclaimTokenHi <= config.tokenHiByteMax;
				const canUseTrailingQuestionToken = hasTrailingQuestion && trailingQuestionTokenHi <= config.tokenHiByteMax;
				if (canUseTrailingPeriodToken) {
					bytes.push(trailingPeriodTokenHi, dictEntry.tokenLo);
					replacedWordsWithTrailingPeriod += 1;
					j += 1;
				} else if (canUseTrailingExclaimToken) {
					bytes.push(trailingExclaimTokenHi, dictEntry.tokenLo);
					replacedWordsWithTrailingExclaim += 1;
					j += 1;
				} else if (canUseTrailingQuestionToken) {
					bytes.push(trailingQuestionTokenHi, dictEntry.tokenLo);
					replacedWordsWithTrailingQuestion += 1;
					j += 1;
				} else if (canUseTrailingSpaceToken) {
					bytes.push(trailingSpaceTokenHi, dictEntry.tokenLo);
					replacedWordsWithTrailingSpace += 1;
					j += 1;
				} else {
					bytes.push(dictEntry.tokenHi, dictEntry.tokenLo);
				}
				replacedWords += 1;
			} else if (rawWord.length > 1 && rawWord.endsWith("S")) {
				const stemEntry = dictionaryMap.get(rawWord.slice(0, -1).toLowerCase());
				const trailingSTokenHi = stemEntry ? stemEntry.tokenHi + TOKEN_SUFFIX_CLASS_OFFSET.sChar : 0;
				if (stemEntry && trailingSTokenHi <= config.tokenHiByteMax) {
					bytes.push(trailingSTokenHi, stemEntry.tokenLo);
					replacedWords += 1;
					replacedWordsWithTrailingS += 1;
				} else {
					for (let k = 0; k < rawWord.length; k++) {
						const letter = rawWord[k];
						const baseByte = mapGlyph(game, letter, context);
						const isLastLetter = k === rawWord.length - 1;
						const hasTrailingSpace = isLastLetter && j < line.length && line[j] === " ";
						if (hasTrailingSpace) {
							bytes.push(baseByte + 0x40);
							replacedCharsWithTrailingSpace += 1;
							j += 1;
						} else {
							bytes.push(baseByte);
						}
					}
				}
			} else if (rawWord.length > 1 && rawWord.endsWith("R")) {
				const stemEntry = dictionaryMap.get(rawWord.slice(0, -1).toLowerCase());
				const trailingRTokenHi = stemEntry ? stemEntry.tokenHi + TOKEN_SUFFIX_CLASS_OFFSET.rChar : 0;
				if (stemEntry && trailingRTokenHi <= config.tokenHiByteMax) {
					bytes.push(trailingRTokenHi, stemEntry.tokenLo);
					replacedWords += 1;
					replacedWordsWithTrailingR += 1;
				} else {
					for (let k = 0; k < rawWord.length; k++) {
						const letter = rawWord[k];
						const baseByte = mapGlyph(game, letter, context);
						const isLastLetter = k === rawWord.length - 1;
						const hasTrailingSpace = isLastLetter && j < line.length && line[j] === " ";
						if (hasTrailingSpace) {
							bytes.push(baseByte + 0x40);
							replacedCharsWithTrailingSpace += 1;
							j += 1;
						} else {
							bytes.push(baseByte);
						}
					}
				}
			} else {
				for (let k = 0; k < rawWord.length; k++) {
					const letter = rawWord[k];
					const baseByte = mapGlyph(game, letter, context);
					const isLastLetter = k === rawWord.length - 1;
					const hasTrailingSpace = isLastLetter && j < line.length && line[j] === " ";
					if (hasTrailingSpace) {
						bytes.push(baseByte + 0x40);
						replacedCharsWithTrailingSpace += 1;
						j += 1;
					} else {
						bytes.push(baseByte);
					}
				}
			}
			i = j;
			continue;
		}
		const baseByte = mapGlyph(game, ch, context);
		const hasTrailingSpace = i + 1 < line.length && line[i + 1] === " ";
		if (hasTrailingSpace) {
			bytes.push(baseByte + 0x40);
			replacedCharsWithTrailingSpace += 1;
			i += 2;
		} else {
			bytes.push(baseByte);
			i += 1;
		}
	}

	return {
		bytes,
		replacedWords,
		replacedWordsWithTrailingSpace,
		replacedWordsWithTrailingPeriod,
		replacedWordsWithTrailingExclaim,
		replacedWordsWithTrailingQuestion,
		replacedWordsWithTrailingS,
		replacedWordsWithTrailingR,
		replacedCharsWithTrailingSpace,
	};
}

function encodeGame(game, dictionaryMap, config) {
	const encodedPassages = [];
	let rawBytes = 0;
	let encodedBytes = 0;
	let replacedWords = 0;
	let replacedWordsWithTrailingSpace = 0;
	let replacedWordsWithTrailingPeriod = 0;
	let replacedWordsWithTrailingExclaim = 0;
	let replacedWordsWithTrailingQuestion = 0;
	let replacedWordsWithTrailingS = 0;
	let replacedWordsWithTrailingR = 0;
	let replacedCharsWithTrailingSpace = 0;

	for (const passage of game.passages) {
		const passageBytes = [];
		for (let i = 0; i < passage.lines.length; i++) {
			const line = passage.lines[i];
			rawBytes += Array.from(line).length;
			const encoded = encodeLineToBytes(game, line, dictionaryMap, {
				passageId: passage.id,
				lineIndex: i,
			}, config);
			passageBytes.push(...encoded.bytes);
			replacedWords += encoded.replacedWords;
			replacedWordsWithTrailingSpace += encoded.replacedWordsWithTrailingSpace;
			replacedWordsWithTrailingPeriod += encoded.replacedWordsWithTrailingPeriod;
			replacedWordsWithTrailingExclaim += encoded.replacedWordsWithTrailingExclaim;
			replacedWordsWithTrailingQuestion += encoded.replacedWordsWithTrailingQuestion;
			replacedWordsWithTrailingS += encoded.replacedWordsWithTrailingS;
			replacedWordsWithTrailingR += encoded.replacedWordsWithTrailingR;
			replacedCharsWithTrailingSpace += encoded.replacedCharsWithTrailingSpace;
			if (i < passage.lines.length - 1) {
				passageBytes.push(config.newlineByte);
				rawBytes += 1;
			}
		}
		passageBytes.push(config.endOfPassageByte);
		rawBytes += 1;
		encodedBytes += passageBytes.length;
		encodedPassages.push({
			id: passage.id,
			bytes: passageBytes,
			byteLength: passageBytes.length,
			sourceLines: passage.lines,
		});
	}

	return {
		...game,
		encodedPassages,
		rawBytes,
		encodedBytes,
		replacedWords,
		replacedWordsWithTrailingSpace,
		replacedWordsWithTrailingPeriod,
		replacedWordsWithTrailingExclaim,
		replacedWordsWithTrailingQuestion,
		replacedWordsWithTrailingS,
		replacedWordsWithTrailingR,
		replacedCharsWithTrailingSpace,
	};
}

function emitDictionaryAsm(dictionary, config) {
	const lines = [];
	lines.push("; AUTO-GENERATED FILE. DO NOT EDIT.");
	lines.push("; Generated by _util/dict_process.js");
	lines.push("");
	lines.push(`DICT_BASE_ADDR EQM $${toHex(config.dictionaryBaseAddress, 4)}`);
	lines.push(`DICT_MAX_BYTES EQM $${toHex(config.dictionaryMaxBytes, 4)}`);
	lines.push(`DICT_TOKEN_HI_MIN EQM $${toHex(config.tokenHiByteMin)}`);
	lines.push(`DICT_TOKEN_HI_MAX EQM $${toHex(config.tokenHiByteMax)}`);
	lines.push(`DICT_TOKEN_SPACE_FLAG EQM $${toHex(TOKEN_SUFFIX_CLASS_OFFSET.space)}`);
	lines.push(`DICT_TOKEN_PERIOD_FLAG EQM $${toHex(TOKEN_SUFFIX_CLASS_OFFSET.period)}`);
	lines.push(`DICT_TOKEN_EXCLAIM_FLAG EQM $${toHex(TOKEN_SUFFIX_CLASS_OFFSET.exclaim)}`);
	lines.push(`DICT_TOKEN_QUESTION_FLAG EQM $${toHex(TOKEN_SUFFIX_CLASS_OFFSET.question)}`);
	lines.push(`DICT_TOKEN_S_FLAG EQM $${toHex(TOKEN_SUFFIX_CLASS_OFFSET.sChar)}`);
	lines.push(`DICT_TOKEN_R_FLAG EQM $${toHex(TOKEN_SUFFIX_CLASS_OFFSET.rChar)}`);
	lines.push(`DICT_NEWLINE_BYTE EQM $${toHex(config.newlineByte)}`);
	lines.push(`DICT_END_OF_PASSAGE_BYTE EQM $${toHex(config.endOfPassageByte)}`);
	lines.push("; Dictionary entry format: [length][ASCII_7BIT_CHARS...]");
	lines.push("; Token hi usage: $80-$8f=word, $90-$9f=word+space, $a0-$af=word+period, $b0-$bf=word+!, $c0-$cf=word+?, $d0-$df=word+S, $e0-$ef=word+R.");
	lines.push("");
	lines.push("dictionary_data:");

	for (const entry of dictionary.entries) {
		lines.push(`\t; "${entry.word}" @ $${toHex(entry.address, 4)} token=$${toHex(entry.tokenHi)}$${toHex(entry.tokenLo)} freq=${entry.count} score=${entry.score}`);
		lines.push(...toAsmHexLines(entry.bytes));
	}

	lines.push("");
	lines.push(`dictionary_data_end: ; $${toHex(dictionary.endAddressExclusive, 4)}`);
	lines.push("");
	return lines.join("\n");
}

function createAlphabetLookupTable(game) {
	const table = new Array(ASCII_TABLE_SIZE).fill(0xff);
	for (const [glyph, patternId] of game.alphabet.entries()) {
		const code = glyph.charCodeAt(0);
		if (code >= ASCII_TABLE_START && code < ASCII_TABLE_START + ASCII_TABLE_SIZE) {
			table[code - ASCII_TABLE_START] = patternId;
		}
	}
	return table;
}

function emitGameAsm(game, config) {
	const dictionaryWordByAddress = new Map();
	for (const entry of game.dictionaryEntries || []) {
		dictionaryWordByAddress.set(entry.address, entry.word);
	}

	const labelRoot = sanitizeLabel(game.gameLabel);
	const lines = [];
	lines.push("; AUTO-GENERATED FILE. DO NOT EDIT.");
	lines.push(`; Game: ${game.gameId}`);
	lines.push("; Generated by _util/dict_process.js");
	lines.push("; Passage bytes: $00-$3f are ASCII offsets ($20-$5f), $40-$7f are same char plus implied trailing space.");
	lines.push("; Token hi bytes: $80-$8f=word, $90-$9f=word+space, $a0-$af=word+period, $b0-$bf=word+!, $c0-$cf=word+?, $d0-$df=word+S, $e0-$ef=word+R.");
	lines.push("");
	lines.push(`${labelRoot}_passage_ptr_lo:`);
	for (let i = 0; i < game.encodedPassages.length; i++) {
		lines.push(`\tbyte #<${labelRoot}_passage_${toHex(i)}`);
	}
	lines.push(`${labelRoot}_passage_ptr_hi:`);
	for (let i = 0; i < game.encodedPassages.length; i++) {
		lines.push(`\tbyte #>${labelRoot}_passage_${toHex(i)}`);
	}
	lines.push("");

	game.encodedPassages.forEach((passage, index) => {
		lines.push(`\t; passage ${index} (${passage.id}) bytes=${passage.byteLength} lines=${passage.sourceLines.length}`);
		lines.push(`${labelRoot}_passage_${toHex(index)}:`);
		const units = decodeRowUnitsFromPassageBytes(passage.bytes, dictionaryWordByAddress, config);
		const rows = splitUnitsIntoRows(units, 16);
		for (const row of rows) {
			const rendered = renderAlignedRow(row);
			lines.push(rendered.commentLine);
			lines.push(rendered.hexLine);
		}
		lines.push("");
	});

	const alphabetTable = createAlphabetLookupTable(game);
	const grossSavings = game.rawBytes - game.encodedBytes;
	lines.push(`${labelRoot}_alphabet_table: ; ASCII($20-$5f) -> pattern_id, $ff unmapped`);
	lines.push(...toAsmHexLines(alphabetTable));
	lines.push("");
	lines.push(`${labelRoot}_passage_count EQM ${game.encodedPassages.length}`);
	lines.push(`; raw_bytes=${game.rawBytes}`);
	lines.push(`; encoded_bytes=${game.encodedBytes}`);
	lines.push(`; gross_text_savings=${grossSavings} (${formatPct(grossSavings, game.rawBytes)})`);
	lines.push(`; replaced_words=${game.replacedWords}`);
	lines.push(`; replaced_words_with_space=${game.replacedWordsWithTrailingSpace}`);
	lines.push(`; replaced_words_with_period=${game.replacedWordsWithTrailingPeriod}`);
	lines.push(`; replaced_words_with_exclaim=${game.replacedWordsWithTrailingExclaim}`);
	lines.push(`; replaced_words_with_question=${game.replacedWordsWithTrailingQuestion}`);
	lines.push(`; replaced_words_with_s=${game.replacedWordsWithTrailingS}`);
	lines.push(`; replaced_words_with_r=${game.replacedWordsWithTrailingR}`);
	lines.push(`; replaced_chars_with_space=${game.replacedCharsWithTrailingSpace}`);
	lines.push("");
	return lines.join("\n");
}

function writeOutput(filePath, content, label) {
	ensureDirForFile(filePath);
	fs.writeFileSync(filePath, content, "utf8");
	info(`Wrote ${label}: ${path.relative(ROOT_DIR, filePath)}`);
}

function formatPct(savings, base) {
	if (base <= 0) return "0.00%";
	return `${((savings / base) * 100).toFixed(2)}%`;
}

function run() {
	const configArg = process.argv[2] ? path.resolve(process.cwd(), process.argv[2]) : DEFAULT_CONFIG_PATH;
	info(`Loading config: ${path.relative(ROOT_DIR, configArg)}`);
	const rawConfig = readJsonFile(configArg, "config");
	const config = validateConfig(rawConfig, configArg);
	info(`Dictionary window: $${toHex(config.dictionaryBaseAddress, 4)}-$${toHex(config.dictionaryBaseAddress + config.dictionaryMaxBytes - 1, 4)}, token hi range: $${toHex(config.tokenHiByteMin)}-$${toHex(config.tokenHiByteMax)}`);
	info(`Loading game specs (${config.games.length} enabled)...`);

	const gamesPayload = config.games.map((game) => {
		ensureGameInputFile(game);
		const payload = readJsonFile(game.inputFile, `game input for ${game.id}`);
		const validated = validateGameInput(game, payload);
		info(`Loaded game "${game.id}" with ${validated.passages.length} passages.`);
		return validated;
	});

	const coverageIssues = [];
	for (const game of gamesPayload) {
		const undefinedGlyphs = getUndefinedGlyphs(game);
		if (undefinedGlyphs.size > 0) {
			coverageIssues.push({
				gameId: game.gameId,
				undefinedGlyphs,
			});
		}
	}
	if (coverageIssues.length > 0) {
		console.log("");
		console.log("Alphabet coverage warnings:");
		for (const issue of coverageIssues) {
			console.log(` - ${issue.gameId}:`);
			for (const [glyph, occurrences] of issue.undefinedGlyphs.entries()) {
				const sample = occurrences
					.slice(0, 3)
					.map((hit) => `${hit.passageId}[line ${hit.lineIndex}, col ${hit.column}]`)
					.join(", ");
				console.log(`   [WARN] Undefined glyph "${glyph}" used ${occurrences.length} time(s): ${sample}`);
			}
		}
		fail("Undefined glyphs were found in text that are missing from game alphabet definitions.");
	}

	info("Selecting dictionary candidates...");
	const wordStats = extractWordStats(gamesPayload);
	const candidates = selectCandidates(wordStats, config.minWordLength, config.minFrequency, config.maxEntries);
	info(`Eligible candidates: ${candidates.length}`);

	info("Packing dictionary...");
	const dictionary = packDictionary(candidates, config);
	info(`Packed dictionary entries: ${dictionary.entries.length}, bytes: ${dictionary.bytesUsed}/${config.dictionaryMaxBytes}`);

	writeOutput(config.dictionaryOutputFile, emitDictionaryAsm(dictionary, config), "master dictionary asm");

	info("Encoding game passages...");
	const encodedGames = gamesPayload.map((game) => ({
		...encodeGame(game, dictionary.byNormalized, config),
		dictionaryEntries: dictionary.entries,
	}));
	for (const game of encodedGames) {
		writeOutput(game.outputPath, emitGameAsm(game, config), `encoded text asm (${game.gameId})`);
	}

	const totalRaw = encodedGames.reduce((sum, game) => sum + game.rawBytes, 0);
	const totalEncoded = encodedGames.reduce((sum, game) => sum + game.encodedBytes, 0);
	const totalWithDictionary = totalEncoded + dictionary.bytesUsed;
	const grossSavings = totalRaw - totalEncoded;
	const netSavings = totalRaw - totalWithDictionary;

	console.log("");
	console.log("=== Dictionary Processing Report ===");
	console.log(`Games processed: ${encodedGames.length}`);
	console.log(`Word stats scanned: ${wordStats.size}`);
	console.log(`Dictionary entries: ${dictionary.entries.length}`);
	console.log(`Dictionary bytes: ${dictionary.bytesUsed}/${config.dictionaryMaxBytes} (remaining ${dictionary.bytesRemaining})`);
	console.log(`Text raw bytes: ${totalRaw}`);
	console.log(`Text encoded bytes (excluding dictionary): ${totalEncoded}`);
	console.log(`Gross text-only savings: ${grossSavings} (${formatPct(grossSavings, totalRaw)})`);
	console.log(`Net savings (including dictionary): ${netSavings} (${formatPct(netSavings, totalRaw)})`);
	console.log("");
	console.log("Per-game stats:");
	for (const game of encodedGames) {
		const savings = game.rawBytes - game.encodedBytes;
		console.log(` - ${game.gameId}: raw=${game.rawBytes} encoded=${game.encodedBytes} savings=${savings} (${formatPct(savings, game.rawBytes)}) replaced_words=${game.replacedWords}`);
		console.log(`   Gross text-only savings: ${savings} (${formatPct(savings, game.rawBytes)})`);
		console.log(`   Word+space tokens used: ${game.replacedWordsWithTrailingSpace}`);
		console.log(`   Word+period tokens used: ${game.replacedWordsWithTrailingPeriod}`);
		console.log(`   Word+exclaim tokens used: ${game.replacedWordsWithTrailingExclaim}`);
		console.log(`   Word+question tokens used: ${game.replacedWordsWithTrailingQuestion}`);
		console.log(`   Word+S tokens used: ${game.replacedWordsWithTrailingS}`);
		console.log(`   Word+R tokens used: ${game.replacedWordsWithTrailingR}`);
		console.log(`   Char+space bytes used (0x40-0x7f): ${game.replacedCharsWithTrailingSpace}`);
	}
	console.log("");
	console.log("Top dictionary entries by score:");
	dictionary.entries
		.slice()
		.sort((a, b) => b.score - a.score)
		.slice(0, 12)
		.forEach((entry, index) => {
			console.log(` ${String(index + 1).padStart(2, "0")}. ${entry.word} @ $${toHex(entry.address, 4)} freq=${entry.count} score=${entry.score}`);
		});
	info("Dictionary pipeline complete.");
}

run();
