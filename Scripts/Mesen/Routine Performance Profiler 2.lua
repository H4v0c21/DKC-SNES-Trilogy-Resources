function profile(entryAddress, exitAddresses, name)
	local routineStartTime
	local routineEndTime

	function routineStart()
		local state = emu.getState()
		routineStartTime = state["masterClock"] 
	end

	function routineEnd()
		local state = emu.getState()
		routineEndTime = state["masterClock"]
	end
	
	-- Add callbacks, which now close over the unique local variables
	emu.addMemoryCallback(routineStart, emu.callbackType.exec, entryAddress, entryAddress, emu.cpuType.snes, emu.memType.snesCpuDebug);

	for _, exitAddress in ipairs(exitAddresses) do
		emu.addMemoryCallback(routineEnd, emu.callbackType.exec, exitAddress, exitAddress, emu.cpuType.snes, emu.memType.snesCpuDebug);
	end
end