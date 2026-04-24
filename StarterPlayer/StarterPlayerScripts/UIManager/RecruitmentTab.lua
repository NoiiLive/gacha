-- @ScriptType: ModuleScript
local RecruitmentTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitDatabase = require(ReplicatedStorage:WaitForChild("UnitDatabase"))

local currentBanner = "Standard"

function RecruitmentTab.Create(playerGui, mainGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RecruitmentGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "BackgroundFrame"
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
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

	local currencyLabel = Instance.new("TextLabel")
	currencyLabel.Name = "CurrencyLabel"
	currencyLabel.Size = UDim2.new(0, 200, 1, 0)
	currencyLabel.Position = UDim2.new(1, -220, 0, 0)
	currencyLabel.Text = "Tickets: 0"
	currencyLabel.TextColor3 = Color3.new(1, 1, 1)
	currencyLabel.TextSize = 20
	currencyLabel.TextXAlignment = Enum.TextXAlignment.Right
	currencyLabel.BackgroundTransparency = 1
	currencyLabel.Parent = topBar

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -50)
	contentFrame.Position = UDim2.new(0, 0, 0, 50)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = backgroundFrame

	local bannerSelectFrame = Instance.new("Frame")
	bannerSelectFrame.Name = "BannerSelectFrame"
	bannerSelectFrame.Size = UDim2.new(0.2, 0, 1, 0)
	bannerSelectFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
	bannerSelectFrame.Parent = contentFrame

	local bannerLayout = Instance.new("UIListLayout")
	bannerLayout.Parent = bannerSelectFrame

	local banners = {"Standard", "Event", "Carnival"}
	for _, bannerName in ipairs(banners) do
		local bBtn = Instance.new("TextButton")
		bBtn.Name = bannerName .. "_Btn"
		bBtn.Size = UDim2.new(1, 0, 0, 60)
		bBtn.Text = bannerName .. " Banner"
		bBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
		bBtn.TextColor3 = Color3.new(1, 1, 1)
		bBtn.Parent = bannerSelectFrame

		bBtn.MouseButton1Click:Connect(function()
			for _, sibling in ipairs(bannerSelectFrame:GetChildren()) do
				if sibling:IsA("TextButton") then
					sibling.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
				end
			end
			bBtn.BackgroundColor3 = Color3.new(0.4, 0.4, 0.5)
			currentBanner = bannerName
			RecruitmentTab.RefreshTickets(screenGui)
		end)
	end

	local pullArea = Instance.new("Frame")
	pullArea.Name = "PullArea"
	pullArea.Size = UDim2.new(0.8, 0, 1, 0)
	pullArea.Position = UDim2.new(0.2, 0, 0, 0)
	pullArea.BackgroundTransparency = 1
	pullArea.Parent = contentFrame

	local bannerTitle = Instance.new("TextLabel")
	bannerTitle.Name = "BannerTitle"
	bannerTitle.Size = UDim2.new(1, 0, 0, 100)
	bannerTitle.Position = UDim2.new(0, 0, 0.1, 0)
	bannerTitle.Text = "Standard Banner"
	bannerTitle.TextSize = 40
	bannerTitle.TextColor3 = Color3.new(1, 1, 1)
	bannerTitle.BackgroundTransparency = 1
	bannerTitle.Parent = pullArea

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "ButtonFrame"
	buttonFrame.Size = UDim2.new(1, 0, 0, 80)
	buttonFrame.Position = UDim2.new(0, 0, 0.8, 0)
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Parent = pullArea

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	btnLayout.Padding = UDim.new(0, 50)
	btnLayout.Parent = buttonFrame

	local pull1Btn = Instance.new("TextButton")
	pull1Btn.Name = "Pull1Btn"
	pull1Btn.Size = UDim2.new(0, 200, 1, 0)
	pull1Btn.Text = "Pull x1"
	pull1Btn.BackgroundColor3 = Color3.new(0.3, 0.6, 0.9)
	pull1Btn.TextColor3 = Color3.new(1, 1, 1)
	pull1Btn.TextSize = 25
	pull1Btn.Parent = buttonFrame

	local pull10Btn = Instance.new("TextButton")
	pull10Btn.Name = "Pull10Btn"
	pull10Btn.Size = UDim2.new(0, 200, 1, 0)
	pull10Btn.Text = "Pull x10"
	pull10Btn.BackgroundColor3 = Color3.new(0.8, 0.6, 0.2)
	pull10Btn.TextColor3 = Color3.new(1, 1, 1)
	pull10Btn.TextSize = 25
	pull10Btn.Parent = buttonFrame

	-- Main Overlay
	local resultOverlay = Instance.new("Frame")
	resultOverlay.Name = "ResultOverlay"
	resultOverlay.Size = UDim2.new(1, 0, 1, 0)
	resultOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	resultOverlay.BackgroundTransparency = 0.4
	resultOverlay.Visible = false
	resultOverlay.ZIndex = 10
	resultOverlay.Parent = pullArea

	-- Container Box for results
	local resultContainer = Instance.new("Frame")
	resultContainer.Name = "ResultContainer"
	resultContainer.Size = UDim2.new(0.9, 0, 0.8, 0)
	resultContainer.Position = UDim2.new(0.05, 0, 0.1, 0)
	resultContainer.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	resultContainer.ZIndex = 11
	resultContainer.Parent = resultOverlay

	local resultTitle = Instance.new("TextLabel")
	resultTitle.Name = "ResultTitle"
	resultTitle.Size = UDim2.new(1, 0, 0, 50)
	resultTitle.Text = "Recruitment Results"
	resultTitle.TextSize = 30
	resultTitle.TextColor3 = Color3.new(1, 1, 1)
	resultTitle.BackgroundTransparency = 1
	resultTitle.ZIndex = 12
	resultTitle.Parent = resultContainer

	-- Inner display frame for the cards
	local resultDisplay = Instance.new("Frame")
	resultDisplay.Name = "ResultDisplay"
	resultDisplay.Size = UDim2.new(0.96, 0, 0.7, 0)
	resultDisplay.Position = UDim2.new(0.02, 0, 0.15, 0)
	resultDisplay.BackgroundTransparency = 1
	resultDisplay.ZIndex = 12
	resultDisplay.Parent = resultContainer

	-- Scaling Layout
	local resultLayout = Instance.new("UIGridLayout")
	-- Uses scale (0.18 = 18%) to ensure 5 cards always fit perfectly horizontally
	resultLayout.CellSize = UDim2.new(0.18, 0, 0.45, 0)
	resultLayout.CellPadding = UDim2.new(0.02, 0, 0.05, 0)
	resultLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	resultLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	resultLayout.SortOrder = Enum.SortOrder.LayoutOrder
	resultLayout.Parent = resultDisplay

	-- Keeps the cards perfectly rectangular regardless of screen stretch
	local aspectConstraint = Instance.new("UIAspectRatioConstraint")
	aspectConstraint.AspectRatio = 0.7
	aspectConstraint.Parent = resultLayout

	local closeResultBtn = Instance.new("TextButton")
	closeResultBtn.Name = "CloseResultBtn"
	closeResultBtn.Size = UDim2.new(0, 200, 0, 50)
	closeResultBtn.Position = UDim2.new(0.5, -100, 0.9, -15)
	closeResultBtn.Text = "Close"
	closeResultBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
	closeResultBtn.TextColor3 = Color3.new(1, 1, 1)
	closeResultBtn.ZIndex = 12
	closeResultBtn.Parent = resultContainer

	closeResultBtn.MouseButton1Click:Connect(function()
		resultOverlay.Visible = false
	end)

	local function executePull(amount)
		local results = ReplicatedStorage.SummonUnits:InvokeServer(currentBanner, amount)
		if results then
			RecruitmentTab.RefreshTickets(screenGui)

			for _, child in ipairs(resultDisplay:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			for i, res in ipairs(results) do
				local baseData = UnitDatabase.GetUnitData(res.UnitID)
				if baseData then
					local card = Instance.new("Frame")
					card.Name = "Card_" .. i
					card.LayoutOrder = i
					card.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
					card.ZIndex = 13
					card.Parent = resultDisplay

					if baseData.BaseRarity == "SP" then card.BackgroundColor3 = Color3.new(0.8, 0.2, 0.8)
					elseif baseData.BaseRarity == "SSR" then card.BackgroundColor3 = Color3.new(0.8, 0.6, 0.2)
					elseif baseData.BaseRarity == "SR" then card.BackgroundColor3 = Color3.new(0.6, 0.6, 0.8)
					end

					local tLabel = Instance.new("TextLabel")
					tLabel.Size = UDim2.new(1, -10, 1, -10)
					tLabel.Position = UDim2.new(0, 5, 0, 5)
					tLabel.Text = baseData.BaseRarity .. "\n\n" .. baseData.Name .. (res.IsCopy and "\n(Copy)" or "\n(New)")
					tLabel.TextColor3 = Color3.new(1, 1, 1)
					tLabel.TextWrapped = true
					tLabel.TextScaled = true
					tLabel.BackgroundTransparency = 1
					tLabel.ZIndex = 14
					tLabel.Parent = card

					-- Limits max text size so it doesn't get massive on big screens
					local textConstraint = Instance.new("UITextSizeConstraint")
					textConstraint.MaxTextSize = 22
					textConstraint.Parent = tLabel
				end
			end

			resultOverlay.Visible = true
		end
	end

	pull1Btn.MouseButton1Click:Connect(function() executePull(1) end)
	pull10Btn.MouseButton1Click:Connect(function() executePull(10) end)

	backButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
		resultOverlay.Visible = false
		mainGui.Enabled = true
	end)

	return screenGui
end

function RecruitmentTab.RefreshTickets(gui)
	local requestActiveDataEvent = ReplicatedStorage:WaitForChild("RequestActiveData")
	local activeData = requestActiveDataEvent:InvokeServer()

	local backgroundFrame = gui:FindFirstChild("BackgroundFrame")
	if not backgroundFrame then return end

	local topBar = backgroundFrame:FindFirstChild("TopBar")
	local contentFrame = backgroundFrame:FindFirstChild("ContentFrame")

	if topBar and contentFrame then
		local currencyLabel = topBar:FindFirstChild("CurrencyLabel")
		local pullArea = contentFrame:FindFirstChild("PullArea")
		local bannerTitle = pullArea and pullArea:FindFirstChild("BannerTitle")

		if bannerTitle then
			bannerTitle.Text = currentBanner .. " Banner"
		end

		if currencyLabel and activeData then
			local count = 0
			local tName = "SummonTickets"
			if currentBanner == "Event" then tName = "EventSummonTickets"
			elseif currentBanner == "Carnival" then tName = "CarnivalTickets" end

			count = activeData[tName] or 0
			currencyLabel.Text = tName .. ": " .. count
		end
	end
end

function RecruitmentTab.InitDefaultSelection(gui)
	currentBanner = "Standard"

	local backgroundFrame = gui:FindFirstChild("BackgroundFrame")
	if backgroundFrame then
		local contentFrame = backgroundFrame:FindFirstChild("ContentFrame")
		if contentFrame then
			local bannerSelectFrame = contentFrame:FindFirstChild("BannerSelectFrame")
			if bannerSelectFrame then
				for _, sibling in ipairs(bannerSelectFrame:GetChildren()) do
					if sibling:IsA("TextButton") then
						if sibling.Name == "Standard_Btn" then
							sibling.BackgroundColor3 = Color3.new(0.4, 0.4, 0.5)
						else
							sibling.BackgroundColor3 = Color3.new(0.2, 0.2, 0.25)
						end
					end
				end
			end
		end
	end

	RecruitmentTab.RefreshTickets(gui)
end

return RecruitmentTab