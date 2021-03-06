local _, Oken = ...
local Cooldowns = Oken:GetModule("Cooldowns")

local SPEC_DISCIPLINE = 256
local SPEC_HOLY = 257
local SPEC_SHADOW = 258

local function GuardianAngel(unit) return unit:HasTalentSpell(200209) and 120 or 0 end

Cooldowns:RegisterSpells("PRIEST", {
	-- Discipline
	[62618] = { -- Power Word: Barrier
		cooldown = 180,
		duration = 10,
		spec = SPEC_DISCIPLINE
	},
	[33206] = { -- Pain Suppression
		cooldown = function(unit) return 240 end,
		duration = 8,
		spec = SPEC_DISCIPLINE
	},
	[47536] = { -- Rapture
		cooldown = 120,
		duration = 8,
		spec = SPEC_DISCIPLINE
	},

	-- Holy
	[64843] = { -- Divine Hymn
		cooldown = 180,
		duration = 7,
		spec = SPEC_HOLY
	},
	[47788] = { -- Guardian Spirit
		cooldown = 240,
		duration = 10,
		spec = SPEC_HOLY
		-- Talent reduces CD by 50% if no proc
	},

	-- Shadow
	[15286] = { -- Vampiric Embrace
		cooldown = 180,
		duration = 15,
		spec = SPEC_SHADOW
	},
	[47585] = { -- Dispersion
		cooldown = function(unit) return 120 - FromTheShadows(unit) end,
		duration = 6,
		spec = SPEC_SHADOW
	},
	[15487] = { -- Silence
		cooldown = 45,
		duration = 3,
		spec = SPEC_SHADOW
	},

	-- Shared
	[73325] = { -- Leap of Faith
		cooldown = 90,
		spec = { SPEC_DISCIPLINE, SPEC_HOLY }
	},
	[32375] = { -- Mass Dispell
		cooldown = 15
	},

	-- Talents
	[200183] = { -- Apotheosis
		cooldown = 180,
		duration = 30,
		talent = true
	},
	[10060] = { -- Power Infusion
		cooldown = 120,
		duration = 20,
		talent = true
	},
	[64901] = { -- Symbol of Hope
		cooldown = 360,
		duration = 10,
		talent = true
	},
	[205369] = { -- Mind Bomb
		cooldown = 30,
		duration = 4,
		talent = true
	},
})
