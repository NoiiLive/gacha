-- @ScriptType: ModuleScript
-- ReplicatedStorage/GameConstants.lua
local GameConstants = {}

GameConstants.Rarities = {
	Base = {"R", "SR", "SSR", "SP"},
	Level = {"R", "SR", "SSR", "UR", "LR", "MR"}
}

GameConstants.Factions = {
	Orderly = "Orderly",
	Friendly = "Friendly",
	Hostile = "Hostile",
	Outcast = "Outcast"
}

GameConstants.Elements = {
	Basic = {"Strength", "Skill", "Speed"},
	Special = {"Psyche", "Wit"}
}

GameConstants.ElementAdvantages = {
	Strength = "Skill",
	Skill = "Speed",
	Speed = "Strength",
	Psyche = "Wit",
	Wit = "Psyche"
}

GameConstants.Classes = {
	Balance = "Balance",
	DPS = "DPS",
	Burst = "Burst",
	Control = "Control",
	Support = "Support"
}

GameConstants.Grades = {
	"D", "D+", "C-", "C", "C+", "B-", "B", "B+", 
	"A-", "A", "A+", "S-", "S", "S+", "SS", "SSS"
}

GameConstants.BaseStats = {
	ATK = 0,
	DEF = 0,
	HP = 0,
	CRIT_Rate = 0,
	CRIT_DMG = 0,
	CRIT_Resist = 0,
	CRIT_DEF = 0,
	Block_Chance = 0,
	PEN_Rate = 0,
	Lifesteal = 0
}

return GameConstants