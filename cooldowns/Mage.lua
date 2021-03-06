local _, Oken = ...
local Cooldowns = Oken:GetModule("Cooldowns")

local SPEC_ARCANE = 62
local SPEC_FIRE = 63
local SPEC_FROST = 64

local function ColdSnap(unit) return unit:HasTalentSpell(11958) and 1 or 0 end

Cooldowns:RegisterSpells("MAGE", {
	[45438] = { -- Ice block
		cooldown = 240,
		duration = 10,
		charges = function(unit) return 1 + ColdSnap(unit) end
	},
	[2139] = { -- Counterspell
		cooldown = 24
	},

	-- Arcane
	[110959] = { -- Greater Invisibility
		cooldown = 120,
		duration = 4,
		spec = SPEC_ARCANE
	},

	-- Fire
	[31661] = { -- Dragon's Breath
		cooldown = 20,
		duration = 4,
		spec = SPEC_FIRE
	},

	-- Talents
	[113724] = { -- Ring of Frost
		cooldown = 45,
		duration = 10,
		talent = true
	},
})
