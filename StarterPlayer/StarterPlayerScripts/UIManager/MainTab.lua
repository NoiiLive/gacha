-- @ScriptType: ModuleScript
local MainTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function MainTab.Create(playerGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = screenGui

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 250, 0, 400)
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundTransparency = 1
	container.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 20)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Parent = container

	local campaignButton = Instance.new("TextButton")
	campaignButton.Name = "CampaignButton"
	campaignButton.Size = UDim2.new(1, 0, 0, 50)
	campaignButton.Text = "Campaign"
	campaignButton.Parent = container

	local recruitmentButton = Instance.new("TextButton")
	recruitmentButton.Name = "RecruitmentButton"
	recruitmentButton.Size = UDim2.new(1, 0, 0, 50)
	recruitmentButton.Text = "Recruitment"
	recruitmentButton.Parent = container

	local indexButton = Instance.new("TextButton")
	indexButton.Name = "IndexButton"
	indexButton.Size = UDim2.new(1, 0, 0, 50)
	indexButton.Text = "Index"
	indexButton.Parent = container

	local testUnitButton = Instance.new("TextButton")
	testUnitButton.Name = "TestUnitButton"
	testUnitButton.Size = UDim2.new(1, 0, 0, 50)
	testUnitButton.Text = "DEV: Give All Test Units"
	testUnitButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
	testUnitButton.TextColor3 = Color3.new(1, 1, 1)
	testUnitButton.Parent = container

	testUnitButton.MouseButton1Click:Connect(function()
		local giveUnitEvent = ReplicatedStorage:FindFirstChild("GiveTestUnit")
		if giveUnitEvent then
			giveUnitEvent:FireServer("U001")
			giveUnitEvent:FireServer("U002")
			giveUnitEvent:FireServer("U003")
			giveUnitEvent:FireServer("U004")
			giveUnitEvent:FireServer("U005")
		end
	end)

	return screenGui
end

return MainTab