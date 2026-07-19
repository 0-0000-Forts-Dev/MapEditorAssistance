-- Copyright (c) [0-0000]. Licensed under MIT.
-- Please do not remove this notice.
-- 请勿删除上述版权声明
dofile("scripts/forts.lua")
function RegisterEvent(name, func)
	local pre = _G[name]
	if pre then
		_G[name] = function(...)
			pre(...)
			func(...)
		end
	else
		_G[name] = func
	end
end

local ControlHandlers = {
	--[[
	-- this name is regared as the captured control's full name
	[name] = function(name, doubleClick) end,
	]]
}
local ControlHandlers_pfx = {
	--[[
	-- this name is regared as the prefix of the captured control's full name
	[name] = function(name, doubleClick) end,
	]]
}
-- This registration function follows the principle of overriding
function RegisterControlHandler(name, callback, isprefix)
	if isprefix then ControlHandlers_pfx[name] = callback
	else ControlHandlers[name] = callback end
end
function OnControlActivated(name, code, doubleClick)
	local callback = ControlHandlers[name]
	if callback then pcall(callback, name, doubleClick) end
	for prefix, callback in pairs(ControlHandlers_pfx) do
		if string.sub(name,1,#prefix)==prefix then
			pcall(callback, name, doubleClick)
		end
	end
end

CtrlState = false
ShiftState = false
AltState = false
function OnKey(key, down)
	if down then
		if key == "left control" then
			CtrlState = true
		elseif key == "left shift" then
			ShiftState = true
		elseif key == "left alt" then
			AltState = true
		end
	else
		if key == "left control" then
			CtrlState = false
		elseif key == "left shift" then
			ShiftState = false
		elseif key == "left alt" then
			AltState = false
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
-- function OnDraw() end

dofile(path.."/scripts/structure.lua")
dofile(path.."/scripts/block.lua")
