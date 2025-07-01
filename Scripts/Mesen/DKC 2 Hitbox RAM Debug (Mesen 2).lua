
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

draw_offset = 7

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


function Frame_End()
	--emu.clearScreen()
	state = emu.getState()
	
	for i = 0,10,1 do
		emu.drawString(0, i*10, "$" .. ToHexWord(0x09A3+(i*8-8)), colors[i], 0xFF000000)
	end
end



function RenderHitbox(base, color)
	state = emu.getState()
	
	cx = ReadWord(0x7E0AD7)
	cy = ReadWord(0x7E0ADB)
	
	x0 = ReadWord(base + 0x7E0000)
	y0 = ReadWord(base + 0x7E0002)
	x1 = ReadWord(base + 0x7E0004)
	y1 = ReadWord(base + 0x7E0006)
	
	x = x0 - cx
	y = y0 - cy + draw_offset
	w = x1 - x0
	h = y1 - y0
	emu.drawRectangle(x, y, w, h, colors[color], false, 1)
	--emu.drawPixel(x0-cx, y0-cy+draw_offset, colors[color])
	--emu.drawPixel(x1-cx, y0-cy+draw_offset, colors[color])
	--emu.drawPixel(x0-cx, y1-cy+draw_offset, colors[color])
	--emu.drawPixel(x1-cx, y1-cy+draw_offset, colors[color])
end



function Address_09A3_Written()
	RenderHitbox(0x09A3, 1)
end

function Address_09AB_Written()
	RenderHitbox(0x09AB, 2)
end

function Address_09B3_Written()
	RenderHitbox(0x09B3, 3)
end

function Address_09BB_Written()
	RenderHitbox(0x09BB, 4)
end

function Address_09C3_Written()
	RenderHitbox(0x09C3, 5)
end

function Address_09CB_Written()
	RenderHitbox(0x09CB, 6)
end

function Address_09D3_Written()
	RenderHitbox(0x09D3, 7)
end

function Address_09DB_Written()
	RenderHitbox(0x09DB, 8)
end

function Address_09E3_Written()
	RenderHitbox(0x09E3, 9)
end

function Address_09EB_Written()
	RenderHitbox(0x09EB, 10)
end

--emu.addMemoryCallback(Address_09A3_Written, emu.callbackType.write, 0x09A3+6, 0x09A3+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09AB_Written, emu.callbackType.write, 0x09AB+6, 0x09AB+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09B3_Written, emu.callbackType.write, 0x09B3+6, 0x09B3+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09BB_Written, emu.callbackType.write, 0x09BB+6, 0x09BB+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09C3_Written, emu.callbackType.write, 0x09C3+6, 0x09C3+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09CB_Written, emu.callbackType.write, 0x09CB+6, 0x09CB+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09D3_Written, emu.callbackType.write, 0x09D3+6, 0x09D3+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09DB_Written, emu.callbackType.write, 0x09DB+6, 0x09DB+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09E3_Written, emu.callbackType.write, 0x09E3+6, 0x09E3+6, emu.cpuType.snes, emu.memType.snesWorkRam);
--emu.addMemoryCallback(Address_09EB_Written, emu.callbackType.write, 0x09EB+6, 0x09EB+6, emu.cpuType.snes, emu.memType.snesWorkRam);

emu.addMemoryCallback(Address_09A3_Written, emu.callbackType.read, 0x09A3, 0x09A3, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09AB_Written, emu.callbackType.read, 0x09AB, 0x09AB, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09B3_Written, emu.callbackType.read, 0x09B3, 0x09B3, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09BB_Written, emu.callbackType.read, 0x09BB, 0x09BB, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09C3_Written, emu.callbackType.read, 0x09C3, 0x09C3, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09CB_Written, emu.callbackType.read, 0x09CB, 0x09CB, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09D3_Written, emu.callbackType.read, 0x09D3, 0x09D3, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09DB_Written, emu.callbackType.read, 0x09DB, 0x09DB, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09E3_Written, emu.callbackType.read, 0x09E3, 0x09E3, emu.cpuType.snes, emu.memType.snesWorkRam);
emu.addMemoryCallback(Address_09EB_Written, emu.callbackType.read, 0x09EB, 0x09EB, emu.cpuType.snes, emu.memType.snesWorkRam);

emu.addEventCallback(Frame_End, emu.eventType.endFrame);