RegisterApplyMod(function()
	for _, v in ipairs(Devices) do
		if v.HideFromEditor then v.HideFromEditor = nil end
		if v.BuildOnGroundOnly and v.PopulationCap then
			v.PopulationCap = v.PopulationCap * 100
		end
	end
end)
