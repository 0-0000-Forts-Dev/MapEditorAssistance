-- Copyright (c) [0-0000]. Licensed under MIT.
-- Please do not remove this notice.
-- 请勿删除上述版权声明

-- MEA Support for Block

local min, max = math.min, math.max

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
		ShowControl("root", "MEA-BlockSetting", true)
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

-- Bounding Box Center
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

RegisterEvent("OnDraw", function()
	if GameMode == "Editor" then
		UpdateBlockSelection()
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
