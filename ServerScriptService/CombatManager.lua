-- @ScriptType: ModuleScript
local CombatManager = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local UnitDatabase = require(ReplicatedStorage:WaitForChild("UnitDatabase"))
local PlayerDataManager = require(script.Parent:WaitForChild("PlayerDataManager"))

local getBattleStateEvent = Instance.new("RemoteFunction")
getBattleStateEvent.Name = "GetBattleState"
getBattleStateEvent.Parent = ReplicatedStorage

local leaveBattleEvent = Instance.new("RemoteFunction")
leaveBattleEvent.Name = "LeaveBattle"
leaveBattleEvent.Parent = ReplicatedStorage

local activeBattles = {}

function CombatManager.Initialize()
	getBattleStateEvent.OnServerInvoke = function(player)
		return CombatManager.GetBattleState(player)
	end

	leaveBattleEvent.OnServerInvoke = function(player)
		return CombatManager.LeaveBattle(player)
	end
end

function CombatManager.StartBattle(player, playerTeamIds, enemies, sceneName)
	local serverData = PlayerDataManager.GetActiveVirtualData(player)
	if not serverData then return false end

	local pTeam = {}
	for _, uuid in ipairs(playerTeamIds) do
		if uuid then
			for _, unit in ipairs(serverData.Units) do
				if unit.UUID == uuid then
					local baseData = UnitDatabase.GetUnitData(unit.UnitID)
					table.insert(pTeam, {
						UUID = uuid,
						UnitID = unit.UnitID,
						Level = unit.Level,
						MaxHP = baseData.BaseStats.HP + (unit.Level * 10),
						CurrentHP = baseData.BaseStats.HP + (unit.Level * 10)
					})
					break
				end
			end
		end
	end

	local arenaName = "Arena_" .. player.UserId
	local existingArena = Workspace:FindFirstChild(arenaName)
	if existingArena then existingArena:Destroy() end

	local battleScenes = ServerStorage:FindFirstChild("BattleScenes")
	local templateScene = nil

	if battleScenes then
		if sceneName and battleScenes:FindFirstChild(sceneName) then
			templateScene = battleScenes:FindFirstChild(sceneName)
		else
			local scenes = battleScenes:GetChildren()
			if #scenes > 0 then
				templateScene = scenes[math.random(1, #scenes)]
			end
		end
	end

	local arenaFolder = Instance.new("Folder")
	arenaFolder.Name = arenaName
	arenaFolder.Parent = Workspace

	local arenaOffset = Vector3.new(0, 1000 + (player.UserId % 1000) * 200, 0)
	local playerSpawns = {}
	local enemySpawns = {}
	local camPos = arenaOffset + Vector3.new(0, 40, -50)
	local focusPart = nil

	if templateScene then
		local clonedScene = templateScene:Clone()
		clonedScene.Parent = arenaFolder
		if clonedScene.PrimaryPart then
			clonedScene:PivotTo(CFrame.new(arenaOffset))
			focusPart = clonedScene.PrimaryPart
		else
			focusPart = clonedScene:FindFirstChildWhichIsA("BasePart", true)
		end

		local pFolder = clonedScene:FindFirstChild("PlayerSpawns")
		if pFolder then
			for i = 1, 4 do
				local sp = pFolder:FindFirstChild("Spawn_" .. i)
				if sp then table.insert(playerSpawns, sp.Position) end
			end
		end

		local eFolder = clonedScene:FindFirstChild("EnemySpawns")
		if eFolder then
			for i = 1, 4 do
				local sp = eFolder:FindFirstChild("Spawn_" .. i)
				if sp then table.insert(enemySpawns, sp.Position) end
			end
		end

		local camPart = clonedScene:FindFirstChild("CameraPos")
		if camPart then
			camPos = camPart.Position
		end
	else
		local arenaBase = Instance.new("Part")
		arenaBase.Name = "ArenaBase"
		arenaBase.Size = Vector3.new(100, 1, 100)
		arenaBase.Position = arenaOffset
		arenaBase.Anchored = true
		arenaBase.BrickColor = BrickColor.new("Dark stone grey")
		arenaBase.Parent = arenaFolder

		focusPart = arenaBase

		for i = 1, 4 do
			table.insert(playerSpawns, arenaBase.Position + Vector3.new(-15 + (i * 6), 3, -10))
			table.insert(enemySpawns, arenaBase.Position + Vector3.new(-15 + (i * 6), 3, 10))
		end
	end

	local unitModelsFolder = ServerStorage:FindFirstChild("UnitModels")

	local function spawnUnit(unitData, spawns, index, prefix, fallbackColor, lookVector)
		local spawnPos = spawns[index] or (arenaOffset + Vector3.new(-15 + (index * 6), 3, lookVector.Z * -10))
		spawnPos = spawnPos + Vector3.new(0, 3, 0)

		local model
		if unitModelsFolder and unitModelsFolder:FindFirstChild(unitData.UnitID) then
			model = unitModelsFolder:FindFirstChild(unitData.UnitID):Clone()
			model.Name = prefix .. "_" .. unitData.UUID
			model.Parent = arenaFolder
			if model:IsA("Model") and model.PrimaryPart then
				model:PivotTo(CFrame.new(spawnPos, spawnPos + lookVector))
			elseif model:IsA("Model") then
				model:MoveTo(spawnPos)
			else
				model.CFrame = CFrame.new(spawnPos, spawnPos + lookVector)
			end
		else
			model = Instance.new("Part")
			model.Name = prefix .. "_" .. unitData.UUID
			model.Size = Vector3.new(4, 5, 4)
			model.CFrame = CFrame.new(spawnPos, spawnPos + lookVector)
			model.Anchored = true
			model.BrickColor = BrickColor.new(fallbackColor)
			model.Parent = arenaFolder
		end

		local baseData = UnitDatabase.GetUnitData(unitData.UnitID)
		if baseData then
			local bgui = Instance.new("BillboardGui")
			bgui.Name = "StatsUI"
			bgui.Size = UDim2.new(6, 0, 2, 0)
			bgui.StudsOffset = Vector3.new(0, 5, 0)
			bgui.AlwaysOnTop = true

			if model:IsA("Model") and model.PrimaryPart then
				bgui.Adornee = model.PrimaryPart
			elseif model:IsA("BasePart") then
				bgui.Adornee = model
			else
				bgui.Adornee = model:FindFirstChildWhichIsA("BasePart", true)
			end

			bgui.Parent = model

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Name = "NameLabel"
			nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = baseData.Name
			nameLabel.TextColor3 = Color3.new(1, 1, 1)
			nameLabel.TextStrokeTransparency = 0
			nameLabel.TextScaled = true
			nameLabel.Parent = bgui

			local hpBarBg = Instance.new("Frame")
			hpBarBg.Name = "HPBarBg"
			hpBarBg.Size = UDim2.new(0.9, 0, 0.3, 0)
			hpBarBg.Position = UDim2.new(0.05, 0, 0.6, 0)
			hpBarBg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
			hpBarBg.BorderSizePixel = 0
			hpBarBg.Parent = bgui

			local hpFill = Instance.new("Frame")
			hpFill.Name = "HPFill"
			local hpPercent = math.clamp(unitData.CurrentHP / unitData.MaxHP, 0, 1)
			hpFill.Size = UDim2.new(hpPercent, 0, 1, 0)
			hpFill.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
			hpFill.BorderSizePixel = 0
			hpFill.Parent = hpBarBg

			local hpLabel = Instance.new("TextLabel")
			hpLabel.Name = "HPLabel"
			hpLabel.Size = UDim2.new(1, 0, 1, 0)
			hpLabel.BackgroundTransparency = 1
			hpLabel.Text = math.floor(unitData.CurrentHP) .. " / " .. math.floor(unitData.MaxHP)
			hpLabel.TextColor3 = Color3.new(1, 1, 1)
			hpLabel.TextStrokeTransparency = 0
			hpLabel.TextScaled = true
			hpLabel.Parent = hpBarBg
		end

		return model
	end

	for i, pUnit in ipairs(pTeam) do
		spawnUnit(pUnit, playerSpawns, i, "PlayerUnit", "Bright blue", Vector3.new(0, 0, 1))
	end

	for i, eUnit in ipairs(enemies) do
		spawnUnit(eUnit, enemySpawns, i, "EnemyUnit", "Bright red", Vector3.new(0, 0, -1))
	end

	player.ReplicationFocus = focusPart

	activeBattles[player.UserId] = {
		Turn = 1,
		PlayerTeam = pTeam,
		EnemyTeam = enemies,
		State = "PlayerTurn",
		Hand = {},
		ArenaPosition = arenaOffset,
		CameraPosition = camPos
	}

	return true
end

function CombatManager.GetBattleState(player)
	return activeBattles[player.UserId]
end

function CombatManager.LeaveBattle(player)
	local arenaName = "Arena_" .. player.UserId
	local existingArena = Workspace:FindFirstChild(arenaName)

	if existingArena then 
		existingArena:Destroy() 
	end

	player.ReplicationFocus = nil
	activeBattles[player.UserId] = nil

	return true
end

return CombatManager