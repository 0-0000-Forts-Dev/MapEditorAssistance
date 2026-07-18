-- Copyright (c) [0-0000]. Licensed under MIT.
-- Please do not remove this notice.
-- 请勿删除上述版权声明

-- MEA Support for Block

local min, max, pi, sin, cos, arcsin, arccos =
math.min, math.max, math.pi, math.sin, math.cos, math.asin, math.acos
local function GetMouseRadFrom(base, mindist, defaultRad)
	local target
	if ShiftState then target = ScreenToWorld(GetMousePos())
	else target = ProcessedMousePos() end
	local diff = target-base
	if Vec3Length(diff)<mindist then return defaultRad
	else return math.atan2(diff.y, diff.x) end
end

local BlockFlags = {
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
local BlockOwner = {
	Background = -2,
	Any = -1,
	None = 0,
	Team1 = 1,
	Team2 = 2,
}

local BlockSelection = {
	-- [i] = blockIndex,
	-- When only one block is selected: Whether the block has made an 'undo' and won't create new vertexs for further clicks
	-- Can be true only when #it = 1
	still = false,
}
local BlockSettingEnabled = false
local BlockNewlyCreated = false

local RotateMinDistance = 5
local RotateLineLength = 500000
-- The target block's id which you are trying to rotate it
local RotateTarget = nil
local RotateCentre = nil
-- Rotate Centre Effect
local RCEffectId1, RCEffectId2 = nil, nil
-- Rotate Line Effect(1: base, 2: new preview)
local RLEffectId1, RLEffectId2 = nil, nil
local RotateBaseRad, RotateOriginRad = nil, nil
-- previous Block Count
local preBC = -1
local function UpdateBlockSelection()
	local selects = GetBlockSelectionCount()

	-- Detect newly created block
	local blockcnt = GetBlockCount()
	if BlockNewlyCreated then
		if selects ~= 1 or GetBlockSelection(0) ~= BlockSelection[1] then
			BlockNewlyCreated = false
		end
	elseif blockcnt == preBC+1 and selects == 1 and GetBlockSelection(0)==preBC then
		BlockNewlyCreated = true
	end
	preBC = blockcnt

	-- Keep it true exactly when the selection has no changes
	if not(BlockSelection.still and selects == 1 and GetBlockSelection(0) == BlockSelection[1]) then
		BlockSelection.still = false
	end
	for i = 1, #BlockSelection do BlockSelection[i] = nil end
	for i = 1, selects do BlockSelection[i] = GetBlockSelection(i-1) end
	-- Note the display state won't be applied until further key inputs
	if not BlockSettingEnabled and selects > 0 then
		if not RotateTarget then
			ShowControl("root", "MEA-BlockSetting", true)
		end
		BlockSettingEnabled = true
	elseif BlockSettingEnabled and selects == 0 then
		ShowControl("root", "MEA-BlockSetting", false)
		BlockSettingEnabled = false
	end
end

local function RepairBlock()
	-- If the user create new vertex in advance. This operation won't work appropriately.
	if #BlockSelection == 1 and not BlockSelection.still then
		-- This delete operation will block further vertex creation by mouse clicking.
		if BlockNewlyCreated then
			DeleteBlockVertex(GetBlockSelection(0), GetBlockVertexCount(GetBlockSelection(0))-1)
		else
			DeleteBlockVertex(GetBlockSelection(0), 1)
		end
		BlockSelection.still = true
		UpdateGroundTriangles()
	end
end

-- Bounding Box Centre
local function GetBlockBBC(blockIndex)
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

local function ExitRotation()
	RotateTarget = nil
	RotateCentre = nil
	if RCEffectId1 then CancelEffect(RCEffectId1) end
	if RCEffectId2 then CancelEffect(RCEffectId2) end
	RCEffectId1, RCEffectId2 = nil, nil
	if RLEffectId1 then CancelEffect(RLEffectId1) end
	if RLEffectId2 then CancelEffect(RLEffectId2) end
	RLEffectId1, RLEffectId2 = nil, nil
	RotateBaseRad, RotateOriginRad = nil, nil
	if BlockSettingEnabled then
		ShowControl("root", "MEA-BlockSetting", true)
	end
end

RegisterEvent("OnDraw", function()
	if not RotateTarget then
		if GameMode == "Editor" then UpdateBlockSelection() end
	else
		-- rotate contre preview
		if not RotateCentre then
			local rcpos
			if ShiftState then
				rcpos = ScreenToWorld(GetMousePos())
			else
				rcpos = ProcessedMousePos()
			end
			rcpos.z = -101
			if RCEffectId1 then CancelEffect(RCEffectId1) end
			if RCEffectId2 then CancelEffect(RCEffectId2) end
			RCEffectId1 = SpawnCircle(rcpos, RotateMinDistance, Colour(255,64,64,255), 1)
			RCEffectId2 = SpawnCircle(rcpos, 100, Colour(255,64,64,160), 1)
		-- rotate lines preview
		else
			local previewRad = GetMouseRadFrom(RotateCentre, RotateMinDistance, 0)
			-- preview the base line
			if RLEffectId1 then CancelEffect(RLEffectId1) end
			local rad = RotateOriginRad or previewRad
			local target = RotateCentre + Vec3(cos(rad)*RotateLineLength, sin(rad)*RotateLineLength, 0)
			target.z = -101 -- draw over terrains: z<=-100
			local rcpos = Vec3(RotateCentre.x,RotateCentre.y,-101)
			RLEffectId1 = SpawnLine(rcpos, target, Colour(255,255,255,255), 1)
			-- preview the target line
			if RotateBaseRad then
				if RLEffectId2 then CancelEffect(RLEffectId2) end
				rad = previewRad
				target = RotateCentre + Vec3(cos(rad)*RotateLineLength, sin(rad)*RotateLineLength, 0)
				target.z = -101 -- draw over terrains: z<=-100
				RLEffectId2 = SpawnLine(rcpos, target, Colour(0,0,0,255), 1)
			end
		end
	end
end)
RegisterEvent("OnKey", function(key, down)
	if not RotateTarget then return end
	if key=="mouse left" and not down then RepairBlock() end
	-- right click to escape
	if key=="mouse right" and down then
		ExitRotation()
		return
	end
	-- determine the rotate centre
	if not RotateCentre then
		-- by mouse's position, but trigger by (Shift+)Enter
		if key=="enter" and down then
			-- Shift will cancel snap
			-- Note that if your mouse clicking position is snap to a vertex of the target block:
			-- The vertex will be selected and be moved to mouse position for further mouse click
			-- So this should be avoided: enter instead
			if ShiftState then
				RotateCentre = ScreenToWorld(GetMousePos())
			else
				RotateCentre = ProcessedMousePos()
			end
		-- for the reasons above. Left click: exit rotation
		elseif key=="mouse left" and down then
			ExitRotation()
		-- Ctrl+Enter: use default: bounding box centre
		elseif key=="enter" and down and CtrlState then
			RotateCentre = GetBlockBBC(RotateTarget)
		end
		-- create a circle effect marking the centre's position
		if RotateCentre then
			RotateBaseRad, RotateOriginRad = nil, nil
			local rcpos = Vec3(RotateCentre.x,RotateCentre.y,-101)
			if RCEffectId1 then CancelEffect(RCEffectId1) end
			if RCEffectId2 then CancelEffect(RCEffectId2) end
			RCEffectId1 = SpawnCircle(rcpos, RotateMinDistance, Colour(255,64,64,255), 1)
			RCEffectId2 = SpawnCircle(rcpos, 100, Colour(255,64,64,160), 1)
		end
	-- determine the rotate base line
	elseif not RotateBaseRad then
		-- use default: x+ direction
		if key=="enter" and down then
			RotateBaseRad = 0
			RotateOriginRad = RotateBaseRad
		elseif key=="mouse left" and down then
			RotateBaseRad = GetMouseRadFrom(RotateCentre, RotateMinDistance, 0)
			RotateOriginRad = RotateBaseRad
		end
	-- apply block rotation
	else
		-- exit rotation
		if key=="enter" and down then
			ExitRotation()
		-- apply rotation
		elseif key=="mouse left" and down then
			local targetRad = GetMouseRadFrom(RotateCentre, RotateMinDistance, 0)
			local cnt = GetBlockVertexCount(RotateTarget)
			for i=0, cnt-1 do
				local diff = GetBlockVertexPos(RotateTarget, i)-RotateCentre
				local rad = targetRad - RotateBaseRad
				local curr = RotateCentre + Vec3(diff.x*cos(rad)-diff.y*sin(rad),diff.x*sin(rad)+diff.y*cos(rad),0)
				SetBlockVertexPos(RotateTarget, i, curr)
			end
			UpdateGroundTriangles()
			-- automaticly made because of mouse clicking
			-- MakeUndoLevel()
			RotateBaseRad = targetRad
		end
	end
end)

-- MEA-BF_$FLAG$-$T/F$
RegisterControlHandler("MEA-BF_", function(name)
	-- shift state: mouse click won't create new block vertex
	if not ShiftState then RepairBlock() end
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
end, true)

-- Block Owner Background Warning
local BOBW = false
-- MEA-BO_$Owner$
RegisterControlHandler("MEA-BO_", function(name)
	if not ShiftState then RepairBlock() end
	local selects = #BlockSelection
	if selects > 0 then
		local owner = string.sub(name, 8)
		for i = 0, selects-1 do
			local blockIndex = GetBlockSelection(i)
			local powner = GetBlockOwner(blockIndex)
			if not BOBW and powner == BlockOwner["Background"] or owner == "Background" then
				Notice([[MEA: You change block's owner to or from "background": could be a [HL=ff7f7fff]wrong operation inconsistent with that by Editor shorcuts[/HL](1-5).]])
				BOBW = true
			end
			SetBlockOwner(blockIndex, BlockOwner[owner])
		end
		MakeUndoLevel()
	end
end, true)

RegisterControlHandler("MEA-BS_FlipNormal", function()
	if not ShiftState then RepairBlock() end
	local selects = #BlockSelection
	if selects > 0 then
		for i = 0, selects-1 do
			local blockIndex = GetBlockSelection(i)
			FlipBlockNormals(GetBlockSelection(i))
		end
		MakeUndoLevel()
	end
end)

RegisterControlHandler("MEA-BS_MirrorHorizontal", function()
	if not ShiftState then RepairBlock() end
	local selects = #BlockSelection
	if selects > 0 then
		for i = 0, selects-1 do
			local blockIndex = GetBlockSelection(i)
			MirrorHorizontal(blockIndex, GetBlockBBC(blockIndex))
		end
		MakeUndoLevel()
	end
end)

RegisterControlHandler("MEA-BS_MirrorVertical", function()
	if not ShiftState then RepairBlock() end
	local selects = #BlockSelection
	if selects > 0 then
		for i = 0, selects-1 do
			local blockIndex = GetBlockSelection(i)
			MirrorVertical(blockIndex, GetBlockBBC(blockIndex))
		end
		MakeUndoLevel()
	end
end)

RegisterControlHandler("MEA-BS_Delete", function(name, doubleClick)
	if not ShiftState then RepairBlock() end
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
end)

RegisterControlHandler("MEA-BS_Rotate", function(name, doubleClick)
	if not ShiftState then RepairBlock() end
	-- Only one block
	if #BlockSelection == 1 and doubleClick then
		RotateTarget = BlockSelection[1]
		ShowControl("root", "MEA-BlockSetting", false)
	end
end)
