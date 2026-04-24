-- @ScriptType: ModuleScript
local UIManager = {}
local Players = game:GetService("Players")

function UIManager.Initialize()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local MainTab = require(script:WaitForChild("MainTab"))
	local ServerListTab = require(script:WaitForChild("ServerListTab"))
	local IndexTab = require(script:WaitForChild("IndexTab"))
	local RecruitmentTab = require(script:WaitForChild("RecruitmentTab"))

	local mainGui = MainTab.Create(playerGui)
	local indexGui = IndexTab.Create(playerGui, mainGui)
	local recruitmentGui = RecruitmentTab.Create(playerGui, mainGui)
	local serverSelectGui = ServerListTab.Create(playerGui, mainGui)

	local indexButton = mainGui:FindFirstChild("IndexButton", true)
	local recruitmentButton = mainGui:FindFirstChild("RecruitmentButton", true)

	if indexButton then
		indexButton.MouseButton1Click:Connect(function()
			mainGui.Enabled = false
			IndexTab.Refresh(indexGui, true)
			indexGui.Enabled = true
		end)
	end

	if recruitmentButton then
		recruitmentButton.MouseButton1Click:Connect(function()
			mainGui.Enabled = false
			RecruitmentTab.InitDefaultSelection(recruitmentGui)
			recruitmentGui.Enabled = true
		end)
	end
end

return UIManager