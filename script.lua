local HttpService = game:GetService("HttpService")

local function getIPInfo(ip)
    local url = "https://ipwhois.app/json/" .. (ip or "")
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        local data = HttpService:JSONDecode(response)
        print("IP:", data.ip)
        print("Country:", data.country)
        print("City:", data.city)
        print("ISP:", data.org)
    else
        warn("Failed to fetch IP info:", response)
    end
end

-- Call with an IP or leave blank to get your own IP info
getIPInfo("8.8.8.8")





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
