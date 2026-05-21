routineEntry = 0x808992
routineExits = {
	0x8089A9
}



routineTime = 0
routineTimeMin = 0xFFFFFFFF
routineTimeMax = 0
routineStartTime = 0
routineEndTime = 0

renderOffsetY = 7



function frameEnd()
	local state = emu.getState()
	
	cpuSpeed = state["memoryManager.cpuSpeed"]
	
	--emu.clearScreen()
	
	emu.drawRectangle(0, renderOffsetY, 256, 32, 0x80000000, true, 1)
	
	routineTime = routineEndTime-routineStartTime
	
	if routineTime < routineTimeMin and routineTime > 0 then
		routineTimeMin = routineTime
	end
	
	if routineTime > routineTimeMax and routineTime < 1000000 then
		routineTimeMax = routineTime
	end
	
	emu.drawString(48, renderOffsetY, "Master", 0xFFFFFF, 0xFF000000)
	emu.drawString(88, renderOffsetY, "CPU", 0xFFFFFF, 0xFF000000)
	
	emu.drawString(8, renderOffsetY+8, "Time:", 0xFFFFFF, 0xFF000000)
	emu.drawString(8, renderOffsetY+16, "Min:", 0xFFFFFF, 0xFF000000)
	emu.drawString(8, renderOffsetY+24, "Max:", 0xFFFFFF, 0xFF000000)
	
	emu.drawString(48, renderOffsetY+8, routineTime, 0xFFFFFF, 0xFF000000)
	emu.drawString(48, renderOffsetY+16, routineTimeMin, 0xFFFFFF, 0xFF000000)
	emu.drawString(48, renderOffsetY+24, routineTimeMax, 0xFFFFFF, 0xFF000000)
	
	emu.drawString(88, renderOffsetY+8, routineTime//cpuSpeed, 0xFFFFFF, 0xFF000000)
	emu.drawString(88, renderOffsetY+16, routineTimeMin//cpuSpeed, 0xFFFFFF, 0xFF000000)
	emu.drawString(88, renderOffsetY+24, routineTimeMax//cpuSpeed, 0xFFFFFF, 0xFF000000)
	
end



function routineStart()
	local state = emu.getState()
	routineStartTime = state["masterClock"]
end

function routineEnd()
	local state = emu.getState()
	routineEndTime = state["masterClock"]
end


emu.addMemoryCallback(routineStart, emu.callbackType.exec, routineEntry, routineEntry, emu.cpuType.snes, emu.memType.snesCpuDebug);

for _, routineExit in ipairs(routineExits) do
	emu.addMemoryCallback(routineEnd, emu.callbackType.exec, routineExit, routineExit, emu.cpuType.snes, emu.memType.snesCpuDebug);
end

emu.addEventCallback(frameEnd, emu.eventType.endFrame);
