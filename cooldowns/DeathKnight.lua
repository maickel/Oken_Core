local _, FS = ...
local Cooldowns = FS:GetModule("Cooldowns")

local SPEC_BLOOD = 250
local SPEC_FROST = 251
local SPEC_UNHOLY = 252

Cooldowns:RegisterSpells("DEATHKNIGHT", {
	[51052] = { -- Anti-Magic Zone
		cooldown = 120,
		duration = 3,
		talent = 19219
	},
	[108199] = { -- Gorefiend's Grasp
		cooldown = 60,
		talent = 19230,
		-- TODO Legion: replace by blood specific spell
	},
	[49576] = { -- Death Grip
		cooldown = 25,
		duration = 3
	},
	[47528] = { -- Mind freeze
		cooldown = 15,
		duration = 4
	},
	[48707] = { -- Anti-magic shell
		cooldown = 60,
		duration = 5
	},
	[212552] = { -- Wraith Walk
		cooldown = 60,
		duration = 3
	},

	-- Blood
	[49028] = { -- Dancing Rune Weapon
		cooldown = 180,
		duration = 8,
		spec = SPEC_BLOOD
	},
	[55233] = { -- Vampiric Blood
		cooldown = 90,
		duration = 10,
		spec = SPEC_BLOOD
	},
	--[[ [108199] = { -- Gorefiend's Grasp
		cooldown = 180,
		spec = SPEC_BLOOD
	}, ]]

	-- Frost
	[47568] = { -- Empower Rune Weapon
		cooldown = 180,
		duration = 0,
		spec = SPEC_FROST,
		disabled = true
	},
	[51271] = { -- Pillar of Frost
		cooldown = 60,
		duration = 20,
		spec = SPEC_FROST
	},
	[196770] = { -- Remorseless Winter
		cooldown = 20,
		duration = 8,
		spec = SPEC_FROST
	},

	-- Unholy
	[42650] = { -- Army of the Dead
		cooldown = 600,
		duration = 4,
		spec = SPEC_UNHOLY
	},
	[63560] = { -- Dark Transformation
		cooldown = 60,
		duration = 20,
		spec = SPEC_UNHOLY,
		disabled = true
	},
	[49206] = { -- Summon Gargoyle
		cooldown = 180,
		duration = 40,
		spec = SPEC_UNHOLY,
		disabled = true
	},

	-- Shared
	[43265] = { -- Death and Decay
		cooldown = 30,
		duration = 10,
		spec = { SPEC_BLOOD, SPEC_UNHOLY },
		disabled = true
	},
	[48792] = { -- Icebound Fortitude
		cooldown = 180,
		duration = 8,
		spec = { SPEC_FROST, SPEC_UNHOLY }
	},
})
