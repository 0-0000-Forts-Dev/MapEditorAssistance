-- Copyright (c) [0-0000]. Licensed under MIT.
-- Please do not remove this notice.
-- 请勿删除上述版权声明

-- MEA Support for Structure

local IgnoredDevices = {
	["reactor"] = true,
	["derrick"] = true,
}

Materials = {}
local function GetMaterialInfo(saveName)
	Materials[saveName] = {
		["HitPoints"] = GetMaterialValue(saveName, 0, COMMANDER_INACTIVE, "HitPoints", 100),
		["MetalRepairCost"] = GetMaterialValue(saveName, 0, COMMANDER_INACTIVE, "MetalRepairCost", 0),
		["MetalBuildCost"] = GetMaterialValue(saveName, 0, COMMANDER_INACTIVE, "MetalBuildCost", 0),
		["EnergyBuildCost"] = GetMaterialValue(saveName, 0, COMMANDER_INACTIVE, "EnergyBuildCost", 0),
		["EnergyRunCost"] = GetMaterialValue(saveName, 0, COMMANDER_INACTIVE, "EnergyRunCost", 0),
		["Invulnerable"] = GetMaterialValue(saveName, 0, COMMANDER_INACTIVE, "Invulnerable", false),
	}
end
local StructureDataResults = {
	-- the resources used to construct the structure
	-- include device costs(except reactor and derrick)
	-- ignore foundation costs
	-- ignore invulnerable materials
	metal = 0,
	energy = 0,
	-- the energy consuming rate to run all energy-consuming links in the structure
	energyrun = 0,
	-- the number of all the nodes(include segmented nodes and foundations) in the strcuture
	nodes=0,
	-- the number of all the foundations in the strcuture
	foundations=0,
	-- the number of all the links(include segmented links) in the strcuture
	links=0,
	-- the original length(ignore compression/expansion) of all the links in the strcuture
	-- ignore invulnerable materials
	lengtho=0,
	-- the actual length(consider compression/expansion) of all the links in the strcuture
	-- ignore invulnerable materials
	length=0,
	-- the actual length of all the invulnerable links in the strcuture
	lengthb=0,
	-- the number of all devices in the strcuture
	devices=0,
	seen={},
}
LinkCallBack = function(nodeA, nodeB, linkPos, saveName)
	if not Materials[saveName] then GetMaterialInfo(saveName) end
	local sdr = StructureDataResults
	sdr.seen[nodeA] = true
	sdr.seen[nodeB] = true
	sdr.links = sdr.links + 1

	-- ignore invulnerable links
	if not Materials[saveName].Invulnerable then
		-- if dlc2 isn't active, regard the actual length as the original length
		local length = Vec3Dist(NodePosition(nodeA),NodePosition(nodeB))
		sdr.length = sdr.length + length
		if dlc2Var_Active then
			local health, damaged = GetLinkHealth(nodeA, nodeB)
			if health > 0.7 then
				damaged = true
				-- use damge-repair to calculate the original length
				dlc2_ApplyDamageToLink(nodeA, nodeB, Materials[saveName].HitPoints*0.5, 0, LINKBREAK_DELETE)
				health = health - 0.5
			end
			length = GetLinkRepairCost(nodeA, nodeB).metal/(1-health)/Materials[saveName].MetalRepairCost
			if damaged then
				dlc2_ApplyDamageToLink(nodeA, nodeB, Materials[saveName].HitPoints*-0.5, 0, LINKBREAK_DELETE)
			end
		end
		sdr.lengtho = sdr.lengtho + length
		sdr.energyrun = sdr.energyrun + length*Materials[saveName].EnergyRunCost
		sdr.metal = sdr.metal + length*Materials[saveName].MetalBuildCost
		sdr.energy = sdr.energy + length*Materials[saveName].EnergyBuildCost
	else
		sdr.lengthb = sdr.lengthb + Vec3Dist(NodePosition(nodeA),NodePosition(nodeB))
	end
	return true
end
local function GetStructureData(structureId)
	StructureDataResults = {metal=0,energy=0,energyrun=0,nodes=0,foundations=0,links=0,lengtho=0,length=0,lengthb=0,seen={},devices=0}
	local sdr = StructureDataResults
	local teamId = GetStructureTeam(structureId)
	EnumerateStructureLinks(teamId, structureId, "LinkCallBack", true)
	for nodeId, _ in pairs(sdr.seen) do
		sdr.nodes = sdr.nodes+1
		if IsFoundation(nodeId) then sdr.foundations = sdr.foundations + 1 end
	end
	sdr.seen = nil
	for i=0, GetDeviceCount(teamId)-1 do
		local deviceId = GetDeviceId(teamId, i)
		if GetDeviceStructureId(deviceId) == structureId then
			sdr.devices = sdr.devices + 1
			local saveName = GetDeviceType(deviceId)
			if not IgnoredDevices[saveName] then
				local cost = GetDeviceCost(saveName)
				sdr.metal = sdr.metal + cost.metal
				sdr.energy = sdr.energy + cost.energy
			end
		end
	end
	return DeepCopy(sdr)
end
local function LogStructureData(structureId)
	local res = GetStructureData(structureId)
	if dlc2Var_Active then
		Notice(string.format("Structure %d: %.1fm, %.1fe, %.1fe-, N %d, F %d, L %.1f, lenO %.1f, len %.1f, lenB %.1f, D %d",structureId,res.metal,res.energy,res.energyrun,res.nodes,res.foundations,res.links,res.lengtho,res.length,res.lengthb,res.devices))
	else
		Notice(string.format("*Structure %d: %.1fm, %.1fe, %.1fe-, N %d, F %d, L %.1f, len %.1f, lenB %.1f, D %d",structureId,res.metal,res.energy,res.energyrun,res.nodes,res.foundations,res.links,res.length,res.lengthb,res.devices))
	end
	return res
end

local function ClearIsolatedNodes()
	for _, sideId in ipairs({-3,0,1,2}) do
		local nodes_todestroy = {}
		for i=0, NodeCount(sideId)-1 do
			local nodeId = GetNodeId(sideId, i)
			if NodeLinkCount(nodeId)==0 then
				nodes_todestroy[#nodes_todestroy+1] = nodeId
			end
		end
		for _, nodeId in ipairs(nodes_todestroy) do
			DestroyNode(NodeTeam(nodeId), nodeId)
		end
	end
end

local StructureOwner = {
	Background = -1,
	None = 0,
	Team1 = 1,
	Team2 = 2,
}

local StructureSelection = nil
local StructureSettingEnabled = false
-- Previous Structure Selection Effect
local preSSE1, preSSE2 = nil, nil
local function UpdateStructureSelection()
	-- Sometimes mistakenly believes that you selects last-selected node when select no nodes
	local objid = GetLocalSelectedNodeId()
	local structureId = nil
	if objid > 0 then
		structureId = NodeStructureId(objid)
	else
		objid = GetLocalSelectedDeviceId()
		if objid ~= -1 then
			local tmpStructureId = GetDeviceStructureId(objid)
			if tmpStructureId ~= 0 then
				structureId = tmpStructureId
			end
		end
	end
	if not StructureSettingEnabled and structureId then
		ShowControl("root", "MEA-StructureSetting", true)
		StructureSettingEnabled = true
	elseif StructureSettingEnabled and not structureId then
		ShowControl("root", "MEA-StructureSetting", false)
		StructureSettingEnabled = false
	end
	if StructureSelection ~= structureId then
		if preSSE1 then
			CancelEffect(preSSE1)
			CancelEffect(preSSE2)
			preSSE1, preSSE2 = nil, nil
		end
		if structureId then
			local pos = GetStructurePos(structureId)
			pos.z = -101 -- draw over terrains: z<=-100
			local radius = GetStructureRadius(structureId)
			preSSE1 = SpawnCircle(pos, radius, Colour(255,64,64,100), 1)
			preSSE2 = SpawnCircle(pos, radius/2, Colour(255,64,63,255), 1)
		end
	end
	StructureSelection = structureId
	SetControlText("MEA-StructureSetting", "MEA-SI_StructureId", "id: "..(structureId and structureId or -1))
end

RegisterEvent("OnKey", function(key, down)
	if GameMode ~= "Editor" then return end
	if down then
		if key == "left control" then
			ctrlState = true
		elseif key == "m" then
			if ctrlState then
				if StructureSelection then LogStructureData(StructureSelection) end
			end
		elseif key == "n" then
			if ctrlState then
				ClearIsolatedNodes()
			end
		end
	else
		if key == "left control" then
			ctrlState = false
		end
	end
end)
RegisterEvent("OnDraw", function()
	if GameMode == "Editor" then
		UpdateStructureSelection()
	end
end)

-- MEA-SO-$Owner$
RegisterControlHandler("MEA-SO_", function(name)
	if StructureSelection then
		local owner = string.sub(name, 8)
		ConvertStructure(StructureSelection, StructureNodeAtIndex(StructureSelection, 0), GetStructureTeam(StructureSelection), StructureOwner[owner])
		MakeUndoLevel()
	end
end, true)

RegisterControlHandler("MEA-SE_CollectInformation", function()
	if StructureSelection then
		LogStructureData(StructureSelection)
	end
end)

RegisterControlHandler("MEA-SS_Delete", function(name, doubleClick)
	if StructureSelection and doubleClick then
		local teamId = GetStructureTeam(StructureSelection)
		-- not existed or with the owner of none(can't be deleted directly)
		if teamId == -1 then
			ConvertStructure(StructureSelection, StructureNodeAtIndex(StructureSelection, 0), -1, 0)
			teamId = 0
		end
		local devs = {}
		for i = 0, GetDeviceCount(teamId)-1 do
			local id = GetDeviceId(teamId, i)
			-- note that for none or background ground devices, it will always be 0
			if GetDeviceStructureId(id) == StructureSelection then
				devs[#devs+1] = id
			end
		end
		for _, id in ipairs(devs) do
			DestroyDeviceById(id)
			if IsGroundDevice(id) then
				DeleteDeviceById(id)
			end
		end
		DestroyStructure(StructureNodeAtIndex(StructureSelection, 0))
		MakeUndoLevel()
	end
end)
