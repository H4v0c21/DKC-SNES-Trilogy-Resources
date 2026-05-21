--DKC Trilogy Sprite Debug Script v2.00
--By: H4v0c21
--Written for: Mesen 2.1.1
--Mesen Commit: https://github.com/SourMesen/Mesen2/commit/137ae7ce3bf3f539d007e2c4ef3cb3b6c97672a1



--Controls:
--START to pause/open debug script options
--L/R to cycle monitored sprite variable
--X+L/R to cycle filtered sprite type

--Left click+drag to move sprites
--Right click to freeze/unfreeze sprites
--Middle click to filter sprites



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
    emu.log("--- Table Keys ---")
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
	
	--playing sound effects in DKC 1 & 3 isn't supported yet
	if game ~= 2 then
		return
	else
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
end


function RenderAdditionalSpriteInfo(sprite, selectedVariableIndex)
	selectedVariableValue = ReadWord(sprite+selectedVariableIndex)
	
	levelNumber = ReadWord(CURRENT_LEVEL)
	spritePlacementNumber = ReadWord(sprite+SPRITE_PLACEMENT_NUMBER)
	
	if game == 1 then
		if spritePlacementNumber >= 0x7FFF or spritePlacementNumber == 0 then
			spritePlacementNumber = nil
		else
			levelPlacementPointer = ReadWord(SPRITE_PLACEMENT_DATA_BASE_POINTER+levelNumber*2) + SPRITE_PLACEMENT_DATA_BANK
			
			spriteSpawnScriptPointer = ReadWord(levelPlacementPointer+spritePlacementNumber*8+6) + SPRITE_SPAWN_SCRIPT_DATA_BANK
		end
	else
		if spritePlacementNumber == 0 then
			spritePlacementNumber = nil
		else
			spritePlacementNumber = spritePlacementNumber - 1
			levelPlacementPointer = ReadWord(SPRITE_PLACEMENT_DATA_BASE_POINTER+levelNumber*2) + SPRITE_PLACEMENT_DATA_BANK
		
			spriteSpawnNumber = ReadWord(levelPlacementPointer+spritePlacementNumber*8+6)
			spriteSpawnScriptPointer = ReadWord(SPRITE_SPAWN_SCRIPT_TABLE_POINTER+spriteSpawnNumber) + SPRITE_SPAWN_SCRIPT_DATA_BANK
		end
	end
	
	spriteType = ReadWord(sprite+SPRITE_TYPE)
	
	
	if game == 3 then
		spriteMainPointer = ReadWord(sprite+SPRITE_MAIN_ADDRESS) + (ReadByte(sprite+SPRITE_MAIN_BANK)*(2^16))
	else
		spriteMainTablePointer = ReadWord(SPRITE_MAIN_TABLE_JMP_POINTER+1) + SPRITE_MAIN_BASE_POINTER
		
		if game  == 1 then
			spriteMainPointer = ReadWord(spriteMainTablePointer+spriteType*4)
		else
			spriteMainPointer = ReadWord(spriteMainTablePointer+spriteType)
		end
	end
	
				
	emu.drawRectangle(mouseState.x, mouseState.y+renderOffsetY, 120, 70, spriteInfoListBGColor, true, 1)

	if spritePlacementNumber then
		
		emu.drawString(mouseState.x+5, mouseState.y+5+renderOffsetY, "Placement ID: $" .. ToHexWord(spritePlacementNumber), spriteBoxColor, 0xFF000000)
		
		if game ~= 1 then
			emu.drawString(mouseState.x+5, mouseState.y+15+renderOffsetY, "Spawn ID: $" .. ToHexWord(spriteSpawnNumber), spriteBoxColor, 0xFF000000)
		end
		
		emu.drawString(mouseState.x+5, mouseState.y+25+renderOffsetY, "Spawn Script: $" .. ToHexLong(spriteSpawnScriptPointer), spriteBoxColor, 0xFF000000)
	end
	
	if spriteMainPointer then
		emu.drawString(mouseState.x+5, mouseState.y+35+renderOffsetY, "Type ID: $" .. ToHexWord(spriteType), spriteBoxColor, 0xFF000000)
		emu.drawString(mouseState.x+5, mouseState.y+45+renderOffsetY, "Main Routine: $" .. ToHexLong(SPRITE_MAIN_BASE_POINTER+spriteMainPointer), spriteBoxColor, 0xFF000000)
	end
	
	emu.drawString(mouseState.x+5, mouseState.y+55+renderOffsetY, "$" .. ToHexByte(selectedVariableIndex) .. ",x: 0x" .. ToHexWord(selectedVariableValue), spriteBoxColor, 0xFF000000)
end

scriptMenuRenderOffsetIncrementX = 10
scriptMenuRenderOffsetIncrementY = 10

function RenderScriptMenuOption(optionText, optionColor, autoIncrementOffsetX, autoIncrementOffsetY)
	
	if not featureHideScriptMenu then
		emu.drawString(scriptMenuRenderOffsetX, scriptMenuRenderOffsetY+renderOffsetY, optionText, optionColor, 0xFF000000)
	end
	
	if autoIncrementOffsetX then
		scriptMenuRenderOffsetX = scriptMenuRenderOffsetX + scriptMenuRenderOffsetIncrementX
	end
	
	if autoIncrementOffsetY then
		scriptMenuRenderOffsetY = scriptMenuRenderOffsetY + scriptMenuRenderOffsetIncrementY
	end
	
end


function UpdateInputStates(inputCurrent, inputPrevious)
	if inputCurrent == inputPrevious then
		inputPress = false
		inputRelease = false
	else
		if inputCurrent then
			inputPress = true
			inputRelease = false
		else
			inputPress = false
			inputRelease = true
		end
	end
	
	inputHeld = inputCurrent
	return inputHeld, inputPress, inputRelease
end




--FEATURE TOGGLES (setting these to true enables them by default when the script initially runs)
featureShowSpriteOrigins = true
featureShowSpriteHitboxes = true
featureShowSpriteInfoList = true
featureShowAdditionalSpriteInfo = true
featureDragSprites = true
featureFreezeSprites = true
featureFilterSprites = true
featureHideScriptMenu = false
featureDebugDisableSprites = false
featureDebugFly = false

--initialize sprite type filter
spriteFilterType = 0
isSpriteFiltering = false

--initialize select sprite variable feature
selectedVariableValue = 0
selectedVariableIndex = 1
selectedVariableOffset = 0



--Setting this to true zeros the sub pixel of frozen and grabbed sprites
--use this to prevent the sprites from shaking
--WARNING: some sprites use the sub pixel variable for other purposes, like barrel cannons that move
precisePositioning = true

--Y offset of all script rendering
renderOffsetY = 7
screenWidth = 256
screenHeight = 224
infoListPadding = 4
infoListWidth = 90
infoListHeight = 10

--GENERAL COLORS ARGB (Alpha (Inverted), Red, Green, Blue)
spriteInfoListBGColor = 0x40404040
pausedBackgroundColor = 0x40404040
featureOptionColor = 0xFFFFFFFF
enabledFeatureColor = 0x0040FF40
disabledFeatureColor = 0x00FF4040
featureOneTimeOptionColor = 0x004040FF
featureTextColor = 0x00FFFFFF
featureSubTextColor = 0x00C0C0C0


--ONLY CHANGE THIS IF YOU WANT TO ATTEMPT TO RUN THIS SCRIPT IN MESEN S/MESEN 1.x.x
--SUPPORT FOR OLDER VERSIONS OF MESEN IS NO LONGER SUPPORTED
MESEN_VERSION = 2



--SPRITE HITBOX ADDRESSES
HITBOX_TABLE_POINTER = nil
HITBOX_BASE_POINTER = nil

--SPRITE SPAWN SCRIPT ADDRESSES
SPRITE_PLACEMENT_DATA_BASE_POINTER = nil
SPRITE_PLACEMENT_DATA_BANK = nil
SPRITE_SPAWN_SCRIPT_TABLE_POINTER = nil
SPRITE_SPAWN_SCRIPT_DATA_BANK = nil

--SPRITE MAIN ADDRESSES
SPRITE_MAIN_BASE_POINTER = nil
SPRITE_MAIN_TABLE_JMP_POINTER = nil

--RAM ADDRESSES
GLOBAL_FRAME_TIMER = nil
CURRENT_LEVEL = nil
CURRENT_KONG = nil
DEBUG_FLAGS = nil
SFX_BUFFER = nil
SFX_BUFFER_INDEX = nil
GAME_STATE = nil
CAMERA_X = nil
CAMERA_Y = nil
SPRITE_RAM_BASE_POINTER = nil

--SPRITE VARIABLE OFFSETS
SPRITE_MAIN_ADDRESS = nil
SPRITE_MAIN_BANK = nil

SPRITE_TYPE = nil
SPRITE_SUB_X = nil
SPRITE_X = nil
SPRITE_SUB_Y = nil
SPRITE_Y = nil
SPRITE_OAM = nil
SPRITE_HITBOX_NUMBER = nil
SPRITE_STATE = nil
SPRITE_PLACEMENT_NUMBER = nil

SPRITE_VARIABLE_TABLES = {}

KONG_DEBUG_FLY_STATE = nil

--SPRITE SLOT INFO
SPRITE_SIZE = nil
SPRITE_SLOT_COUNT = nil

--SPRITE TYPE RANGE
SPRITE_TYPE_MIN = nil
SPRITE_TYPE_MAX = nil
SPRITE_TYPE_STEP = nil

--SPRITE COLORS RGB (Red, Green, Blue)
spriteColors = {}


game = 0

DKC1_GAME_CODE = "8X  "
DKC2_GAME_CODE = "ADNE"
DKC3_GAME_CODE = "A3CE"

function GetGame(gameCode)
	if gameCode == DKC1_GAME_CODE then
		return 1
	elseif  gameCode == DKC2_GAME_CODE then
		return 2
	elseif  gameCode == DKC3_GAME_CODE then
		return 3
	end
end


function SetGameInfo(game)
	if game == 1 then
		--SPRITE HITBOX ADDRESSES
		HITBOX_TABLE_POINTER = 0xBB8000
		HITBOX_BASE_POINTER = 0xBB0000

		--SPRITE SPAWN SCRIPT ADDRESSES
		SPRITE_PLACEMENT_DATA_BASE_POINTER = 0xBD8000
		SPRITE_PLACEMENT_DATA_BANK = 0xBD * 65536
		SPRITE_SPAWN_SCRIPT_DATA_BANK = 0xB5 * 65536

		--SPRITE MAIN ADDRESSES
		SPRITE_MAIN_BASE_POINTER = 0xBF0000
		SPRITE_MAIN_TABLE_JMP_POINTER = 0xBF8174

		--RAM ADDRESSES
		GLOBAL_FRAME_TIMER = 0x7E002A
		CURRENT_LEVEL = 0x7E003E
		DEBUG_FLAGS = 0x7E0535
			SFX_BUFFER = 0x7E0622
			SFX_BUFFER_INDEX = 0x7E0634
		GAME_STATE = 0x7E0579
		CAMERA_X = 0x7E088B
		CAMERA_Y = 0x7E0895
		LEVEL_HEIGHT = 0x7E004A
		SPRITE_RAM_BASE_POINTER = 0x0000

		--SPRITE VARIABLE OFFSETS
		SPRITE_TYPE = 0x0D45
		SPRITE_SUB_X = 0x0DB9
		SPRITE_X = 0x0B19
		SPRITE_SUB_Y = 0x0E21
		SPRITE_Y = 0x0BC1
		SPRITE_OAM = 0x0C69
		SPRITE_HITBOX_NUMBER = 0x0D11
		SPRITE_STATE = 0x1029
		SPRITE_PLACEMENT_NUMBER = 0x15FD
		
		SPRITE_VARIABLE_TABLES = {
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

		KONG_DEBUG_FLY_STATE = 0x0008

		--SPRITE SLOT INFO
		SPRITE_SLOT_COUNT = 24

		--SPRITE TYPE RANGE
		SPRITE_TYPE_MIN = 0x0000
		SPRITE_TYPE_MAX = 0x0078
		SPRITE_TYPE_STEP = 1
		
		--SPRITE COLORS RGB (Red, Green, Blue)
		spriteColors = {
			0xFFFFFF,	-- White
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
			0xFF8C00,	-- Dark orange
			0xDC143C,	-- Crimson
			0x4B0082,	-- Indigo
			0x228B22,	-- Forest green
			0x808080,	-- Gray
			0xCD5C5C,	-- Indian red
			0x8A2BE2,	-- Blue-violet
			0x6A5ACD,	-- Slate blue
			0xDEB887	-- Burly wood
		}
	elseif game == 2 then
		--SPRITE HITBOX ADDRESSES
		HITBOX_TABLE_POINTER = 0xBCB600
		HITBOX_BASE_POINTER = 0xBC0000

		--SPRITE SPAWN SCRIPT ADDRESSES
		SPRITE_PLACEMENT_DATA_BASE_POINTER = 0xFE0000
		SPRITE_PLACEMENT_DATA_BANK = 0xFE * 65536
		SPRITE_SPAWN_SCRIPT_TABLE_POINTER = 0xFBE800
		SPRITE_SPAWN_SCRIPT_DATA_BANK = 0xFF * 65536

		--SPRITE MAIN ADDRESSES
		SPRITE_MAIN_BASE_POINTER = 0xB30000
		SPRITE_MAIN_TABLE_JMP_POINTER = 0xB3804F

		--RAM ADDRESSES
		GLOBAL_FRAME_TIMER = 0x7E002C
		CURRENT_LEVEL = 0x7E00D3
		CURRENT_KONG = 0x7E0593
		DEBUG_FLAGS = 0x7E05BB
		SFX_BUFFER = 0x7E0622
		SFX_BUFFER_INDEX = 0x7E0634
		GAME_STATE = 0x7E08C2
		CAMERA_X = 0x7E0AD7
		CAMERA_Y = 0x7E0ADB
		SPRITE_RAM_BASE_POINTER = 0x0DE2

		--SPRITE VARIABLE OFFSETS
		SPRITE_TYPE = 0x00
		SPRITE_SUB_X = 0x05
		SPRITE_X = 0x06
		SPRITE_SUB_Y = 0x09
		SPRITE_Y = 0x0A
		SPRITE_OAM = 0x12
		SPRITE_HITBOX_NUMBER = 0x1A
		SPRITE_STATE = 0x2E
		SPRITE_PLACEMENT_NUMBER = 0x56
		
		SPRITE_VARIABLE_TABLES = {
			0x00,
			0x02,
			0x04,
			0x06,
			0x08,
			0x0A,
			0x0C,
			0x0E,
			0x10,
			0x12,
			0x14,
			0x16,
			0x18,
			0x1A,
			0x1C,
			0x1E,
			0x20,
			0x22,
			0x24,
			0x26,
			0x28,
			0x2A,
			0x2C,
			0x2E,
			0x30,
			0x32,
			0x34,
			0x36,
			0x38,
			0x3A,
			0x3C,
			0x3E,
			0x40,
			0x42,
			0x44,
			0x46,
			0x48,
			0x4A,
			0x4C,
			0x4E,
			0x50,
			0x52,
			0x54,
			0x56,
			0x58,
			0x5A,
			0x5C
		}
		
		KONG_DEBUG_FLY_STATE = 0x0008

		--SPRITE SLOT INFO
		SPRITE_SIZE = 0x5E
		SPRITE_SLOT_COUNT = 24

		--SPRITE TYPE RANGE
		SPRITE_TYPE_MIN = 0x0000
		SPRITE_TYPE_MAX = 0x031C
		SPRITE_TYPE_STEP = 4
		
		--SPRITE COLORS RGB (Red, Green, Blue)
		spriteColors = {
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
		0xFF8C00,	-- Dark orange
		0xDC143C,	-- Crimson
		0x4B0082,	-- Indigo
		0x228B22,	-- Forest green
		0x808080,	-- Gray
		0xCD5C5C,	-- Indian red
		0x8A2BE2,	-- Blue-violet
		0x6A5ACD,	-- Slate blue
		0xDEB887	-- Burly wood
		}
	elseif game == 3 then
		--SPRITE HITBOX ADDRESSES
		HITBOX_TABLE_POINTER = 0xBC8000
		HITBOX_BASE_POINTER = 0xBC0000

		--SPRITE SPAWN SCRIPT ADDRESSES
		SPRITE_PLACEMENT_DATA_BASE_POINTER = 0xFE0000
		SPRITE_PLACEMENT_DATA_BANK = 0xFE * 65536
		SPRITE_SPAWN_SCRIPT_TABLE_POINTER = 0xFF0040
		SPRITE_SPAWN_SCRIPT_DATA_BANK = 0xFF * 65536

		--SPRITE MAIN ADDRESSES
		SPRITE_MAIN_BASE_POINTER = 0x000000
		SPRITE_MAIN_TABLE_JMP_POINTER = 0xBB8084

		--RAM ADDRESSES
		GLOBAL_FRAME_TIMER = 0x7E005A
		CURRENT_LEVEL = 0x7E00C0
		CURRENT_KONG = 0x7E04F9
		DEBUG_FLAGS = 0x7E05BB
		SFX_BUFFER = 0x7E0436
		SFX_BUFFER_INDEX = 0x7E043A
		GAME_STATE = 0x7E05AF
		CAMERA_X = 0x7E0493
		CAMERA_Y = 0x7E0497
		SPRITE_RAM_BASE_POINTER = 0x0878

		--SPRITE VARIABLE OFFSETS
		SPRITE_MAIN_ADDRESS = 0x02
		SPRITE_MAIN_BANK = 0x04
		SPRITE_TYPE = 0x00
		SPRITE_SUB_X = 0x11
		SPRITE_X = 0x12
		SPRITE_SUB_Y = 0x15
		SPRITE_Y = 0x16
		SPRITE_OAM = 0x1E
		SPRITE_HITBOX_NUMBER = 0x24
		SPRITE_STATE = 0x38
		SPRITE_PLACEMENT_NUMBER = 0x08
		
		SPRITE_VARIABLE_TABLES = {
			0x00,
			0x02,
			0x04,
			0x06,
			0x08,
			0x0A,
			0x0C,
			0x0E,
			0x10,
			0x12,
			0x14,
			0x16,
			0x18,
			0x1A,
			0x1C,
			0x1E,
			0x20,
			0x22,
			0x24,
			0x26,
			0x28,
			0x2A,
			0x2C,
			0x2E,
			0x30,
			0x32,
			0x34,
			0x36,
			0x38,
			0x3A,
			0x3C,
			0x3E,
			0x40,
			0x42,
			0x44,
			0x46,
			0x48,
			0x4A,
			0x4C,
			0x4E,
			0x50,
			0x52,
			0x54,
			0x56,
			0x58,
			0x5A,
			0x5C,
			0x5E,
			0x60,
			0x62,
			0x64,
			0x66,
			0x68,
			0x6A,
			0x6C
		}
		
		KONG_DEBUG_FLY_STATE = 0x0000

		--SPRITE SLOT INFO
		SPRITE_SIZE = 0x6E
		SPRITE_SLOT_COUNT = 28

		--SPRITE TYPE RANGE
		SPRITE_TYPE_MIN = 0x0000
		SPRITE_TYPE_MAX = 0x04DC
		SPRITE_TYPE_STEP = 4
		
		--SPRITE COLORS RGB (Red, Green, Blue)
		spriteColors = {
		0xFF00FF,	-- Magenta
		0x00FFFF,	-- Cyan
		0x00FF00,	-- Lime
		0x0000FF,	-- Blue
		0xFFFF00,	-- Yellow
		0xFF0000,	-- Red
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
		0xFF8C00,	-- Dark orange
		0xDC143C,	-- Crimson
		0x4B0082,	-- Indigo
		0x228B22,	-- Forest green
		0x808080,	-- Gray
		0xCD5C5C,	-- Indian red
		0x8A2BE2,	-- Blue-violet
		0x6A5ACD,	-- Slate blue
		0xDEB887	-- Burly wood
		}
	end
end

if MESEN_VERSION == 2 then
	CTRL_KEY = "Left Ctrl"
	ALT_KEY =  "Left Alt"
	SHIFT_KEY =  "Left Shift"
else
	CTRL_KEY = "Ctrl"
	ALT_KEY =  "Alt"
	SHIFT_KEY =  "Shift"
end



--initialize input state
yHold = false
bHold = false
xHold = false
aHold = false
lHold = false
rHold = false
startHold = false
selectHold = false
leftHold = false
rightHold = false
upHold = false
downHold = false

mouseLeftHold = false
mouseRightHold = false
mouseMiddleHold = false

--initialize grab and freeze features
spriteGrabs = {}
spriteGrabXs = {}
spriteGrabYs = {}
spriteFreezes = {}
spriteFreezeXs = {}
spriteFreezeYs = {}



--main sprite debug function
function SpriteDebug()
	state = emu.getState()
	
	--clear previous renders and read new states
	emu.clearScreen()
	
	--get the current game and update variables if game changed
	gameCode = ReadString(0x00FFB2,4)
	currentGame = GetGame(gameCode)
	
	if currentGame ~= game then
		SetGameInfo(currentGame)
		game = currentGame
		
		for spriteIndex = SPRITE_SLOT_COUNT, 1 do
			spriteSelections[spriteIndex] = false
			spriteGrabXs[spriteIndex] = nil
			spriteGrabYs[spriteIndex] = nil
			
			spriteFreezes[spriteIndex] = false
			spriteFreezeXs[spriteIndex] = nil
			spriteFreezeXs[spriteIndex] = nil
		end
		
	end
	
	--poll controller inputs
	input = emu.getInput(0)
	yHold,		yPress,			yRelease		= UpdateInputStates(input.y, yHold)
	bHold,		bPress,			bRelease		= UpdateInputStates(input.b, bHold)
	xHold,		xPress,			xRelease		= UpdateInputStates(input.x, xHold)
	aHold,		aPress,			aRelease		= UpdateInputStates(input.a, aHold)
	lHold,		lPress,			lRelease		= UpdateInputStates(input.l, lHold)
	rHold,		rPress,			rRelease		= UpdateInputStates(input.r, rHold)
	startHold,	startPress,		startRelease	= UpdateInputStates(input.start, startHold)
	selectHold,	selectPress,	selectRelease	= UpdateInputStates(input.select, selectHold)
	leftHold,	leftPress,		leftRelease		= UpdateInputStates(input.left, leftHold)
	rightHold,	rightPress,		rightRelease	= UpdateInputStates(input.right, rightHold)
	upHold,	    upPress,	    upRelease		= UpdateInputStates(input.up, upHold)
	downHold,	downPress,		downRelease		= UpdateInputStates(input.down, downHold)
	
	--poll mouse inputs
	mouseState = emu.getMouseState()
	mouseLeftHold, mouseLeftPress, mouseLeftRelease = UpdateInputStates(mouseState.left, mouseLeftHold)
	mouseRightHold, mouseRightPress, mouseRightRelease = UpdateInputStates(mouseState.right, mouseRightHold)
	
	if mouseState.middle then
		middleMouseTemp = true
	else
		middleMouseTemp = false
	end
	mouseMiddleHold, mouseMiddlePress, mouseMiddleRelease = UpdateInputStates(middleMouseTemp, mouseMiddleHold)
	
	--get game variables
	globalFrameTimer = ReadWord(GLOBAL_FRAME_TIMER)
	
	cameraX = ReadWord(CAMERA_X)
	cameraY = ReadWord(CAMERA_Y)
	if game == 1 then
		levelHeight = ReadWord(LEVEL_HEIGHT)
	end
	
	if not startPress and featureDebugFly then
		currentKongSprite = ReadWord(CURRENT_KONG)
		WriteWord(currentKongSprite+SPRITE_STATE, KONG_DEBUG_FLY_STATE)
		featureDebugFly = false
	end
	
	if rPress then
		QueueInGameSoundEffect(0x076F)
	end
	
	isGamePaused = CheckBit(ReadWord(GAME_STATE), 0x0040)
	
	if not isGamePaused then
		--if L pressed decrease variable to display/sprite type to filter if X held
		if lPress then
			if xHold then
				isSpriteFiltering = true
				spriteFilterType = spriteFilterType - SPRITE_TYPE_STEP
				
				--if variable underflowed loop back around to variable $5C,x
				if spriteFilterType < 0 then
					spriteFilterType = SPRITE_TYPE_MAX
				end
			else
				selectedVariableIndex = selectedVariableIndex - 1
				
				--if variable underflowed loop back around to variable $5C,x
				if selectedVariableIndex <= 0 then
					selectedVariableIndex = #SPRITE_VARIABLE_TABLES
				end
			end
		end
	
		--if R pressed increase variable to display/sprite type to filter if X held
		if rPress then
			if xHold then
				isSpriteFiltering = true
				spriteFilterType = spriteFilterType + SPRITE_TYPE_STEP
				
				--if variable overflowed loop back around
				if spriteFilterType >= SPRITE_TYPE_MAX then
					spriteFilterType = SPRITE_TYPE_MIN
				end
			else
				selectedVariableIndex = selectedVariableIndex + 1
				
				--if variable overflowed loop back around to variable $00,x
				if selectedVariableIndex >= #SPRITE_VARIABLE_TABLES then
					selectedVariableIndex = 1
				end
			end
		end
	end
	
	selectedVariableOffset = SPRITE_VARIABLE_TABLES[selectedVariableIndex]
	
	--render sprite info list header
	if featureShowSpriteInfoList then
		guiSpriteInfoOffsetY = 0
		emu.drawRectangle(0, renderOffsetY, infoListWidth, infoListHeight+infoListPadding, spriteInfoListBGColor, true, 1)
		
		emu.drawString(infoListPadding, infoListPadding+renderOffsetY, "Index Type " .. ToHexByte(selectedVariableOffset) .. ",x", 0xFFFFFF, 0xFF000000)

		if isSpriteFiltering then
			emu.drawRectangle(infoListWidth, renderOffsetY, 60, infoListHeight+infoListPadding, spriteInfoListBGColor, true, 1)
			emu.drawString(infoListWidth, infoListPadding+renderOffsetY,"filter: " .. ToHexWord(spriteFilterType), 0xFFFFFF, 0xFF000000)
		end
		
		guiSpriteInfoOffsetY = guiSpriteInfoOffsetY + infoListHeight+infoListPadding+renderOffsetY
	end
		
	--iterate through every sprite slot
	for spriteIndex = 0,SPRITE_SLOT_COUNT-1,1 do
		--assign color to sprite
		spriteBoxColor = spriteColors[spriteIndex+1]
		
		--get sprite info
		
		if game == 1 then
			spriteRAMPointer = spriteIndex*2 + SPRITE_RAM_BASE_POINTER
		else
			spriteRAMPointer = SPRITE_SIZE * spriteIndex + SPRITE_RAM_BASE_POINTER
		end
		
		spriteType = ReadWord(spriteRAMPointer+SPRITE_TYPE)
		
		--get viewed variable value
		selectedVariableValue = ReadWord(spriteRAMPointer+selectedVariableOffset)
		
		--if sprite is valid process the sprite
		if spriteType == 0 then
			spriteGrabs[spriteIndex] = false
			spriteGrabXs[spriteIndex] = nil
			spriteGrabYs[spriteIndex] = nil
			spriteFreezes[spriteIndex] = false
			spriteFreezeXs[spriteIndex] = nil
			spriteFreezeYs[spriteIndex] = nil
		else
			
			if not isSpriteFiltering or spriteType == spriteFilterType then
				--get sprite position and direction
				spriteX = ReadWord(spriteRAMPointer+SPRITE_X)
				
				if game == 1 then
					spriteY = levelHeight-ReadWord(spriteRAMPointer+SPRITE_Y)
				else
					spriteY = ReadWord(spriteRAMPointer+SPRITE_Y)
				end
				
				spriteFacing = ReadWord(spriteRAMPointer+SPRITE_OAM)
				
				--get sprite hitbox
				hitboxNumber = ReadWord(spriteRAMPointer+SPRITE_HITBOX_NUMBER)
				
				--if the sprite doesnt have a hitbox then make a dummy 8x8 one so the user can still grab it
				if hitboxNumber == 0 then
					hitboxOffsetX = -4
					hitboxOffsetY = -4
					hitboxWidth = 8
					hitboxHeight = 8
				else
					if game == 3 then
						hitboxPointer = emu.readWord(HITBOX_TABLE_POINTER+hitboxNumber+3, emu.memType[cpuDebug], false)
						hitboxOffsetX = emu.readWord(HITBOX_BASE_POINTER+hitboxPointer, emu.memType[cpuDebug], true)
						hitboxOffsetY = emu.readWord(HITBOX_BASE_POINTER+hitboxPointer+2, emu.memType[cpuDebug], true)
						hitboxWidth = emu.readWord(HITBOX_BASE_POINTER+hitboxPointer+4, emu.memType[cpuDebug], true)
						hitboxHeight = emu.readWord(HITBOX_BASE_POINTER+hitboxPointer+6, emu.memType[cpuDebug], true)
					else
						hitboxPointer = emu.readWord(HITBOX_TABLE_POINTER+hitboxNumber/2, emu.memType[cpuDebug], false)
						hitboxOffsetX = emu.readWord(HITBOX_BASE_POINTER+hitboxPointer, emu.memType[cpuDebug], true)
						hitboxOffsetY = emu.readWord(HITBOX_BASE_POINTER+hitboxPointer+2, emu.memType[cpuDebug], true)
						hitboxWidth = emu.readWord(HITBOX_BASE_POINTER+hitboxPointer+4, emu.memType[cpuDebug], true)
						hitboxHeight = emu.readWord(HITBOX_BASE_POINTER+hitboxPointer+6, emu.memType[cpuDebug], true)
					end
					
					--if sprite is x flipped mirror the hitbox
					if CheckBit(spriteFacing,0x4000) then
						hitboxWidth = hitboxWidth * -1
						hitboxOffsetX = hitboxOffsetX * -1
					end
					
					--if sprite is y flipped mirror the hitbox
					if CheckBit(spriteFacing,0x8000) then
						hitboxHeight = hitboxHeight * -1
						hitboxOffsetY = hitboxOffsetY * -1
					end
				end
			
				hitboxScreenX = (spriteX-cameraX)+hitboxOffsetX
				hitboxScreenY = (spriteY-cameraY)+hitboxOffsetY+renderOffsetY
				
				--render sprite origin points
				if featureShowSpriteOrigins then
					emu.drawPixel(spriteX-cameraX, spriteY-cameraY+renderOffsetY, spriteBoxColor)
				end
				
				--render sprite hitbox
				if featureShowSpriteHitboxes then
					if hitboxNumber == 0 then
						emu.drawRectangle(hitboxScreenX, hitboxScreenY, hitboxWidth, hitboxHeight, spriteBoxColor+0x80000000, true, 1)
					else
						emu.drawRectangle(hitboxScreenX, hitboxScreenY, hitboxWidth, hitboxHeight, spriteBoxColor+0x80000000, false, 1)
					end
				end
				
				--render sprite info list
				if featureShowSpriteInfoList then
					emu.drawRectangle(0, guiSpriteInfoOffsetY, infoListWidth, infoListHeight, spriteInfoListBGColor, true, 1)
					emu.drawString(infoListPadding, guiSpriteInfoOffsetY, ToHexWord(spriteRAMPointer).. " " .. ToHexWord(spriteType) .." " .. ToHexWord(selectedVariableValue), spriteBoxColor, 0xFF000000)
					guiSpriteInfoOffsetY = guiSpriteInfoOffsetY + infoListHeight
				end
				
				--only handle cursor features if mouse in on screen
				if mouseState.x >= 0 and mouseState.y >= 0 then
					if featureDragSprites then
						if mouseLeftPress then
							cursorBoxOffsetX, cursorBoxOffsetY = GetBoxCoordinates(mouseState.x, mouseState.y, hitboxScreenX, hitboxScreenY, hitboxWidth, hitboxHeight)
							
							if cursorBoxOffsetX ~= nil and cursorBoxOffsetY ~= nil then
								spriteGrabs[spriteIndex] = true
								spriteGrabXs[spriteIndex] = mouseState.x + cameraX - spriteX
								
								
								if game == 1 then
									spriteGrabYs[spriteIndex] = spriteY-cameraY-mouseState.y+renderOffsetY
								else
									spriteGrabYs[spriteIndex] = mouseState.y + cameraY - spriteY
								end
							end
						end
						
						if mouseLeftRelease then
							spriteGrabs[spriteIndex] = false
							spriteGrabXs[spriteIndex] = nil
							spriteGrabYs[spriteIndex] = nil
						end
						
						if mouseLeftHold and spriteGrabs[spriteIndex] then
							if precisePositioning then
								WriteByte(spriteRAMPointer+SPRITE_SUB_X, 0)
								WriteByte(spriteRAMPointer+SPRITE_SUB_Y, 0)
							end
							
							WriteWord(spriteRAMPointer+SPRITE_X, mouseState.x+cameraX-spriteGrabXs[spriteIndex])
							
							if game == 1 then
								--WriteWord(spriteRAMPointer+SPRITE_Y, screenHeight-mouseState.y+cameraY-spriteGrabYs[spriteIndex])
								WriteWord(spriteRAMPointer+SPRITE_Y, ((mouseState.y+cameraY-renderOffsetY-levelHeight)*-1)-spriteGrabYs[spriteIndex])
							else
								WriteWord(spriteRAMPointer+SPRITE_Y, mouseState.y+cameraY-spriteGrabYs[spriteIndex])
							end
							
							spriteFreezeXs[spriteIndex] = mouseState.x+cameraX-spriteGrabXs[spriteIndex]
							
							if game == 1 then
								spriteFreezeYs[spriteIndex] = mouseState.y-renderOffsetY+cameraY+spriteGrabYs[spriteIndex]
							else
								spriteFreezeYs[spriteIndex] = mouseState.y+cameraY-spriteGrabYs[spriteIndex]
							end
						end
					end
					
					if featureFreezeSprites then
						if mouseRightPress then
							cursorBoxOffsetX, cursorBoxOffsetY = GetBoxCoordinates(mouseState.x, mouseState.y, hitboxScreenX, hitboxScreenY, hitboxWidth, hitboxHeight)
							
							if cursorBoxOffsetX ~= nil and cursorBoxOffsetY ~= nil then
								if spriteFreezes[spriteIndex] ~= true then
									spriteFreezes[spriteIndex] = true
									spriteFreezeXs[spriteIndex] = spriteX
									spriteFreezeYs[spriteIndex] = spriteY
									QueueInGameSoundEffect(0x075E)
								else
									spriteFreezes[spriteIndex] = false
									spriteFreezeXs[spriteIndex] = nil
									spriteFreezeYs[spriteIndex] = nil
									QueueInGameSoundEffect(0x075E)
								end
							end
						end
					end
					
					if featureFilterSprites then
						if mouseMiddlePress then
							cursorBoxOffsetX, cursorBoxOffsetY = GetBoxCoordinates(mouseState.x, mouseState.y, hitboxScreenX, hitboxScreenY, hitboxWidth, hitboxHeight)
							if cursorBoxOffsetX ~= nil and cursorBoxOffsetY ~= nil then
								isSpriteFiltering = true
								spriteFilterType = spriteType
								mouseMiddlePress = false
								QueueInGameSoundEffect(0x011C)
							else
								isSpriteFiltering = false
							end
						end
					end
				end
				
				if featureFreezeSprites then
					if spriteFreezes[spriteIndex] then
						if precisePositioning then
							WriteByte(spriteRAMPointer+SPRITE_SUB_X, 0)
							WriteByte(spriteRAMPointer+SPRITE_SUB_Y, 0)
						end
						
						WriteWord(spriteRAMPointer+SPRITE_X, spriteFreezeXs[spriteIndex])
						
						if game == 1 then
							WriteWord(spriteRAMPointer+SPRITE_Y, (spriteFreezeYs[spriteIndex]-levelHeight)*-1)
						else
							WriteWord(spriteRAMPointer+SPRITE_Y, spriteFreezeYs[spriteIndex])
						end
						
						emu.drawRectangle(spriteX-cameraX-4, spriteY-cameraY+renderOffsetY-4, 2, 8, 0x00FFFFFF, true, 1)
						emu.drawRectangle(spriteX-cameraX, spriteY-cameraY+renderOffsetY-4, 2, 8, 0x00FFFFFF, true, 1)
					end
				end
				
				if featureShowAdditionalSpriteInfo then
					cursorBoxOffsetX, cursorBoxOffsetY = GetBoxCoordinates(mouseState.x, mouseState.y, hitboxScreenX, hitboxScreenY, hitboxWidth, hitboxHeight)
					if cursorBoxOffsetX ~= nil and cursorBoxOffsetY ~= nil then
						RenderAdditionalSpriteInfo(spriteRAMPointer,selectedVariableOffset)
					end
				end
				
				--render a darker hitbox if the sprite is hovered over with mouse
				if featureShowSpriteHitboxes then
					x, y = GetBoxCoordinates(mouseState.x, mouseState.y, hitboxScreenX, hitboxScreenY, hitboxWidth, hitboxHeight)
					
					if x ~= nil and y ~= nil then
						emu.drawRectangle(hitboxScreenX, hitboxScreenY, hitboxWidth, hitboxHeight, spriteBoxColor+0x80000000, true, 1)
					end
				end
			else
			
				if featureFilterSprites and mouseMiddlePress then
					isSpriteFiltering = false
					mouseMiddlePress = false
				end
			end
			
		end
	end

	if isGamePaused then
		
		scriptMenuRenderOffsetX = 10
		scriptMenuRenderOffsetY = 30
		
		if featureHideScriptMenu then
			if Bitwise(globalFrameTimer,0x10,AND) ~= 0 then
				emu.drawString(208, 208+renderOffsetY, "PRESS Y", featureTextColor, 0xFF000000)
			end
		else
			emu.clearScreen()
			emu.drawRectangle(0, 0+renderOffsetY, screenWidth, screenHeight, pausedBackgroundColor, true, 1)
			emu.drawString(25, 10+renderOffsetY, "H4v0c21's DKC Trilogy Debug Script v2.00", featureTextColor, 0xFF000000)
		end
		
		if game == 1 then
			RenderScriptMenuOption("[DKC 1 DETECTED]", 0x00FF4040, false, true)
		elseif game == 2 then                        
			RenderScriptMenuOption("[DKC 2 DETECTED]", 0x00FF40FF, false, true)
		elseif game == 3 then                        
			RenderScriptMenuOption("[DKC 3 DETECTED]", 0x0040FFFF, false, true)
		end
		
		RenderScriptMenuOption("", featureTextColor, false, true)

		if featureDragSprites then 
			featureOptionColor = enabledFeatureColor
		else
			featureOptionColor = disabledFeatureColor
		end
		RenderScriptMenuOption("[A]      Drag Sprites (Hold Left Click)", featureOptionColor, false, true)
		
		if featureFreezeSprites then 
			featureOptionColor = enabledFeatureColor
		else
			featureOptionColor = disabledFeatureColor
		end
		RenderScriptMenuOption("[B]      Freeze Sprites (Right Click)", featureOptionColor, false, true)
		
		if featureFilterSprites then 
			featureOptionColor = enabledFeatureColor
		else
			featureOptionColor = disabledFeatureColor
		end
		RenderScriptMenuOption("[X]      Filter Sprites (Middle Click)", featureOptionColor, false, true)
		
		RenderScriptMenuOption("[Y]      Hide Script Menu", featureOneTimeOptionColor, false, true)
		
		if featureShowSpriteOrigins then 
			featureOptionColor = enabledFeatureColor
		else
			featureOptionColor = disabledFeatureColor
		end
		RenderScriptMenuOption("", 0xFFFFFFFF, false, true)
		RenderScriptMenuOption("[UP]     Show Sprite Origins", featureOptionColor, false, true)
		
		if featureShowSpriteHitboxes then 
			featureOptionColor = enabledFeatureColor
		else
			featureOptionColor = disabledFeatureColor
		end
		RenderScriptMenuOption("[DOWN]   Show Sprite Hitboxes", featureOptionColor, false, true)
		
		if featureShowSpriteInfoList then 
			featureOptionColor = enabledFeatureColor
		else
			featureOptionColor = disabledFeatureColor
		end
		RenderScriptMenuOption("[LEFT]   Show Sprite Info List", featureOptionColor, false, true)
		
		if featureShowAdditionalSpriteInfo then 
			featureOptionColor = enabledFeatureColor
		else
			featureOptionColor = disabledFeatureColor
		end
		RenderScriptMenuOption("[RIGHT]  Show Additional Sprite Info", featureOptionColor, false, true)
		
		if featureDebugDisableSprites then 
			featureOptionColor = enabledFeatureColor
		else
			featureOptionColor = disabledFeatureColor
		end
		RenderScriptMenuOption("", 0xFFFFFFFF, false, true)
		
		if game == 1 then
			RenderScriptMenuOption("[L]      Enable Debug", featureOptionColor, false, true)
		elseif game == 2 then
			RenderScriptMenuOption("[L]      Enable Sprite Debug", featureOptionColor, false, true)
			RenderScriptMenuOption("[R]      Enable Debug Fly", featureOneTimeOptionColor, false, true)
		elseif game == 3 then
			RenderScriptMenuOption("[L]      Enable Debug Fly", featureOneTimeOptionColor, false, true)
		end
		
		
		
		RenderScriptMenuOption("", 0xFFFFFFFF, false, true)
		RenderScriptMenuOption("[SELECT] Exit Level", featureSubTextColor, false, true)
		RenderScriptMenuOption("[START]  Unpause", featureSubTextColor, false, true)
		
		if aPress then
			QueueInGameSoundEffect(0x000A)
			
			if featureDragSprites then
				featureDragSprites = false
			else
				featureDragSprites = true
			end
		end
		
		if bPress then
			QueueInGameSoundEffect(0x011C)
			
			if featureFreezeSprites then
				featureFreezeSprites = false
			else
				featureFreezeSprites = true
			end
		end
		
		if xPress then
			QueueInGameSoundEffect(0x0235)
			
			if featureFilterSprites then
				featureFilterSprites = false
			else
				featureFilterSprites = true
			end
		end
		
		if yPress then
			if featureHideScriptMenu then
				featureHideScriptMenu = false
			else
				featureHideScriptMenu = true
			end
		end
		
		if upPress then
			QueueInGameSoundEffect(0x0527)
			
			if featureShowSpriteOrigins then
				featureShowSpriteOrigins = false
			else
				featureShowSpriteOrigins = true
			end
		end
		
		if downPress then
			QueueInGameSoundEffect(0x0628)
			
			if featureShowSpriteHitboxes then
				featureShowSpriteHitboxes = false
			else
				featureShowSpriteHitboxes = true
			end
		end
		
		if leftPress then
			QueueInGameSoundEffect(0x0729)
			
			if featureShowSpriteInfoList then
				featureShowSpriteInfoList = false
			else
				featureShowSpriteInfoList = true
			end
		end
		
		if rightPress then
			QueueInGameSoundEffect(0x072A)
			
			if featureShowAdditionalSpriteInfo then
				featureShowAdditionalSpriteInfo = false
			else
				featureShowAdditionalSpriteInfo = true
			end
		end
		
		if lPress then
			if game == 1 then
				QueueInGameSoundEffect(0x0609)
				
				if featureDebugDisableSprites then
					ResetMemoryWordBits(DEBUG_FLAGS, 0x0001)
					featureDebugDisableSprites = false
				else
					SetMemoryWordBits(DEBUG_FLAGS, 0x0001)
					featureDebugDisableSprites = true
				end
				
			elseif game == 2 then
				QueueInGameSoundEffect(0x0609)
				
				if featureDebugDisableSprites then
					ResetMemoryWordBits(DEBUG_FLAGS, 0x0040)
					featureDebugDisableSprites = false
				else
					SetMemoryWordBits(DEBUG_FLAGS, 0x0040)
					featureDebugDisableSprites = true
				end
				
			elseif game == 3 then
				QueueInGameSoundEffect(0x0703)
			
				if featureDebugFly then
					currentKongSprite = ReadWord(CURRENT_KONG)
					WriteWord(currentKongSprite+SPRITE_STATE, KONG_DEBUG_FLY_STATE)
					featureDebugFly = false
				else
					currentKongSprite = ReadWord(CURRENT_KONG)
					WriteWord(currentKongSprite+SPRITE_STATE, KONG_DEBUG_FLY_STATE)
					featureDebugFly = true
				end
			end
		end
		
		
		if game == 2 then
			if rPress then
				QueueInGameSoundEffect(0x0703)
				
				if featureDebugFly then
					currentKongSprite = ReadWord(CURRENT_KONG)
					WriteWord(currentKongSprite+SPRITE_STATE, KONG_DEBUG_FLY_STATE)
					featureDebugFly = false
				else
					currentKongSprite = ReadWord(CURRENT_KONG)
					WriteWord(currentKongSprite+SPRITE_STATE, KONG_DEBUG_FLY_STATE)
					featureDebugFly = true
				end
			end
		end
		
	end
	
end

--call sprite debug
emu.addEventCallback(SpriteDebug, emu.eventType.endFrame);

--display startup message
emu.displayMessage("Script", "H4v0c21's DKC Trilogy Debug Script loaded.")