-- @ScriptType: ModuleScript
local TeamManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))

local updateTeamEvent = Instance.new("RemoteFunction")
updateTeamEvent.Name = "UpdateTeam"
updateTeamEvent.Parent = ReplicatedStorage

function TeamManager.Initialize()
	updateTeamEvent.OnServerInvoke = function(player, mainTeam, backupUnit)
		return TeamManager.UpdatePlayerTeam(player, mainTeam, backupUnit)
	end
end

function TeamManager.UpdatePlayerTeam(player, mainTeam, backupUnit)
	local serverData = PlayerDataManager.GetActiveVirtualData(player)
	if not serverData then return false end

	local function ownsUnit(uuid)
		if not uuid then return true end
		for _, unit in ipairs(serverData.Units) do
			if unit.UUID == uuid then return true end
		end
		return false
	end

	for i = 1, 4 do
		if not ownsUnit(mainTeam[i]) then return false end
	end

	if not ownsUnit(backupUnit) then return false end

	serverData.Team.Main = mainTeam
	serverData.Team.Backup = backupUnit

	return true
end

return TeamManager