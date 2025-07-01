--DKC 2 VRAM Debug Script v0.01
--By: H4v0c21
--Designed for: Mesen S 2.0.0

function readByte(address)
	byte = emu.read(address, emu.memType[cpuDebug], false)
	return byte
end

function readWord(address)
	word = emu.readWord(address, emu.memType[cpuDebug], false)
	return word
end

function tohexlong(number)
	local hexString = string.format("%X", number)
	while #hexString < 6 do
		hexString = "0" .. hexString
	end
	hexString = hexString:upper()
	return hexString
end

function tohex(number)
	local hexString = string.format("%X", number)
	while #hexString < 4 do
		hexString = "0" .. hexString
	end
	hexString = hexString:upper()
	return hexString
end


function tohexbyte(number)
	local hexString = string.format("%X", number)
	while #hexString < 2 do
		hexString = "0" .. hexString
	end
	hexString = hexString:upper()
	return hexString
end


colors = {
	0xFF0000,	-- Red
	0xFF00FF,	-- Magenta
	0x00FF00,	-- Lime
	0x0000FF,	-- Blue
	0xFFFF00,	-- Yellow
	0x00FFFF,	-- Cyan
	0xFF8000,	-- Orange
	0x8000FF,	-- Purple
	0x00FF80,	-- Spring green
	0xFF0080,	-- Rose
	0x80FF00,	-- Chartreuse
	0x0080FF,	-- Deep sky blue
	0xFF8080,	-- Light coral
	0x808000,	-- Olive
	0xFFA500,	-- Orange
	0xFF4500,	-- Orange-red
	0x008000,	-- Green
	0x000080,	-- Navy
	0xFFC0CB,	-- Pink
	0x8B008B,	-- Dark magenta
	0x008080,	-- Teal
	0xFF6347,	-- Tomato
	0xFF1493,	-- Deep pink
	0xFF8C00	-- Dark orange
}

function main()
	emu.clearScreen()
	
	state = emu.getState()

	variable_00D3 = readWord(0x7E00D3)
	variable_05A3 = readWord(0x7E05A3)
	variable_05A5 = readWord(0x7E05A5)
	variable_08A8 = readWord(0x7E08A8)
	
	
	emu.drawString(0, 20, "$00D3: " .. tohex(variable_00D3), 0xFFFFFF, 0xFF000000)
	emu.drawString(0, 30, "$05A3: " .. tohex(variable_05A3), 0xFFFFFF, 0xFF000000)
	emu.drawString(0, 40, "$05A5: " .. tohex(variable_05A5), 0xFFFFFF, 0xFF000000)
	emu.drawString(0, 50, "$08A8: " .. tohex(variable_08A8), 0xFFFFFF, 0xFF000000)

end

emu.addEventCallback(main, emu.eventType.endFrame);

emu.displayMessage("Script", "DKC 2 debug script loaded.")