-------------------------------------------------------------------------------
-- ElvUI Improved Spec Switch Datatext By Lockslap
-- Backport 3.3.5a By Zidras
-------------------------------------------------------------------------------
local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts")
local L = LibStub("AceLocale-3.0"):GetLocale("ElvUI_ISS", false)
local EP = LibStub("LibElvUIPlugin-1.0")

--Lua functions
local _G = _G
local format, join = string.format, string.join

--WoW API / Variables
local GetNumEquipmentSets = GetNumEquipmentSets
local GetEquipmentSetInfo = GetEquipmentSetInfo
local GetActiveTalentGroup = GetActiveTalentGroup
local GetTalentTabInfo = GetTalentTabInfo
local UseEquipmentSet = UseEquipmentSet
local GetNumTalentGroups = GetNumTalentGroups
local SetActiveTalentGroup = SetActiveTalentGroup
local ToggleTalentFrame = ToggleTalentFrame
local lastPanel, active, activeSet
local displayString, noSpecString = ""
local activeString = ("|cff00ff00%s|r"):format("Active") -- ACTIVE_PETS doesn't exist and didn't find an "Active" global
local inactiveString = ("|cffff0000%s|r"):format(_G.FACTION_INACTIVE)

local function ColorizeSettingName(name)
	return format("|cff1784d1%s|r", name)
end

local function AddTexture(texture)
	texture = texture and "|T"..texture..":16:16:0:0:50:50:4:46:4:46|t" or ""
	return texture
end

local function GetCurrentEquipmentSet()
	if GetNumEquipmentSets() == 0 then return false end
	for i = 1, GetNumEquipmentSets() do
		local name, _, _, isEquipped, _, _, _, _, _ = GetEquipmentSetInfo(i)
		if isEquipped then
			return name
		end
	end
	return false
end

local function OnEvent(self, event)
	lastPanel = self

	--[[if not GetTalentTabInfo(1) then return end
	active = GetActiveTalentGroup()
	activeSet = GetCurrentEquipmentSet()
	if GetActiveTalentGroup(false, false, active) then
		self.text:SetText(select(2, GetTalentTabInfo(GetActiveTalentGroup(false, false, active))))
	end]]

	local specIndex = GetActiveTalentGroup()
	if not specIndex then
		self.text:SetFormattedText(noSpecString, L["No Specialization"])
		return
	end	
	
	active = specIndex
	activeSet = GetCurrentEquipmentSet()

	--[[local talent = ''
	if GetActiveTalentGroup(false, false, active) then
		talent = format('|T%s:14:14:0:0:64:64:4:60:4:60|t', select(4, GetTalentTabInfo(GetActiveTalentGroup(false, false, active))))
		--_, specName, talent = E:GetTalentSpecInfo()
	end]]

	local _, specName, talent = E:GetTalentSpecInfo()
	talent = format("|T%s:24:24:0:0:64:64:4:60:4:60|t", talent)
	self.text:SetText(format("%s: %s", L["Spec"], specName))
	
	-- determine if we need to change the equipment set

	if self.clicked and E.db.impss.switch and GetNumEquipmentSets() > 0 then
		local set = active == 1 and E.db.impss.primary or E.db.impss.secondary	-- the set that should be equipped
		if set ~= "none" and set ~= activeSet then
			UseEquipmentSet(set)
		end
		self.clicked = not self.clicked
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	for i = 1, _G.MAX_TALENT_TABS do
		local _, specName, talent = E:GetTalentSpecInfo()
		local name, icon = GetTalentTabInfo(i)
			DT.tooltip:AddLine(join(" ", AddTexture(icon), format(displayString, name), (specName == name and activeString or inactiveString)), 1, 1, 1)
			--DT.tooltip:AddDoubleLine(displayString:format(icon, name), (specName == name and activeString or inactiveString), 1, 1, 1)
	end
	

	--[[if GetActiveTalentGroup(false, false, i) then
			local _, name, _, icon, _, _ = GetTalentTabInfo(GetActiveTalentGroup(false, false, i))
			DT.tooltip:AddDoubleLine(displayString:format(icon, name), i == active and activeString or inactiveString, 1, 1, 1)
		end
	end]]

	if E.db.impss.hint == true then
		DT.tooltip:AddLine(" ")
		DT.tooltip:AddDoubleLine(L["Left Click"], L["Change Specialization"], 1, 1, 1, 1, 1, 0)
		DT.tooltip:AddDoubleLine(L["Right Click"], L["Toggle Talents Frame"], 1, 1, 1, 1, 1, 0)
	end
	DT.tooltip:Show()	
end

local function OnClick(self, button)
	local specIndex = GetActiveTalentGroup()
	if not specIndex then return end
	
	if button == "LeftButton" then
		SetActiveTalentGroup(active == 1 and 2 or 1)
		self.clicked = true
	else
		ToggleTalentFrame()
	end
end

local function ValueColorUpdate(hex)
	--displayString = join("", "|T%s:22:22:1:0|t |cffffffff%s:|r")
	displayString = join("", "|cffFFFFFF%s:|r ")
	noSpecString = join("", hex, "%s|r")
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

P["impss"] = {
	["switch"] = false,
	["primary"] = "none",
	["secondary"] = "none",
	["hint"] = true,
}

local function InsertOptions()
	--[[if not E.Options.args.lockslap then
		E.Options.args.lockslap = {
			type = "group",
			order = -2,
			name = L["Plugins by |cff9382c9Lockslap|r"],
			args = {
				thanks = {
					type = "description",
					order = 1,
					name = L["Thanks for using and supporting my work!  -- |cff9382c9Lockslap|r\n\n|cffff0000If you find any bugs, or have any suggestions for any of my addons, please open a ticket at that particular addon's page on CurseForge."],
				},
			},
		}
	elseif not E.Options.args.lockslap.args.thanks then
		E.Options.args.lockslap.args.thanks = {
			type = "description",
			order = 1,
			name = L["Thanks for using and supporting my work!  -- |cff9382c9Lockslap|r\n\n|cffff0000If you find any bugs, or have any suggestions for any of my addons, please open a ticket at that particular addon's page on CurseForge."],
		}
	end]]
	
	E.Options.args.plugins.args.ISS = {
		type = "group",
		name = L["Improved Spec Switch"],
		disabled = function() return GetNumEquipmentSets() == 0 end,
		get = function(info) return E.db.impss[info[#info]] end,
		set = function(info, value) E.db.impss[info[#info]] = value end,
		args = {
			switch = {
				type = "toggle",
				order = 1,
				name = L["Swap Equipment Sets"],
				desc = L["Change equipment sets when you change your spec."],
				disabled = function()
					if not GetActiveTalentGroup(false, false, 1) or not GetActiveTalentGroup(false, false, 2) then 
						return true
					else
						return false
					end
				end,
			},
			primary = {
				type = "select",
				order = 2,
				name = GetActiveTalentGroup(false, false, 1) and select(2, GetTalentTabInfo(GetActiveTalentGroup(false, false, 1))) or L["Primary Talents"],
				desc = L["Choose the equipment set to use for your primary spec."],
				disabled = function() return not E.db.impss.switch end,
				values = function()
					local sets = {
						["none"] = L["No Change"],
					}
					for i = 1, GetNumEquipmentSets() do
						local name, _, _, _, _, _, _, _, _ = GetEquipmentSetInfo(i)
						if name then
							sets[name] = name
						end
					end
					sort(sets, function(a, b) return a < b end)
					return sets
				end,
			},
			secondary = {
				type = "select",
				order = 3,
				name = GetActiveTalentGroup(false, false, 2) and select(2, GetTalentTabInfo(GetActiveTalentGroup(false, false, 2))) or L["Secondary Talents"],
				desc = L["Choose the equipment set to use for your secondary spec."],
				disabled = function() return not E.db.impss.switch end,
				values = function()
					local sets = {
						["none"] = L["No Change"],
					}
					for i = 1, GetNumEquipmentSets() do
						local name, _, _, _, _, _, _, _, _ = GetEquipmentSetInfo(i)
						if name then
							sets[name] = name
						end
					end
					sort(sets, function(a, b) return a < b end)
					return sets
				end,
			},
			hint = {
				type = "toggle",
				order = 4,
				name = L["Show Hint"],
				desc = L["Show the hint in the tooltip."],
			},
		},
	}
end

EP:RegisterPlugin(..., InsertOptions)
DT:RegisterDatatext(L["Improved Spec Switch"], {"PLAYER_ENTERING_WORLD", "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "ACTIVE_TALENT_GROUP_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, ColorizeSettingName(L["Improved Spec Switch"]))