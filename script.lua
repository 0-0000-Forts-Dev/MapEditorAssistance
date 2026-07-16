-- Copyright (c) [0-0000]. Licensed under MIT.
-- Please do not remove this notice.
-- 请勿删除上述版权声明
local min, max = math.min, math.max
dofile("scripts/forts.lua")

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
function GetStructureData(structureId)
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
function LogStructureData(structureId)
	local res = GetStructureData(structureId)
	if dlc2Var_Active then
		Notice(string.format("Structure %d: %.1fm, %.1fe, %.1fe-, N %d, F %d, L %.1f, lenO %.1f, len %.1f, lenB %.1f, D %d",structureId,res.metal,res.energy,res.energyrun,res.nodes,res.foundations,res.links,res.lengtho,res.length,res.lengthb,res.devices))
	else
		Notice(string.format("*Structure %d: %.1fm, %.1fe, %.1fe-, N %d, F %d, L %.1f, len %.1f, lenB %.1f, D %d",structureId,res.metal,res.energy,res.energyrun,res.nodes,res.foundations,res.links,res.length,res.lengthb,res.devices))
	end
	return res
end

function ClearIsolatedNodes()
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

BlockFlags = {
	Foundations = 1<<0,
	Mines = 1<<8,
	WaterLevel = 1<<9,
	EdgeWithFill = 1<<11,
	--OilDrills = 1<<16,
	--OilRigs = 1<<24,
	PassProjectiles = 1<<25,
	PassBeams = 1<<26,
	Hazard = 1<<27,
	NoSplash = 1<<28,
	NoBuild = 1<<29,
	CanBuildOver = 1<<30,
	NoDrawEdges = 1<<31,
}
BlockOwner = {
	Background = -2,
	Any = -1,
	None = 0,
	Team1 = 1,
	Team2 = 2,
}
StructureOwner = {
	Background = -1,
	None = 0,
	Team1 = 1,
	Team2 = 2,
}

BlockSelection = {
	-- [i] = blockIndex,
	-- When only one block is selected: Whether the block has made an 'undo' and won't create new vertexs for further clicks
	-- Can be true only when #it = 1
	still = false,
}
BlockSettingEnabled = false

function UpdateBlockSelection()
	local selects = GetBlockSelectionCount()
	-- Keep it true exactly when the selection has no changes
	if not(BlockSelection.still and selects == 1 and GetBlockSelection(0) == BlockSelection[1]) then
		BlockSelection.still = false
	end
	for i = 1, #BlockSelection do BlockSelection[i] = nil end
	for i = 1, selects do BlockSelection[i] = GetBlockSelection(i-1) end
	-- Note the display state won't be applied until further key inputs
	if not BlockSettingEnabled and selects > 0 then
		ShowControl("root", "MEA-BlockSetting", true)
		BlockSettingEnabled = true
	elseif BlockSettingEnabled and selects == 0 then
		ShowControl("root", "MEA-BlockSetting", false)
		BlockSettingEnabled = false
	end
end
StructureSelection = nil
StructureSettingEnabled = false
function UpdateStructureSelection()
	local id = GetLocalSelectedNodeId()
	local structureId = nil
	if id > 0 then
		structureId = NodeStructureId(id)
	else
		id = GetLocalSelectedDeviceId()
		if id ~= -1 then
			id = GetDeviceStructureId(id)
			if id ~= 0 then structureId = id end
		end
	end
	if not StructureSettingEnabled and structureId then
		ShowControl("root", "MEA-StructureSetting", true)
		StructureSettingEnabled = true
	elseif StructureSettingEnabled and not structureId then
		ShowControl("root", "MEA-StructureSetting", false)
		StructureSettingEnabled = false
	end
	StructureSelection = structureId
	if not structureId then structureId = -1 end
	SetControlText("MEA-StructureSetting", "MEA-SI_StructureId", "id: "..structureId)
end

function RepairBlock()
	if #BlockSelection == 1 and not BlockSelection.still then
		DeleteBlockVertex(GetBlockSelection(0), 1)
		BlockSelection.still = true
		UpdateGroundTriangles()
	end
end
-- Bounding Box Center
function GetBlockBBC(blockIndex)
	local cnt = GetBlockVertexCount(blockIndex)
	if cnt==0 then return Vec3(0,0,0) end
	local xmin,xmax,ymin,ymax = 1e39,-1e39,1e39,-1e39
	for i=0, cnt-1 do
		local pos = GetBlockVertexPos(blockIndex, i)
		xmin = min(xmin, pos.x); xmax = max(xmax, pos.x)
		ymin = min(ymin, pos.y); ymax = max(ymax, pos.y)
	end
	return Vec3((xmin+xmax)*0.5, (ymin+ymax)*0.5, 0)
end

function OnControlActivated(name, code, doubleClick)
	if GameMode ~= "Editor" then return end
	-- MEA-BF_$FLAG$-$T/F$
	if string.sub(name, 1, 7)=="MEA-BF_" then
		RepairBlock()
		local selects = #BlockSelection
		if selects > 0 then
			local flag = string.sub(name, 8, -3)
			local value = string.sub(name, -1)=="T"
			for i = 0, selects-1 do
				local blockIndex = GetBlockSelection(i)
				SetBlockFlags(blockIndex, BlockFlags[flag], value)
			end
			MakeUndoLevel()
		end
	-- MEA-BO_$Owner$
	elseif string.sub(name, 1, 7)=="MEA-BO_" then
		RepairBlock()
		local selects = #BlockSelection
		if selects > 0 then
			local owner = string.sub(name, 8)
			for i = 0, selects-1 do
				local blockIndex = GetBlockSelection(i)
				SetBlockOwner(blockIndex, BlockOwner[owner])
			end
			MakeUndoLevel()
		end
	elseif name == "MEA-BS_FlipNormal" then
		RepairBlock()
		local selects = #BlockSelection
		if selects > 0 then
			for i = 0, selects-1 do
				local blockIndex = GetBlockSelection(i)
				FlipBlockNormals(GetBlockSelection(i))
			end
			MakeUndoLevel()
		end
	elseif name == "MEA-BS_MirrorHorizontal" then
		RepairBlock()
		local selects = #BlockSelection
		if selects > 0 then
			for i = 0, selects-1 do
				local blockIndex = GetBlockSelection(i)
				MirrorHorizontal(blockIndex, GetBlockBBC(blockIndex))
			end
			MakeUndoLevel()
		end
	elseif name == "MEA-BS_MirrorVertical" then
		RepairBlock()
		local selects = #BlockSelection
		if selects > 0 then
			for i = 0, selects-1 do
				local blockIndex = GetBlockSelection(i)
				MirrorVertical(blockIndex, GetBlockBBC(blockIndex))
			end
			MakeUndoLevel()
		end
	elseif name == "MEA-BS_Delete" then
		RepairBlock()
		local selects = #BlockSelection
		if selects > 0 and doubleClick then
			local blocks = {}
			for i = 0, selects-1 do
				blocks[#blocks+1] = GetBlockSelection(i)
			end
			table.sort(blocks)
			for i = #blocks, 1, -1 do
				DeleteBlock(blocks[i])
			end
		end
	-- MEA-SO-$Owner$
	elseif string.sub(name, 1, 7)=="MEA-SO_" then
		if StructureSelection then
			local owner = string.sub(name, 8)
			ConvertStructure(StructureSelection, StructureNodeAtIndex(StructureSelection, 0), GetStructureTeam(StructureSelection), StructureOwner[owner])
			MakeUndoLevel()
		end
	elseif name == "MEA-SE_CollectInformation" then
		if StructureSelection then LogStructureData(StructureSelection) end
	elseif name == "MEA-SS_Delete" then
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
	end
end

local ctrlState = false
function OnKey(key, down)
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
end
function Load(gameStart)
	GameMode = GetGameMode()
	if GameMode ~= "Editor" then
		Log("Error: Map Editor Assistance: Editor mode expected. Please don't load this mod in other modes.")
	else
		Log("Map Editor Assistance: Thanks for your use. Hope this mod will help your map edit.")
		Log("See the original Repos: github.com/0-0000-Forts-Dev/MapEditorAssistance")
		Log("Ctrl+M: Get some information about the structure which the selected node belongs to.")
		Log("Ctrl+N: Clear all isolated nodes.")
		if dlc2Var_Active then
			Log("DLC2 is enabled. You can use this mod fluently.")
		else
			Log("Error: DLC2 isn't enabled. You will get weakened features.")
		end
		if Language() == "Chinese" then
			AddStrings(path.."/db/strings_Chinese.lua")
		else
			AddStrings(path.."/db/strings_English.lua")
		end
		LoadControl(path.."/ui/screens/StructureSetting.lua", "root")
		LoadControl(path.."/ui/screens/BlockSetting.lua", "root")
		ShowControl("root", "MEA-BlockSetting", false)
		ShowControl("root", "MEA-StructureSetting", false)
		BlockSettingEnabled = false
		StructureSettingEnabled = false
	end
end

-- The only workable event. Update and OnUpdate won't work in Editor
function OnDraw()
	if GameMode ~= "Editor" then return end
	UpdateBlockSelection()
	UpdateStructureSelection()
end
