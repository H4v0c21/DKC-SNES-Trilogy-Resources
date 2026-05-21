

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
	
	--availibleLogicTime = NMIStartTime-tilesetLogicStartTime
	--tilesetLogicTime = tilesetLogicEndTime-tilesetLogicStartTime
	--
	--tilesetLogicPercent = tilesetLogicTime / availibleLogicTime * 100
	
	--if tilesetLogicTime >= 0 then
	--	tilesetLogicSegment = tilesetLogicTime / availibleLogicTime * tilesetLogicUsageBarWidth
	--	
	--	inputHandlerTime = inputHandlerEndTime-inputHandlerStartTime
	--	inputHandlerLogicPercent = inputHandlerTime / tilesetLogicTime * 100
	--	inputHandlerLogicSegment = inputHandlerTime / tilesetLogicTime * tilesetLogicUsageBarWidth * (tilesetLogicTime / availibleLogicTime)
	--	
	--	spriteLoaderTime = spriteLoaderEndTime-spriteLoaderStartTime
	--	spriteLoaderLogicPercent = spriteLoaderTime / tilesetLogicTime * 100
	--	spriteLoaderLogicSegment = spriteLoaderTime / tilesetLogicTime * tilesetLogicUsageBarWidth * (tilesetLogicTime / availibleLogicTime)
	--	
	--	spriteHandlerTime = spriteHandlerEndTime-spriteHandlerStartTime
	--	spriteHandlerLogicPercent = spriteHandlerTime / tilesetLogicTime * 100
	--	spriteHandlerLogicSegment = spriteHandlerTime / tilesetLogicTime * tilesetLogicUsageBarWidth * (tilesetLogicTime / availibleLogicTime)
	--	
	--	cameraHandlerTime = cameraHandlerEndTime-cameraHandlerStartTime
	--	cameraHandlerLogicPercent = cameraHandlerTime / tilesetLogicTime * 100
	--	cameraHandlerLogicSegment = cameraHandlerTime / tilesetLogicTime * tilesetLogicUsageBarWidth * (tilesetLogicTime / availibleLogicTime)
	--	
	--	scrollHandlerTime = scrollHandlerEndTime-scrollHandlerStartTime
	--	scrollHandlerLogicPercent = scrollHandlerTime / tilesetLogicTime * 100
	--	scrollHandlerLogicSegment = scrollHandlerTime / tilesetLogicTime * tilesetLogicUsageBarWidth * (tilesetLogicTime / availibleLogicTime)
	--	
	--	oamHandlerTime = oamHandlerEndTime-oamHandlerStartTime
	--	oamHandlerLogicPercent = oamHandlerTime / tilesetLogicTime * 100
	--	oamHandlerLogicSegment = oamHandlerTime / tilesetLogicTime * tilesetLogicUsageBarWidth * (tilesetLogicTime / availibleLogicTime)
	--	
	--	oamClearTime = oamClearEndTime-oamClearStartTime
	--	oamClearLogicPercent = oamClearTime / tilesetLogicTime * 100
	--	oamClearLogicSegment = oamClearTime / tilesetLogicTime * tilesetLogicUsageBarWidth * (tilesetLogicTime / availibleLogicTime)
	--	
	--	fadeHandlerTime = fadeHandlerEndTime-fadeHandlerStartTime
	--	fadeHandlerLogicPercent = fadeHandlerTime / tilesetLogicTime * 100
	--	fadeHandlerLogicSegment = fadeHandlerTime / tilesetLogicTime * tilesetLogicUsageBarWidth * (tilesetLogicTime / availibleLogicTime)
	--	
	--	
	--	
	--	
	--	usageColor = percentageColors[math.floor(tilesetLogicPercent/10)+1]
	--	emu.drawString(4, renderOffsetY+4, "Tileset Logic: " .. string.format("%.2f", tilesetLogicPercent) .. "% (" .. tilesetLogicTime .. "/" .. availibleLogicTime .." cycles)", usageColor, 0xFF000000)
	--
	--else
	--	emu.drawString(4, renderOffsetY+4, "Tileset Logic: OVERLOAD", 0xFF0000, 0xFF000000)
	--end


	--emu.drawString(8, renderOffsetY+8, "Total Logic Budget: (" .. availibleLogicTime .. " cycles)", 0xFFFFFF, 0xFF000000)
	
	
	--tilesetLogicUsageBarSegmentOffset = 0
	
	
	--emu.drawRectangle(tilesetLogicUsageBarX, tilesetLogicUsageBarY, tilesetLogicUsageBarWidth, tilesetLogicUsageBarHeight, 0x00404040, true, 1)
	--emu.drawRectangle(tilesetLogicUsageBarX, tilesetLogicUsageBarY, tilesetLogicSegment, tilesetLogicUsageBarHeight, 0x00FFFFFF, true, 1)
	--
	--
	--tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
	--	tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
	--	tilesetLogicUsageBarY,
	--	testHandlerLogicSegment,
	--	tilesetLogicUsageBarHeight,
	--	0x00FF00FF
	--)
	
	testHandlerTime = testHandlerEndTime-testHandlerStartTime
	
	emu.drawString(4+10, renderOffsetY+4+10, "test: " .. testHandlerTime .. " cycles", 0xFF00FF, 0xFF000000)
	
	
	
--	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
--		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
--		tilesetLogicUsageBarY,
--		spriteLoaderLogicSegment,
--		tilesetLogicUsageBarHeight,
--		0x00FFFF00
--	)
--	
--	emu.drawString(4+10, renderOffsetY+4+20, "Sp Init: " .. string.format("%.2f", spriteLoaderLogicPercent) .. "% (" .. spriteLoaderTime .. " cycles)", 0xFFFF00, 0xFF000000)
--	
--	
--	
--	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
--		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
--		tilesetLogicUsageBarY,
--		spriteHandlerLogicSegment,
--		tilesetLogicUsageBarHeight,
--		0x00FF0000
--	)
--	
--	emu.drawString(4+10, renderOffsetY+4+30, "Sp Main: " .. string.format("%.2f", spriteHandlerLogicPercent) .. "% (" .. spriteHandlerTime .. " cycles)", 0xFF0000, 0xFF000000)
--	
--	
--	
--	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
--		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
--		tilesetLogicUsageBarY,
--		cameraHandlerLogicSegment,
--		tilesetLogicUsageBarHeight,
--		0x0000FFFF
--	)
--	
--	emu.drawString(4+10, renderOffsetY+4+40, "Camera: " .. string.format("%.2f", cameraHandlerLogicPercent) .. "% (" .. cameraHandlerTime .. " cycles)", 0x00FFFF, 0xFF000000)
--	
--	
--	
--	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
--		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
--		tilesetLogicUsageBarY,
--		scrollHandlerLogicSegment,
--		tilesetLogicUsageBarHeight,
--		0x0000FF00
--	)
--	
--	emu.drawString(4+10, renderOffsetY+4+50, "Scroll: " .. string.format("%.2f", scrollHandlerLogicPercent) .. "% (" .. scrollHandlerTime .. " cycles)", 0x00FF00, 0xFF000000)
--
--
--
--	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
--		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
--		tilesetLogicUsageBarY,
--		oamHandlerLogicSegment,
--		tilesetLogicUsageBarHeight,
--		0x000000FF
--	)
--	
--	emu.drawString(4+10, renderOffsetY+4+60, "Sp Draw: " .. string.format("%.2f", oamHandlerLogicPercent) .. "% (" .. oamHandlerTime .. " cycles)", 0x0000FF, 0xFF000000)
--
--
--
--	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
--		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
--		tilesetLogicUsageBarY,
--		oamClearLogicSegment,
--		tilesetLogicUsageBarHeight,
--		0x008000FF
--	)
--	
--	emu.drawString(4+10, renderOffsetY+4+70, "OAM Clear: " .. string.format("%.2f", oamClearLogicPercent) .. "% (" .. oamClearTime .. " cycles)", 0x8000FF, 0xFF000000)
--
--
--
--	tilesetLogicUsageBarSegmentOffset = tilesetLogicUsageBarSegmentOffset + renderUsageSegment(
--		tilesetLogicUsageBarX+tilesetLogicUsageBarSegmentOffset,
--		tilesetLogicUsageBarY,
--		fadeHandlerLogicSegment,
--		tilesetLogicUsageBarHeight,
--		0x80FF8000
--	)
--	
--	emu.drawString(4+10, renderOffsetY+4+80, "Fade: " .. string.format("%.2f", fadeHandlerLogicPercent) .. "% (" .. fadeHandlerTime .. " cycles)", 0xFF8000, 0xFF000000)

	
	
end



--NMIStartTime = 0
--
--function NMIStart()
--	local state = emu.getState()
--	NMIStartTime = state["masterClock"]
--end
--
--emu.addMemoryCallback(NMIStart, emu.callbackType.exec, 0x808608, 0x808608, emu.cpuType.snes, emu.memType.snesCpuDebug);



--tilesetLogicStartTime = 0
--tilesetLogicEndTime = 0
--
--function tilesetLogicStart()
--	local state = emu.getState()
--	tilesetLogicStartTime = state["masterClock"]
--end
--
--function tilesetLogicEnd()
--	local state = emu.getState()
--	tilesetLogicEndTime = state["masterClock"]
--end
--
--emu.addMemoryCallback(tilesetLogicStart, emu.callbackType.exec, 0x808834, 0x808834, emu.cpuType.snes, emu.memType.snesCpuDebug);
--emu.addMemoryCallback(tilesetLogicEnd, emu.callbackType.exec, 0x80864F, 0x80864F, emu.cpuType.snes, emu.memType.snesCpuDebug);



testHandlerStartTime = 0
testHandlerEndTime = 0

function testHandlerStart()
	local state = emu.getState()
	testHandlerStartTime = state["masterClock"]
end

function testHandlerEnd()
	local state = emu.getState()
	testHandlerEndTime = state["masterClock"]
end

emu.addMemoryCallback(testHandlerStart, emu.callbackType.exec, 0xBBB8A5, 0xBBB8A5, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(testHandlerEnd, emu.callbackType.exec, 0xBBB8EB, 0xBBB8EB, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(testHandlerEnd, emu.callbackType.exec, 0xBBB975, 0xBBB975, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(testHandlerEnd, emu.callbackType.exec, 0xBBB996, 0xBBB996, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(testHandlerEnd, emu.callbackType.exec, 0xBBB9AF, 0xBBB9AF, emu.cpuType.snes, emu.memType.snesCpuDebug);
emu.addMemoryCallback(testHandlerEnd, emu.callbackType.exec, 0xBBB9DC, 0xBBB9DC, emu.cpuType.snes, emu.memType.snesCpuDebug);

emu.addEventCallback(frameEnd, emu.eventType.endFrame);