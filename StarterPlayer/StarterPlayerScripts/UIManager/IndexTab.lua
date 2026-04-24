-- @ScriptType: ModuleScript
local IndexTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitDatabase = require(ReplicatedStorage:WaitForChild("UnitDatabase"))
local GameConstants = require(ReplicatedStorage:WaitForChild("GameConstants"))

local currentSelectedUnitUUID = nil

function IndexTab.Create(playerGui, mainGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "IndexGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "BackgroundFrame"
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	backgroundFrame.Parent = screenGui

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	topBar.Parent = backgroundFrame

	local backButton = Instance.new("TextButton")
	backButton.Name = "BackButton"
	backButton.Size = UDim2.new(0, 100, 1, 0)
	backButton.Text = "Back"
	backButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
	backButton.TextColor3 = Color3.new(1, 1, 1)
	backButton.Parent = topBar

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -50)
	contentFrame.Position = UDim2.new(0, 0, 0, 50)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = backgroundFrame

	local rosterList = Instance.new("ScrollingFrame")
	rosterList.Name = "RosterList"
	rosterList.Size = UDim2.new(0.3, 0, 1, 0)
	rosterList.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	rosterList.CanvasSize = UDim2.new(0, 0, 0, 0)
	rosterList.Parent = contentFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = rosterList

	local viewArea = Instance.new("Frame")
	viewArea.Name = "ViewArea"
	viewArea.Size = UDim2.new(0.7, 0, 1, 0)
	viewArea.Position = UDim2.new(0.3, 0, 0, 0)
	viewArea.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
	viewArea.Parent = contentFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -20, 0, 50)
	nameLabel.Position = UDim2.new(0, 10, 0, 10)
	nameLabel.Text = "Select a Unit"
	nameLabel.TextSize = 30
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextWrapped = true
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = viewArea

	local infoContainer = Instance.new("Frame")
	infoContainer.Name = "InfoContainer"
	infoContainer.Size = UDim2.new(1, -20, 1, -150)
	infoContainer.Position = UDim2.new(0, 10, 0, 70)
	infoContainer.BackgroundTransparency = 1
	infoContainer.Visible = false
	infoContainer.Parent = viewArea

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "InfoLabel"
	infoLabel.Size = UDim2.new(0.5, -10, 1, 0)
	infoLabel.Position = UDim2.new(0, 0, 0, 0)
	infoLabel.Text = ""
	infoLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.TextYAlignment = Enum.TextYAlignment.Top
	infoLabel.TextWrapped = true
	infoLabel.TextScaled = true
	infoLabel.BackgroundTransparency = 1
	infoLabel.Parent = infoContainer

	local infoConstraint = Instance.new("UITextSizeConstraint")
	infoConstraint.MaxTextSize = 20
	infoConstraint.Parent = infoLabel

	local statsLabel = Instance.new("TextLabel")
	statsLabel.Name = "StatsLabel"
	statsLabel.Size = UDim2.new(0.5, -10, 1, 0)
	statsLabel.Position = UDim2.new(0.5, 10, 0, 0)
	statsLabel.Text = ""
	statsLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.TextYAlignment = Enum.TextYAlignment.Top
	statsLabel.TextWrapped = true
	statsLabel.TextScaled = true
	statsLabel.BackgroundTransparency = 1
	statsLabel.Parent = infoContainer

	local statsConstraint = Instance.new("UITextSizeConstraint")
	statsConstraint.MaxTextSize = 20
	statsConstraint.Parent = statsLabel

	local starsPanel = Instance.new("Frame")
	starsPanel.Name = "StarsPanel"
	starsPanel.Size = UDim2.new(1, -20, 1, -150)
	starsPanel.Position = UDim2.new(0, 10, 0, 70)
	starsPanel.BackgroundTransparency = 1
	starsPanel.Visible = false
	starsPanel.Parent = viewArea

	local starsInfoLabel = Instance.new("TextLabel")
	starsInfoLabel.Name = "StarsInfoLabel"
	starsInfoLabel.Size = UDim2.new(1, 0, 0.4, 0)
	starsInfoLabel.Position = UDim2.new(0, 0, 0, 0)
	starsInfoLabel.Text = ""
	starsInfoLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
	starsInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
	starsInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
	starsInfoLabel.TextWrapped = true
	starsInfoLabel.TextScaled = true
	starsInfoLabel.BackgroundTransparency = 1
	starsInfoLabel.Parent = starsPanel

	local starsConstraint = Instance.new("UITextSizeConstraint")
	starsConstraint.MaxTextSize = 25
	starsConstraint.Parent = starsInfoLabel

	local starUpButton = Instance.new("TextButton")
	starUpButton.Name = "StarUpButton"
	starUpButton.Size = UDim2.new(0, 200, 0, 50)
	starUpButton.Position = UDim2.new(0, 0, 0.5, 0)
	starUpButton.Text = "Star Up"
	starUpButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
	starUpButton.TextColor3 = Color3.new(1, 1, 1)
	starUpButton.Parent = starsPanel

	local gradeUpButton = Instance.new("TextButton")
	gradeUpButton.Name = "GradeUpButton"
	gradeUpButton.Size = UDim2.new(0, 200, 0, 50)
	gradeUpButton.Position = UDim2.new(0, 0, 0.5, 0)
	gradeUpButton.Text = "Grade Up"
	gradeUpButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.8)
	gradeUpButton.TextColor3 = Color3.new(1, 1, 1)
	gradeUpButton.Visible = false
	gradeUpButton.Parent = starsPanel

	starUpButton.MouseButton1Click:Connect(function()
		if currentSelectedUnitUUID then
			local success = ReplicatedStorage.StarUpUnit:InvokeServer(currentSelectedUnitUUID)
			if success then
				IndexTab.Refresh(screenGui, false)
			end
		end
	end)

	gradeUpButton.MouseButton1Click:Connect(function()
		if currentSelectedUnitUUID then
			local success = ReplicatedStorage.GradeUpUnit:InvokeServer(currentSelectedUnitUUID)
			if success then
				IndexTab.Refresh(screenGui, false)
			end
		end
	end)

	local menuFrame = Instance.new("Frame")
	menuFrame.Name = "MenuFrame"
	menuFrame.Size = UDim2.new(1, -20, 0, 60)
	menuFrame.Position = UDim2.new(0, 10, 1, -70)
	menuFrame.BackgroundTransparency = 1
	menuFrame.Parent = viewArea

	local menuLayout = Instance.new("UIListLayout")
	menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
	menuLayout.FillDirection = Enum.FillDirection.Horizontal
	menuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	menuLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	menuLayout.Padding = UDim.new(0.02, 0)
	menuLayout.Parent = menuFrame

	local subMenus = {"Info", "Levels", "Stars", "Charms", "Bonds"}
	for i, menuName in ipairs(subMenus) do
		local btn = Instance.new("TextButton")
		btn.Name = menuName .. "Button"
		btn.LayoutOrder = i
		btn.Size = UDim2.new(0.18, 0, 1, 0)
		btn.Text = menuName
		btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Parent = menuFrame

		btn.MouseButton1Click:Connect(function()
			if not currentSelectedUnitUUID then return end

			if menuName == "Info" then
				infoContainer.Visible = true
				starsPanel.Visible = false
			elseif menuName == "Stars" then
				infoContainer.Visible = false
				starsPanel.Visible = true
			else
				infoContainer.Visible = false
				starsPanel.Visible = false
			end
		end)
	end

	backButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
		mainGui.Enabled = true
		currentSelectedUnitUUID = nil
	end)

	return screenGui
end

function IndexTab.Refresh(gui, resetSelection)
	local requestActiveDataEvent = ReplicatedStorage:WaitForChild("RequestActiveData")
	local activeData = requestActiveDataEvent:InvokeServer()

	local backgroundFrame = gui:FindFirstChild("BackgroundFrame")
	if not backgroundFrame then return end

	local contentFrame = backgroundFrame:FindFirstChild("ContentFrame")
	if not contentFrame then return end

	local rosterList = contentFrame:FindFirstChild("RosterList")
	local viewArea = contentFrame:FindFirstChild("ViewArea")

	if not rosterList or not viewArea then return end

	if resetSelection then
		currentSelectedUnitUUID = nil

		local nameLabel = viewArea:FindFirstChild("NameLabel")
		if nameLabel then nameLabel.Text = "Select a Unit" end

		local infoContainer = viewArea:FindFirstChild("InfoContainer")
		if infoContainer then infoContainer.Visible = false end

		local starsPanel = viewArea:FindFirstChild("StarsPanel")
		if starsPanel then starsPanel.Visible = false end
	end

	for _, child in ipairs(rosterList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	if activeData and activeData.Units then
		local yOffset = 0
		local indexOrder = 1
		for _, unitInstance in ipairs(activeData.Units) do
			local baseData = UnitDatabase.GetUnitData(unitInstance.UnitID)
			if baseData then
				local unitBtn = Instance.new("TextButton")
				unitBtn.Name = unitInstance.UnitID .. "_Btn"
				unitBtn.LayoutOrder = indexOrder
				unitBtn.Size = UDim2.new(1, 0, 0, 50)
				unitBtn.Text = "[" .. baseData.Title .. "] " .. baseData.Name .. " (Lv." .. unitInstance.Level .. ")"
				unitBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)

				if currentSelectedUnitUUID == unitInstance.UUID then
					unitBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
					IndexTab.DisplayUnit(viewArea, unitInstance, baseData, activeData)
				end

				unitBtn.TextColor3 = Color3.new(1, 1, 1)
				unitBtn.Parent = rosterList

				unitBtn.MouseButton1Click:Connect(function()
					for _, sibling in ipairs(rosterList:GetChildren()) do
						if sibling:IsA("TextButton") then
							sibling.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
						end
					end
					unitBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
					IndexTab.DisplayUnit(viewArea, unitInstance, baseData, activeData)

					local infoContainer = viewArea:FindFirstChild("InfoContainer")
					local starsPanel = viewArea:FindFirstChild("StarsPanel")
					if infoContainer and starsPanel and not infoContainer.Visible and not starsPanel.Visible then
						infoContainer.Visible = true
					end
				end)

				yOffset = yOffset + 50
				indexOrder = indexOrder + 1
			end
		end
		rosterList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	end
end

function IndexTab.DisplayUnit(viewArea, unitInstance, baseData, activeData)
	currentSelectedUnitUUID = unitInstance.UUID

	local nameLabel = viewArea:FindFirstChild("NameLabel")
	local infoContainer = viewArea:FindFirstChild("InfoContainer")
	local starsPanel = viewArea:FindFirstChild("StarsPanel")

	local currentGradeDisplay = unitInstance.Grade
	if currentGradeDisplay == "Base" then currentGradeDisplay = "D" end

	if nameLabel then
		nameLabel.Text = "[" .. baseData.Title .. "] " .. baseData.Name
	end

	if infoContainer then
		local infoLabel = infoContainer:FindFirstChild("InfoLabel")
		local statsLabel = infoContainer:FindFirstChild("StatsLabel")

		if infoLabel then
			local infoText = "Level: " .. unitInstance.Level .. "\n"
			infoText = infoText .. "Base Rarity: " .. baseData.BaseRarity .. "\n"
			infoText = infoText .. "Current Grade: " .. currentGradeDisplay .. "\n"
			infoText = infoText .. "Stars: " .. unitInstance.Stars .. "/6\n\n"
			infoText = infoText .. "Faction: " .. baseData.Faction .. "\n"
			infoText = infoText .. "Element: " .. baseData.Element .. "\n"
			infoText = infoText .. "Class: " .. baseData.Class
			infoLabel.Text = infoText
		end

		if statsLabel then
			local statsText = "Base Stats:\n"
			for statName, statVal in pairs(baseData.BaseStats) do
				statsText = statsText .. statName .. ": " .. statVal .. "\n"
			end
			statsLabel.Text = statsText
		end
	end

	if starsPanel then
		local starsInfoLabel = starsPanel:FindFirstChild("StarsInfoLabel")
		local starUpButton = starsPanel:FindFirstChild("StarUpButton")
		local gradeUpButton = starsPanel:FindFirstChild("GradeUpButton")

		local copies = 0
		if activeData.Inventory and activeData.Inventory.UnitCopies then
			copies = activeData.Inventory.UnitCopies[unitInstance.UnitID] or 0
		end

		local isGradeUpMode = false
		if unitInstance.Stars >= 6 and (baseData.BaseRarity == "SSR" or baseData.BaseRarity == "SP") then
			isGradeUpMode = true
		end

		if isGradeUpMode then
			starUpButton.Visible = false
			gradeUpButton.Visible = true

			local gradeIndex = table.find(GameConstants.Grades, currentGradeDisplay) or 1
			local isMaxGrade = gradeIndex >= #GameConstants.Grades

			if starsInfoLabel then
				if isMaxGrade then
					starsInfoLabel.Text = "Current Grade: SSS (MAX)\nCopies Available: " .. copies .. "\n\nMax Grade Reached!"
					gradeUpButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
					gradeUpButton.Text = "Max Grade"
				else
					local nextGrade = GameConstants.Grades[gradeIndex + 1]
					starsInfoLabel.Text = "Current Grade: " .. currentGradeDisplay .. " -> " .. nextGrade .. "\nCopies Available: " .. copies .. "\n\nCost: 1 Copy to Grade Up"
					gradeUpButton.Text = "Grade Up"
					if copies < 1 then
						gradeUpButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
					else
						gradeUpButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.8)
					end
				end
			end
		else
			starUpButton.Visible = true
			gradeUpButton.Visible = false

			if starsInfoLabel then
				starsInfoLabel.Text = "Current Stars: " .. unitInstance.Stars .. " / 6\n"
				starsInfoLabel.Text = starsInfoLabel.Text .. "Copies Available: " .. copies .. "\n\n"
				if unitInstance.Stars >= 6 then
					starsInfoLabel.Text = starsInfoLabel.Text .. "Max Stars Reached!"
				else
					starsInfoLabel.Text = starsInfoLabel.Text .. "Cost: 1 Copy to Star Up"
				end
			end

			if starUpButton then
				if unitInstance.Stars >= 6 or copies < 1 then
					starUpButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
				else
					starUpButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
				end
			end
		end
	end
end

return IndexTab