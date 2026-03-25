--This is an example script to give a general idea of how to build scripts
--Press F5 or click the Run button to execute it
--Scripts must be written in Lua (https://www.lua.org)
--This text editor contains an auto-complete feature for all Mesen-specific functions
--Typing "emu."


function Main()
  state = emu.getState()
  --emu.drawString(12, 12, "Frame: " .. state.ppu.frameCount, 0xFFFFFF, 0xFF0000, 1)
  
  for ent = 0,31 do
    v = emu.read(0x5c0 + ent, 0)
    if v > 0 then
      x = emu.read(0x580 + ent, 0)
      y = emu.read(0x520 + ent, 0)
      if y == 0 then 
        y = emu.read(0x5a0 + ent, 0)
      end
      w = emu.read(0x540 + ent, 0)
      h = emu.read(0x560 + ent, 0)
      emu.drawRectangle(x, y, w, h, 0x00ffff, 0)
    end

  end


  emu.drawPixel(emu.read(0x0056, 0), emu.read(0x0057, 0), 0xff00ff)

  emu.drawString(10,10,"ass",0xffffff,0x000000)
end

emu.addEventCallback(Main, emu.eventType.startFrame)
--Display a startup message
emu.displayMessage("Script", "Example ass Lua script loaded.")
