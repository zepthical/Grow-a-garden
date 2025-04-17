-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")


_G.autoCollect = false
_G.autoWalkToPlant = false


local function getOwnedPlot()
	for _, plot in pairs(workspace.Farm:GetChildren()) do
		local important = plot:FindFirstChild("Important") or plot:FindFirstChild("Importanert")
		if important then
			local data = important:FindFirstChild("Data")
			if data and data:FindFirstChild("Owner") and data.Owner.Value == player.Name then
				return plot
			end
		end
	end
	return nil
end


task.spawn(function()
	while task.wait(1) do
		if _G.autocollect then
			local plot = getOwnedPlot()
			local farm = plot and plot:FindFirstChild("Important"):FindFirstChild("Plants_Physical")
			if farm then
				for _, prompt in ipairs(farm:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") then
						local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						if playerRoot then
							local dist = (playerRoot.Position - prompt.Parent.Position).Magnitude
							if dist <= 20 then
								prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
								prompt.MaxActivationDistance = 100
								prompt.RequiresLineOfSight = false
								prompt.Enabled = true
								fireproximityprompt(prompt, 1, true)
							elseif _G.autoWalkToPlant then
								local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
								if humanoid then
									humanoid:MoveTo(prompt.Parent.Position + Vector3.new(0, 5, 0))
								end
							end
						end
					end
				end
			end
		end
	end
end)
