-- @ScriptType: ModuleScript
local UnitDatabase = {}
local GameConstants = require(script.Parent:WaitForChild("GameConstants"))

UnitDatabase.Units = {
	["U001"] = {
		ID = "U001",
		Name = "Strength Unit",
		Title = "Test",
		BaseRarity = "SSR",
		Banners = {"Standard", "Event", "Carnival"},
		Faction = GameConstants.Factions.Hostile,
		Element = "Strength",
		Class = GameConstants.Classes.DPS,
		BaseStats = {
			ATK = 150,
			DEF = 50,
			HP = 1000,
			CRIT_Rate = 5,
			CRIT_DMG = 50,
			CRIT_Resist = 0,
			CRIT_DEF = 0,
			Block_Chance = 0,
			PEN_Rate = 0,
			Lifesteal = 0
		}
	},
	["U002"] = {
		ID = "U002",
		Name = "Skill Unit",
		Title = "Test",
		BaseRarity = "SR",
		Banners = {"Standard", "Event", "Carnival"},
		Faction = GameConstants.Factions.Friendly,
		Element = "Skill",
		Class = GameConstants.Classes.Support,
		BaseStats = {
			ATK = 80,
			DEF = 100,
			HP = 1200,
			CRIT_Rate = 0,
			CRIT_DMG = 50,
			CRIT_Resist = 10,
			CRIT_DEF = 10,
			Block_Chance = 5,
			PEN_Rate = 0,
			Lifesteal = 0
		}
	},
	["U003"] = {
		ID = "U003",
		Name = "Speed Unit",
		Title = "Test",
		BaseRarity = "SSR",
		Banners = {"Standard", "Event", "Carnival"},
		Faction = GameConstants.Factions.Orderly,
		Element = "Speed",
		Class = GameConstants.Classes.Burst,
		BaseStats = {
			ATK = 180,
			DEF = 40,
			HP = 800,
			CRIT_Rate = 20,
			CRIT_DMG = 80,
			CRIT_Resist = 0,
			CRIT_DEF = 0,
			Block_Chance = 0,
			PEN_Rate = 5,
			Lifesteal = 0
		}
	},
	["U004"] = {
		ID = "U004",
		Name = "Psyche Unit",
		Title = "Test",
		BaseRarity = "SP",
		Banners = {"Carnival"},
		Faction = GameConstants.Factions.Outcast,
		Element = "Psyche",
		Class = GameConstants.Classes.Control,
		BaseStats = {
			ATK = 120,
			DEF = 90,
			HP = 1100,
			CRIT_Rate = 5,
			CRIT_DMG = 50,
			CRIT_Resist = 5,
			CRIT_DEF = 5,
			Block_Chance = 10,
			PEN_Rate = 0,
			Lifesteal = 0
		}
	},
	["U005"] = {
		ID = "U005",
		Name = "Wit Unit",
		Title = "Test",
		BaseRarity = "SP",
		Banners = {"Carnival"},
		Faction = GameConstants.Factions.Orderly,
		Element = "Wit",
		Class = GameConstants.Classes.Balance,
		BaseStats = {
			ATK = 110,
			DEF = 110,
			HP = 1100,
			CRIT_Rate = 10,
			CRIT_DMG = 60,
			CRIT_Resist = 10,
			CRIT_DEF = 10,
			Block_Chance = 5,
			PEN_Rate = 5,
			Lifesteal = 5
		}
	},
	["U006"] = {
		ID = "U006",
		Name = "Basic Grunt",
		Title = "Test",
		BaseRarity = "R",
		Banners = {"Standard", "Event", "Carnival"},
		Faction = GameConstants.Factions.Hostile,
		Element = "Strength",
		Class = GameConstants.Classes.Balance,
		BaseStats = {
			ATK = 40,
			DEF = 30,
			HP = 500,
			CRIT_Rate = 0,
			CRIT_DMG = 50,
			CRIT_Resist = 0,
			CRIT_DEF = 0,
			Block_Chance = 0,
			PEN_Rate = 0,
			Lifesteal = 0
		}
	}
}

function UnitDatabase.GetUnitData(unitId)
	return UnitDatabase.Units[unitId]
end

return UnitDatabase