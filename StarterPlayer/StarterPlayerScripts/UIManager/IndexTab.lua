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

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -50)
	contentFrame.Position = UDim2.new(0, 0, 0, 50)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = backgroundFrame

	local infoArea = Instance.new("Frame")
	infoArea.Name = "InfoArea"
	infoArea.Size = UDim2.new(0.67, 0, 1, 0)
	infoArea.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
	infoArea.Parent = contentFrame

	local starVisualLabel = Instance.new("TextLabel")
	starVisualLabel.Name = "StarVisualLabel"
	starVisualLabel.Size = UDim2.new(1, -40, 0, 30)
	starVisualLabel.Position = UDim2.new(0, 20, 0, 10)
	starVisualLabel.Text = ""
	starVisualLabel.TextSize = 30
	starVisualLabel.TextColor3 = Color3.new(1, 0.8, 0)
	starVisualLabel.TextXAlignment = Enum.TextXAlignment.Left
	starVisualLabel.TextYAlignment = Enum.TextYAlignment.Center
	starVisualLabel.BackgroundTransparency = 1
	starVisualLabel.Parent = infoArea

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -40, 0, 40)
	nameLabel.Position = UDim2.new(0, 20, 0, 40)
	nameLabel.Text = "Select a unit to view details."
	nameLabel.TextSize = 35
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextYAlignment = Enum.TextYAlignment.Top
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = infoArea

	local infoContainer = Instance.new("Frame")
	infoContainer.Name = "InfoContainer"
	infoContainer.Size = UDim2.new(1, -40, 1, -170)
	infoContainer.Position = UDim2.new(0, 20, 0, 90)
	infoContainer.BackgroundTransparency = 1
	infoContainer.Visible = false
	infoContainer.Parent = infoArea

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
	infoConstraint.MaxTextSize = 25
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
	statsConstraint.MaxTextSize = 25
	statsConstraint.Parent = statsLabel

	local starsPanel = Instance.new("Frame")
	starsPanel.Name = "StarsPanel"
	starsPanel.Size = UDim2.new(1, -40, 1, -170)
	starsPanel.Position = UDim2.new(0, 20, 0, 90)
	starsPanel.BackgroundTransparency = 1
	starsPanel.Visible = false
	starsPanel.Parent = infoArea

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
	starsConstraint.MaxTextSize = 30
	starsConstraint.Parent = starsInfoLabel

	local starUpButton = Instance.new("TextButton")
	starUpButton.Name = "StarUpButton"
	starUpButton.Size = UDim2.new(0, 250, 0, 60)
	starUpButton.Position = UDim2.new(0, 0, 0.5, 0)
	starUpButton.Text = "Star Up"
	starUpButton.TextSize = 25
	starUpButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
	starUpButton.TextColor3 = Color3.new(1, 1, 1)
	starUpButton.Parent = starsPanel

	local gradeUpButton = Instance.new("TextButton")
	gradeUpButton.Name = "GradeUpButton"
	gradeUpButton.Size = UDim2.new(0, 250, 0, 60)
	gradeUpButton.Position = UDim2.new(0, 0, 0.5, 0)
	gradeUpButton.Text = "Grade Up"
	gradeUpButton.TextSize = 25
	gradeUpButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.8)
	gradeUpButton.TextColor3 = Color3.new(1, 1, 1)
	gradeUpButton.Visible = false
	gradeUpButton.Parent = starsPanel

	local tabArea = Instance.new("Frame")
	tabArea.Name = "TabArea"
	tabArea.Size = UDim2.new(1, 0, 0, 60)
	tabArea.Position = UDim2.new(0, 0, 1, -60)
	tabArea.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
	tabArea.Parent = infoArea

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 20)
	tabLayout.Parent = tabArea

	local statsBtn = Instance.new("TextButton")
	statsBtn.Name = "StatsBtn"
	statsBtn.Size = UDim2.new(0, 150, 0, 40)
	statsBtn.Text = "Stats"
	statsBtn.TextSize = 20
	statsBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
	statsBtn.TextColor3 = Color3.new(1, 1, 1)
	statsBtn.Parent = tabArea

	local starUpTabBtn = Instance.new("TextButton")
	starUpTabBtn.Name = "StarUpTabBtn"
	starUpTabBtn.Size = UDim2.new(0, 150, 0, 40)
	starUpTabBtn.Text = "Star Up"
	starUpTabBtn.TextSize = 20
	starUpTabBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	starUpTabBtn.TextColor3 = Color3.new(1, 1, 1)
	starUpTabBtn.Parent = tabArea

	local rosterList = Instance.new("ScrollingFrame")
	rosterList.Name = "RosterList"
	rosterList.Size = UDim2.new(0.33, 0, 1, 0)
	rosterList.Position = UDim2.new(0.67, 0, 0, 0)
	rosterList.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	rosterList.CanvasSize = UDim2.new(0, 0, 0, 0)
	rosterList.Parent = contentFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 160, 0, 220)
	gridLayout.CellPadding = UDim2.new(0, 20, 0, 20)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.Parent = rosterList

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 20)
	padding.PaddingBottom = UDim.new(0, 20)
	padding.Parent = rosterList

	gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		rosterList.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 40)
	end)

	statsBtn.MouseButton1Click:Connect(function()
		if currentSelectedUnitUUID then
			infoContainer.Visible = true
			starsPanel.Visible = false
			statsBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
			starUpTabBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
		end
	end)

	starUpTabBtn.MouseButton1Click:Connect(function()
		if currentSelectedUnitUUID then
			infoContainer.Visible = false
			starsPanel.Visible = true
			starUpTabBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
			statsBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
		end
	end)

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
	local infoArea = contentFrame:FindFirstChild("InfoArea")

	if not rosterList or not infoArea then return end

	if resetSelection then
		currentSelectedUnitUUID = nil

		local nameLabel = infoArea:FindFirstChild("NameLabel")
		if nameLabel then nameLabel.Text = "Select a unit to view details." end

		local starVisualLabel = infoArea:FindFirstChild("StarVisualLabel")
		if starVisualLabel then starVisualLabel.Text = "" end

		local infoContainer = infoArea:FindFirstChild("InfoContainer")
		if infoContainer then infoContainer.Visible = false end

		local starsPanel = infoArea:FindFirstChild("StarsPanel")
		if starsPanel then starsPanel.Visible = false end

		local tabArea = infoArea:FindFirstChild("TabArea")
		if tabArea then
			local statsBtn = tabArea:FindFirstChild("StatsBtn")
			local starUpTabBtn = tabArea:FindFirstChild("StarUpTabBtn")
			if statsBtn then statsBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3) end
			if starUpTabBtn then starUpTabBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2) end
		end
	end

	for _, child in ipairs(rosterList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local unitModelsFolder = ReplicatedStorage:FindFirstChild("UnitModels")

	if activeData and activeData.Units then
		local indexOrder = 1
		local focusOffset = Vector3.new(0, 1.0, 0)
		local camOffset = Vector3.new(0, 1.2, -3.0)

		for _, unitInstance in ipairs(activeData.Units) do
			local baseData = UnitDatabase.GetUnitData(unitInstance.UnitID)
			if baseData then
				local unitBtn = Instance.new("TextButton")
				unitBtn.Name = unitInstance.UUID
				unitBtn.LayoutOrder = indexOrder
				unitBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
				unitBtn.Text = ""
				unitBtn.Parent = rosterList

				if currentSelectedUnitUUID == unitInstance.UUID then
					unitBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.2)
					IndexTab.DisplayUnit(infoArea, unitInstance, baseData, activeData)
				end

				local viewport = Instance.new("ViewportFrame")
				viewport.Name = "Viewport"
				viewport.Size = UDim2.new(1, 0, 0.75, 0)
				viewport.Position = UDim2.new(0, 0, 0, 0)
				viewport.BackgroundTransparency = 1
				viewport.Parent = unitBtn

				local camera = Instance.new("Camera")
				viewport.CurrentCamera = camera
				camera.Parent = viewport

				local modelToUse
				if unitModelsFolder and unitModelsFolder:FindFirstChild(unitInstance.UnitID) then
					modelToUse = unitModelsFolder:FindFirstChild(unitInstance.UnitID):Clone()
				else
					modelToUse = Instance.new("Part")
					modelToUse.Size = Vector3.new(4, 5, 4)
					modelToUse.BrickColor = BrickColor.new("Bright blue")
				end

				modelToUse.Parent = viewport

				if modelToUse:IsA("Model") and modelToUse.PrimaryPart then
					modelToUse:PivotTo(CFrame.new(0, 0, 0))
					local lookAt = modelToUse.PrimaryPart.Position + focusOffset
					camera.CFrame = CFrame.lookAt(modelToUse.PrimaryPart.Position + camOffset, lookAt)
				elseif modelToUse:IsA("Model") then
					modelToUse:MoveTo(Vector3.new(0,0,0))
					camera.CFrame = CFrame.lookAt(Vector3.new(0,0,0) + camOffset, Vector3.new(0,0,0) + focusOffset)
				else
					modelToUse.CFrame = CFrame.new(0, 0, 0)
					camera.CFrame = CFrame.lookAt(Vector3.new(0,0,0) + camOffset, Vector3.new(0,0,0) + focusOffset)
				end

				local infoLabel = Instance.new("TextLabel")
				infoLabel.Name = "InfoLabel"
				infoLabel.Size = UDim2.new(1, 0, 0.25, 0)
				infoLabel.Position = UDim2.new(0, 0, 0.75, 0)
				infoLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
				infoLabel.Text = baseData.Name .. "\nLv. " .. unitInstance.Level
				infoLabel.TextColor3 = Color3.new(1, 1, 1)
				infoLabel.TextScaled = true
				infoLabel.Parent = unitBtn

				local currentGradeDisplay = unitInstance.Grade
				if currentGradeDisplay == "Base" then currentGradeDisplay = "D" end

				local listStarLabel = Instance.new("TextLabel")
				listStarLabel.Name = "ListStarLabel"
				listStarLabel.Size = UDim2.new(1, -10, 0, 20)
				listStarLabel.Position = UDim2.new(0, 5, 0, 5)
				listStarLabel.BackgroundTransparency = 1
				listStarLabel.TextScaled = true
				listStarLabel.TextXAlignment = Enum.TextXAlignment.Left
				listStarLabel.Parent = unitBtn

				if unitInstance.Stars >= 6 and (baseData.BaseRarity == "SSR" or baseData.BaseRarity == "SP") then
					listStarLabel.Text = "Grade: " .. currentGradeDisplay
					listStarLabel.TextColor3 = Color3.new(0.8, 0.4, 1)
				else
					local starStr = ""
					for i = 1, unitInstance.Stars do
						starStr = starStr .. "★"
					end
					for i = unitInstance.Stars + 1, 6 do
						starStr = starStr .. "☆"
					end
					listStarLabel.Text = starStr
					listStarLabel.TextColor3 = Color3.new(1, 0.8, 0)
				end

				local listStarConstraint = Instance.new("UITextSizeConstraint")
				listStarConstraint.MaxTextSize = 18
				listStarConstraint.Parent = listStarLabel

				unitBtn.MouseButton1Click:Connect(function()
					for _, sibling in ipairs(rosterList:GetChildren()) do
						if sibling:IsA("TextButton") then
							sibling.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
						end
					end
					unitBtn.BackgroundColor3 = Color3.new(0.5, 0.5, 0.2)

					IndexTab.DisplayUnit(infoArea, unitInstance, baseData, activeData)

					local infoContainer = infoArea:FindFirstChild("InfoContainer")
					local starsPanel = infoArea:FindFirstChild("StarsPanel")
					if infoContainer and starsPanel and not infoContainer.Visible and not starsPanel.Visible then
						infoContainer.Visible = true
					end
				end)

				indexOrder = indexOrder + 1
			end
		end
	end
end

function IndexTab.DisplayUnit(infoArea, unitInstance, baseData, activeData)
	currentSelectedUnitUUID = unitInstance.UUID

	local nameLabel = infoArea:FindFirstChild("NameLabel")
	local starVisualLabel = infoArea:FindFirstChild("StarVisualLabel")
	local infoContainer = infoArea:FindFirstChild("InfoContainer")
	local starsPanel = infoArea:FindFirstChild("StarsPanel")

	local currentGradeDisplay = unitInstance.Grade
	if currentGradeDisplay == "Base" then currentGradeDisplay = "D" end

	if nameLabel then
		nameLabel.Text = "[" .. baseData.Title .. "] " .. baseData.Name
	end

	if starVisualLabel then
		if unitInstance.Stars >= 6 and (baseData.BaseRarity == "SSR" or baseData.BaseRarity == "SP") then
			starVisualLabel.Text = "Grade: " .. currentGradeDisplay
			starVisualLabel.TextColor3 = Color3.new(0.8, 0.4, 1)
		else
			local starStr = ""
			for i = 1, unitInstance.Stars do
				starStr = starStr .. "★"
			end
			for i = unitInstance.Stars + 1, 6 do
				starStr = starStr .. "☆"
			end
			starVisualLabel.Text = starStr
			starVisualLabel.TextColor3 = Color3.new(1, 0.8, 0)
		end
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