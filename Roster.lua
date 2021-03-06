local _, Oken = ...
local Roster = Oken:RegisterModule("Roster", "AceTimer-3.0")

local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")

-------------------------------------------------------------------------------
-- Roster config
--------------------------------------------------------------------------------

local roster_config = {
	title = {
		type = "description",
		name = "|cff64b4ffRoster tracker",
		fontSize = "large",
		order = 0
	},
	desc = {
		type = "description",
		name = "Tracks spec and talents from allied units.\n",
		fontSize = "medium",
		order = 1
	},
	ref = {
		type = "header",
		name = "Module reference",
		order = 1000
	},
	docs = Oken.Config:MakeDoc("Public API", 2000, {
		{":Iterate ( sorted , limit ) -> [ unit ]", "Returns an iterator over the group members.\nIf sorted is given and you are in a raid group, units are sorted by role."},
		{":GetUnit ( guid ) -> unit", "Returns the unitid for a given GUID, if known."},
		{":GetInfo ( guid ) -> InfoTable", "Returns talents and glyphs information for a player. See LibGroupInSpec_T for more information."}
	}, "Oken.Roster"),
	events = Oken.Config:MakeDoc("Emitted events", 3000, {
		{"_JOINED ( guid , unit )", "Emitted when a new unit has joined the group."},
		{"_UPDATE ( guid , unit , info )", "Emitted when talents info are updated for a unit."},
		{"_LEFT ( guid )", "Emitted when a unit has left the group."},
	}, "OKEN_ROSTER")
}

--------------------------------------------------------------------------------

function Roster:OnInitialize()
	Oken.Config:Register("Roster tracker", roster_config)

	self.group = {}
	self.infos = {}
	self.legendaries = {}

	LGIST.RegisterCallback(self, "GroupInSpecT_Update", "RosterUpdate")
	LGIST.RegisterCallback(self, "GroupInSpecT_Remove", "RosterRemove")

	self:RegisterMessage("OKEN_MSG_ROSTER_BROADCAST")
	self:RegisterMessage("OKEN_MSG_ROSTER_REQUEST", "ScheduleBroadcast")

	self:RegisterEvent("GROUP_ROSTER_UPDATE", "ScheduleBroadcast")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "ScheduleLegendariesRebuild")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ScheduleLegendariesRebuild")
end

function Roster:OnEnable()
end

function Roster:OnDisable()
end

--------------------------------------------------------------------------------

function Roster:PLAYER_ENTERING_WORLD()
	if IsInGroup() then
		Oken:Send("ROSTER_REQUEST", true)
	end
	self:ScheduleLegendariesRebuild()
end

--------------------------------------------------------------------------------

do
	local function broadcast()
		if IsInGroup() then
			local guid = UnitGUID("player")
			Oken:Send("ROSTER_BROADCAST", { guid, Roster.legendaries[guid] })
		end
	end

	local pending = false
	local last_update = 0

	function Roster:ScheduleBroadcast()
		if not pending then
			pending = true
			local delta = GetTime() - last_update
			C_Timer.After((delta < 30) and 30 or 5, function()
				broadcast()
				pending = false
				last_update = GetTime()
			end)
		end
	end

	function Roster:OKEN_MSG_ROSTER_BROADCAST(_, data)
		local guid = data[1]
		local legendaries = data[2]

		if guid == UnitGUID("player") then return end

		Roster.legendaries[guid] = legendaries
		Roster:SendMessage("OKEN_ROSTER_UPDATE", guid, Roster:GetUnit(guid), Roster:GetInfo(guid))
	end
end

--------------------------------------------------------------------------------

do
	local role_order = {
		["tank"] = 1,
		["melee"] = 3,
		["damager"] = 5,
		["ranged"] = 7,
		["healer"] = 9,
	}

	local function solo_iterator()
		local done = false
		return function()
			if not done then
				done = true
				return "player", 1
			end
		end
	end

	local function party_iterator()
		local i = -1
		return function()
			i = i + 1
			if i < GetNumGroupMembers() then
				return i == 0 and "player" or ("party" .. i), i + 1
			end
		end
	end

	local function raid_iterator(limit, sorted, overrides)
		local order

		if type(limit) ~= "number" then
			limit = 40
		end

		if sorted then
			order = {}
			local roles = {}
			local indices = {}

			for unit, idx in Roster:Iterate(limit) do
				table.insert(order, unit)
				local info = Roster:GetInfo(UnitGUID(unit))
				roles[unit] = info and (info.spec_role_detailed or info.spec_role) or UnitGroupRolesAssigned(unit):lower()
				indices[unit] = idx
			end

			table.sort(order, function(a, b)
				if roles[a] ~= roles[b] then
					local a_order = (overrides and overrides[roles[a]]) or role_order[roles[a]]
					local b_order = (overrides and overrides[roles[b]]) or role_order[roles[b]]
					return a_order < b_order
				else
					return indices[a] < indices[b]
				end
			end)
		end

		local i = 0
		return function()
			i = i + 1
			local unit

			if i > limit or i > GetNumGroupMembers() then
				return
			elseif order then
				unit = order[i]
			else
				unit = "raid" .. i
			end

			return unit, i
		end
	end

	function Roster:Iterate(limit, sorted, overrides)
		if not IsInGroup() then
			return solo_iterator()
		elseif not IsInRaid() then
			return party_iterator()
		else
			return raid_iterator(limit, sorted, overrides)
		end
	end
end



--------------------------------------------------------------------------------

function Roster:GetUnit(guid)
	if UnitExists(guid) then
		return guid
	end
	local unit = LGIST:GuidToUnit(guid)
	if unit then return unit end
	for unit in self:Iterate() do
		if UnitGUID(unit) == guid then
			return unit
		end
	end
end

function Roster:GetInfo(guid)
	local info = self.infos[guid]
	if not info then return end
	info.legendaries = self.legendaries[guid]
	return info
end

--------------------------------------------------------------------------------

do
	local function rebuild()
		local guid = UnitGUID("player")

		local data = {}
		for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
			local item = GetInventoryItemID("player", slot)
			if item then
				local _, _, quality = GetItemInfo(item)
				if quality == 5 then
					data[item] = true
				end
			end
		end

		Roster.legendaries[guid] = data
		Roster:SendMessage("OKEN_ROSTER_UPDATE", guid, "player", Roster:GetInfo(guid))
		Roster:ScheduleBroadcast()
		Roster:SendMessage("OKEN_ROSTER_LEGENDARIES_REBUILT")
	end

	local rebuild_pending = false

	function Roster:ScheduleLegendariesRebuild()
		if not rebuild_pending then
			rebuild_pending = true
			C_Timer.After(1, function()
				rebuild()
				rebuild_pending = false
			end)
		end
	end
end

--------------------------------------------------------------------------------

function Roster:RosterUpdate(_, guid, unit, info)
	if not self.group[guid] then
		self:SendMessage("OKEN_ROSTER_JOINED", guid, unit)
		self.group[guid] = true
	end
	self.infos[guid] = info
	self:SendMessage("OKEN_ROSTER_UPDATE", guid, unit, self:GetInfo(guid))
end

function Roster:RosterRemove(_, guid)
	self.group[guid] = nil
	self.infos[guid] = nil
	self:SendMessage("OKEN_ROSTER_LEFT", guid)
end
