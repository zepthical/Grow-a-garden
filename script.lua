-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Local Variables
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local oldCFrame = hrp.CFrame
local leaderstats = lp:FindFirstChild("leaderstats")
local shecklesStat = leaderstats and leaderstats:FindFirstChild("Sheckles")
local seedRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
local gearRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock")
local easterRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEasterStock")
local seedPath = lp.PlayerGui.Seed_Shop.Frame.ScrollingFrame
local gearPath = lp.PlayerGui.Gear_Shop.Frame.ScrollingFrame
local gearicon = Players.LocalPlayer.PlayerGui.Teleport_UI.Frame.Gear
local dmRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock")
local bmPath = lp.PlayerGui.EventShop_UI.Frame.ScrollingFrame
local autoBuyEnabled = false
local autoBuyEnabledE = false
local dmRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock")
local bmPath = lp.PlayerGui.EventShop_UI.Frame.ScrollingFrame

-- Tables

local seedItems = {"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk"}
local gearItems = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler","Favorite Tool"}
local mutationOptions = {"Wet","Gold","Frozen","Rainbow","Choc","Chilled","Shocked","Moonlit","Bloodlit","Celestial"}
local selectedMutations = {"Gold","Frozen","Rainbow","Choc","Chilled","Shocked","Moonlit","Bloodlit","Celestial"}
local seedNames = {"Apple","Banana","Bamboo","Blueberry","Candy Blossom","Candy Sunflower","Carrot","Cactus","Chocolate Carrot","Chocolate Sprinkler","Coconut","Corn","Cranberry","Cucumber","Cursed Fruit","Daffodil","Dragon Fruit","Durian","Easter Egg","Eggplant","Grape","Lemon","Lotus","Mango","Mushroom","Pepper","Orange Tulip","Papaya","Passionfruit","Peach","Pear","Pineapple","Pumpkin","Raspberry","Red Lollipop","Soul Fruit","Strawberry","Tomato","Venus Fly Trap","Watermelon","Cacao","Beanstalk"}
local selectedSeeds, selectedGears = {}, {}
local farms = {}
local plants = {}
local bmItems = {"Mysterious Crate","Night Egg","Night Seed Pack","Blood Banana","Moon Melon","Star Caller","Blood Hedgehog","Blood Kiwi","Blood Owl"}
local selectedSeeds, selectedGears, selectedBMItems = {}, {}, {}

gearicon.Active = true
gearicon.Visible = true
gearicon.ImageColor3 = Color3.fromRGB(255, 255, 255)

-- Auto Farm Functions
local autoFarmEnabled = false
local farmThread

local function updateFarmData()
    farms = {}
    plants = {}
    for _, farm in pairs(workspace:FindFirstChild("Farm"):GetChildren()) do -- no error here lmao
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
            table.insert(farms, farm)
            local plantsFolder = farm.Important:FindFirstChild("Plants_Physical")
            if plantsFolder then
                for _, plantModel in pairs(plantsFolder:GetChildren()) do
                    for _, part in pairs(plantModel:GetDescendants()) do
                        if part:IsA("BasePart") and part:FindFirstChildOfClass("ProximityPrompt") then
                            table.insert(plants, part)
                            break
                        end
                    end
                end
            end
        end
    end
end

local looptpwait = nil
local willlooptp = false

looptp = function(obj, posit)
    while willlooptp do task.wait()
        obj.CFrame = CFrame.new(posit)
    end

    if task.wait(looptpwait) then
        willlooptp = false
    end
end

local function glitchTeleport(pos)
    if not lp.Character then return end
    local root = lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    willlooptp = true
    task.wait(0.1)
    looptp(root, pos + Vector3.new(0, -5, 0))
end

local function parseMoney(moneyStr)
    if not moneyStr then return 0 end
    moneyStr = tostring(moneyStr):gsub("Ã‚Â¢", ""):gsub(",", ""):gsub(" ", ""):gsub("%$", "")
    local multiplier = 1
    if moneyStr:lower():find("k") then
        multiplier = 1000
        moneyStr = moneyStr:lower():gsub("k", "")
    elseif moneyStr:lower():find("m") then
        multiplier = 1000000
        moneyStr = moneyStr:lower():gsub("m", "")
    end
    return (tonumber(moneyStr) or 0) * multiplier
end

local function getPlayerMoney()
    return parseMoney((shecklesStat and shecklesStat.Value) or 0)
end

local function isInventoryFull()
    return #lp.Backpack:GetChildren() >= 200
end


local function instantFarm()
    if farmThread then task.cancel(farmThread) end
    farmThread = task.spawn(function()
        while autoFarmEnabled do
            while isInventoryFull() do
                if not autoFarmEnabled then return end
                task.wait(1)
            end
            if not autoFarmEnabled then return end
            updateFarmData()
            for _, part in pairs(plants) do
                if not autoFarmEnabled then return end
                if isInventoryFull() then break end
                if part and part.Parent then
                    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        glitchTeleport(part.Position)
                        task.wait(0.2)
                        for _, farm in pairs(farms) do
                            if not autoFarmEnabled or isInventoryFull() then break end
                            for _, obj in pairs(farm:GetDescendants()) do
                                if obj:IsA("ProximityPrompt") then
                                    local str = tostring(obj.Parent)
                                    if not (str:find("Grow_Sign") or str:find("Core_Part")) then
                                        fireproximityprompt(obj, 1)
                                    end
                                end
                            end
                        end
                        if not autoFarmEnabled then return end
                        task.wait(0.2)
                    end
                end
            end
            if autoFarmEnabled then task.wait(0.1) end
        end
    end)
end

local fastClickEnabled = false
local fastClickThread
local CLICK_DELAY = 0.00000001
local MAX_DISTANCE = 50

local function isValidPrompt(prompt)
    local parent = prompt.Parent
    if not parent then return false end
    local name = parent.Name:lower()
    return not (name:find("sign") or name:find("core"))
end

local function getNearbyPrompts()
    local nearby = {}
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nearby end
    
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
            for _, obj in pairs(farm:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and isValidPrompt(obj) then
                    local part = obj.Parent
                    if part:IsA("BasePart") then
                        local dist = (hrp.Position - part.Position).Magnitude
                        if dist <= MAX_DISTANCE then
                            table.insert(nearby, obj)
                        end
                    end
                end
            end
        end
    end
    return nearby
end

local function fastClickFarm()
    if fastClickThread then task.cancel(fastClickThread) end
    fastClickThread = task.spawn(function()
        while fastClickEnabled do
            if isInventoryFull() then
                task.wait(1)
                continue
            end
            local prompts = getNearbyPrompts()
            for _, prompt in pairs(prompts) do
                if not fastClickEnabled then return end
                if isInventoryFull() then break end
                fireproximityprompt(prompt, 1)
                task.wait(CLICK_DELAY)
            end
            task.wait(0.1)
        end
    end)
end

local autoSellEnabled = false
local autoSellThread

local function sellItems()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if not steven then return false end
    
    local char = lp.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local originalPosition = hrp.CFrame
    hrp.CFrame = steven.HumanoidRootPart.CFrame * CFrame.new(0, 3, 3)
    task.wait(0.5)
    
    for _ = 1, 5 do
        pcall(function()
            game.ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
        end)
        task.wait(0.15)
    end
    
    hrp.CFrame = originalPosition
    return true
end

-- Harvest Functions
local HarvestEnabled = false
local HarvestConnection = nil

local function FindGarden()
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return nil end
    
    for _, plot in ipairs(farm:GetChildren()) do
        local data = plot:FindFirstChild("Important") and plot.Important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")
        if owner and owner.Value == lp.Name then
            return plot
        end
    end
    return nil
end

local function CanHarvest(part)
    local prompt = part:FindFirstChild("ProximityPrompt")
    if prompt and prompt.Enabled == true then
        return prompt and prompt.Enabled
    end
end

local function Harvest()
    if not HarvestEnabled then return end
    if isInventoryFull() then return end
    
    local garden = FindGarden()
    if not garden then return end
    
    local plants = garden:FindFirstChild("Important") and garden.Important:FindFirstChild("Plants_Physical")
    if not plants then return end
    
    for _, plant in ipairs(plants:GetChildren()) do
        if not HarvestEnabled then break end
        local fruits = plant:FindFirstChild("Fruits")
        if fruits then
            for _, fruit in ipairs(fruits:GetChildren()) do
                if not HarvestEnabled then break end
                for _, part in ipairs(fruit:GetChildren()) do
                    if not HarvestEnabled then break end
                    if part:IsA("BasePart") and CanHarvest(part) then
                        local prompt = part.ProximityPrompt
                        local pos = part.Position + Vector3.new(0, -3, 0)
                        if lp.Character and lp.Character.PrimaryPart then
                            lp.Character:SetPrimaryPartCFrame(CFrame.new(pos))
                            task.wait(0.1)
                            if not HarvestEnabled then break end
                            prompt:InputHoldBegin()
                            task.wait(0.1)
                            if not HarvestEnabled then break end
                            prompt:InputHoldEnd()
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end

local function ToggleHarvest(state)
    if HarvestConnection then
        HarvestConnection:Disconnect()
        HarvestConnection = nil
    end
    HarvestEnabled = state
    if state then
        HarvestConnection = RunService.Heartbeat:Connect(function()
            if HarvestEnabled then
                Harvest()
            else
                HarvestConnection:Disconnect()
                HarvestConnection = nil
            end
        end)
    end
end

-- Shop Functions
local function OpenShop()
    local shop = lp.PlayerGui.Seed_Shop
    shop.Enabled = not shop.Enabled
end

local function OpenGearShop()
    local gear = lp.PlayerGui.Gear_Shop
    gear.Enabled = not gear.Enabled
end

local function OpenEaster()
    local easter = lp.PlayerGui.Easter_Shop
    easter.Enabled = not easter.Enabled
end

local function OpenQuest()
    local quest = lp.PlayerGui.DailyQuests_UI
    quest.Enabled = not quest.Enabled
end

local function OpenTravelMer()
    local quest = lp.PlayerGui.TravellingMerchant_Shop
    quest.Enabled = not quest.Enabled
end

local function EggShop1()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations["Common Egg"].ProximityPrompt)
end

local function EggShop2()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations:GetChildren()[6].ProximityPrompt)
end

local function EggShop3()
    fireproximityprompt(workspace.NPCS["Pet Stand"].EggLocations:GetChildren()[5].ProximityPrompt)
end

local function OpenBloodShop()
    local Bs = lp.PlayerGui.EventShop_UI
    Bs.Enabled = not Bs.Enabled
end

-- Sell Functions
local function SellAll()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if steven then
        hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        wait(0.2)
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
        
        local farms = workspace:WaitForChild("Farm"):GetChildren()
        for _, farm in pairs(farms) do
            local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
            if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
                local spawn = farm:FindFirstChild("Spawn_Point")
                if spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end
end

local function HSell()
    local steven = workspace.NPCS:FindFirstChild("Steven")
    if steven then
        hrp.CFrame = steven.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        wait(0.2)
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Item"):FireServer()
        
        local farms = workspace:WaitForChild("Farm"):GetChildren()
        for _, farm in pairs(farms) do
            local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
            if data and data:FindFirstChild("Owner") and data.Owner.Value == lp.Name then
                local spawn = farm:FindFirstChild("Spawn_Point")
                if spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end
    end
end

local autoMoon = false

local function AutoGiveFruitMoon(State)
    autoMoon = State

    task.spawn(function()
        while autoMoon do
            local player = game:GetService("Players").LocalPlayer
            local backpack = player:FindFirstChild("Backpack")
            local character = player.Character or player.CharacterAdded:Wait()

            if backpack and character then
                for _, tool in pairs(backpack:GetChildren()) do
                    if typeof(tool) == "Instance" and tool:IsA("Tool") and string.find(tool.Name, "%[Moonlit%]") then
                        tool.Parent = character
                        wait(0.5)

                        for i = 1, 10 do
                            game:GetService("ReplicatedStorage").GameEvents.NightQuestRemoteEvent:FireServer("SubmitHeldPlant")
                        end

                        wait(0.5)
                    end
                end
            end

            wait(0.5)
        end
    end)
end

local function AntiAfk(state)
    if state then
        if not _G.AntiAfkConnection then
            _G.AntiAfkConnection = Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    elseif _G.AntiAfkConnection then
        _G.AntiAfkConnection:Disconnect()
        _G.AntiAfkConnection = nil
    end
end

local function DestroySign()
    for _, farm in pairs(workspace.Farm:GetChildren()) do
        local sign = farm:FindFirstChild("Sign")
        if sign then
            local core = sign:FindFirstChild("Core_Part")
            if core then
                for _, obj in pairs(core:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        obj:Destroy()
                    end
                end
            end
        end
        
        local growSign = farm:FindFirstChild("Grow_Sign")
        if growSign then
            for _, obj in pairs(growSign:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj:Destroy()
                end
            end
        end
    end
end

-- Auto Favorite Functions
local favoriteEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item")
local connection = nil
local autoFavoriteEnabled = false

local function toolMatchesMutation(toolName)
    for _, mutation in ipairs(selectedMutations) do
        if string.find(toolName, mutation) then
            return true
        end
    end
    return false
end

local function isToolFavorited(tool)
    return tool:GetAttribute("Favorite") or (tool:FindFirstChild("Favorite") and tool.Favorite.Value)
end

local function favoriteToolIfMatches(tool)
    if toolMatchesMutation(tool.Name) and not isToolFavorited(tool) then
        favoriteEvent:FireServer(tool)
        task.wait(0.1)
    end
end

local function processBackpack()
    local backpack = lp:FindFirstChild("Backpack") or lp:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        favoriteToolIfMatches(tool)
    end
end

local function setupAutoFavorite()
    if connection then connection:Disconnect() end

    local backpack = lp:WaitForChild("Backpack")

    connection = backpack.ChildAdded:Connect(function(tool)
        task.wait(0.1)
        favoriteToolIfMatches(tool)
    end)

    processBackpack()
end

-- Auto Claim Premium Seeds Functions
local autoClaimToggle = false
local claimConnection = nil

local function claimPremiumSeed()
    ReplicatedStorage.GameEvents.SeedPackGiverEvent:FireServer("ClaimPremiumPack")
end

local function toggleAutoClaim(newState)
    autoClaimToggle = newState
    if claimConnection then
        claimConnection:Disconnect()
        claimConnection = nil
    end
    if autoClaimToggle then
        claimConnection = RunService.Heartbeat:Connect(function()
            claimPremiumSeed()
            task.wait()
        end)
    end
end

-- Auto Plant Functions
local plantRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Plant_RE")
local AutoPlanting = false
local CurrentlyPlanting = false
local SelectedSeeds = {}

local function getPlayerPosition()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    return root and root.Position or Vector3.zero
end

local function getCurrentSeedsInBackpack()
    local result = {}
    for _, tool in ipairs(lp.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local base = tool.Name:match("^(.-) Seed")
            if base and table.find(SelectedSeeds, base) then
                result[#result + 1] = {BaseName = base, Tool = tool}
            end
        end
    end
    return result
end

local function plantEquippedSeed(seedName)
    local pos = getPlayerPosition()
    plantRemote:FireServer(pos, seedName)
end

local function equipTool(tool)
    if not tool or not tool:IsDescendantOf(lp.Backpack) then return end
    
    pcall(function()
        lp.Character.Humanoid:UnequipTools()
        task.wait(0.1)
        tool.Parent = lp.Character
        while not lp.Character:FindFirstChild(tool.Name) do
            task.wait(0.1)
        end
    end)
end

local function startAutoPlanting()
    if CurrentlyPlanting then return end
    CurrentlyPlanting = true
    
    task.spawn(function()
        while AutoPlanting do
            local seeds = getCurrentSeedsInBackpack()
            for _, data in ipairs(seeds) do
                local tool = data.Tool
                local seedName = data.BaseName
                
                if not table.find(SelectedSeeds, seedName) then continue end
                
                if tool and tool:IsA("Tool") and tool:IsDescendantOf(lp.Backpack) then
                    equipTool(tool)
                    task.wait(0.5)
                    
                    while AutoPlanting and lp.Character:FindFirstChild(tool.Name) do
                        if not table.find(SelectedSeeds, seedName) then break end
                        plantEquippedSeed(seedName)
                        task.wait(0.2)
                    end
                end
            end
            task.wait(0.5)
        end
        CurrentlyPlanting = false
    end)
end

-- Destroy Others's Farm Function
local function DestoryOthersFarm()
    local farms = workspace:FindFirstChild("Farm")
    if not farms then return end
    
    for _, farm in pairs(farms:GetChildren()) do
        local data = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Data")
        if data and data:FindFirstChild("Owner") and data.Owner.Value ~= lp.Name then
            local plants = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
            if plants then
                for _, obj in pairs(plants:GetChildren()) do
                    obj:Destroy()
                end
            end
        end
    end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Moonlight Hub | Grow a garden",
   Icon = 0, 
   LoadingTitle = "Moonlight Hub",
   LoadingSubtitle = "Grow a garden",
   Theme = "Default", 

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "mlh",
      FileName = "gag"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink", 
      RememberJoins = true
    },

   KeySystem = false, 
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", 
      FileName = "Key", 
      SaveKey = true,
      GrabKeyFromSite = false, 
      Key = {"Hello"} 
   }
})

local MainTab = Window:CreateTab("Auto Collect", 4483362458)


local Section = MainTab:CreateSection("Auto")

local CollectToggle = MainTab:CreateToggle({
   Name = "Auto Collect",
   CurrentValue = false,
   Flag = "acol",
   Callback = function(state)
        fastClickEnabled = state
        if fastClickEnabled then
            fastClickFarm()
        elseif fastClickThread then
            task.cancel(fastClickThread)
            fastClickThread = nil
        end
   end,
})

local CollectnearbyToggle = MainTab:CreateToggle({
   Name = "Auto Collect Nearby",
   CurrentValue = false,
   Flag = "cnear",
   Callback = function(Value)
        spamE = Value
        updateFarmData()
        
        for _, farm in pairs(farms) do
            for _, obj in ipairs(farm:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    handleNewPrompt(obj)
                end
            end
        end
        
        if spamE then
            collectionThread = task.spawn(function()
                while spamE and task.wait(0.1) do
                    if not isInventoryFull() then
                        local plr = game.Players.LocalPlayer
                        local char = plr and plr.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        
                        if root then
                            for prompt, _ in pairs(promptTracker) do
                                if prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.KeyboardKeyCode == Enum.KeyCode.E then
                                    local targetPos
                                    local parent = prompt.Parent
                                    
                                    if parent:IsA("BasePart") then
                                        targetPos = parent.Position
                                    elseif parent:IsA("Model") and parent:FindFirstChild("HumanoidRootPart") then
                                        targetPos = parent.HumanoidRootPart.Position
                                    end
                                    
                                    if targetPos and (root.Position - targetPos).Magnitude <= RANGE then
                                        pcall(function()
                                            fireproximityprompt(prompt, 1, true)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            for prompt, data in pairs(promptTracker) do
                if prompt:IsA("ProximityPrompt") then
                    pcall(function()
                        prompt.RequiresLineOfSight = data.originalRequiresLOS
                        prompt.Exclusivity = data.originalExclusivity
                    end)
                end
            end
            
            if collectionThread then
                task.cancel(collectionThread)
                collectionThread = nil
            end
        end
   end,
})

descendantConnection = workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") and isInsideFarm(obj) then
        handleNewPrompt(obj)
    end
end)

for _, farm in pairs(farms) do
    for _, obj in ipairs(farm:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            handleNewPrompt(obj)
        end
    end
end



local Section = MainTab:CreateSection("Sell")

local AutoSellToggle = MainTab:CreateToggle({
   Name = "Auto Sell -When Inventory is full",
   CurrentValue = false,
   Flag = "asell",
   Callback = function(Value)
        autoSellEnabled = Value
        if autoSellEnabled then
            autoSellThread = task.spawn(function()
                while autoSellEnabled and task.wait(1) do
                    if isInventoryFull() then
                        sellItems()
                    end
                end
            end)
        elseif autoSellThread then
            task.cancel(autoSellThread)
        end
   end,
})

local InsSellToggle = MainTab:CreateToggle({
   Name = "Instant Sell",
   CurrentValue = false,
   Flag = "insell",
   Callback = SellAll()
})

Rayfield:LoadConfiguration()
