-- @ScriptType: ModuleScript
local BattleTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local cameraConnection = nil

function BattleTab.Create(playerGui, mainGui)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BattleGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "BackgroundFrame"
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.BackgroundTransparency = 1
	backgroundFrame.Parent = screenGui

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 50)
	topBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	topBar.Parent = backgroundFrame

	local fleeButton = Instance.new("TextButton")
	fleeButton.Name = "FleeButton"
	fleeButton.Size = UDim2.new(0, 100, 1, 0)
	fleeButton.Text = "Flee"
	fleeButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
	fleeButton.TextColor3 = Color3.new(1, 1, 1)
	fleeButton.Parent = topBar

	local turnLabel = Instance.new("TextLabel")
	turnLabel.Name = "TurnLabel"
	turnLabel.Size = UDim2.new(0, 200, 1, 0)
	turnLabel.Position = UDim2.new(0.5, -100, 0, 0)
	turnLabel.Text = "Turn: 1"
	turnLabel.TextColor3 = Color3.new(1, 1, 1)
	turnLabel.TextSize = 25
	turnLabel.BackgroundTransparency = 1
	turnLabel.Parent = topBar

	local cardArea = Instance.new("Frame")
	cardArea.Name = "CardArea"
	cardArea.Size = UDim2.new(1, 0, 0.2, 0)
	cardArea.Position = UDim2.new(0, 0, 0.8, 0)
	cardArea.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
	cardArea.Parent = backgroundFrame

	fleeButton.MouseButton1Click:Connect(function()
		local leaveEvent = ReplicatedStorage:FindFirstChild("LeaveBattle")
		if leaveEvent then
			leaveEvent:InvokeServer()
		end

		screenGui.Enabled = false
		mainGui.Enabled = true

		if cameraConnection then
			cameraConnection:Disconnect()
			cameraConnection = nil
		end
	end)

	return screenGui
end

function BattleTab.Refresh(gui)
	local getBattleStateEvent = ReplicatedStorage:WaitForChild("GetBattleState")
	local state = getBattleStateEvent:InvokeServer()

	if not state then return end

	local backgroundFrame = gui:FindFirstChild("BackgroundFrame")
	if not backgroundFrame then return end

	local topBar = backgroundFrame:FindFirstChild("TopBar")
	if topBar then
		local turnLabel = topBar:FindFirstChild("TurnLabel")
		if turnLabel then
			turnLabel.Text = "Turn: " .. state.Turn
		end
	end

	local player = Players.LocalPlayer
	Workspace:WaitForChild("Arena_" .. player.UserId, 10)

	if cameraConnection then
		cameraConnection:Disconnect()
		cameraConnection = nil
	end

	cameraConnection = RunService.RenderStepped:Connect(function()
		local camera = Workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable

		local targetPos = state.ArenaPosition
		local camPos = state.CameraPosition or (targetPos + Vector3.new(0, 40, -50))
		camera.CFrame = CFrame.lookAt(camPos, targetPos)
	end)
end

return BattleTab