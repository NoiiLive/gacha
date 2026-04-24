-- @ScriptType: ModuleScript
local CampaignManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))
local CombatManager = require(script.Parent:WaitForChild("CombatManager"))

local startCampaignEvent = Instance.new("RemoteFunction")
startCampaignEvent.Name = "StartCampaignBattle"
startCampaignEvent.Parent = ReplicatedStorage

function CampaignManager.Initialize()
	startCampaignEvent.OnServerInvoke = function(player)
		return CampaignManager.StartBattle(player)
	end
end

function CampaignManager.StartBattle(player)
	local serverData = PlayerDataManager.GetActiveVirtualData(player)
	if not serverData then return false end

	if not serverData.Team or not serverData.Team.Main then return false end

	local hasValidUnit = false
	for _, uuid in ipairs(serverData.Team.Main) do
		if uuid then 
			hasValidUnit = true 
			break 
		end
	end

	if not hasValidUnit then return false end

	local currentStage = serverData.CampaignStage or 1

	local enemies = {}
	for i = 1, 3 do
		table.insert(enemies, {
			UUID = "ENEMY_" .. i .. "_" .. currentStage,
			UnitID = "U006",
			Level = currentStage,
			MaxHP = 500 + (currentStage * 50),
			CurrentHP = 500 + (currentStage * 50)
		})
	end

	return CombatManager.StartBattle(player, serverData.Team.Main, enemies)
end

return CampaignManager