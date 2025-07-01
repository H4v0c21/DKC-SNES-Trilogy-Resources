
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

cps = 3580000
fps = 60
cpf = cps / fps


nmi_start_time = 0
nmi_end_time = 0
logic_start_time = 0
logic_end_time = 0


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


function nmi_execution_start()
	--emu.clearScreen()
	state = emu.getState()
	nmi_start_time = state["masterClock"]
end

function logic_execution_start()
	state = emu.getState()
	nmi_end_time = state["masterClock"]
	logic_start_time = state["masterClock"]
end

function logic_execution_end()
	state = emu.getState()
	logic_end_time = state["masterClock"]
	
	nmi_time = nmi_end_time-nmi_start_time
	logic_time = logic_end_time-logic_start_time
	
	sprite_load_time = sprite_loading_end_time-sprite_loading_start_time
	sprite_handler_time = sprite_handler_end_time-sprite_handler_start_time
	sprite_renderer_time = sprite_renderer_end_time-sprite_renderer_start_time
	
	emu.drawString(12, 21, "Level NMI: " .. nmi_time, 0xFFFFFF, 0xFF000000)
	emu.drawString(12, 31, "Level Logic: " .. logic_time, 0xFFFFFF, 0xFF000000)
	emu.drawString(12, 41, "Sprite Load: " .. sprite_load_time, 0xFFFFFF, 0xFF000000)
	emu.drawString(12, 51, "Sprite Handler: " .. sprite_handler_time, 0xFFFFFF, 0xFF000000)
	emu.drawString(12, 61, "Sprite Renderer: " .. sprite_renderer_time, 0xFFFFFF, 0xFF000000)
	
	emu.drawString(12, 101, "Time Available: " .. cpf, 0xFFFFFF, 0xFF000000)
	
	--emu.drawString(12, 51, logic_start_time .. "-" .. logic_end_time, 0xFFFFFF, 0xFF000000)
end

function sprite_loading_start()
	state = emu.getState()
	sprite_loading_start_time = state["masterClock"]
end

function sprite_handler_start()
	state = emu.getState()
	sprite_loading_end_time = state["masterClock"]
	sprite_handler_start_time = state["masterClock"]
end

function sprite_handler_end()
	state = emu.getState()
	sprite_handler_end_time = state["masterClock"]
end

function sprite_renderer_start()
	state = emu.getState()
	sprite_renderer_start_time = state["masterClock"]
end

function sprite_renderer_end()
	state = emu.getState()
	sprite_renderer_end_time = state["masterClock"]
end


--call main function
emu.addMemoryCallback(nmi_execution_start, emu.callbackType.exec, 0x80881D, 0x80881D, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(logic_execution_start, emu.callbackType.exec, 0x808834, 0x808834, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(logic_execution_end, emu.callbackType.exec, 0x808CA2, 0x808CA2, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_loading_start, emu.callbackType.exec, 0xBBB5C4, 0xBBB5C4, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_handler_start, emu.callbackType.exec, 0xB38007, 0xB38007, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_handler_end, emu.callbackType.exec, 0xB3806C, 0xB3806C, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_handler_end, emu.callbackType.exec, 0xB3807E, 0xB3807E, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_renderer_start, emu.callbackType.exec, 0x80F35B, 0x80F35B, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_renderer_end, emu.callbackType.exec, 0x80F3B3, 0x80F3B3, emu.cpuType.snes, emu.memType.snesCpuDebug);


--display startup message
emu.displayMessage("Script", "DKC 2 Performance Profiler script loaded.")