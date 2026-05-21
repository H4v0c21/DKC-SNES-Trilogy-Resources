--DKC 1 Sprite Debug Script v0.05
--By: H4v0c21
--Sprite Variables found by: RainbowSprinklez
--Designed for: Mesen S 2.0.0

--Controls:

--Left click+drag to move objects
--Right click to freeze/unfreeze objects
--Shift to toggle object info and hitboxes
--Hold CTRL to show all object variables
--L/R on controller to cycle object variable to view


mesen_version = 2

object_routine_table = 0xBF8177
animation_table = 0xBE8572
hitbox_table = 0xBB8000
hitbox_base = 0xBB0000

type_table = 0x0D45
x_position_table = 0x0B19
y_position_table = 0x0BC1
oam_table = 0x0C69
animation_id_table = 0x10D1
graphic_id_table = 0x0D11

draw_object_info = true
draw_hitboxes = true
drag_objects = true
freeze_objects = true
hover_object_info = true

draw_y_offset = 7
bg_color = 0x80404040

variable_tables = {
	0x0A7D,
	0x0AB1,
	0x0AE5,
	0x0B19,
	0x0B8D,
	0x0BC1,
	0x0C35,
	0x0C69,
	0x0CDD,
	0x0D11,
	0x0D45,
	0x0DB9,
	0x0DED,
	0x0E21,
	0x0E55,
	0x0E89,
	0x0EBD,
	0x0EF1,
	0x0F25,
	0x0F59,
	0x0F8D,
	0x0FC1,
	0x0FF5,
	0x1029,
	0x109D,
	0x10D1,
	0x1105,
	0x1139,
	0x116D,
	0x11A1,
	0x11D5,
	0x1209,
	0x123D,
	0x1271,
	0x12A5,
	0x12D9,
	0x130D,
	0x1341,
	0x1375,
	0x13E9,
	0x145D,
	0x1491,
	0x14C5,
	0x14F9,
	0x152D,
	0x1561,
	0x1595,
	0x15C9,
	0x15FD,
	0x1631,
	0x1665,
	0x16AD,
	0x16B9,
	0x16FD
}


if mesen_version == 2 then
	ctrl_key = "Left Ctrl"
	alt_key =  "Left Alt"
	shift_key =  "Left Shift"
else
	ctrl_key = "Ctrl"
	alt_key =  "Alt"
	shift_key =  "Shift"
end


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


function BitAND(a, b)
	local p,c=1,0
	
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	
	return c
end


function IsMouseInsideBox(mouse_x, mouse_y, box_x, box_y, box_width, box_height)
	if mouse_x >= box_x + math.min(0, box_width) and mouse_x <= box_x + math.max(0, box_width) and
		mouse_y >= box_y and mouse_y <= box_y + box_height then
		return true
	else
		return false
	end
end


function FindInTable(tbl, value)
	for i, entry in ipairs(tbl) do
		v = entry[1]
		if v == value then
			return i
		end
	end
	return nil
end


colors = {
	0xFFFF00,	-- Yellow
	0xFF0000,	-- Red
	0xFF00FF,	-- Magenta
	0x00FF00,	-- Lime
	0x0000FF,	-- Blue
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

viewed_variable_index = 1
viewed_variable_number = variable_tables[1]
grabbed_objects = {}
frozen_objects = {}

mouse_left_hold = false
mouse_left_press = false
mouse_left_release = false
mouse_right_hold = false
mouse_right_press = false
mouse_right_release = false

shift_hold = false
shift_press = false
shift_release = false


function Sprite_Debug()
	emu.clearScreen()
	
	state = emu.getState()
	mouseState = emu.getMouseState()
	player_input = ReadWord(0x7E0510)
	
	
	--update input states
	if mouse_left_hold ~= mouseState.left then
		if mouseState.left == true then
			mouse_left_press = true
			mouse_left_release = false
		else
			mouse_left_press = false
			mouse_left_release = true
		end
	else
		mouse_left_press = false
		mouse_left_release = false
	end
	
	if mouse_right_hold ~= mouseState.right then
		if mouseState.right == true then
			mouse_right_press = true
			mouse_right_release = false
		else
			mouse_right_press = false
			mouse_right_release = true
		end
	else
		mouse_right_press = false
		mouse_right_release = false
	end

	mouse_left_hold = mouseState.left
	mouse_right_hold = mouseState.right


	if shift_hold ~= emu.isKeyPressed(shift_key) then
		if emu.isKeyPressed(shift_key) == true then
			shift_press = true
			shift_release = false
		else
			shift_press = false
			shift_release = true
		end
	else
		shift_press = false
		shift_release = false
	end
	
	shift_hold = emu.isKeyPressed(shift_key)
	
	if shift_press == true then
		draw_object_info = not draw_object_info
		draw_hitboxes = not draw_hitboxes
	end

	--if mouse left not held drop all objects
	if mouse_left_hold == false then grabbed_objects = {} end
	
	
	--if L pressed decrease variable to display
	if BitAND(player_input,0x0020) == 0x0020 then
		viewed_variable_index = viewed_variable_index - 1
		
		--if variable underflowed loop back around to variable $5C,x
		if viewed_variable_index < 1 then
			viewed_variable_index = #variable_tables
		end
	end
	
	--if R pressed increase variable to display
	if BitAND(player_input,0x0010) == 0x0010 then
		viewed_variable_index = viewed_variable_index + 1
		
		--if variable overflowed loop back around to variable $00,x
		if viewed_variable_index >= #variable_tables then
			viewed_variable_index = 1
		end
	end
	
	viewed_variable_number = variable_tables[viewed_variable_index]
	
	--draw object info box
	if draw_object_info == true then
		
		--if ctrl isn't pressed draw object info header box
		if emu.isKeyPressed(ctrl_key) ~= true then
			--init y draw offset of info box
			gui_object_info_y_offset = 0
			
			--draw info box
			emu.drawRectangle(0, 10, 110, 10, bg_color, true, 1)
			
			--draw info header text
			emu.drawString(0, 10, "address type  $" .. ToHexWord(viewed_variable_number) .. ",x", 0xFFFFFF, 0xFF000000)
			
			--update y draw offset
			gui_object_info_y_offset = gui_object_info_y_offset + 20
		end
	end
	
	--update game variables
	camera_x = ReadWord(0x7E088B)
	camera_y = ReadWord(0x7E00C0)
	level_height = ReadWord(0x7E004A)
	
	--iterate through objects
	for object_index = 0,24,1 do
		
		--assign color to object
		object_color = colors[object_index+1]
		
		--get object info
		object = object_index * 2 + 2
		object_type = ReadObjectVariableWord(object,type_table)												--get object type
		object_main_routine = ReadObjectVariableWord(object_routine_table,object_type * 4)
		object_animation_id = ReadObjectVariableWord(object,animation_id_table)
		object_animation_script = ReadObjectVariableWord(animation_table,object_animation_id * 2)
		
		--if object is valid process the object
		if object_type ~= 0 then
			
			--get object position and direction
			object_x = ReadObjectVariableWord(object,x_position_table)
			object_y = level_height-ReadObjectVariableWord(object,y_position_table)
			object_facing = ReadObjectVariableWord(object,oam_table)
			
			--get object hitbox
			hitbox_id = ReadObjectVariableWord(object,graphic_id_table)
			hitbox_offset = emu.readWord(hitbox_table+hitbox_id / 2, emu.memType[cpuDebug], false)
			hitbox_x_offset = emu.readWord(hitbox_base+hitbox_offset, emu.memType[cpuDebug], true)
			hitbox_y_offset = emu.readWord(hitbox_base+hitbox_offset+2, emu.memType[cpuDebug], true)
			hitbox_width = emu.readWord(hitbox_base+hitbox_offset+4, emu.memType[cpuDebug], true)
			hitbox_height = emu.readWord(hitbox_base+hitbox_offset+6, emu.memType[cpuDebug], true)
			
			--get viewed variable value
			viewed_variable = ReadObjectVariableWord(object,viewed_variable_number)
			
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
			if draw_hitboxes == true then
				emu.drawRectangle((object_x-camera_x)+hitbox_x_offset, (object_y-camera_y)+hitbox_y_offset+draw_y_offset, hitbox_width, hitbox_height, object_color+0x80000000, false, 1)
			end
			
			--render object info
			if draw_object_info == true then
				
				--if control isn't pressed render object info
				if emu.isKeyPressed(ctrl_key) == false then
					
					--draw object origin
					emu.drawPixel(object_x-camera_x, object_y-camera_y+draw_y_offset, object_color)
					
					--draw info box
					emu.drawRectangle(0, gui_object_info_y_offset, 110, 10, bg_color, true, 1)
					
					--draw info text
					emu.drawString(0, gui_object_info_y_offset, "$" .. ToHexWord(object).. " #" .. ToHexWord(object_type) .." 0x" .. ToHexWord(viewed_variable), object_color, 0xFF000000)
					
					--update draw offset
					gui_object_info_y_offset = gui_object_info_y_offset + 10
				end
			end
			
			--handle object dragging
			if drag_objects == true then
				
				--if left click is pressed and if the mouse is over an object add it to dragged objects
				if mouse_left_hold == true then
					if IsMouseInsideBox(mouseState.x, mouseState.y, object_x-camera_x+hitbox_x_offset, object_y-camera_y+hitbox_y_offset+draw_y_offset, hitbox_width, hitbox_height) == true then
						table.insert(grabbed_objects, object)
					end
				end
			end
			
			--handle object position freezing
			if freeze_objects == true then
				if mouse_right_press == true then
					if IsMouseInsideBox(mouseState.x, mouseState.y, object_x-camera_x+hitbox_x_offset, object_y-camera_y+hitbox_y_offset+draw_y_offset, hitbox_width, hitbox_height) == true then
						frozen_object = {object, object_x, object_y}
						
						table_index = FindInTable(frozen_objects, object)
						
						if table_index == nil then
							table.insert(frozen_objects, frozen_object)
						else
							table.remove(frozen_objects, table_index)
						end

					end
				end
			end
			
			--handle object hover info
			if hover_object_info == true then
				
				--if mouse is over an object
				if IsMouseInsideBox(mouseState.x, mouseState.y, object_x-camera_x+hitbox_x_offset, object_y-camera_y+hitbox_y_offset+draw_y_offset, hitbox_width, hitbox_height) == true then
					
					--if ctrl is pressed render all object variables
					if emu.isKeyPressed(ctrl_key) == true then
						
						--draw variable box
						emu.drawRectangle(0, 0, 256, 256, bg_color, true, 1)
						
						--draw variable header text
						--emu.drawString(0, 10, "$$$$ ", object_color, 0xFF000000)
						
						--draw object variables
						--for i = 0,15,1 do
						--	emu.drawString(i * 14+14+4, 10, ToHexByte(i), object_color, 0xFF000000)
						--end
						
						for i = 1,#variable_tables,1 do
							variable_address = variable_tables[i]
							variable_word = ReadObjectVariableWord(variable_address,(object_index+1)*2)
							emu.drawString(((i-1)//19) * 84, ((i-1)%19) * 12, "$" .. ToHexWord(variable_address) .. ",x " .. ToHexWord(variable_word), object_color, 0xFF000000)
						end
						
						--for v = 0,0x5D,1 do
						--	variable_byte = ReadObjectVariableByte(object,v)
						--	emu.drawString((v%16) * 14 +14+4, (v//16) * 16+24, ToHexByte(variable_byte), object_color, 0x10000000)
						--end
					
					--ctrl is not pressed, draw normal hover info
					else
						emu.drawRectangle(mouseState.x-4, mouseState.y-draw_y_offset-4, 92, 64, bg_color, true, 1)
						
						emu.drawString(mouseState.x, mouseState.y-draw_y_offset, "slot: #" .. object_index, object_color, 0xFF000000)
						emu.drawString(mouseState.x, mouseState.y-draw_y_offset+10, "address: $" .. ToHexWord(object), object_color, 0xFF000000)
						emu.drawString(mouseState.x, mouseState.y-draw_y_offset+20, "type: #" .. ToHexWord(object_type), object_color, 0xFF000000)
						emu.drawString(mouseState.x, mouseState.y-draw_y_offset+30,"$" .. ToHexWord(viewed_variable_number) .. ",x: 0x" .. ToHexWord(viewed_variable), object_color, 0xFF000000)
						emu.drawString(mouseState.x, mouseState.y-draw_y_offset+40, "main: $BF" .. ToHexWord(object_main_routine), object_color, 0xFF000000)
						emu.drawString(mouseState.x, mouseState.y-draw_y_offset+50, "anim: $BE" .. ToHexWord(object_animation_script), object_color, 0xFF000000)
					end
				end
			end
		end
	end
	
	
	--move all dragged objects to mouse position
	if drag_objects == true then
		for object = 1, #grabbed_objects do
			emu.writeWord(grabbed_objects[object]+x_position_table, mouseState.x+camera_x, emu.memType[cpuDebug])
			emu.writeWord(grabbed_objects[object]+y_position_table, (level_height-mouseState.y+draw_y_offset)-camera_y, emu.memType[cpuDebug])
		end
	end

	--handle object position freezing
	if freeze_objects == true then
		for _, frozen_object in ipairs(frozen_objects) do
			local object = frozen_object[1]
			local x = frozen_object[2]
			local y = frozen_object[3]
			emu.writeWord(object+x_position_table, x, emu.memType[cpuDebug])
			emu.writeWord(object+y_position_table, level_height-y, emu.memType[cpuDebug])
			emu.drawRectangle(x-camera_x-4, y-camera_y+draw_y_offset-4, 2, 8, 0x00FFFFFF, true, 1)
			emu.drawRectangle(x-camera_x, y-camera_y+draw_y_offset-4, 2, 8, 0x00FFFFFF, true, 1)
		end
	end

end

--call sprite debug
emu.addEventCallback(Sprite_Debug, emu.eventType.endFrame);

--display startup message
emu.displayMessage("Script", "DKC 2 Sprite Debug Script loaded.")