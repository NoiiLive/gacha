-- @ScriptType: ModuleScript
local PlayerDataManager = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local UnitDatabase = require(ReplicatedStorage:WaitForChild("UnitDatabase"))
local GameConstants = require(ReplicatedStorage:WaitForChild("GameConstants"))

local SaveDataStore = DataStoreService:GetDataStore("GachaSaveData_V1")

local globalPlayerData = {}
local virtualServerData = {}

local joinEvent = Instance.new("RemoteEvent")
joinEvent.Name = "JoinVirtualServer"
joinEvent.Parent = ReplicatedStorage

local requestServersEvent = Instance.new("RemoteFunction")
requestServersEvent.Name = "RequestVirtualServers"
requestServersEvent.Parent = ReplicatedStorage

local requestActiveDataEvent = Instance.new("RemoteFunction")
requestActiveDataEvent.Name = "RequestActiveData"
requestActiveDataEvent.Parent = ReplicatedStorage

local starUpEvent = Instance.new("RemoteFunction")
starUpEvent.Name = "StarUpUnit"
starUpEvent.Parent = ReplicatedStorage

local gradeUpEvent = Instance.new("RemoteFunction")
gradeUpEvent.Name = "GradeUpUnit"
gradeUpEvent.Parent = ReplicatedStorage

local giveTestUnitEvent = Instance.new("RemoteEvent")
giveTestUnitEvent.Name = "GiveTestUnit"
giveTestUnitEvent.Parent = ReplicatedStorage

local summonEvent = Instance.new("RemoteFunction")
summonEvent.Name = "SummonUnits"
summonEvent.Parent = ReplicatedStorage

function PlayerDataManager.Initialize()
	Players.PlayerAdded:Connect(function(player)
		PlayerDataManager.LoadGlobalData(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		PlayerDataManager.SaveAllData(player)
	end)

	joinEvent.OnServerEvent:Connect(function(player, serverId)
		PlayerDataManager.LoadVirtualServer(player, serverId)
	end)

	requestServersEvent.OnServerInvoke = function(player)
		return PlayerDataManager.GetGlobalData(player)
	end

	requestActiveDataEvent.OnServerInvoke = function(player)
		return PlayerDataManager.GetActiveVirtualData(player)
	end

	starUpEvent.OnServerInvoke = function(player, unitUUID)
		return PlayerDataManager.StarUpUnit(player, unitUUID)
	end

	gradeUpEvent.OnServerInvoke = function(player, unitUUID)
		return PlayerDataManager.GradeUpUnit(player, unitUUID)
	end

	summonEvent.OnServerInvoke = function(player, bannerType, amount)
		return PlayerDataManager.HandleSummon(player, bannerType, amount)
	end

	giveTestUnitEvent.OnServerEvent:Connect(function(player, unitId)
		PlayerDataManager.AddUnit(player, unitId)
	end)
end

function PlayerDataManager.LoadGlobalData(player)
	local success, data = pcall(function()
		return SaveDataStore:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		globalPlayerData[player.UserId] = data.Global or {
			LastServer = "P001",
			ServersJoined = {}
		}
		virtualServerData[player.UserId] = data.Servers or {}
	else
		globalPlayerData[player.UserId] = {
			LastServer = "P001",
			ServersJoined = {}
		}
		virtualServerData[player.UserId] = {}
	end
end

function PlayerDataManager.LoadVirtualServer(player, serverId)
	if serverId == "T001" and not RunService:IsStudio() then
		return
	end

	if not virtualServerData[player.UserId][serverId] then
		local defaultUnitUUID = HttpService:GenerateGUID(false)

		virtualServerData[player.UserId][serverId] = {
			CampaignStage = 1,
			SummonTickets = 0,
			EventSummonTickets = 0,
			CarnivalTickets = 0,
			Inventory = {
				UnitCopies = {}
			},
			Units = {
				{
					UUID = defaultUnitUUID,
					UnitID = "U001",
					Level = 1,
					Stars = 0,
					Grade = "D",
					Charms = {Attack = nil, Defense = nil, Health = nil},
					Equipment = {Unlocked = false, Tier = 0, Level = 1},
					Potentials = {},
					Tactics = {nil, nil, nil}
				}
			},
			Team = {
				Main = {defaultUnitUUID, nil, nil, nil},
				Backup = nil
			}
		}

		if serverId == "T001" then
			virtualServerData[player.UserId][serverId].SummonTickets = 999
			virtualServerData[player.UserId][serverId].EventSummonTickets = 999
			virtualServerData[player.UserId][serverId].CarnivalTickets = 999
		end
	end

	local globalData = globalPlayerData[player.UserId]

	if serverId ~= "T001" then
		local found = false

		for _, v in ipairs(globalData.ServersJoined) do
			if v == serverId then
				found = true
				break
			end
		end

		if not found then
			table.insert(globalData.ServersJoined, serverId)
		end

		globalData.LastServer = serverId
	end

	globalData.CurrentActiveServer = serverId
end

function PlayerDataManager.AddUnit(player, unitId)
	local serverData = PlayerDataManager.GetActiveVirtualData(player)
	if not serverData then return nil end

	local unitBaseData = UnitDatabase.GetUnitData(unitId)
	if not unitBaseData then return nil end

	if not serverData.Inventory then
		serverData.Inventory = {UnitCopies = {}}
	end

	local hasUnit = false
	for _, existingUnit in ipairs(serverData.Units) do
		if existingUnit.UnitID == unitId then
			hasUnit = true
			break
		end
	end

	if hasUnit then
		serverData.Inventory.UnitCopies[unitId] = (serverData.Inventory.UnitCopies[unitId] or 0) + 1
		return {UnitID = unitId, IsCopy = true}
	end

	local newUnitInstance = {
		UUID = HttpService:GenerateGUID(false),
		UnitID = unitId,
		Level = 1,
		Stars = 0,
		Grade = "D",
		Charms = {Attack = nil, Defense = nil, Health = nil},
		Equipment = {Unlocked = false, Tier = 0, Level = 1},
		Potentials = {},
		Tactics = {nil, nil, nil}
	}

	table.insert(serverData.Units, newUnitInstance)
	return {UnitID = unitId, IsCopy = false, Instance = newUnitInstance}
end

function PlayerDataManager.HandleSummon(player, bannerType, amount)
	local serverData = PlayerDataManager.GetActiveVirtualData(player)
	if not serverData then return nil end

	local ticketKey = "SummonTickets"
	if bannerType == "Event" then
		ticketKey = "EventSummonTickets"
	elseif bannerType == "Carnival" then
		ticketKey = "CarnivalTickets"
	end

	if (serverData[ticketKey] or 0) < amount then
		return nil
	end

	serverData[ticketKey] = serverData[ticketKey] - amount

	local SummonManager = require(script.Parent:WaitForChild("SummonManager"))
	local pulledUnitIds = SummonManager.PerformSummon(bannerType, amount)

	local finalResults = {}
	for _, unitId in ipairs(pulledUnitIds) do
		local addResult = PlayerDataManager.AddUnit(player, unitId)
		if addResult then
			table.insert(finalResults, addResult)
		end
	end

	return finalResults
end

function PlayerDataManager.StarUpUnit(player, unitUUID)
	local serverData = PlayerDataManager.GetActiveVirtualData(player)
	if not serverData then return false end

	local targetUnit = nil
	for _, unit in ipairs(serverData.Units) do
		if unit.UUID == unitUUID then
			targetUnit = unit
			break
		end
	end

	if not targetUnit then return false end
	if targetUnit.Stars >= 6 then return false end
	if not serverData.Inventory or not serverData.Inventory.UnitCopies then return false end

	local copies = serverData.Inventory.UnitCopies[targetUnit.UnitID] or 0
	if copies > 0 then
		serverData.Inventory.UnitCopies[targetUnit.UnitID] = copies - 1
		targetUnit.Stars = targetUnit.Stars + 1
		return true
	end

	return false
end

function PlayerDataManager.GradeUpUnit(player, unitUUID)
	local serverData = PlayerDataManager.GetActiveVirtualData(player)
	if not serverData then return false end

	local targetUnit = nil
	for _, unit in ipairs(serverData.Units) do
		if unit.UUID == unitUUID then
			targetUnit = unit
			break
		end
	end

	if not targetUnit then return false end

	local baseData = UnitDatabase.GetUnitData(targetUnit.UnitID)
	if not baseData then return false end

	if targetUnit.Stars < 6 then return false end
	if baseData.BaseRarity ~= "SSR" and baseData.BaseRarity ~= "SP" then return false end
	if not serverData.Inventory or not serverData.Inventory.UnitCopies then return false end

	local currentGrade = targetUnit.Grade
	if currentGrade == "Base" then currentGrade = "D" end

	local gradeIndex = table.find(GameConstants.Grades, currentGrade) or 1
	if gradeIndex >= #GameConstants.Grades then return false end

	local copies = serverData.Inventory.UnitCopies[targetUnit.UnitID] or 0
	if copies > 0 then
		serverData.Inventory.UnitCopies[targetUnit.UnitID] = copies - 1
		targetUnit.Grade = GameConstants.Grades[gradeIndex + 1]
		return true
	end

	return false
end

function PlayerDataManager.SaveAllData(player)
	local globalData = globalPlayerData[player.UserId]
	local serverData = virtualServerData[player.UserId]

	if globalData and serverData then
		if serverData["T001"] then
			serverData["T001"] = nil
		end

		local dataToSave = {
			Global = globalData,
			Servers = serverData
		}

		local success, err = pcall(function()
			SaveDataStore:SetAsync(tostring(player.UserId), dataToSave)
		end)

		if not success then
			warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
		end
	end

	globalPlayerData[player.UserId] = nil
	virtualServerData[player.UserId] = nil
end

function PlayerDataManager.GetGlobalData(player)
	return globalPlayerData[player.UserId]
end

function PlayerDataManager.GetActiveVirtualData(player)
	local globalData = globalPlayerData[player.UserId]
	if globalData and globalData.CurrentActiveServer then
		return virtualServerData[player.UserId][globalData.CurrentActiveServer]
	end
	return nil
end

return PlayerDataManager