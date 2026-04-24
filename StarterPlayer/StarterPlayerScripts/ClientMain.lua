-- @ScriptType: LocalScript
local UIManager = require(script.Parent:WaitForChild("UIManager"))
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

UIManager.Initialize()

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

RunService.RenderStepped:Connect(function()
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end

	local battleGui = playerGui:FindFirstChild("BattleGui")
	if battleGui and battleGui.Enabled then return end

	local lobbyScene = Workspace:FindFirstChild("LobbyScene")
	if lobbyScene then
		local camPos = lobbyScene:FindFirstChild("LobbyCamera")
		local char = player.Character

		if camPos and char and char.PrimaryPart then
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.lookAt(camPos.Position, char.PrimaryPart.Position)
		end
	end
end)