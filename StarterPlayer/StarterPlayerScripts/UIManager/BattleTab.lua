-- @ScriptType: ModuleScript
-- StarterPlayer/StarterPlayerScripts/UIManager/BattleTab.lua
local BattleTab = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local cameraConnection = nil

local function cloneTable(t)
	local newT = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			newT[k] = cloneTable(v)
		else
			newT[k] = v
		end
	end
	return newT
end

-- Fixed to prevent execution timeout
local function ResolveCardCombinations(hand)
	local combined = true
	local iterations = 0
	while combined and iterations < 50 do
		iterations = iterations + 1
		combined = false
		for i = #hand, 2, -1 do
			local rightCard = hand[i]
			local leftCard = hand[i-1]
			if rightCard and leftCard then
				if rightCard.UUID == leftCard.UUID and rightCard.Tier == leftCard.Tier and rightCard.Tier < 3 then
					leftCard.Tier = leftCard.Tier + 1
					table.remove(hand, i)
					combined = true
					break 
				end
			end
		end
	end
end

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

	local bottomArea = Instance.new("Frame")
	bottomArea.Name = "BottomArea"
	bottomArea.Size = UDim2.new(1, 0, 0.25, 0)
	bottomArea.Position = UDim2.new(0, 0, 0.75, 0)
	bottomArea.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
	bottomArea.Parent = backgroundFrame

	local selectedArea = Instance.new("Frame")
	selectedArea.Name = "SelectedArea"
	selectedArea.Size = UDim2.new(1, 0, 0.35, 0)
	selectedArea.Position = UDim2.new(0, 0, 0, 0)
	selectedArea.BackgroundTransparency = 1
	selectedArea.Parent = bottomArea

	local selectedLayout = Instance.new("UIListLayout")
	selectedLayout.FillDirection = Enum.FillDirection.Horizontal
	selectedLayout.Padding = UDim.new(0, 10)
	selectedLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	selectedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	selectedLayout.Parent = selectedArea

	local handArea = Instance.new("Frame")
	handArea.Name = "HandArea"
	handArea.Size = UDim2.new(1, 0, 0.65, 0)
	handArea.Position = UDim2.new(0, 0, 0.35, 0)
	handArea.BackgroundTransparency = 1
	handArea.Parent = bottomArea

	local handLayout = Instance.new("UIListLayout")
	handLayout.FillDirection = Enum.FillDirection.Horizontal
	handLayout.Padding = UDim.new(0, 5)
	handLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	handLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	handLayout.Parent = handArea

	fleeButton.MouseButton1Click:Connect(function()
		local leaveEvent = ReplicatedStorage:FindFirstChild("LeaveBattle")
		if leaveEvent then leaveEvent:InvokeServer() end
		screenGui.Enabled = false
		mainGui.Enabled = true
		if cameraConnection then cameraConnection:Disconnect() cameraConnection = nil end
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
		if turnLabel then turnLabel.Text = "Turn: " .. state.Turn end
	end

	local activeMembers = 0
	if state.PlayerTeam then
		for _, u in ipairs(state.PlayerTeam) do
			if u.CurrentHP > 0 then activeMembers = activeMembers + 1 end
		end
	end
	if activeMembers < 1 then activeMembers = 1 end
	local maxHandSize = activeMembers * 3

	local bottomArea = backgroundFrame:FindFirstChild("BottomArea")
	if bottomArea then
		local handArea = bottomArea:FindFirstChild("HandArea")
		local selectedArea = bottomArea:FindFirstChild("SelectedArea")

		if state.State == "Victory" or state.State == "Defeat" then
			if topBar and topBar:FindFirstChild("TurnLabel") then topBar.TurnLabel.Text = state.State .. "!" end
			if handArea then for _, c in ipairs(handArea:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end end
			if selectedArea then for _, c in ipairs(selectedArea:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end end
		elseif handArea and selectedArea then

			local localHand = cloneTable(state.Hand)
			local localNextCards = cloneTable(state.NextCards)
			local selectedQueue = {}
			local clickSequence = {}
			local isProcessing = false
			local UnitDatabase = require(ReplicatedStorage:WaitForChild("UnitDatabase"))

			local function RefillLocalHand()
				while #localHand < maxHandSize and #localNextCards > 0 do
					local newCard = table.remove(localNextCards, 1)
					if newCard then table.insert(localHand, newCard) end
					ResolveCardCombinations(localHand)
				end
			end

			local function addTierBorder(parent, tier)
				local stroke = Instance.new("UIStroke")
				stroke.Thickness = 4
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				if tier == 1 then stroke.Color = Color3.fromRGB(150, 150, 150)
				elseif tier == 2 then stroke.Color = Color3.fromRGB(255, 215, 0)
				elseif tier >= 3 then stroke.Color = Color3.fromRGB(128, 0, 128) end
				stroke.Parent = parent
			end

			local function UpdateSelectionVisuals()
				for _, c in ipairs(selectedArea:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
				for _, c in ipairs(handArea:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end

				for _, cData in ipairs(selectedQueue) do
					local uData = UnitDatabase.GetUnitData(cData.UnitID)
					local color = Color3.new(0.3, 0.3, 0.3)
					if uData then
						if uData.Element == "Strength" then color = Color3.new(0.8, 0.3, 0.3)
						elseif uData.Element == "Skill" then color = Color3.new(0.3, 0.8, 0.3)
						elseif uData.Element == "Speed" then color = Color3.new(0.3, 0.3, 0.8)
						elseif uData.Element == "Psyche" then color = Color3.new(0.8, 0.3, 0.8)
						elseif uData.Element == "Wit" then color = Color3.new(0.8, 0.8, 0.3) end
					end

					local sFrame = Instance.new("Frame")
					sFrame.Size = UDim2.new(0, 60, 0, 90)
					sFrame.BackgroundColor3 = color
					addTierBorder(sFrame, cData.Tier)

					local txt = Instance.new("TextLabel", sFrame)
					txt.Size = UDim2.new(1, -6, 1, -6)
					txt.Position = UDim2.new(0, 3, 0, 3)
					txt.Text = (uData and uData.Name or "Unknown") .. "\n\nTier " .. cData.Tier
					txt.TextScaled = true
					txt.TextWrapped = true
					txt.TextColor3 = Color3.new(1, 1, 1)
					txt.BackgroundTransparency = 1
					sFrame.Parent = selectedArea
				end

				for i, cardData in ipairs(localHand) do
					local btn = Instance.new("TextButton")
					btn.LayoutOrder = i
					btn.Size = UDim2.new(0, 80, 0, 120)

					local uData = UnitDatabase.GetUnitData(cardData.UnitID)
					local color = Color3.new(0.3, 0.3, 0.3)
					if uData then
						if uData.Element == "Strength" then color = Color3.new(0.8, 0.3, 0.3)
						elseif uData.Element == "Skill" then color = Color3.new(0.3, 0.8, 0.3)
						elseif uData.Element == "Speed" then color = Color3.new(0.3, 0.3, 0.8)
						elseif uData.Element == "Psyche" then color = Color3.new(0.8, 0.3, 0.8)
						elseif uData.Element == "Wit" then color = Color3.new(0.8, 0.8, 0.3) end
					end

					btn.BackgroundColor3 = color
					btn.TextColor3 = Color3.new(1, 1, 1)
					btn.Text = (uData and uData.Name or "Unknown") .. "\n\nTier " .. cardData.Tier
					btn.TextWrapped = true

					addTierBorder(btn, cardData.Tier)
					btn.Parent = handArea

					btn.MouseButton1Click:Connect(function()
						if isProcessing or #selectedQueue >= activeMembers then return end
						isProcessing = true

						local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
						local moveTween = TweenService:Create(btn, tweenInfo, {Position = UDim2.new(0, 0, -1, 0), BackgroundTransparency = 1, TextTransparency = 1})
						moveTween:Play()

						local stroke = btn:FindFirstChildOfClass("UIStroke")
						if stroke then TweenService:Create(stroke, tweenInfo, {Transparency = 1}):Play() end

						task.wait(0.15)

						local cData = cloneTable(localHand[i])
						table.insert(clickSequence, i)
						table.insert(selectedQueue, cData)
						table.remove(localHand, i)

						RefillLocalHand()
						UpdateSelectionVisuals()

						if #clickSequence >= activeMembers then
							task.spawn(function()
								local playEvent = ReplicatedStorage:FindFirstChild("PlayTurn")
								if playEvent then
									-- Pause for visual "ready" state
									task.wait(0.5) 
									playEvent:InvokeServer(clickSequence)

									-- "Turn Playing" visual delay
									if topBar and topBar:FindFirstChild("TurnLabel") then
										topBar.TurnLabel.Text = "Combat playing..."
									end

									task.wait(1.5) -- Time for animations/effects to play out

									clickSequence = {}
									selectedQueue = {}
									BattleTab.Refresh(gui)
								end
							end)
						else
							isProcessing = false
						end
					end)
				end
			end

			UpdateSelectionVisuals()
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