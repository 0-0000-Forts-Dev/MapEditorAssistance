-- Copyright (c) [0-0000]. Licensed under MIT.
-- Please do not remove this notice.
-- 请勿删除上述版权声明

-- MEA Support for Block

local min, max, pi, sin, cos, arcsin, arccos =
math.min, math.max, math.pi, math.sin, math.cos, math.asin, math.acos

local OverTerrainZ = -101 -- draw over terrains: z<=-100

-- Get the bounding box centre of a block
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

-- Get the math rad of a vector from positon `base` to mouse's world position
-- midist: if the distance between the two position is smaller than it, return defaultRad
local function GetMouseRadFrom(base, mindist, defaultRad)
	local target
	if ShiftState then target = ScreenToWorld(GetMousePos())
	else target = ProcessedMousePos() end
	local diff = target-base
	if Vec3Length(diff)<mindist then return defaultRad
	else return math.atan2(diff.y, diff.x) end
end

-- Rotate a block based on the `initial` table
-- initial[i] should be the initial Vec3 position of the i-th vertex of the block
-- Empty block isn't allowed
local function RotateBlock(blockIndex, initial, centre, rad)
	for i=0, #initial do
		local diff = initial[i]-centre
		local curr = centre + Vec3(diff.x*cos(rad)-diff.y*sin(rad),diff.x*sin(rad)+diff.y*cos(rad),0)
		SetBlockVertexPos(blockIndex, i, curr)
	end
	UpdateGroundTriangles()
	-- automaticly made at the right time because of mouse clicking
	-- MakeUndoLevel()
end
--[[
local function RotateBlock(blockIndex, centre, rad)
	local cnt = GetBlockVertexCount(blockIndex)
	for i=0, cnt-1 do
		local diff = GetBlockVertexPos(blockIndex, i)-centre
		local curr = centre + Vec3(diff.x*cos(rad)-diff.y*sin(rad),diff.x*sin(rad)+diff.y*cos(rad),0)
		SetBlockVertexPos(blockIndex, i, curr)
	end
	UpdateGroundTriangles()
	-- automaticly made because of mouse clicking
	-- MakeUndoLevel()
end
--]]


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

-- Rotate Constants&Variables
local RB_MinDistance = 5
local RB_LineLength = 500000
-- The target block's id which you are trying to rotate it
local RB_Block = nil
-- The block's vertexs' initial postion table
local RB_Initial = {}
local RB_Centre = nil
-- Rotation centre effect
local RB_CEffect1, RB_CEffect2 = nil, nil
-- Rotation line effect(1: base, 2: preview)
local RB_LEffect1, RB_LEffect2 = nil, nil
-- Rotation base line's math rad and currect rad after actual rotation
local RB_BaseRad, RB_CurrRad = nil, nil


-- Block Selection & Block Repair
local BlockSelection = {
	-- [i] = blockIndex,
	-- When only one block is selected: Whether the block has made an 'undo' and won't create new vertexs for further clicks
	-- Can be true only when #it = 1
	still = false,
}
local BlockSettingEnabled = false
local BlockNewlyCreated = false
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
		if not RB_Block then
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

local function EnterRotation()
	RB_Block = BlockSelection[1]
	ShowControl("root", "MEA-BlockSetting", false)
	local cnt = GetBlockVertexCount(RB_Block)
	for i=0, cnt-1 do
		RB_Initial[i] = GetBlockVertexPos(RB_Block, i)
	end
end
local function ExitRotation()
	-- cancel block rotation preview
	if RB_CurrRad then
		RotateBlock(RB_Block, RB_Initial, RB_Centre, RB_CurrRad - RB_BaseRad)
	end
	RB_Block = nil
	RB_Centre = nil
	if RB_CEffect1 then CancelEffect(RB_CEffect1) end
	if RB_CEffect2 then CancelEffect(RB_CEffect2) end
	RB_CEffect1, RB_CEffect2 = nil, nil
	if RB_LEffect1 then CancelEffect(RB_LEffect1) end
	if RB_LEffect2 then CancelEffect(RB_LEffect2) end
	RB_LEffect1, RB_LEffect2 = nil, nil
	RB_BaseRad, RB_CurrRad = nil, nil
	if BlockSettingEnabled then
		ShowControl("root", "MEA-BlockSetting", true)
	end
	for k in pairs(RB_Initial) do
	    RB_Initial[k] = nil
	end
end

RegisterEvent("OnDraw", function()
	if not RB_Block then
		if GameMode == "Editor" then UpdateBlockSelection() end
	else
		-- rotatation centre preview
		if not RB_Centre then
			local rcpos
			if ShiftState then
				rcpos = ScreenToWorld(GetMousePos())
			else
				rcpos = ProcessedMousePos()
			end
			rcpos.z = OverTerrainZ
			if RB_CEffect1 then CancelEffect(RB_CEffect1) end
			if RB_CEffect2 then CancelEffect(RB_CEffect2) end
			RB_CEffect1 = SpawnCircle(rcpos, RB_MinDistance, Colour(255,64,64,255), 1)
			RB_CEffect2 = SpawnCircle(rcpos, 100, Colour(255,64,64,160), 1)
		-- rotatation lines preview
		else
			local previewRad = GetMouseRadFrom(RB_Centre, RB_MinDistance, 0)
			-- preview the base line
			local rad = RB_BaseRad or previewRad
			local target = RB_Centre + Vec3(cos(rad)*RB_LineLength, sin(rad)*RB_LineLength, 0)
			target.z = OverTerrainZ
			local rcpos = Vec3(RB_Centre.x,RB_Centre.y,OverTerrainZ)
			if RB_LEffect1 then CancelEffect(RB_LEffect1) end
			RB_LEffect1 = SpawnLine(rcpos, target, Colour(255,255,255,255), 1)
			-- preview the target line
			if RB_BaseRad then
				rad = previewRad
				target = RB_Centre + Vec3(cos(rad)*RB_LineLength, sin(rad)*RB_LineLength, 0)
				target.z = OverTerrainZ
				if RB_LEffect2 then CancelEffect(RB_LEffect2) end
				RB_LEffect2 = SpawnLine(rcpos, target, Colour(0,0,0,255), 1)
				-- rotation preview
				if CtrlState then
					local targetRad = GetMouseRadFrom(RB_Centre, RB_MinDistance, 0)
					RotateBlock(RB_Block, RB_Initial, RB_Centre, targetRad-RB_BaseRad)
				end
			end
		end
	end
end)
RegisterEvent("OnKey", function(key, down)
	if not RB_Block then return end
	if key=="mouse left" and not down then RepairBlock() end
	-- right click to escape
	if key=="mouse right" and down then
		ExitRotation()
		return
	end
	-- determine the rotate centre
	if not RB_Centre then
		-- by mouse's position, but trigger by Enter
		if key=="enter" and down and not CtrlState then
			-- Alt+Enter: use default: bounding box centre
			if AltState then
				RB_Centre = GetBlockBBC(RB_Block)
			else
				-- Shift will cancel snap
				-- If your mouse clicking position is snap to a vertex of the target block:
				-- The vertex will be selected and be moved to mouse position for further mouse click
				-- So this should be avoided: enter instead
				if ShiftState then
					RB_Centre = ScreenToWorld(GetMousePos())
				else
					RB_Centre = ProcessedMousePos()
				end
			end
		-- for the reasons above. Left click: exit rotation
		elseif key=="mouse left" and down then
			ExitRotation()
		end
		-- create a circle effect marking the centre's position
		if RB_Centre then
			local rcpos = Vec3(RB_Centre.x,RB_Centre.y,OverTerrainZ)
			if RB_CEffect1 then CancelEffect(RB_CEffect1) end
			if RB_CEffect2 then CancelEffect(RB_CEffect2) end
			RB_CEffect1 = SpawnCircle(rcpos, RB_MinDistance, Colour(255,64,64,255), 1)
			RB_CEffect2 = SpawnCircle(rcpos, 100, Colour(255,64,64,160), 1)
		end
	-- determine the rotate base line
	elseif not RB_BaseRad then
		-- use default: x+ direction
		if key=="enter" and down then
			RB_BaseRad = 0
			RB_CurrRad = RB_BaseRad
		elseif key=="mouse left" and down then
			RB_BaseRad = GetMouseRadFrom(RB_Centre, RB_MinDistance, 0)
			RB_CurrRad = RB_BaseRad
		end
	-- apply block rotation
	else
		-- exit rotation
		if key=="enter" and down then
			ExitRotation()
		-- apply rotation
		elseif key=="mouse left" and down then
			local targetRad = GetMouseRadFrom(RB_Centre, RB_MinDistance, 0)
			RotateBlock(RB_Block, RB_Initial, RB_Centre, targetRad - RB_BaseRad)
			RB_CurrRad = targetRad
		-- cancel block rotation preview
		elseif key=="left control" and not down then
			RotateBlock(RB_Block, RB_Initial, RB_Centre, RB_CurrRad - RB_BaseRad)
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

-- Block Rotation Tip
local BSRT = false
RegisterControlHandler("MEA-BS_Rotate", function(name, doubleClick)
	if not ShiftState then RepairBlock() end
	-- Only one block
	if not BSRT then
		Notice([[MEA: You are trying to rotate a block. Please refer to the [HL=7fff7fff]README[/HL] file of this mod for its usage.]])
		BSRT = true
	end
	if #BlockSelection == 1 then
		EnterRotation()
	end
end)
