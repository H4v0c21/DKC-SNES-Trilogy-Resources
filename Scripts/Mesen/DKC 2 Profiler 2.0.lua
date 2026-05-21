

maxLineClocks = 1364
cpuLineRefreshClocks = 40
activeLineClocks = maxLineClocks - cpuLineRefreshClocks

--internalRegisters.hCounter
--internalRegisters.horizontalTimer
--internalRegisters.ioPortOutput
--internalRegisters.irqFlag
--internalRegisters.irqLevel
--internalRegisters.needIrq
--internalRegisters.nmiFlag
--internalRegisters.vCounter
--internalRegisters.verticalTimer


percentageColors = {
    0x00FF00,
    0x33FF00,
    0x66FF00,
    0x99FF00,
    0xCCFF00,
    0xFFCC00,
    0xFF9900,
    0xFF6600,
    0xFF3300,
    0xFF0000
}

renderOffsetY = 7

function renderUsageSegment(x, y, segmentSize, barHeight, color)
	emu.drawRectangle(x, y, segmentSize, barHeight, color, true, 1)
	return segmentSize
end


tilesetLogicUsageBarX = 0
tilesetLogicUsageBarY = renderOffsetY + 216
tilesetLogicUsageBarWidth = 256
tilesetLogicUsageBarHeight = 8

inputHandlerTime = 0
inputHandlerLogicPercent = 0
inputHandlerLogicSegment = 0

spriteLoaderTime = 0
spriteLoaderLogicPercent = 0
spriteLoaderLogicSegment = 0

spriteHandlerTime = 0
spriteHandlerLogicPercent = 0
spriteHandlerLogicSegment = 0

cameraHandlerTime = 0
cameraHandlerLogicPercent = 0
cameraHandlerLogicSegment = 0

scrollHandlerTime = 0
scrollHandlerLogicPercent = 0
scrollHandlerLogicSegment = 0

oamHandlerTime = 0
oamHandlerLogicPercent = 0
oamHandlerLogicSegment = 0

oamClearTime = 0
oamClearLogicPercent = 0
oamClearLogicSegment = 0

fadeHandlerTime = 0
fadeHandlerLogicPercent = 0
fadeHandlerLogicSegment = 0



function frameEnd()
	local state = emu.getState()
	
	--emu.clearScreen()
	
	emu.drawRectangle(0, renderOffsetY, 256, 100, 0x80000000, true, 1)
	
	NMIStartTime = state["masterClock"]
	
	availableLogicTime = NMIStartTime-tilesetLogicStartTime
	tilesetLogicTime = tilesetLogicEndTime-tilesetLogicStartTime
	
	tilesetLogicPercent = tilesetLogicTime / availableLogicTime * 100
	
	if tilesetLogicTime >= 0 then
		tilesetLogicSegment = tilesetLogicTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		inputHandlerTime = inputHandlerEndTime-inputHandlerStartTime
		inputHandlerLogicPercent = inputHandlerTime / availableLogicTime * 100
		inputHandlerLogicSegment = inputHandlerTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		spriteLoaderTime = spriteLoaderEndTime-spriteLoaderStartTime
		spriteLoaderLogicPercent = spriteLoaderTime / availableLogicTime * 100
		spriteLoaderLogicSegment = spriteLoaderTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		spriteHandlerTime = spriteHandlerEndTime-spriteHandlerStartTime
		spriteHandlerLogicPercent = spriteHandlerTime / availableLogicTime * 100
		spriteHandlerLogicSegment = spriteHandlerTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		cameraHandlerTime = cameraHandlerEndTime-cameraHandlerStartTime
		cameraHandlerLogicPercent = cameraHandlerTime / availableLogicTime * 100
		cameraHandlerLogicSegment = cameraHandlerTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		scrollHandlerTime = scrollHandlerEndTime-scrollHandlerStartTime
		scrollHandlerLogicPercent = scrollHandlerTime / availableLogicTime * 100
		scrollHandlerLogicSegment = scrollHandlerTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		oamHandlerTime = oamHandlerEndTime-oamHandlerStartTime
		oamHandlerLogicPercent = oamHandlerTime / availableLogicTime * 100
		oamHandlerLogicSegment = oamHandlerTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		oamClearTime = oamClearEndTime-oamClearStartTime
		oamClearLogicPercent = oamClearTime / availableLogicTime * 100
		oamClearLogicSegment = oamClearTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		fadeHandlerTime = fadeHandlerEndTime-fadeHandlerStartTime
		fadeHandlerLogicPercent = fadeHandlerTime / availableLogicTime * 100
		fadeHandlerLogicSegment = fadeHandlerTime / availableLogicTime * tilesetLogicUsageBarWidth
		
		
		
		
		usageColor = percentageColors[math.floor(tilesetLogicPercent/10)+1]
		emu.drawString(4, renderOffsetY+4, "Tileset Logic: " .. string.format("%.2f", tilesetLogicPercent) .. "% (" .. tilesetLogicTime .. "/" .. availableLogicTime .." cycles)", usageColor, 0xFF000000)
	
	else
		emu.drawString(4, renderOffsetY+4, "Tileset Logic: OVERLOAD", 0xFF0000, 0xFF000000)
	end


	--emu.drawString(8, renderOffsetY+8, "Total Logic Budget: (" .. availableLogicTime .. " cycles)", 0xFFFFFF, 0xFF000000)
	
	
	tilesetLogicUsageBarSegmentOffset = 0
	
	
	emu.drawRectangle(tilesetLogicUsageBarX, tilesetLogicUsageBarY, tilesetLogicUsageBarWidth, tilesetLogicUsageBarHeight, 0x00404040, true, 1)
	emu.drawRectangle(tilesetLogicUsageBarX, tilesetLogicUsageBarY, tilesetLogicSegment, tilesetLogicUsageBarHeight, 0x00FFFFFF, true, 1)
	
	
	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
		tilesetLogicUsageBarY,
		inputHandlerLogicSegment,
		tilesetLogicUsageBarHeight,
		0x00FF00FF
	)
	
	emu.drawString(4+10, renderOffsetY+4+10, "Input: " .. string.format("%.2f", inputHandlerLogicPercent) .. "% (" .. inputHandlerTime .. " cycles)", 0xFF00FF, 0xFF000000)
	
	
	
	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
		tilesetLogicUsageBarY,
		spriteLoaderLogicSegment,
		tilesetLogicUsageBarHeight,
		0x00FFFF00
	)
	
	emu.drawString(4+10, renderOffsetY+4+20, "Sp Init: " .. string.format("%.2f", spriteLoaderLogicPercent) .. "% (" .. spriteLoaderTime .. " cycles)", 0xFFFF00, 0xFF000000)
	
	
	
	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
		tilesetLogicUsageBarY,
		spriteHandlerLogicSegment,
		tilesetLogicUsageBarHeight,
		0x00FF0000
	)
	
	emu.drawString(4+10, renderOffsetY+4+30, "Sp Main: " .. string.format("%.2f", spriteHandlerLogicPercent) .. "% (" .. spriteHandlerTime .. " cycles)", 0xFF0000, 0xFF000000)
	
	
	
	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
		tilesetLogicUsageBarY,
		cameraHandlerLogicSegment,
		tilesetLogicUsageBarHeight,
		0x0000FFFF
	)
	
	emu.drawString(4+10, renderOffsetY+4+40, "Camera: " .. string.format("%.2f", cameraHandlerLogicPercent) .. "% (" .. cameraHandlerTime .. " cycles)", 0x00FFFF, 0xFF000000)
	
	
	
	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
		tilesetLogicUsageBarY,
		scrollHandlerLogicSegment,
		tilesetLogicUsageBarHeight,
		0x0000FF00
	)
	
	emu.drawString(4+10, renderOffsetY+4+50, "Scroll: " .. string.format("%.2f", scrollHandlerLogicPercent) .. "% (" .. scrollHandlerTime .. " cycles)", 0x00FF00, 0xFF000000)



	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
		tilesetLogicUsageBarY,
		oamHandlerLogicSegment,
		tilesetLogicUsageBarHeight,
		0x000000FF
	)
	
	emu.drawString(4+10, renderOffsetY+4+60, "Sp Draw: " .. string.format("%.2f", oamHandlerLogicPercent) .. "% (" .. oamHandlerTime .. " cycles)", 0x0000FF, 0xFF000000)



	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
		tilesetLogicUsageBarY,
		oamClearLogicSegment,
		tilesetLogicUsageBarHeight,
		0x008000FF
	)
	
	emu.drawString(4+10, renderOffsetY+4+70, "OAM Clear: " .. string.format("%.2f", oamClearLogicPercent) .. "% (" .. oamClearTime .. " cycles)", 0x8000FF, 0xFF000000)



	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
		tilesetLogicUsageBarY,
		fadeHandlerLogicSegment,
		tilesetLogicUsageBarHeight,
		0x80FF8000
	)
	
	emu.drawString(4+10, renderOffsetY+4+80, "Fade: " .. string.format("%.2f", fadeHandlerLogicPercent) .. "% (" .. fadeHandlerTime .. " cycles)", 0xFF8000, 0xFF000000)

	
	
end



--NMIStartTime = 0
--
--function NMIStart()
--	local state = emu.getState()
--	NMIStartTime = state["masterClock"]
--end
--
--emu.addMemoryCallback(NMIStart, emu.callbackType.exec, 0x808608, 0x808608, emu.cpuType.snes, emu.memType.snesCpuDebug);



tilesetLogicStartTime = 0
tilesetLogicEndTime = 0

function tilesetLogicStart()
	local state = emu.getState()
	tilesetLogicStartTime = state["masterClock"]
end

function tilesetLogicEnd()
	local state = emu.getState()
	tilesetLogicEndTime = state["masterClock"]
end

emu.addMemoryCallback(tilesetLogicStart, emu.callbackType.exec, 0x808834, 0x808834, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(tilesetLogicEnd, emu.callbackType.exec, 0x80864F, 0x80864F, emu.cpuType.snes, emu.memType.snesCpuDebug);



inputHandlerStartTime = 0
inputHandlerEndTime = 0

function inputHandlerStart()
	local state = emu.getState()
	inputHandlerStartTime = state["masterClock"]
end

function inputHandlerEnd()
	local state = emu.getState()
	inputHandlerEndTime = state["masterClock"]
end

emu.addMemoryCallback(inputHandlerStart, emu.callbackType.exec, 0x808988, 0x808988, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(inputHandlerEnd, emu.callbackType.exec, 0x808A8C, 0x808A8C, emu.cpuType.snes, emu.memType.snesCpuDebug);



spriteLoaderStartTime = 0
spriteLoaderEndTime = 0

function spriteLoaderStart()
	local state = emu.getState()
	spriteLoaderStartTime = state["masterClock"]
end

function spriteLoaderEnd()
	local state = emu.getState()
	spriteLoaderEndTime = state["masterClock"]
end

emu.addMemoryCallback(spriteLoaderStart, emu.callbackType.exec, 0xBBB5C4, 0xBBB5C4, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(spriteLoaderEnd, emu.callbackType.exec, 0xBBB61F, 0xBBB61F, emu.cpuType.snes, emu.memType.snesCpuDebug);



spriteHandlerStartTime = 0
spriteHandlerEndTime = 0

function spriteHandlerStart()
	local state = emu.getState()
	spriteHandlerStartTime = state["masterClock"]
end

function spriteHandlerEnd()
	local state = emu.getState()
	spriteHandlerEndTime = state["masterClock"]
end

emu.addMemoryCallback(spriteHandlerStart, emu.callbackType.exec, 0xB38007, 0xB38007, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(spriteHandlerEnd, emu.callbackType.exec, 0xB3806C, 0xB3806C, emu.cpuType.snes, emu.memType.snesCpuDebug);

--Alternate Exit: Timestop
emu.addMemoryCallback(spriteHandlerEnd, emu.callbackType.exec, 0xB3807E, 0xB3807E, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(spriteHandlerEnd, emu.callbackType.exec, 0xB38082, 0xB38082, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(spriteHandlerEnd, emu.callbackType.exec, 0xB38086, 0xB38086, emu.cpuType.snes, emu.memType.snesCpuDebug);



cameraHandlerStartTime = 0
cameraHandlerEndTime = 0

function cameraHandlerStart()
	local state = emu.getState()
	cameraHandlerStartTime = state["masterClock"]
end

function cameraHandlerEnd()
	local state = emu.getState()
	cameraHandlerEndTime = state["masterClock"]
end

emu.addMemoryCallback(cameraHandlerStart, emu.callbackType.exec, 0xB5E50D, 0xB5E50D, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(cameraHandlerEnd, emu.callbackType.exec, 0xB5E55F, 0xB5E55F, emu.cpuType.snes, emu.memType.snesCpuDebug);



scrollHandlerStartTime = 0
scrollHandlerEndTime = 0

function scrollHandlerStart()
	local state = emu.getState()
	scrollHandlerStartTime = state["masterClock"]
end

function scrollHandlerEnd()
	local state = emu.getState()
	scrollHandlerEndTime = state["masterClock"]
end

emu.addMemoryCallback(scrollHandlerStart, emu.callbackType.exec, 0xB5B54A, 0xB5B54A, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(scrollHandlerStart, emu.callbackType.exec, 0xB5B9A5, 0xB5B9A5, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(scrollHandlerStart, emu.callbackType.exec, 0xB5B9B0, 0xB5B9B0, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(scrollHandlerEnd, emu.callbackType.exec, 0xB5B445, 0xB5B445, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(scrollHandlerEnd, emu.callbackType.exec, 0xB5B8A5, 0xB5B8A5, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(scrollHandlerEnd, emu.callbackType.exec, 0xB5AEB2, 0xB5AEB2, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(scrollHandlerEnd, emu.callbackType.exec, 0xB5AFE1, 0xB5AFE1, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(scrollHandlerEnd, emu.callbackType.exec, 0xB5B00A, 0xB5B00A, emu.cpuType.snes, emu.memType.snesCpuDebug);

--B5B54A	square
--B5B9A5	vertical
--B5B9B0	horizontal
--B5B445	square end
--B5B8A5	vertical end
--B5AEB2	horizontal end
--B5AFE1 end
--B5B00A end



oamHandlerStartTime = 0
oamHandlerEndTime = 0

function oamHandlerStart()
	local state = emu.getState()
	oamHandlerStartTime = state["masterClock"]
end

function oamHandlerEnd()
	local state = emu.getState()
	oamHandlerEndTime = state["masterClock"]
end

emu.addMemoryCallback(oamHandlerStart, emu.callbackType.exec, 0x80F35B, 0x80F35B, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(oamHandlerEnd, emu.callbackType.exec, 0x80F3B3, 0x80F3B3, emu.cpuType.snes, emu.memType.snesCpuDebug);



oamClearStartTime = 0
oamClearEndTime = 0

function oamClearStart()
	local state = emu.getState()
	oamClearStartTime = state["masterClock"]
end

function oamClearEnd()
	local state = emu.getState()
	oamClearEndTime = state["masterClock"]
end

emu.addMemoryCallback(oamClearStart, emu.callbackType.exec, 0x8088BA, 0x8088BA, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(oamClearEnd, emu.callbackType.exec, 0x8088D1, 0x8088D1, emu.cpuType.snes, emu.memType.snesCpuDebug);



fadeHandlerStartTime = 0
fadeHandlerEndTime = 0

function fadeHandlerStart()
	local state = emu.getState()
	fadeHandlerStartTime = state["masterClock"]
end

function fadeHandlerEnd()
	local state = emu.getState()
	fadeHandlerEndTime = state["masterClock"]
end

emu.addMemoryCallback(fadeHandlerStart, emu.callbackType.exec, 0x808C3D, 0x808C3D, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(fadeHandlerEnd, emu.callbackType.exec, 0x808C7F, 0x808C7F, emu.cpuType.snes, emu.memType.snesCpuDebug);







emu.addEventCallback(frameEnd, emu.eventType.endFrame);