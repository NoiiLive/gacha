-- @ScriptType: ModuleScript
local CampaignTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

function CampaignTab.Create(playerGui, mainGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CampaignGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "BackgroundFrame"
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.BackgroundColor3 = Color3.new(0.1, 0.15, 0.1)
	backgroundFrame.Parent = screenGui

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.BackgroundColor3 = Color3.new(0.05, 0.1, 0.05)
	topBar.Parent = backgroundFrame

	local backButton = Instance.new("TextButton")
	backButton.Name = "BackButton"
	backButton.Size = UDim2.new(0, 100, 1, 0)
	backButton.Text = "Back"
	backButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
	backButton.TextColor3 = Color3.new(1, 1, 1)
	backButton.Parent = topBar

	local centerContainer = Instance.new("Frame")
	centerContainer.Name = "CenterContainer"
	centerContainer.Size = UDim2.new(0.5, 0, 0.5, 0)
	centerContainer.Position = UDim2.new(0.25, 0, 0.25, 0)
	centerContainer.BackgroundTransparency = 1
	centerContainer.Parent = backgroundFrame

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 20)
	layout.Parent = centerContainer

	local stageLabel = Instance.new("TextLabel")
	stageLabel.Name = "StageLabel"
	stageLabel.Size = UDim2.new(1, 0, 0, 60)
	stageLabel.Text = "Stage: Loading..."
	stageLabel.TextSize = 40
	stageLabel.TextColor3 = Color3.new(1, 1, 1)
	stageLabel.BackgroundTransparency = 1
	stageLabel.Parent = centerContainer

	local battleButton = Instance.new("TextButton")
	battleButton.Name = "BattleButton"
	battleButton.Size = UDim2.new(0, 200, 0, 60)
	battleButton.Text = "Start Battle"
	battleButton.TextSize = 25
	battleButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
	battleButton.TextColor3 = Color3.new(1, 1, 1)
	battleButton.Parent = centerContainer

	backButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
		mainGui.Enabled = true
	end)

	battleButton.MouseButton1Click:Connect(function()
		local startEvent = ReplicatedStorage:FindFirstChild("StartCampaignBattle")
		if startEvent then
			local success = startEvent:InvokeServer()
			if success then
				screenGui.Enabled = false
				local battleGui = playerGui:FindFirstChild("BattleGui")
				if battleGui then
					local BattleTab = require(script.Parent:WaitForChild("BattleTab"))
					BattleTab.Refresh(battleGui)
					battleGui.Enabled = true
				end
			end
		end
	end)

	return screenGui
end

function CampaignTab.Refresh(gui)
	local requestActiveDataEvent = ReplicatedStorage:WaitForChild("RequestActiveData")
	local activeData = requestActiveDataEvent:InvokeServer()

	if activeData and activeData.CampaignStage then
		local backgroundFrame = gui:FindFirstChild("BackgroundFrame")
		if backgroundFrame then
			local center = backgroundFrame:FindFirstChild("CenterContainer")
			if center then
				local stageLabel = center:FindFirstChild("StageLabel")
				if stageLabel then
					stageLabel.Text = "Stage: " .. tostring(activeData.CampaignStage)
				end
			end
		end
	end
end

return CampaignTab