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

-- Auto Farm Functions
local autoFarmEnabled = false
local farmThread

local function updateFarmData()
    farms = {}
    plants = {}
    for _, farm in pairs(workspace:FindFirstChild("Farm"):GetChildren()) do
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

local function getPlayerMoney()
    return parseMoney((shecklesStat and shecklesStat.Value) or 0)
end

local looptpwait = nil
local willlooptp = false

local function looptp(obj, posit)
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
    looptp(root, pos + Vector3.new(0, -2, 0))
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

-- Auto Collect Functions
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

-- Auto Sell Functions
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
            ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
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
    return prompt and prompt.Enabled
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
                        local pos = part.Position + Vector3.new(0, 3, 0)
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

-- Movement Functions
local flyEnabled = false
local flySpeed = 48
local bodyVelocity, bodyGyro
local flightConnection

local function Fly(state)
    flyEnabled = state
    if flyEnabled then
        local character = lp.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        bodyGyro = Instance.new("BodyGyro")
        bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro.P = 9000
        bodyGyro.maxTorque = Vector3.new(8999999488, 8999999488, 8999999488)
        bodyGyro.cframe = character.HumanoidRootPart.CFrame
        bodyGyro.Parent = character.HumanoidRootPart
        
        bodyVelocity.velocity = Vector3.new(0, 0, 0)
        bodyVelocity.maxForce = Vector3.new(8999999488, 8999999488, 8999999488)
        bodyVelocity.Parent = character.HumanoidRootPart
        humanoid.PlatformStand = true
        
        flightConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not character:FindFirstChild("HumanoidRootPart") then
                if flightConnection then flightConnection:Disconnect() end
                return
            end
            
            local cam = workspace.CurrentCamera.CFrame
            local moveVec = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVec = moveVec + cam.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVec = moveVec - cam.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVec = moveVec - cam.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVec = moveVec + cam.RightVector
            end
            
            if moveVec.Magnitude > 0 then
                moveVec = moveVec.Unit * flySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVec = moveVec + Vector3.new(0, flySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVec = moveVec + Vector3.new(0, -flySpeed, 0)
            end
            
            bodyVelocity.velocity = moveVec
            bodyGyro.cframe = cam
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        
        local character = lp.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end
        
        if flightConnection then
            flightConnection:Disconnect()
            flightConnection = nil
        end
    end
end

-- NoClip Functions
local noclip = false

RunService.Stepped:Connect(function()
    if noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

local function ToggleNoclip(state)
    noclip = state
end

-- Infinite Jump Functions
local infJump = false

UserInputService.JumpRequest:Connect(function()
    if infJump and char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function ToggleInfJump(state)
    infJump = state
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

-- Auto Buy Egg
local Autoegg_npc = workspace:WaitForChild("NPCS"):WaitForChild("Pet Stand")
local Autoegg_timer = Autoegg_npc.Timer.SurfaceGui:WaitForChild("ResetTimeLabel")
local Autoegg_eggLocations = Autoegg_npc:WaitForChild("EggLocations")
local Autoegg_events = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents")

local Autoegg_autoBuyEnabled = false
local Autoegg_firstRun = true

local player = game.Players.LocalPlayer
local originalCFrame = player.Character and player.Character:WaitForChild("HumanoidRootPart").CFrame or CFrame.new()
local targetCFrame = CFrame.new(-255.12291, 2.99999976, -1.13749218, -0.0163238496, 1.05261321e-07, 0.999866784, -5.92361182e-09, 1, -1.0537206e-07, -0.999866784, -7.64290053e-09, -0.0163238496)

local function Autoegg_safeFirePrompt(prompt)
    if prompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end

local function Autoegg_safeFireServer(id)
    pcall(function()
        Autoegg_events:WaitForChild("BuyPetEgg"):FireServer(id)
    end)
end

local function Autoegg_setAlwaysShow()
    for _, obj in ipairs(Autoegg_eggLocations:GetChildren()) do
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                child.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
            end
        end
    end
end

local function Autoegg_autoBuyEggs()
    if Autoegg_autoBuyEnabled then
        if not Autoegg_firstRun then
            while Autoegg_timer.Text ~= "00:00:00" do
                task.wait(0.1)
            end
            task.wait(3)
        else
            Autoegg_firstRun = false
        end

        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        player.Character.HumanoidRootPart.CFrame = targetCFrame

        Autoegg_setAlwaysShow()

        local commonEggPrompt = Autoegg_eggLocations:FindFirstChild("Common Egg")
        if commonEggPrompt then
            Autoegg_safeFirePrompt(commonEggPrompt:FindFirstChild("ProximityPrompt"))
            task.wait(0.3)
            Autoegg_safeFireServer(1)
        end

        local eggSlot6 = Autoegg_eggLocations:GetChildren()[6]
        if eggSlot6 then
            Autoegg_safeFirePrompt(eggSlot6:FindFirstChild("ProximityPrompt"))
            task.wait(0.3)
            Autoegg_safeFireServer(2)
        end

        local eggSlot5 = Autoegg_eggLocations:GetChildren()[5]
        if eggSlot5 then
            Autoegg_safeFirePrompt(eggSlot5:FindFirstChild("ProximityPrompt"))
            task.wait(0.3)
            Autoegg_safeFireServer(3)
        end

        player.Character.HumanoidRootPart.CFrame = originalCFrame
    end
end

spawn(function()
    while true do
        task.wait(0.5)
        if Autoegg_autoBuyEnabled then
            Autoegg_autoBuyEggs()
        end
    end
end)

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

local function OpenBloodShop()
    local Bs = lp.PlayerGui.EventShop_UI
    Bs.Enabled = not Bs.Enabled
end

-- Dupe Functions
local dupeLLPEnabled = false
local dupeLLPThread

local function DupeLLP()
    if dupeLLPThread then task.cancel(dupeLLPThread) end
    dupeLLPThread = task.spawn(function()
        while dupeLLPEnabled do
            local event = ReplicatedStorage.GameEvents.EasterShopService
            for i = 1, 5 do
                event:FireServer("PurchaseSeed", i)
                task.wait(0.1)
            end
            task.wait(20)
        end
    end)
end

local BananaDupe
local BAnanaDupeE = false

local function DupeBanana()
    if BananaDupe then task.cancel(BananaDupe) end
    BananaDupe = task.spawn(function()
        while BAnanaDupeE do
            ReplicatedStorage.GameEvents.BuySeedStock:FireServer("Banana")
            task.wait(20)
        end
    end)
end

local CrimsonDupe
local CRimsonDupeE = false

local function DupeCrimson()
    if CrimsonDupe then task.cancel(CrimsomDupe) end
    CrimsonDupe = task.spawn(function()
        while CRimsonDupeE do
            ReplicatedStorage.GameEvents.BuySeedStock:FireServer("Crimson Vine")
            task.wait(20)
        end
    end)
end

-- Auto Collect V2 Functions
local spamE = false
local RANGE = 50
local promptTracker = {}
local collectionThread
local descendantConnection

local function modifyPrompt(prompt, show)
    pcall(function()
        prompt.RequiresLineOfSight = not show
        prompt.Exclusivity = show and Enum.ProximityPromptExclusivity.AlwaysShow or Enum.ProximityPromptExclusivity.One
    end)
end

local function isInsideFarm(part)
    for _, farm in pairs(farms) do
        if part:IsDescendantOf(farm) then
            return true
        end
    end
    return false
end

local function handleNewPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if not isInsideFarm(prompt) then return end
    
    if not promptTracker[prompt] then
        promptTracker[prompt] = {
            originalRequiresLOS = prompt.RequiresLineOfSight,
            originalExclusivity = prompt.Exclusivity
        }
    end
    
    modifyPrompt(prompt, spamE)
    prompt.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            promptTracker[prompt] = nil
        end
    end)
end

-- One Click Remove Functions
local enabled = false

local function OneClickRemove(state)
    enabled = state
    local confirmFrame = Players.LocalPlayer.PlayerGui:FindFirstChild("ShovelPrompt")
    if confirmFrame and confirmFrame:FindFirstChild("ConfirmFrame") then
        confirmFrame.ConfirmFrame.Visible = not state
    end
end

-- Anti-AFK Function
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

-- Destroy Sign Function
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

-- Auto Open Crate Functions
local autoSkipEnabled = false

local function toggleAutoSkip()
    autoSkipEnabled = not autoSkipEnabled
    if autoSkipEnabled then
        task.spawn(function()
            local character = lp.Character
            local backpack = lp:FindFirstChild("Backpack")
            local seedTool
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Basic Seed Pack") then
                        seedTool = tool
                        break
                    end
                end
            end
            if seedTool and character then
                seedTool.Parent = character
            end
            
            while autoSkipEnabled do
                local PlayerGui = lp:FindFirstChild("PlayerGui")
                local RollCrate_UI = PlayerGui and PlayerGui:FindFirstChild("RollCrate_UI")
                local character = lp.Character
                local equippedTool = character and character:FindFirstChildOfClass("Tool")
                local holdingSeed = equippedTool and equippedTool.Name:find("Basic Seed Pack")
                
                if RollCrate_UI then
                    if RollCrate_UI.Enabled then
                        local Frame = RollCrate_UI:FindFirstChild("Frame")
                        local Button = Frame and Frame:FindFirstChild("Skip")
                        if Button and Button:IsA("ImageButton") and Button.Visible then
                            GuiService.SelectedObject = Button
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    elseif holdingSeed then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end

-- Server Hop Function
local function ServerHop()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local PlaceId = game.PlaceId
    local currentJobId = game.JobId
    local servers = {}
    local cursor = nil

    -- Fetch servers
    local function GetServers(cursor)
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then
            url = url .. "&cursor=" .. cursor
        end
        return HttpService:JSONDecode(game:HttpGet(url))
    end

    -- Collect servers with fewer players than max
    repeat
        local data = GetServers(cursor)
        for _, server in ipairs(data.data) do
            if server.playing < server.maxPlayers and server.id ~= currentJobId then
                table.insert(servers, { id = server.id, playing = server.playing })
            end
        end
        cursor = data.nextPageCursor
    until not cursor or #servers > 0

    -- Notify if no servers are found
    if #servers == 0 then
        warn("No available servers found.")
        return
    end

    -- Sort servers by player count (ascending) to target older servers
    table.sort(servers, function(a, b)
        return a.playing < b.playing
    end)

    -- Teleport to the server with the lowest player count
    local targetServer = servers[1].id
    TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, game.Players.LocalPlayer)
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

-- Destroy Others Farm Function
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

local Env = loadstring(game:HttpGet("https://raw.githubusercontent.com/MerrySubs4t/96soul/refs/heads/main/Utilities/NongkhawKawaii-UI.luau", true))()

local Banner = {
	['Genral'] = 101849161408766,
	['Auto'] = 110162136250435,
	['Setting'] = 72210587662292,
	['Misc'] = 84034775913393,
	['Items'] = 98574803492996,
	['Shop'] = 74630923244478,
	['Teleport'] = 137847566773112,
	['Visual'] = 123257335719276,
	['Combat'] = 112935442242481,
	['Update'] = 86844430363710,
}

local Window = Env:Window({
	Title = "Moonlight Hub",
	Desc = "- Grow a Garden"
})

local AutoTab = Window:Add({
	Title = "Auto",
	Desc = "Automatically",
	Banner = Banner.Auto
})

local ACSection = AutoTab:Section({
	Title = "Auto Collect",
	Side = 'l'
})

ACSection:CreateToggle({
    Title = "Auto Collect",
    Desc = "Automatically Collect Fruits",
    Value = false,
    Callback = function(v)
        pcall(function()
            fastClickEnabled = v
            if fastClickEnabled then
                fastClickFarm()
            elseif fastClickThread then
                task.cancel(fastClickThread)
                fastClickThread = nil
            end
        end)
    end,
})

ACSection:CreateToggle({
    Title = "Auto Collect Nearby",
    Desc = "Automatically Collect Nearby Fruits",
    Value = false,
    Callback = function(v)
        pcall(function()
            spamE = v
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
        end)
    end,
})

pcall(function()
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
end)

ACSection:CreateToggle({
    Title = "Auto Sell",
    Desc = "Automatically Sell When Inventory is full.",
    Value = false,
    Callback = function(v)
        pcall(function()
            autoSellEnabled = v
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
        end)
    end,
})

ACSection:CreateToggle({
    Title = "Insta Sell",
    Desc = "Instantly Sell",
    Value = false,
    Callback = function(v)
        pcall(function()
            autoSellEnabled = v
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
        end)
    end,
})

ACSection:Line()

ACSection:Dropdown({
    Title = "Select Mutation",
    Multi = true,
	List = mutationOptions,
	Value = selectedMutations,
	Callback = function(Options)
        pcall(function()
            selectedMutations = Options
            if autoFavoriteEnabled then
                processBackpack()
            end
        end)
    end,
})

ACSection:CreateToggle({
    Title = "Auto Favorite",
    Desc = "Automatically Favorite Fruits with the right Mutations",
    Value = false,
    Callback = function(v)
        pcall(function()
            autoFavoriteEnabled = v
            if v then
                setupAutoFavorite()
            elseif connection then
                connection:Disconnect()
                connection = nil
            end
        end)
    end,
})

local function Unfavall()
    local backpack = lp:FindFirstChild("Backpack") or lp:WaitForChild("Backpack")
    for _, tool in ipairs(backpack:GetChildren()) do
        local isFavorited = tool:GetAttribute("Favorite") or (tool:FindFirstChild("Favorite") and tool.Favorite.Value)
        if isFavorited then
            favoriteEvent:FireServer(tool)
            task.wait()
        end
    end
end
