-- @ScriptType: ModuleScript
local ServerListTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

function ServerListTab.Create(playerGui, mainGui)
	local serverSelectGui = Instance.new("ScreenGui")
	serverSelectGui.Name = "ServerSelectGui"
	serverSelectGui.ResetOnSpawn = false
	serverSelectGui.IgnoreGuiInset = true
	serverSelectGui.Parent = playerGui

	local serverFrame = Instance.new("Frame")
	serverFrame.Size = UDim2.new(1, 0, 1, 0)
	serverFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	serverFrame.Parent = serverSelectGui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 60)
	titleLabel.Position = UDim2.new(0, 0, 0.1, 0)
	titleLabel.Text = "Select Virtual Server"
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextSize = 30
	titleLabel.Parent = serverFrame

	local scrollContainer = Instance.new("ScrollingFrame")
	scrollContainer.Size = UDim2.new(0, 300, 0.7, 0)
	scrollContainer.Position = UDim2.new(0.5, 0, 0.2, 0)
	scrollContainer.AnchorPoint = Vector2.new(0.5, 0)
	scrollContainer.BackgroundTransparency = 1
	scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollContainer.ScrollBarThickness = 8
	scrollContainer.Parent = serverFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = scrollContainer

	local requestServersEvent = ReplicatedStorage:WaitForChild("RequestVirtualServers")
	local globalData = requestServersEvent:InvokeServer()

	if not globalData then
		task.wait(1)
		globalData = requestServersEvent:InvokeServer()
	end

	local availableServers = {"P001", "P002", "P003", "P004"}

	if RunService:IsStudio() then
		table.insert(availableServers, 1, "T001")
	end

	local yOffset = 0
	for _, serverId in ipairs(availableServers) do
		local sButton = Instance.new("TextButton")
		sButton.Size = UDim2.new(0, 200, 0, 50)

		local isOwned = false
		if globalData and globalData.ServersJoined then
			for _, ownedId in ipairs(globalData.ServersJoined) do
				if ownedId == serverId then
					isOwned = true
					break
				end
			end
		end

		if serverId == "T001" then
			sButton.Text = serverId .. " (Test Wipe)"
			sButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
		elseif isOwned then
			sButton.Text = serverId .. " (Continue)"
			sButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
		else
			sButton.Text = serverId .. " (New Game)"
			sButton.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
		end

		sButton.TextColor3 = Color3.new(1, 1, 1)
		sButton.Parent = scrollContainer
		yOffset = yOffset + 60

		sButton.MouseButton1Click:Connect(function()
			local joinEvent = ReplicatedStorage:WaitForChild("JoinVirtualServer")
			joinEvent:FireServer(serverId)
			serverSelectGui.Enabled = false
			mainGui.Enabled = true
		end)
	end

	scrollContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset)

	return serverSelectGui
end

return ServerListTab