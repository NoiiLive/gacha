-- @ScriptType: ModuleScript
local TeamTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitDatabase = require(ReplicatedStorage:WaitForChild("UnitDatabase"))

local selectedUnitUUID = nil
local currentMainTeam = {nil, nil, nil, nil}
local currentBackupUnit = nil
local rosterDataCache = {}

function TeamTab.Create(playerGui, mainGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeamGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "BackgroundFrame"
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	backgroundFrame.Parent = screenGui

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
	topBar.Parent = backgroundFrame

	local backButton = Instance.new("TextButton")
	backButton.Name = "BackButton"
	backButton.Size = UDim2.new(0, 100, 1, 0)
	backButton.Text = "Back"
	backButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
	backButton.TextColor3 = Color3.new(1, 1, 1)
	backButton.Parent = topBar

	local saveButton = Instance.new("TextButton")
	saveButton.Name = "SaveButton"
	saveButton.Size = UDim2.new(0, 150, 1, 0)
	saveButton.Position = UDim2.new(1, -150, 0, 0)
	saveButton.Text = "Save Team"
	saveButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
	saveButton.TextColor3 = Color3.new(1, 1, 1)
	saveButton.Parent = topBar

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -50)
	contentFrame.Position = UDim2.new(0, 0, 0, 50)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = backgroundFrame

	local rosterList = Instance.new("ScrollingFrame")
	rosterList.Name = "RosterList"
	rosterList.Size = UDim2.new(0.3, 0, 1, 0)
	rosterList.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	rosterList.CanvasSize = UDim2.new(0, 0, 0, 0)
	rosterList.Parent = contentFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = rosterList

	local teamArea = Instance.new("Frame")
	teamArea.Name = "TeamArea"
	teamArea.Size = UDim2.new(0.7, 0, 1, 0)
	teamArea.Position = UDim2.new(0.3, 0, 0, 0)
	teamArea.BackgroundTransparency = 1
	teamArea.Parent = contentFrame

	local mainLabel = Instance.new("TextLabel")
	mainLabel.Size = UDim2.new(1, 0, 0, 50)
	mainLabel.Position = UDim2.new(0, 0, 0.1, 0)
	mainLabel.Text = "Main Team (Up to 4)"
	mainLabel.TextSize = 25
	mainLabel.TextColor3 = Color3.new(1, 1, 1)
	mainLabel.BackgroundTransparency = 1
	mainLabel.Parent = teamArea

	local mainSlotsFrame = Instance.new("Frame")
	mainSlotsFrame.Name = "MainSlotsFrame"
	mainSlotsFrame.Size = UDim2.new(1, 0, 0, 150)
	mainSlotsFrame.Position = UDim2.new(0, 0, 0.2, 0)
	mainSlotsFrame.BackgroundTransparency = 1
	mainSlotsFrame.Parent = teamArea

	local mainLayout = Instance.new("UIListLayout")
	mainLayout.FillDirection = Enum.FillDirection.Horizontal
	mainLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	mainLayout.Padding = UDim.new(0, 20)
	mainLayout.Parent = mainSlotsFrame

	for i = 1, 4 do
		local slotBtn = Instance.new("TextButton")
		slotBtn.Name = "MainSlot_" .. i
		slotBtn.Size = UDim2.new(0, 120, 0, 150)
		slotBtn.Text = "Empty"
		slotBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
		slotBtn.TextColor3 = Color3.new(1, 1, 1)
		slotBtn.TextWrapped = true
		slotBtn.Parent = mainSlotsFrame

		slotBtn.MouseButton1Click:Connect(function()
			if selectedUnitUUID then
				TeamTab.AssignUnitToSlot("Main", i, selectedUnitUUID, teamArea)
			else
				TeamTab.AssignUnitToSlot("Main", i, nil, teamArea)
			end
		end)
	end

	local backupLabel = Instance.new("TextLabel")
	backupLabel.Size = UDim2.new(1, 0, 0, 50)
	backupLabel.Position = UDim2.new(0, 0, 0.5, 0)
	backupLabel.Text = "Backup Unit"
	backupLabel.TextSize = 25
	backupLabel.TextColor3 = Color3.new(1, 1, 1)
	backupLabel.BackgroundTransparency = 1
	backupLabel.Parent = teamArea

	local backupSlot = Instance.new("TextButton")
	backupSlot.Name = "BackupSlot"
	backupSlot.Size = UDim2.new(0, 120, 0, 150)
	backupSlot.Position = UDim2.new(0.5, -60, 0.6, 0)
	backupSlot.Text = "Empty"
	backupSlot.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	backupSlot.TextColor3 = Color3.new(1, 1, 1)
	backupSlot.TextWrapped = true
	backupSlot.Parent = teamArea

	backupSlot.MouseButton1Click:Connect(function()
		if selectedUnitUUID then
			TeamTab.AssignUnitToSlot("Backup", 1, selectedUnitUUID, teamArea)
		else
			TeamTab.AssignUnitToSlot("Backup", 1, nil, teamArea)
		end
	end)

	local instructionLabel = Instance.new("TextLabel")
	instructionLabel.Size = UDim2.new(1, 0, 0, 50)
	instructionLabel.Position = UDim2.new(0, 0, 0.9, 0)
	instructionLabel.Text = "Select a unit from the left, then click a slot to assign. Click an occupied slot to clear."
	instructionLabel.TextSize = 18
	instructionLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	instructionLabel.BackgroundTransparency = 1
	instructionLabel.Parent = teamArea

	backButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
		mainGui.Enabled = true
	end)

	saveButton.MouseButton1Click:Connect(function()
		local success = ReplicatedStorage.UpdateTeam:InvokeServer(currentMainTeam, currentBackupUnit)
		if success then
			saveButton.Text = "Saved!"
			saveButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
			task.wait(1)
			saveButton.Text = "Save Team"
			saveButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
		end
	end)

	return screenGui
end

function TeamTab.AssignUnitToSlot(slotType, index, uuid, teamArea)
	if uuid then
		for i = 1, 4 do
			if currentMainTeam[i] == uuid then currentMainTeam[i] = nil end
		end
		if currentBackupUnit == uuid then currentBackupUnit = nil end
	end

	if slotType == "Main" then
		currentMainTeam[index] = uuid
	elseif slotType == "Backup" then
		currentBackupUnit = uuid
	end

	TeamTab.UpdateSlotVisuals(teamArea)
end

function TeamTab.UpdateSlotVisuals(teamArea)
	local mainSlotsFrame = teamArea:FindFirstChild("MainSlotsFrame")
	local backupSlot = teamArea:FindFirstChild("BackupSlot")

	local function formatSlotText(uuid)
		if not uuid then return "Empty" end
		local inst = rosterDataCache[uuid]
		if not inst then return "Unknown" end
		local base = UnitDatabase.GetUnitData(inst.UnitID)
		if not base then return "Unknown" end
		return base.Name .. "\nLv." .. inst.Level
	end

	if mainSlotsFrame then
		for i = 1, 4 do
			local btn = mainSlotsFrame:FindFirstChild("MainSlot_" .. i)
			if btn then
				btn.Text = formatSlotText(currentMainTeam[i])
				if currentMainTeam[i] then
					btn.BackgroundColor3 = Color3.new(0.3, 0.4, 0.6)
				else
					btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
				end
			end
		end
	end

	if backupSlot then
		backupSlot.Text = formatSlotText(currentBackupUnit)
		if currentBackupUnit then
			backupSlot.BackgroundColor3 = Color3.new(0.6, 0.4, 0.3)
		else
			backupSlot.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
		end
	end
end

function TeamTab.Refresh(gui)
	local requestActiveDataEvent = ReplicatedStorage:WaitForChild("RequestActiveData")
	local activeData = requestActiveDataEvent:InvokeServer()

	selectedUnitUUID = nil
	rosterDataCache = {}

	if activeData and activeData.Team then
		currentMainTeam = {
			activeData.Team.Main[1],
			activeData.Team.Main[2],
			activeData.Team.Main[3],
			activeData.Team.Main[4]
		}
		currentBackupUnit = activeData.Team.Backup
	end

	local backgroundFrame = gui:FindFirstChild("BackgroundFrame")
	if not backgroundFrame then return end

	local contentFrame = backgroundFrame:FindFirstChild("ContentFrame")
	if not contentFrame then return end

	local rosterList = contentFrame:FindFirstChild("RosterList")
	local teamArea = contentFrame:FindFirstChild("TeamArea")

	if not rosterList or not teamArea then return end

	for _, child in ipairs(rosterList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	if activeData and activeData.Units then
		local yOffset = 0
		local indexOrder = 1

		for _, unitInstance in ipairs(activeData.Units) do
			rosterDataCache[unitInstance.UUID] = unitInstance
			local baseData = UnitDatabase.GetUnitData(unitInstance.UnitID)
			if baseData then
				local unitBtn = Instance.new("TextButton")
				unitBtn.Name = unitInstance.UUID
				unitBtn.LayoutOrder = indexOrder
				unitBtn.Size = UDim2.new(1, 0, 0, 50)
				unitBtn.Text = "[" .. baseData.Title .. "] " .. baseData.Name .. " (Lv." .. unitInstance.Level .. ")"
				unitBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
				unitBtn.TextColor3 = Color3.new(1, 1, 1)
				unitBtn.Parent = rosterList

				unitBtn.MouseButton1Click:Connect(function()
					for _, sibling in ipairs(rosterList:GetChildren()) do
						if sibling:IsA("TextButton") then
							sibling.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
						end
					end

					if selectedUnitUUID == unitInstance.UUID then
						selectedUnitUUID = nil
						unitBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
					else
						selectedUnitUUID = unitInstance.UUID
						unitBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.2)
					end
				end)

				yOffset = yOffset + 50
				indexOrder = indexOrder + 1
			end
		end
		rosterList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	end

	TeamTab.UpdateSlotVisuals(teamArea)
end

return TeamTab