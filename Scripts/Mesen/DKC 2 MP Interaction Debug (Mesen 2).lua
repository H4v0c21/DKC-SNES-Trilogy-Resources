


function ReadByte(address)
	byte = emu.read(address, emu.memType[cpuDebug], false)
	return byte
end


function ReadWord(address)
	word = emu.readWord(address, emu.memType[cpuDebug], false)
	return word
end

function ReadString(address, length)
	str = ""
	for i = 0,length-1,1 do
		byte = emu.read(address+i, emu.memType[cpuDebug], false)
		str = str .. string.char(byte)
	end
	
	return str
end


function WriteByte(address, value)
	emu.write(address, value, emu.memType[cpuDebug])
end


function WriteWord(address, value)
	emu.writeWord(address, value, emu.memType[cpuDebug])
end


function ToHexLong(number)
	local hexString = string.format("%X", number)
	
	while #hexString < 6 do
		hexString = "0" .. hexString
	end
	
	hexString = hexString:upper()
	return hexString
end


function ToHexWord(number)
	local hexString = string.format("%X", number)
	
	while #hexString < 4 do
		hexString = "0" .. hexString
	end
	
	hexString = hexString:upper()
	return hexString
end


function ToHexByte(number)
	local hexString = string.format("%X", number)
	
	while #hexString < 2 do
		hexString = "0" .. hexString
	end
	
	hexString = hexString:upper()
	return hexString
end


--converts global xy coordinates into local coordinates inside a box, returns nil x and y if the coordinates arent in the box
function GetBoxCoordinates(cursorX, cursorY, boxX, boxY, boxWidth, boxHeight)
	
	if boxWidth < 0 then
		boxWidth = boxWidth * -1
		cursorLocalX = (cursorX - boxX) * -1
	else
		cursorLocalX = cursorX - boxX
	end
	
	if boxHeight < 0 then
		boxHeight = boxHeight * -1
		cursorLocalY = (cursorY - boxY) * -1
	else
		cursorLocalY = cursorY - boxY
	end

	if cursorLocalX >= 0
	and cursorLocalX < boxWidth
	and cursorLocalY >= 0
	and cursorLocalY < boxHeight then
		return cursorLocalX, cursorLocalY
	else
		return nil, nil
	end
end


--converts global xy coordinates to xy coordinates relative to origin xy
function ToLocalCoordinates(x, y, originX, originY)
	return x-originX, y-originY
end


--list all the keys that a table/object can have
function PrintTableKeys(t)
    emu.log("--- Tabel Keys ---")
    for key, value in pairs(t) do
        emu.log(key)
    end
    emu.log("-------------------------")
end


function CheckBit(value, bit)
	if Bitwise(value,bit,AND) == bit then
		return true
	else
		return false
	end
end


OR, XOR, AND = 1, 3, 4
function Bitwise(a, b, op)
	local r, m, s = 0, 2^31
	repeat
	s,a,b = a+b+m, a%m, b%m
	r,m = r + m*op%(s-a-b), m/2
	until m < 1
	return r
end


function ResetMemoryWordBits(address, bits)
	bits = Bitwise(bits, 0xFFFF, XOR)
	value = emu.readWord(address, emu.memType[cpuDebug], false)
	value = Bitwise(value, bits, AND)
	emu.writeWord(address, value, emu.memType[cpuDebug])
end


function SetMemoryWordBits(address, bits)
	value = emu.readWord(address, emu.memType[cpuDebug], false)
	value = Bitwise(value, bits, OR)
	emu.writeWord(address, value, emu.memType[cpuDebug])
end


function ToggleMemoryWordBits(address, bits)
	value = emu.readWord(address, emu.memType[cpuDebug], false)
	value = Bitwise(value, 0x0040, XOR)
	emu.writeWord(address, value, emu.memType[cpuDebug])
end


function TestMemoryWordBits(address, bits)
	value = emu.readWord(address, emu.memType[cpuDebug], false)
	value = Bitwise(value, bits, AND)
	if value ~= 0 then
		return true
	else
		return false
	end
end


function QueueInGameSoundEffect(soundEffect)
	soundBufferIndex = ReadWord(SFX_BUFFER_INDEX)
	
	--if the sound isnt already queued then try adding it to the buffer
	if ReadWord(SFX_BUFFER + soundBufferIndex) == soundEffect then
		return
	end
	
	soundBufferIndex = Bitwise(soundBufferIndex+2, 0x000E, AND)
		
	--if the buffer is full then dont queue the sound
	if ReadWord(SFX_BUFFER + Bitwise(soundBufferIndex, 0x000E, AND)) ~= 0 then
		return
	end
	
	WriteWord(SFX_BUFFER + soundBufferIndex, soundEffect)
	WriteWord(SFX_BUFFER_INDEX, soundBufferIndex)
end



function MpDebug()
	--clear previous renders and read new states
	emu.clearScreen()
	
	state = emu.getState()
	mouseState = emu.getMouseState()
	
	INTERACTION_VARIABLE_COUNT = 0x6
	CURRENT_INTERACTION_VARIABLES = 0x0A82
	DIDDY_INTERACTION_VARIABLES = 0x1A00
	DIXIE_INTERACTION_VARIABLES = 0x1A10
	
	emu.drawRectangle(0, 10-2, 200, 40, 0x40404040, true, 1)
	--emu.drawString(0, 10, "Test" .. ToHexByte(selectedVariableOffset) .. ",x", 0xFFFFFF, 0xFF000000)
	
	
	for interactionVariable = 0, INTERACTION_VARIABLE_COUNT*2-1, 2 do
		value = ReadWord(CURRENT_INTERACTION_VARIABLES+interactionVariable)
		emu.drawString(interactionVariable * 16 + 8, 10, ToHexWord(CURRENT_INTERACTION_VARIABLES+interactionVariable), 0x00808080, 0xFF000000)
		emu.drawString(interactionVariable * 16 + 8, 20, ToHexWord(value), 0x00FFFFFF, 0xFF000000)
	end
	
	for interactionVariable = 0, INTERACTION_VARIABLE_COUNT*2-1, 2 do
		value = ReadWord(DIDDY_INTERACTION_VARIABLES+interactionVariable)
		emu.drawString(interactionVariable * 16 + 8, 30, ToHexWord(value), 0x00FF0000, 0xFF000000)
	end
	
	for interactionVariable = 0, INTERACTION_VARIABLE_COUNT*2-1, 2 do
		value = ReadWord(DIXIE_INTERACTION_VARIABLES+interactionVariable)
		emu.drawString(interactionVariable * 16 + 8, 40, ToHexWord(value), 0x00FF00FF, 0xFF000000)
	end
	
	--emu.drawRectangle(0, guiSpriteInfoOffsetY, 110, 10, spriteInfoListBGColor, true, 1)
	--emu.drawString(0, guiSpriteInfoOffsetY, "$" .. ToHexWord(spriteRAMPointer), 0xFFFFFFFF, 0xFF000000)

end

--call sprite debug
emu.addEventCallback(MpDebug, emu.eventType.endFrame);

--display startup message
emu.displayMessage("Script", "DKC 2 MP Debug Script loaded.")