--BCFD66

drawOffset = 7

colors = {
	0x00FF4040,	-- Red
	0x00FF8040,	-- Orange
	0x00FFFF40,	-- Yellow
	0x0080FF00,	-- Lime
	0x0040FF40,	-- Green
	0x0040FFFF,	-- Cyan
	0x004040FF,	-- Blue
	0x008040FF,	-- Purple
	0x00FF40FF,	-- Magenta
	0x00FFFFFF,	-- White
	
	
	--0x00FF8000,	-- Orange
	--0x008000FF,	-- Purple
	--0x0000FF80,	-- Spring green
	--0x00FF0080,	-- Rose
	--0x0080FF00,	-- Chartreuse
	--0x000080FF,	-- Deep sky blue
	--0x00FF8080,	-- Light coral
	--0x00808000,	-- Olive
	--0x00FF4500,	-- Orange-red
	--0x00000080,	-- Navy
	--0x00FFC0CB,	-- Pink
	--0x008B008B,	-- Dark magenta
	--0x00008080,	-- Teal
	--0x00FF6347,	-- Tomato
	--0x00FF1493,	-- Deep pink
	--0x00FF8C00	-- Dark orange
}

function ReadByte(address)
	byte = emu.read(address, emu.memType[cpuDebug], false)
	return byte
end


function ReadWord(address)
	word = emu.readWord(address, emu.memType[cpuDebug], false)
	return word
end


function FrameEnd()
	state = emu.getState()
	emu.clearScreen()
	
	cx = ReadWord(0x7E0AD7)
	cy = ReadWord(0x7E0ADB)

	for index = 0, 128, 2 do
		x = ReadWord(0x7E0BA6+index)
		if x ~= 0 then
			emu.drawLine(x-cx, 0, x-cx, 256, colors[1], false, 1)
		end
	end
	
	--emu.drawRectangle(x, y, w, h, colors[color], false, 1)
	--emu.drawPixel(x0-cx, y0-cy+drawOffset, colors[color])
end

emu.addEventCallback(FrameEnd, emu.eventType.endFrame);