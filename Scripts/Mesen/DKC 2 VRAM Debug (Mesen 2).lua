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

peak_vram_upload = 0
queue_peak = 0

function vramDebug()
	emu.clearScreen()
	
	state = emu.getState()
	mouseState = emu.getMouseState()
	
	gui_y_offset = 20
	size_total = 0
	queue_size = 0
	
	
	for i = 0,120,8 do
		dma_size = readWord(0x7E1732+i)
		vram_address = readWord(0x7E1732+2+i)
		data_address = readWord(0x7E1732+4+i)
		data_bank = readWord(0x7E1732+6+i)
		size_total = size_total + dma_size
		
		queue_size = i // 8
		
		
		emu.drawString(0, gui_y_offset, "$" .. tohex(data_bank) .. tohex(data_address) .."->$" .. tohex(vram_address) .." 0x" .. tohex(dma_size), 0xFF40FF, 0xFF000000)
		gui_y_offset = gui_y_offset + 10
		
		if data_bank < 0x8000 then
			break
		end
	end
	
	
	if size_total > peak_vram_upload then
		peak_vram_upload = size_total
	end
	
	if queue_size > queue_peak then
		queue_peak = queue_size
	end
	
	
	emu.drawString(0, 10, "size: 0x" .. tohex(size_total) .. " peak: 0x" .. tohex(peak_vram_upload) .. " queue: " .. queue_size .. " qpeak: " .. queue_peak, 0xFFFF40, 0xFF000000)

end

--Register some code (printInfo function) that will be run at the end of each frame
emu.addEventCallback(vramDebug, emu.eventType.endFrame);

--Display a startup message
emu.displayMessage("Script", "DKC 2 debug script loaded.")