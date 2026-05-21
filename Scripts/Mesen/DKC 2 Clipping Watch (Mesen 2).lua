drawOffset = 7

colors = {
	0xFF4040,	-- Red
	0xFF8040,	-- Orange
	0xFFFF40,	-- Yellow
	0x80FF00,	-- Lime
	0x40FF40,	-- Green
	0x40FFFF,	-- Cyan
	0x4040FF,	-- Blue
	0x8040FF,	-- Purple
	0xFF40FF,	-- Magenta
	0xFFFFFF,	-- White
	
	--0xFF8000,	-- Orange
	--0x8000FF,	-- Purple
	--0x00FF80,	-- Spring green
	--0xFF0080,	-- Rose
	--0x80FF00,	-- Chartreuse
	--0x0080FF,	-- Deep sky blue
	--0xFF8080,	-- Light coral
	--0x808000,	-- Olive
	--0xFF4500,	-- Orange-red
	--0x000080,	-- Navy
	--0xFFC0CB,	-- Pink
	--0x8B008B,	-- Dark magenta
	--0x008080,	-- Teal
	--0xFF6347,	-- Tomato
	--0xFF1493,	-- Deep pink
	--0xFF8C00	-- Dark orange
}

function ReadByte(address)
	byte = emu.read(address, emu.memType[cpuDebug], false)
	return byte
end


function ReadWord(address)
	word = emu.readWord(address, emu.memType[cpuDebug], false)
	return word
end

function RenderClippingHitbox(base, color)
	cx = ReadWord(0x7E0AD7)
	cy = ReadWord(0x7E0ADB)
	
	if ReadWord(base + 0x7E0004) ~= 0 then
		x0 = ReadWord(base + 0x7E0000)
		y0 = ReadWord(base + 0x7E0002)
		x1 = ReadWord(base + 0x7E0004)
		y1 = ReadWord(base + 0x7E0006)
		
		x = x0 - cx
		y = y0 - cy + drawOffset
		w = x1 - x0
		h = y1 - y0
		emu.drawRectangle(x, y, w, h, 0x00000000 | colors[color], false, 1)
	end
end

--function RenderSpriteHitbox(sprite, hitbox_pointer, color)
--	cx = ReadWord(0x7E0AD7)
--	cy = ReadWord(0x7E0ADB)
--	
--	x = ReadWord(sprite + 0x06) + ReadWord(hitboxPointer) - cx
--	y = ReadWord(sprite + 0x0A) + ReadWord(hitboxPointer+2) - cy
--	w = ReadWord(hitboxPointer+4)
--	h = ReadWord(hitboxPointer+6)
--	emu.drawRectangle(x, y, w, h, 0x00000000 | colors[color], false, 1)
--end

function FrameEnd()
	state = emu.getState()
	emu.clearScreen()
end

clippingBase = 0x09A3
clippingSlot0 = 0x00
clippingSlot1 = 0x08
clippingSlot2 = 0x10
clippingSlot3 = 0x18
clippingSlot4 = 0x20
clippingSlot5 = 0x28
clippingSlot6 = 0x30
clippingSlot7 = 0x38
clippingSlot8 = 0x40
clippingSlot9 = 0x48

function CheckForCollision()
	state = emu.getState()
	
	playerClippingBase = state["cpu.y"] + 0x09A3
	
	RenderClippingHitbox(playerClippingBase+clippingSlot0, 1)
	RenderClippingHitbox(playerClippingBase+clippingSlot1, 2)
	
	RenderClippingHitbox(clippingBase+clippingSlot6, 4)
	RenderClippingHitbox(clippingBase+clippingSlot7, 5)
end

function CheckForKongMountCollision()
	state = emu.getState()

	RenderClippingHitbox(clippingBase+clippingSlot9, 3)
	
	RenderClippingHitbox(clippingBase+clippingSlot6, 4)
	RenderClippingHitbox(clippingBase+clippingSlot7, 5)
end

--function CheckForSpriteCollisions()
--	state = emu.getState()
--	
--	hitboxAddress = state["cpu.a"]
--	currentSprite = ReadWord(0x6A)
--	
--	RenderSpriteHitbox(currentSprite, hitboxAddress, 1)
--end

emu.addMemoryCallback(CheckForCollision, emu.callbackType.exec, 0xBCFD61, 0xBCFD61, emu.cpuType.snes, emu.memType[cpuDebug]);
emu.addMemoryCallback(CheckForKongMountCollision, emu.callbackType.exec, 0xBCFCDD, 0xBCFCDD, emu.cpuType.snes, emu.memType[cpuDebug]);

--emu.addMemoryCallback(CheckForSpriteCollisions, emu.callbackType.exec, 0xBCFE3E, 0xBCFE3E, emu.cpuType.snes, emu.memType[cpuDebug]);

