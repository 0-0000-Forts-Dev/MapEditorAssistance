RegisterApplyMod(function()
	for _, v in ipairs(Materials) do
		if v.Prerequisite then v.Prerequisite = nil end
		if v.HideFromEditor then v.HideFromEditor = nil end
		v.MetalRepairCost = -1
		if v.HitPoints and v.HitPoints <= 0 then v.HitPoints = 1 end
	end
end)
