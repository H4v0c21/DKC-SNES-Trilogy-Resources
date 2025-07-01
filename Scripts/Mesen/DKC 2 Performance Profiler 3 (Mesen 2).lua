
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

--all units are in hz
fps = 60
master_clock_speed = 21477000
sa1_clock_speed = master_clock_speed / 2	--~10.74 MHz
fast_clock_speed = master_clock_speed / 6	--~3.58 MHz
medium_clock_speed = master_clock_speed / 8	--~2.68 MHz
slow_clock_speed = master_clock_speed / 12	--~1.79 MHz


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


--function nmi_execution_start()
--	--emu.clearScreen()
--	state = emu.getState()
--	nmi_start_time = state["masterClock"]
--end
--
--function logic_execution_start()
--	state = emu.getState()
--	nmi_end_time = state["masterClock"]
--	logic_start_time = state["masterClock"]
--end
--
--function logic_execution_end()
--	state = emu.getState()
--	logic_end_time = state["masterClock"]
--	
--	nmi_time = nmi_end_time-nmi_start_time
--	logic_time = logic_end_time-logic_start_time
--	
--	sprite_load_time = sprite_loading_end_time-sprite_loading_start_time
--	sprite_handler_time = sprite_handler_end_time-sprite_handler_start_time
--	sprite_renderer_time = sprite_renderer_end_time-sprite_renderer_start_time
--	
--	emu.drawString(12, 21, "Level NMI: " .. nmi_time, 0xFFFFFF, 0xFF000000)
--	emu.drawString(12, 31, "Level Logic: " .. logic_time, 0xFFFFFF, 0xFF000000)
--	emu.drawString(12, 41, "Sprite Load: " .. sprite_load_time, 0xFFFFFF, 0xFF000000)
--	emu.drawString(12, 51, "Sprite Handler: " .. sprite_handler_time, 0xFFFFFF, 0xFF000000)
--	emu.drawString(12, 61, "Sprite Renderer: " .. sprite_renderer_time, 0xFFFFFF, 0xFF000000)
--	
--	emu.drawString(12, 101, "Time Available: " .. cpf, 0xFFFFFF, 0xFF000000)
--	
--	--emu.drawString(12, 51, logic_start_time .. "-" .. logic_end_time, 0xFFFFFF, 0xFF000000)
--end

--function sprite_loading_start()
--	state = emu.getState()
--	sprite_loading_start_time = state["masterClock"]
--end
--
--function sprite_handler_start()
--	state = emu.getState()
--	sprite_loading_end_time = state["masterClock"]
--	sprite_handler_start_time = state["masterClock"]
--end
--
--function sprite_handler_end()
--	state = emu.getState()
--	sprite_handler_end_time = state["masterClock"]
--end
--
function sprite_oam_start()
	state = emu.getState()
	sprite_oam_start_clock = state["masterClock"]
end

function sprite_oam_stop()
	state = emu.getState()
	sprite_oam_stop_clock = state["masterClock"]
end


function sprite_dma_start()
	state = emu.getState()
	sprite_dma_start_clock = state["masterClock"]
end

function sprite_dma_stop()
	state = emu.getState()
	sprite_dma_stop_clock = state["masterClock"]
end
--
--function logic_end()
--	state = emu.getState()
--	logic_end_time = state["masterClock"]
--	--emu.log(state["masterClock"])
--end

scanlines_per_frame = 261
cycles_per_scanline = 1364
cycles_per_refresh = 40

available_cycles = (cycles_per_scanline*scanlines_per_frame) + cycles_per_refresh

function get_keys(t)
	local keys={}
	for key,_ in pairs(t) do
		emu.log(key)
		table.insert(keys, key)
	end
	return keys
end

global_draw_y_offset = 7
draw_y_offset = 20
draw_y_step = 10
sprite_main_start_cycles  = 0
sprite_main_end_cycles  = 0
total_sprite_execution_cycles = 0
total_sprite_execution_time = 0
sprite_dma_cycles = 0
sprite_dma_time = 0


--function sprite_main_init()
--	sprite_main_start_time = 0
--	sprite_main_end_time = 0
--end

function sprite_main_execute()
	state = emu.getState()
	
	sprite_main_execute_clock  = state["masterClock"]
	
	--emu.log(get_keys(state))
end

object_base_address = 0xDE2
object_size = 0x5E
object_routine_table = 0xB38348
animation_table = 0xF90000
hitbox_table = 0xBCB600
hitbox_base = 0xBC0000


function sprite_main_return()
	local state = emu.getState()
	local sprite_main_return_clock  = state["masterClock"]
	local a = state["cpu.a"]
	local x = state["cpu.x"]
	local y = state["cpu.y"]
	local execution_cycles = 0
	local execution_time = 0
	local sprite_type = ReadObjectVariableWord(x,0)
	
	if sprite_type ~= 0 then
		execution_cycles = sprite_main_return_clock - sprite_main_execute_clock
		total_sprite_execution_cycles = total_sprite_execution_cycles + execution_cycles 
		execution_time = (execution_cycles / master_clock_speed) * 1000000
		
		
		--update game variables
		camera_x = ReadWord(0x7E0AD7)
		camera_y = ReadWord(0x7E0ADB)
		
		
		object = x
		object_index = (object - object_base_address) // object_size
		object_color = colors[object_index+1]
		
		--get object position and direction
		object_x = ReadObjectVariableWord(object,0x6)
		object_y = ReadObjectVariableWord(object,0xA)
		object_facing = ReadObjectVariableWord(object,0x12)
		
		--get object hitbox
		hitbox_id = ReadObjectVariableWord(object,0x1A)
		hitbox_offset = emu.readWord(hitbox_table+hitbox_id / 2, emu.memType[cpuDebug], false)
		hitbox_x_offset = emu.readWord(hitbox_base+hitbox_offset, emu.memType[cpuDebug], true)
		hitbox_y_offset = emu.readWord(hitbox_base+hitbox_offset+2, emu.memType[cpuDebug], true)
		hitbox_width = emu.readWord(hitbox_base+hitbox_offset+4, emu.memType[cpuDebug], true)
		hitbox_height = emu.readWord(hitbox_base+hitbox_offset+6, emu.memType[cpuDebug], true)
		
		--if object is x flipped mirror the hitbox
		if BitAND(object_facing,0x4000) == 0x4000 then
			hitbox_width = hitbox_width * -1
			hitbox_x_offset = hitbox_x_offset * -1
		end
		
		--if object is y flipped mirror the hitbox
		if BitAND(object_facing,0x8000) == 0x8000 then
			hitbox_height = hitbox_height * -1
			hitbox_y_offset = hitbox_y_offset * -1
		end
	
		--render object hitbox
		emu.drawRectangle((object_x-camera_x)+hitbox_x_offset, (object_y-camera_y)+hitbox_y_offset+global_draw_y_offset, hitbox_width, hitbox_height, object_color+0x80000000, false, 1)		
	
		emu.drawString(8, draw_y_offset, ToHexWord(x) .. ": " .. math.floor(execution_time) .. "us", object_color, 0xFF000000)
		draw_y_offset = draw_y_offset + draw_y_step
	end
end


function frame_advance()
	state = emu.getState()
	
	emu.drawString(8, global_draw_y_offset+8, "Sprite Main:", 0xFFFFFF, 0xFF000000)
	
	total_sprite_execution_time = (total_sprite_execution_cycles / master_clock_speed) * 1000000
	sprite_execution_cpu_usage = (total_sprite_execution_cycles / available_cycles) * 100
	
	emu.drawString(8, 200, "sprite main: " .. math.floor(sprite_execution_cpu_usage) .. "% " .. math.floor(total_sprite_execution_time) .. "us", 0xFFFFFF, 0xFF000000)
	
	sprite_dma_cycles = sprite_dma_stop_clock - sprite_dma_start_clock
	sprite_dma_time = (sprite_dma_cycles / master_clock_speed) * 1000000
	sprite_dma_cpu_usage = (sprite_dma_cycles / available_cycles) * 100
	
	emu.drawString(8, 210, "sprite DMA: " .. math.floor(sprite_dma_cpu_usage) .. "% " .. math.floor(sprite_dma_time) .. "us", 0xFFFFFF, 0xFF000000)
	
	sprite_oam_cycles = sprite_oam_stop_clock - sprite_oam_start_clock
	sprite_oam_time = (sprite_oam_cycles / master_clock_speed) * 1000000
	sprite_oam_cpu_usage = (sprite_oam_cycles / available_cycles) * 100
	
	emu.drawString(8, 220, "sprite OAM: " .. math.floor(sprite_oam_cpu_usage) .. "% " .. math.floor(sprite_oam_time) .. "us", 0xFFFFFF, 0xFF000000)
	
	
	total_sprite_execution_cycles = 0
	total_sprite_execution_time = 0
	draw_y_offset = global_draw_y_offset + 20
	
	--sprite_dma_clocks = sprite_dma_end_time-sprite_dma_start_time
	--sprite_dma_time = ((sprite_dma_clocks * 6) / master_clock_speed) * 1000000
	
	--emu.drawString(12, 61, "Sprite GFX DMA: " .. string.format('%.04f',sprite_dma_time) .. " ns", 0xFFFFFF, 0xFF000000)
	--emu.drawString(12, 61, "Sprite GFX DMA: " .. math.floor(sprite_dma_time) .. "ns", 0xFFFFFF, 0xFF000000)
end


--call main function
--emu.addMemoryCallback(nmi_execution_start, emu.callbackType.exec, 0x80881D, 0x80881D, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(logic_execution_start, emu.callbackType.exec, 0x808834, 0x808834, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(logic_execution_end, emu.callbackType.exec, 0x808CA2, 0x808CA2, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(sprite_loading_start, emu.callbackType.exec, 0xBBB5C4, 0xBBB5C4, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(sprite_handler_start, emu.callbackType.exec, 0xB38007, 0xB38007, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(sprite_handler_end, emu.callbackType.exec, 0xB3806C, 0xB3806C, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(sprite_handler_end, emu.callbackType.exec, 0xB3807E, 0xB3807E, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_oam_start, emu.callbackType.exec, 0x80F35B, 0x80F35B, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_oam_stop, emu.callbackType.exec, 0x80F39B, 0x80F39B, emu.cpuType.snes, emu.memType.snesCpuDebug);

--emu.addMemoryCallback(sprite_dma_start, emu.callbackType.exec, 0xB5A919, 0xB5A919, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(sprite_dma_stop, emu.callbackType.exec, 0xB5A94F, 0xB5A94F, emu.cpuType.snes, emu.memType.snesCpuDebug);

emu.addMemoryCallback(sprite_dma_start, emu.callbackType.exec, 0xB5A923, 0xB5A923, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_dma_stop, emu.callbackType.exec, 0xB5A94D, 0xB5A94D, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(logic_end, emu.callbackType.exec, 0x808652, 0x808652, emu.cpuType.snes, emu.memType.snesCpuDebug);


--emu.addMemoryCallback(sprite_main_init, emu.callbackType.exec, 0xB38048, 0xB38048, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_main_execute, emu.callbackType.exec, 0xB3804C, 0xB3804C, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(sprite_main_return, emu.callbackType.exec, 0xB38054, 0xB38054, emu.cpuType.snes, emu.memType.snesCpuDebug);


emu.addEventCallback(frame_advance, emu.eventType.endFrame);


--display startup message
emu.displayMessage("Script", "DKC 2 Performance Profiler script loaded.")