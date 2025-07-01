
function ReadByte(address)
	byte = emu.read(address, emu.memType[cpuDebug], false)
	return byte
end


function ReadWord(address)
	word = emu.readWord(address, emu.memType[cpuDebug], false)
	return word
end


function ReadObjectVariableWord(object,variable_offset)
	word = ReadWord(object+variable_offset)
	return word
end


function ReadObjectVariableByte(object,variable_offset)
	byte = ReadByte(object+variable_offset)
	return byte
end


function ToHexLong(number)
	local hex_string = string.format("%X", number)
	
	while #hex_string < 6 do
		hex_string = "0" .. hex_string
	end
	
	hex_string = hex_string:upper()
	return hex_string
end


function ToHexWord(number)
	local hex_string = string.format("%X", number)
	
	while #hex_string < 4 do
		hex_string = "0" .. hex_string
	end
	
	hex_string = hex_string:upper()
	return hex_string
end


function ToHexByte(number)
	local hex_string = string.format("%X", number)
	
	while #hex_string < 2 do
		hex_string = "0" .. hex_string
	end
	
	hex_string = hex_string:upper()
	return hex_string
end


local function BitAND(a,b)
	local p,c=1,0
	
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	
	return c
end

draw_y_offset = 7

clipping_base = 0x7E09A3

colors = {
	0x00FF0000,	-- Red
	0x00FF00FF,	-- Magenta
	0x0000FF00,	-- Lime
	0x000000FF,	-- Blue
	0x00FFFF00,	-- Yellow
	0x0000FFFF,	-- Cyan
	0x00FF8000,	-- Orange
	0x008000FF,	-- Purple
	0x0000FF80,	-- Spring green
	0x00FF0080,	-- Rose
	0x0080FF00,	-- Chartreuse
	0x000080FF,	-- Deep sky blue
	0x00FF8080,	-- Light coral
	0x00808000,	-- Olive
	0x00FFA500,	-- Orange
	0x00FF4500,	-- Orange-red
	0x00008000,	-- Green
	0x00000080,	-- Navy
	0x00FFC0CB,	-- Pink
	0x008B008B,	-- Dark magenta
	0x00008080,	-- Teal
	0x00FF6347,	-- Tomato
	0x00FF1493,	-- Deep pink
	0x00FF8C00	-- Dark orange
}


function frame_end()
	emu.clearScreen()
	state = emu.getState()
end


function main()
	--emu.clearScreen()
	state = emu.getState()
	
	camera_x = ReadWord(0x7E0AD7)
	camera_y = ReadWord(0x7E0ADB)
	
	x = ReadWord(0x7E00D9) - camera_x
	y = ReadWord(0x7E00D9+2) - camera_y + draw_y_offset
	w = ReadWord(0x7E00D9+4) - ReadWord(0x7E00D9)
	h = ReadWord(0x7E00D9+6) - ReadWord(0x7E00D9+2)
	emu.drawRectangle(x, y, w, h, colors[9], false, 1)
	
end


--call main function
emu.addMemoryCallback(main, emu.callbackType.read, 0x00D9, 0x00E0, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addEventCallback(frame_end, emu.eventType.endFrame);

--display startup message
emu.displayMessage("Script", "DKC 2 Carryable Sprite Debug Script loaded.")