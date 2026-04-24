-- @ScriptType: Script
local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
local TeamManager = require(script.Parent:WaitForChild("TeamManager"))
local CampaignManager = require(script.Parent:WaitForChild("CampaignManager"))
local CombatManager = require(script.Parent:WaitForChild("CombatManager"))

PlayerDataManager.Initialize()
TeamManager.Initialize()
CampaignManager.Initialize()
CombatManager.Initialize()