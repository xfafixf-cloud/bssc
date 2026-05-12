--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║                    CHAOS - BSS SCRIPT                         ║
    ║              Bee Swarm Simulator Automation                   ║
    ║                   Version: 2.0 XENO                           ║
    ║                 GitHub Release Ready                          ║
    ║                                                               ║
    ║            Created by: Anna Fant (Chaos Team)                 ║
    ║            Executor: XENO SUPPORT                             ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & VARIABLES
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Mouse = LocalPlayer:GetMouse()

-- Main Configuration
local Chaos = {
    Version = "2.0",
    Loaded = false,
    Farming = false,
    Combat = false,
    Settings = {
        AutoFarm = true,
        AutoDig = true,
        AutoSprinkler = true,
        ConvertBalloons = true,
        FarmBubble = true,
        FarmMode = "Closest", -- Closest, HighestLevel, Random, Pattern
        FarmSpeed = 55,
        LoopAutoFarm = true,
        AntiAFK = true,
        AutoRespawn = true,
        WalkSpeed = 16,
        JumpPower = 50,
        TeleportSpeed = 0.5,
        AutoCollectTokens = true,
        AutoUseItems = true,
        AutoDispensers = true,
        AutoQuest = true,
        AutoBoss = false,
        SafeMode = true,
        Notifications = true
    }
}

-- Fields List
local Fields = {
    ["Clover"] = {Position = Vector3.new(0, 0, 0), Level = 1},
    ["Bamboo"] = {Position = Vector3.new(400, 0, 0), Level = 5},
    ["Pineapple"] = {Position = Vector3.new(800, 0, 0), Level = 10},
    ["Stump"] = {Position = Vector3.new(-200, 0, 400), Level = 15},
    ["Cactus"] = {Position = Vector3.new(0, 0, 800), Level = 20},
    ["Pumpkin"] = {Position = Vector3.new(-600, 0, 200), Level = 25},
    ["PineTree"] = {Position = Vector3.new(200, 0, -400), Level = 30},
    ["Rose"] = {Position = Vector3.new(600, 0, -200), Level = 35},
    ["Spider"] = {Position = Vector3.new(-400, 0, -600), Level = 40},
    ["BambooForest"] = {Position = Vector3.new(1000, 0, 400), Level = 45},
    ["Sunflower"] = {Position = Vector3.new(-800, 0, 0), Level = 50},
    ["Mushroom"] = {Position = Vector3.new(400, 0, 800), Level = 60},
    ["BlueFlower"] = {Position = Vector3.new(-200, 0, -800), Level = 70},
    ["MountainTop"] = {Position = Vector3.new(0, 200, 0), Level = 80}
}

local SelectedField = "PineTreeForest"

-- Items Configuration
local Items = {
    BluePollen = {Enabled = false, Priority = 1},
    RedPollen = {Enabled = false, Priority = 2},
    BlueExtract = {Enabled = true, Threshold = 50},
    RedExtract = {Enabled = true, Threshold = 50},
    Glitter = {Enabled = true, Threshold = 100},
    Glue = {Enabled = true, Threshold = 100},
    Oil = {Enabled = true, Threshold = 100},
    Enzymes = {Enabled = true, Threshold = 100},
    TropicalDrink = {Enabled = false, Priority = 3},
    PurplePotion = {Enabled = false, Priority = 4},
    SuperSmoothie = {Enabled = false, Priority = 5},
    MarshmallowBee = {Enabled = false, Priority = 6}
}

-- Combat Targets
local CombatTargets = {
    Crab = {Enabled = false, Priority = 1},
    Snail = {Enabled = false, Priority = 2},
    Spider = {Enabled = false, Priority = 3},
    Mantis = {Enabled = false, Priority = 4},
    Scorpion = {Enabled = false, Priority = 5},
    Werewolf = {Enabled = false, Priority = 6}
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function Print(Message)
    if Chaos.Settings.Notifications then
        print("[CHAOS v" .. Chaos.Version .. "] " .. Message)
    end
end

local function Notify(Message, Duration)
    Duration = Duration or 3
    game.StarterGui:SetCore("SendNotification", {
        Title = "CHAOS SCRIPT",
        Text = Message,
        Duration = Duration,
        Button1 = "OK"
    })
end

local function GetDistance(Part1, Part2)
    if Part1 and Part2 then
        return (Part1.Position - Part2.Position).Magnitude
    end
    return math.huge
end

local function GetNearestObject(Tag)
    local Nearest = nil
    local MinDistance = math.huge
    
    local Objects = Workspace:FindFirstChild(Tag)
    if not Objects then return nil end
    
    for _, Object in pairs(Objects:GetChildren()) do
        if Object:IsA("BasePart") then
            local Distance = GetDistance(HumanoidRootPart, Object)
            if Distance < MinDistance and Distance < 50 then
                MinDistance = Distance
                Nearest = Object
            end
        end
    end
    
    return Nearest
end

local function GetNearestFlower()
    local Nearest = nil
    local MinDistance = math.huge
    
    local Flowers = Workspace:FindFirstChild("Flowers")
    if not Flowers then return nil end
    
    for _, Flower in pairs(Flowers:GetChildren()) do
        if Flower:IsA("BasePart") and Flower.Transparency < 1 then
            local Distance = GetDistance(HumanoidRootPart, Flower)
            if Distance < MinDistance and Distance < 30 then
                MinDistance = Distance
                Nearest = Flower
            end
        end
    end
    
    return Nearest, MinDistance
end

local function GetNearestToken()
    local Nearest = nil
    local MinDistance = math.huge
    
    local Tokens = Workspace:FindFirstChild("Tokens")
    if not Tokens then return nil end
    
    for _, Token in pairs(Tokens:GetChildren()) do
        if Token:IsA("BillboardGui") or Token:IsA("SurfaceGui") then
            local TokenPart = Token.Parent
            if TokenPart:IsA("BasePart") then
                local Distance = GetDistance(HumanoidRootPart, TokenPart)
                if Distance < MinDistance and Distance < 40 then
                    MinDistance = Distance
                    Nearest = TokenPart
                end
            end
        end
    end
    
    return Nearest
end

local function WalkTo(Position, Speed)
    Speed = Speed or Chaos.Settings.WalkSpeed
    Humanoid.WalkSpeed = Speed
    
    local Direction = (Position - HumanoidRootPart.Position)
    Direction = Vector3.new(Direction.X, 0, Direction.Z).Unit
    
    Humanoid:Move(Direction)
    
    local Distance = GetDistance(HumanoidRootPart, {Position = Position})
    return Distance < 5
end

local function TeleportTo(Position)
    local TweenInfo = TweenInfo.new(
        Chaos.Settings.TeleportSpeed,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local Goal = {CFrame = CFrame.new(Position)}
    local Tween = TweenService:Create(HumanoidRootPart, TweenInfo, Goal)
    
    Tween:Play()
end

local function Interact(Object)
    if not Object then return false end
    
    local InteractionPrompt = Object:FindFirstChild("InteractionPrompt") or 
                              Object:FindFirstChild("ClickDetector") or
                              Object:FindFirstChild("ProximityPrompt")
    
    if InteractionPrompt then
        if InteractionPrompt:IsA("ProximityPrompt") then
            InteractionPrompt:InputHoldBegin()
            task.wait(0.5)
            InteractionPrompt:InputHoldEnd()
        else
            fireproximityprompt(Object) or 
            fireclickdetector(Object)
        end
        return true
    end
    
    return false
end

-- ═══════════════════════════════════════════════════════════════
-- FARMING FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function AutoFarm()
    while Chaos.Farming and Chaos.Settings.AutoFarm do
        task.wait(Chaos.Settings.FarmSpeed / 1000)
        
        if Chaos.Settings.AutoDig then
            local Flower, Distance = GetNearestFlower()
            if Flower and Distance < 30 then
                if Distance > 5 then
                    WalkTo(Flower.Position, Chaos.Settings.WalkSpeed)
                else
                    Interact(Flower)
                end
            end
        end
        
        if Chaos.Settings.AutoCollectTokens then
            local Token = GetNearestToken()
            if Token then
                WalkTo(Token.Position, Chaos.Settings.WalkSpeed * 1.5)
            end
        end
    end
end

local function AutoSprinkler()
    while Chaos.Farming and Chaos.Settings.AutoSprinkler do
        task.wait(2)
        
        local Sprinklers = Workspace:FindFirstChild("Sprinklers")
        if Sprinklers then
            for _, Sprinkler in pairs(Sprinklers:GetChildren()) do
                if Sprinkler:IsA("BasePart") then
                    local Distance = GetDistance(HumanoidRootPart, Sprinkler)
                    if Distance < 20 then
                        Interact(Sprinkler)
                    end
                end
            end
        end
    end
end

local function ConvertBalloons()
    while Chaos.Farming and Chaos.Settings.ConvertBalloons do
        task.wait(1)
        
        local Balloons = Character:FindFirstChild("Balloons")
        if Balloons and Balloons.Value >= 10 then
            local Converter = Workspace:FindFirstChild("BalloonConverter")
            if Converter then
                WalkTo(Converter.Position, Chaos.Settings.WalkSpeed)
                Interact(Converter)
                Notify("Balloons converted!", 2)
            end
        end
    end
end

local function FarmBubble()
    while Chaos.Farming and Chaos.Settings.FarmBubble do
        task.wait(0.5)
        
        local Bubbles = Workspace:FindFirstChild("Bubbles")
        if Bubbles then
            for _, Bubble in pairs(Bubbles:GetChildren()) do
                if Bubble:IsA("BasePart") then
                    local Distance = GetDistance(HumanoidRootPart, Bubble)
                    if Distance < 15 then
                        WalkTo(Bubble.Position, Chaos.Settings.WalkSpeed * 2)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ITEMS FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function UseItem(ItemName)
    local Item = ReplicatedStorage:FindFirstChild("Items"):FindFirstChild(ItemName)
    if Item then
        fireclickdetector(Item.ClickDetector) or
        ReplicatedStorage.Remotes.UseItem:FireServer(ItemName)
        Print("Used item: " .. ItemName)
    end
end

local function UseAllBuffs(PollenType)
    local Buffs = {
        ["Blue"] = {"BlueExtract", "Glitter", "Glue", "Oil"},
        ["Red"] = {"RedExtract", "Enzymes", "TropicalDrink"}
    }
    
    local BuffList = Buffs[PollenType]
    if BuffList then
        for _, Buff in ipairs(BuffList) do
            if Items[Buff].Enabled then
                UseItem(Buff)
                task.wait(0.2)
            end
        end
    end
end

local function UseAllDispensers()
    local Dispensers = Workspace:FindFirstChild("Dispensers")
    if Dispensers then
        for _, Dispenser in pairs(Dispensers:GetChildren()) do
            if Dispenser:IsA("BasePart") then
                local Distance = GetDistance(HumanoidRootPart, Dispenser)
                if Distance < 20 then
                    Interact(Dispenser)
                    task.wait(0.5)
                end
            end
        end
    end
end

local function AutoUseItems()
    while Chaos.Farming and Chaos.Settings.AutoUseItems do
        task.wait(5)
        
        -- Check inventory and use items based on thresholds
        for ItemName, Config in pairs(Items) do
            if Config.Enabled and Config.Threshold then
                -- Simulate checking inventory count
                local CurrentCount = math.random(0, 200) -- Replace with actual inventory check
                if CurrentCount >= Config.Threshold then
                    UseItem(ItemName)
                    Notify("Used " .. ItemName, 1)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- COMBAT FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function TrainMob(MobName)
    local Mob = Workspace:FindFirstChild("Mobs"):FindFirstChild(MobName)
    if Mob then
        local MobPart = Mob:FindFirstChild("HumanoidRootPart") or Mob
        if MobPart then
            WalkTo(MobPart.Position, Chaos.Settings.WalkSpeed)
            task.wait(0.1)
        end
    end
end

local function AutoCombat()
    while Chaos.Combat do
        task.wait(0.5)
        
        for MobName, Config in pairs(CombatTargets) do
            if Config.Enabled then
                TrainMob(MobName)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- TELEPORT FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function TeleportToField(FieldName)
    local Field = Fields[FieldName]
    if Field then
        TeleportTo(Field.Position)
        SelectedField = FieldName
        Notify("Teleported to " .. FieldName, 2)
    else
        Notify("Field not found: " .. FieldName, 2)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- ANTI-AFK & SAFETY
-- ═══════════════════════════════════════════════════════════════

local function AntiAFK()
    while Chaos.Settings.AntiAFK do
        task.wait(120)
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton1(Vector2.new())
    end
end

local function AutoRespawn()
    while Chaos.Settings.AutoRespawn do
        task.wait(1)
        if Character and Character:FindFirstChild("Humanoid") then
            local Humanoid = Character.Humanoid
            if Humanoid.Health <= 0 then
                Notify("Respawning...", 2)
                task.wait(3)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- GUI CREATION
-- ═══════════════════════════════════════════════════════════════

local function CreateGUI()
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ChaosGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.BorderSizePixel = 0
    Title.Text = "CHAOS v" .. Chaos.Version .. " | BSS SCRIPT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Toggle Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -35, 0, 10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "X"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 16
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = Title
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -50)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 0)
    ContainerCorner.Parent = TabContainer
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 100, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = TabContainer
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 0)
    SidebarCorner.Parent = Sidebar
    
    -- Tab Buttons
    local Tabs = {"Home", "Farming", "Teleport", "Items", "Combat", "Setting"}
    local TabPages = {}
    
    for i, TabName in ipairs(Tabs) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = TabName .. "Tab"
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.Position = UDim2.new(0, 0, 0, (i-1) * 40)
        TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = TabName
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.TextSize = 14
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = Sidebar
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 5)
        BtnCorner.Parent = TabBtn
        
        -- Content Area
        local ContentArea = Instance.new("ScrollingFrame")
        ContentArea.Name = TabName .. "Content"
        ContentArea.Size = UDim2.new(1, -100, 1, 0)
        ContentArea.Position = UDim2.new(0, 100, 0, 0)
        ContentArea.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ContentArea.BorderSizePixel = 0
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, 500)
        ContentArea.ScrollBarThickness = 5
        ContentArea.Visible = false
        ContentArea.Parent = TabContainer
        
        TabPages[TabName] = ContentArea
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, Page in pairs(TabPages) do
                Page.Visible = false
            end
            ContentArea.Visible = true
            
            for _, Btn in ipairs(Sidebar:GetChildren()) do
                if Btn:IsA("TextButton") then
                    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            TabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
    
    -- Home Tab Content
    local HomeTitle = Instance.new("TextLabel")
    HomeTitle.Size = UDim2.new(1, -20, 0, 40)
    HomeTitle.Position = UDim2.new(0, 10, 0, 10)
    HomeTitle.BackgroundTransparency = 1
    HomeTitle.Text = "Welcome to CHAOS"
    HomeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HomeTitle.TextSize = 24
    HomeTitle.Font = Enum.Font.GothamBold
    HomeTitle.TextXAlignment = Enum.TextXAlignment.Left
    HomeTitle.Parent = TabPages["Home"]
    
    local HomeDesc = Instance.new("TextLabel")
    HomeDesc.Size = UDim2.new(1, -20, 0, 100)
    HomeDesc.Position = UDim2.new(0, 10, 0, 50)
    HomeDesc.BackgroundTransparency = 1
    HomeDesc.Text = "The most advanced Bee Swarm Simulator automation script\n\nFeatures:\n✓ Auto Farm\n✓ Auto Dig\n✓ Auto Sprinkler\n✓ Convert Balloons\n✓ Farm Bubble\n✓ Auto Items\n✓ Combat Training\n✓ Teleport\n✓ XENO Compatible"
    HomeDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    HomeDesc.TextSize = 12
    HomeDesc.Font = Enum.Font.Gotham
    HomeDesc.TextXAlignment = Enum.TextXAlignment.Left
    HomeDesc.TextYAlignment = Enum.TextYAlignment.Top
    HomeDesc.Parent = TabPages["Home"]
    
    -- Farming Tab Content
    local FarmTitle = Instance.new("TextLabel")
    FarmTitle.Size = UDim2.new(1, -20, 0, 30)
    FarmTitle.Position = UDim2.new(0, 10, 0, 10)
    FarmTitle.BackgroundTransparency = 1
    FarmTitle.Text = "Farming Settings"
    FarmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FarmTitle.TextSize = 18
    FarmTitle.Font = Enum.Font.GothamBold
    FarmTitle.TextXAlignment = Enum.TextXAlignment.Left
    FarmTitle.Parent = TabPages["Farming"]
    
    -- Farming Toggles
    local ToggleY = 50
    local function CreateToggle(Parent, Name, Default, YOffset)
        local Toggle = Instance.new("Frame")
        Toggle.Size = UDim2.new(1, -20, 0, 35)
        Toggle.Position = UDim2.new(0, 10, 0, YOffset)
        Toggle.BackgroundTransparency = 1
        Toggle.Parent = Parent
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Toggle
        
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
        ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
        ToggleBtn.BackgroundColor3 = Default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 200, 200)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Text = Default and "ON" or "OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextSize = 12
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.Parent = Toggle
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 12)
        BtnCorner.Parent = ToggleBtn
        
        local Enabled = Default
        
        ToggleBtn.MouseButton1Click:Connect(function()
            Enabled = not Enabled
            ToggleBtn.BackgroundColor3 = Enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 200, 200)
            ToggleBtn.Text = Enabled and "ON" or "OFF"
            
            -- Update settings
            if Name == "Autofarm" then Chaos.Settings.AutoFarm = Enabled
            elseif Name == "Auto Dig" then Chaos.Settings.AutoDig = Enabled
            elseif Name == "Sprinkler" then Chaos.Settings.AutoSprinkler = Enabled
            elseif Name == "Convert Ballons" then Chaos.Settings.ConvertBalloons = Enabled
            elseif Name == "Farm Bubble" then Chaos.Settings.FarmBubble = Enabled
            end
            
            if Enabled and Name == "Autofarm" then
                Chaos.Farming = true
                Notify("AutoFarm Started", 2)
            elseif not Enabled and Name == "Autofarm" then
                Chaos.Farming = false
                Notify("AutoFarm Stopped", 2)
            end
        end)
        
        return Toggle
    end
    
    CreateToggle(TabPages["Farming"], "Autofarm", true, ToggleY); ToggleY += 40
    CreateToggle(TabPages["Farming"], "Auto Dig", true, ToggleY); ToggleY += 40
    CreateToggle(TabPages["Farming"], "Sprinkler", true, ToggleY); ToggleY += 40
    CreateToggle(TabPages["Farming"], "Convert Ballons", true, ToggleY); ToggleY += 40
    CreateToggle(TabPages["Farming"], "Farm Bubble", false, ToggleY)
    
    -- Field Selection
    local FieldLabel = Instance.new("TextLabel")
    FieldLabel.Size = UDim2.new(1, -20, 0, 30)
    FieldLabel.Position = UDim2.new(0, 10, 0, ToggleY + 10)
    FieldLabel.BackgroundTransparency = 1
    FieldLabel.Text = "Select Field:"
    FieldLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FieldLabel.TextSize = 14
    FieldLabel.Font = Enum.Font.Gotham
    FieldLabel.TextXAlignment = Enum.TextXAlignment.Left
    FieldLabel.Parent = TabPages["Farming"]
    
    local FieldDropdown = Instance.new("TextBox")
    FieldDropdown.Size = UDim2.new(1, -20, 0, 30)
    FieldDropdown.Position = UDim2.new(0, 10, 0, ToggleY + 45)
    FieldDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    FieldDropdown.BorderSizePixel = 0
    FieldDropdown.Text = SelectedField
    FieldDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    FieldDropdown.TextSize = 14
    FieldDropdown.Font = Enum.Font.Gotham
    FieldDropdown.Parent = TabPages["Farming"]
    
    local FieldCorner = Instance.new("UICorner")
    FieldCorner.CornerRadius = UDim.new(0, 5)
    FieldCorner.Parent = FieldDropdown
    
    -- Items Tab Content
    local ItemsTitle = Instance.new("TextLabel")
    ItemsTitle.Size = UDim2.new(1, -20, 0, 30)
    ItemsTitle.Position = UDim2.new(0, 10, 0, 10)
    ItemsTitle.BackgroundTransparency = 1
    ItemsTitle.Text = "Items Manager"
    ItemsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ItemsTitle.TextSize = 18
    ItemsTitle.Font = Enum.Font.GothamBold
    ItemsTitle.TextXAlignment = Enum.TextXAlignment.Left
    ItemsTitle.Parent = TabPages["Items"]
    
    local ItemY = 50
    local ItemList = {
        "Use All Buffs [Blue Pollen]",
        "Use All Buffs [Red Pollen]",
        "Use Blue Extract",
        "Use Red Extract",
        "Use Glitter",
        "Use Glue",
        "Use Oil",
        "Use Enzymes",
        "Use Tropical Drink",
        "Use Purple Potion",
        "Use Super Smoothie",
        "Use Marshmallow Bee",
        "Use All Dispensers"
    }
    
    for _, ItemName in ipairs(ItemList) do
        local ItemBtn = Instance.new("TextButton")
        ItemBtn.Size = UDim2.new(1, -20, 0, 35)
        ItemBtn.Position = UDim2.new(0, 10, 0, ItemY)
        ItemBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ItemBtn.BorderSizePixel = 0
        ItemBtn.Text = ItemName
        ItemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ItemBtn.TextSize = 13
        ItemBtn.Font = Enum.Font.Gotham
        ItemBtn.Parent = TabPages["Items"]
        
        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 5)
        ItemCorner.Parent = ItemBtn
        
        ItemBtn.MouseButton1Click:Connect(function()
            if ItemName == "Use All Buffs [Blue Pollen]" then
                UseAllBuffs("Blue")
            elseif ItemName == "Use All Buffs [Red Pollen]" then
                UseAllBuffs("Red")
            else
                local CleanName = ItemName:gsub("Use ", "")
                UseItem(CleanName)
            end
            Notify("Used: " .. ItemName, 1)
        end)
        
        ItemY += 40
    end
    
    -- Combat Tab Content
    local CombatTitle = Instance.new("TextLabel")
    CombatTitle.Size = UDim2.new(1, -20, 0, 30)
    CombatTitle.Position = UDim2.new(0, 10, 0, 10)
    CombatTitle.BackgroundTransparency = 1
    CombatTitle.Text = "Combat Training"
    CombatTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    CombatTitle.TextSize = 18
    CombatTitle.Font = Enum.Font.GothamBold
    CombatTitle.TextXAlignment = Enum.TextXAlignment.Left
    CombatTitle.Parent = TabPages["Combat"]
    
    local CombatY = 50
    CreateToggle(TabPages["Combat"], "Train Crab", false, CombatY); CombatY += 40
    CreateToggle(TabPages["Combat"], "Train Snail", false, CombatY)
    
    -- Settings Tab Content
    local SettingsTitle = Instance.new("TextLabel")
    SettingsTitle.Size = UDim2.new(1, -20, 0, 30)
    SettingsTitle.Position = UDim2.new(0, 10, 0, 10)
    SettingsTitle.BackgroundTransparency = 1
    SettingsTitle.Text = "Settings"
    SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsTitle.TextSize = 18
    SettingsTitle.Font = Enum.Font.GothamBold
    SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    SettingsTitle.Parent = TabPages["Setting"]
    
    local SettingsY = 50
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, -20, 0, 30)
    SpeedLabel.Position = UDim2.new(0, 10, 0, SettingsY)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "AutoFarm Speed: " .. Chaos.Settings.FarmSpeed
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextSize = 14
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = TabPages["Setting"]
    
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Size = UDim2.new(1, -20, 0, 20)
    SpeedSlider.Position = UDim2.new(0, 10, 0, SettingsY + 35)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Parent = TabPages["Setting"]
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 10)
    SliderCorner.Parent = SpeedSlider
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(Chaos.Settings.FarmSpeed / 100, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SpeedSlider
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = SliderFill
    
    -- Keybind Info
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(1, -20, 0, 50)
    KeybindLabel.Position = UDim2.new(0, 10, 0, SettingsY + 70)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = "Toggle UI: LeftAlt + K\nScript will auto-start on load"
    KeybindLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    KeybindLabel.TextSize = 12
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = TabPages["Setting"]
    
    -- Show GUI Keybind
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        
        if Input.KeyCode == Enum.KeyCode.K and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    Print("GUI Loaded. Press LeftAlt + K to toggle.")
    return ScreenGui
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN EXECUTION
-- ═══════════════════════════════════════════════════════════════

local function Initialize()
    if Chaos.Loaded then
        Print("Script already loaded!")
        return
    end
    
    Chaos.Loaded = true
    Print("CHAOS v" .. Chaos.Version .. " initializing...")
    
    -- Create GUI
    local GUI = CreateGUI()
    
    -- Start threads
    spawn(AutoFarm)
    spawn(AutoSprinkler)
    spawn(ConvertBalloons)
    spawn(FarmBubble)
    spawn(AutoUseItems)
    spawn(AutoCombat)
    spawn(AntiAFK)
    spawn(AutoRespawn)
    
    Notify("CHAOS v" .. Chaos.Version .. " loaded successfully!", 3)
    Print("All systems operational. Ready to farm.")
end

-- Auto-execute
task.spawn(Initialize)

-- ═══════════════════════════════════════════════════════════════
-- END OF SCRIPT
-- ═══════════════════════════════════════════════════════════════
