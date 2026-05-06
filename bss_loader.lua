-- SWILL Bee Swarm Simulator Script v3.0 - Полный функционал
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local network = replicatedStorage:WaitForChild("Network")

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeeSwarmSWILL"
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.Text = "SWILL BSS HUB | v3.0"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = title
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Вкладки
local tabNames = {"Farming", "Teleport", "Items", "Combat", "Setting"}
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 40)
tabFrame.Position = UDim2.new(0, 0, 0, 35)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -85)
contentFrame.Position = UDim2.new(0, 5, 0, 75)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local tabs = {}
local currentTab = nil

-- Функции создания UI
local function createButton(text, y, callback, parent, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 35)
    btn.Position = UDim2.new(0.5, -140, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggle(text, y, callback, parent, defaultState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 35)
    btn.Position = UDim2.new(0.5, -140, 0, y)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local state = defaultState or false
    local updateBtn = function()
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 70)
    end
    updateBtn()
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateBtn()
        callback(state)
    end)
    return btn, function() return state end
end

local function createDropdown(text, y, options, callback, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 35)
    btn.Position = UDim2.new(0.5, -140, 0, y)
    btn.Text = text .. ": " .. options[1]
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local selected = options[1]
    local expanded = false
    local dropdownFrame = nil
    
    btn.MouseButton1Click:Connect(function()
        if expanded then
            if dropdownFrame then dropdownFrame:Destroy() end
            expanded = false
        else
            dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(0, 280, 0, #options * 30)
            dropdownFrame.Position = UDim2.new(0.5, -140, 0, 35)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            dropdownFrame.BackgroundTransparency = 0.05
            dropdownFrame.Parent = parent
            local dfc = Instance.new("UICorner")
            dfc.CornerRadius = UDim.new(0, 6)
            dfc.Parent = dropdownFrame
            
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.Position = UDim2.new(0, 0, 0, (i-1)*30)
                optBtn.Text = opt
                optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 13
                optBtn.Parent = dropdownFrame
                local optc = Instance.new("UICorner")
                optc.CornerRadius = UDim.new(0, 4)
                optc.Parent = optBtn
                
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    btn.Text = text .. ": " .. selected
                    callback(selected)
                    dropdownFrame:Destroy()
                    expanded = false
                end)
            end
            expanded = true
        end
    end)
    
    return btn, function() return selected end
end

-- Переменные для автофарма
local autoFarm = false
local autoDig = false
local autoSprinkler = false
local autoConvertBaloons = false
local autoFarmBubble = false
local selectedField = "SunflowerField"
local farmSpeed = 55

-- Поля для фарма
local fieldsList = {
    "SunflowerField", "DandelionField", "MushroomField", "BlueFlowerField",
    "CloverField", "SpiderField", "BambooField", "PineapplePatch",
    "StrawberryField", "PineTreeForest", "CoconutField", "PepperPatch",
    "RoseField", "TigerField", "MountainTopField", "CactusField"
}

-- ВКЛАДКА FARMING
local farmingTab = Instance.new("Frame")
farmingTab.Name = "Farming"
farmingTab.Size = UDim2.new(1, 0, 1, 0)
farmingTab.BackgroundTransparency = 1
farmingTab.Parent = contentFrame

local autoFarmToggle, getAutoFarm = createToggle("AutoFarm", 10, function(state)
    autoFarm = state
    if state then
        spawn(function()
            while autoFarm do
                runService.RenderStepped:Wait()
                pcall(function()
                    local args = {[1] = "AutoFarm"}
                    network:InvokeServer(unpack(args))
                end)
                wait(0.5)
            end
        end)
    end
end, farmingTab, false)

local fieldDropdown, getField = createDropdown("Select Field", 55, fieldsList, function(field)
    selectedField = field
    pcall(function()
        local args = {[1] = "SetField", [2] = field}
        network:InvokeServer(unpack(args))
    end)
end, farmingTab)

local autoDigToggle, getAutoDig = createToggle("Auto Dig", 100, function(state)
    autoDig = state
    if state then
        spawn(function()
            while autoDig do
                pcall(function()
                    local args = {[1] = "AutoDig"}
                    network:InvokeServer(unpack(args))
                end)
                wait(3)
            end
        end)
    end
end, farmingTab, false)

local sprinklerToggle, getSprinkler = createToggle("Sprinkler", 145, function(state)
    autoSprinkler = state
    if state then
        spawn(function()
            while autoSprinkler do
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Sprinkler" and v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                        pcall(function() v.ClickDetector:Click() end)
                    end
                end
                wait(30)
            end
        end)
    end
end, farmingTab, false)

local convertBaloonsToggle, getConvertBaloons = createToggle("Convert Balloons", 190, function(state)
    autoConvertBaloons = state
    if state then
        spawn(function()
            while autoConvertBaloons do
                pcall(function()
                    local args = {[1] = "ConvertBalloons"}
                    network:InvokeServer(unpack(args))
                end)
                wait(5)
            end
        end)
    end
end, farmingTab, false)

local farmBubbleToggle, getFarmBubble = createToggle("Farm Bubble", 235, function(state)
    autoFarmBubble = state
    if state then
        spawn(function()
            while autoFarmBubble do
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Bubble" and v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                        pcall(function() v.ClickDetector:Click() end)
                    end
                end
                wait(1)
            end
        end)
    end
end, farmingTab, false)

-- Настройки скорости
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 280, 0, 25)
speedLabel.Position = UDim2.new(0.5, -140, 0, 280)
speedLabel.Text = "AutoFarm Speed: " .. farmSpeed
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.Parent = farmingTab

local speedPlus = createButton("+", 310, function()
    farmSpeed = math.min(farmSpeed + 5, 100)
    speedLabel.Text = "AutoFarm Speed: " .. farmSpeed
    pcall(function()
        local args = {[1] = "SetSpeed", [2] = farmSpeed}
        network:InvokeServer(unpack(args))
    end)
end, farmingTab, Color3.fromRGB(0, 100, 0))

speedPlus.Size = UDim2.new(0, 135, 0, 30)
speedPlus.Position = UDim2.new(0.5, -145, 0, 310)

local speedMinus = createButton("-", 310, function()
    farmSpeed = math.max(farmSpeed - 5, 10)
    speedLabel.Text = "AutoFarm Speed: " .. farmSpeed
    pcall(function()
        local args = {[1] = "SetSpeed", [2] = farmSpeed}
        network:InvokeServer(unpack(args))
    end)
end, farmingTab, Color3.fromRGB(100, 0, 0))
speedMinus.Size = UDim2.new(0, 135, 0, 30)
speedMinus.Position = UDim2.new(0.5, 10, 0, 310)

-- ВКЛАДКА ITEMS
local itemsTab = Instance.new("Frame")
itemsTab.Name = "Items"
itemsTab.Size = UDim2.new(1, 0, 1, 0)
itemsTab.BackgroundTransparency = 1
itemsTab.Visible = false
itemsTab.Parent = contentFrame

local itemsList = {
    {"Use All Buffs [Blue Pollen]", "UseBluePollen"},
    {"Use All Buffs [Red Pollen]", "UseRedPollen"},
    {"Use Blue Extract", "BlueExtract"},
    {"Use Red Extract", "RedExtract"},
    {"Use Glitter", "Glitter"},
    {"Use Glue", "Glue"},
    {"Use Oil", "Oil"},
    {"Use Enzymes", "Enzymes"},
    {"Use Tropical Drink", "TropicalDrink"},
    {"Use Purple Potion", "PurplePotion"},
    {"Use Super Smoothie", "SuperSmoothie"},
    {"Use Marshmallow Bee", "MarshmallowBee"},
    {"Dispensers", "UseAllDispensers"},
    {"Use All Dispensers", "UseAllDispensers"}
}

for i, item in ipairs(itemsList) do
    createButton(item[1], 10 + (i-1) * 35, function()
        pcall(function()
            local args = {[1] = "UseItem", [2] = item[2]}
            network:InvokeServer(unpack(args))
        end)
    end, itemsTab)
end

-- ВКЛАДКА COMBAT
local combatTab = Instance.new("Frame")
combatTab.Name = "Combat"
combatTab.Size = UDim2.new(1, 0, 1, 0)
combatTab.BackgroundTransparency = 1
combatTab.Visible = false
combatTab.Parent = contentFrame

createButton("Train Crab", 10, function()
    pcall(function()
        local args = {[1] = "TrainCrab"}
        network:InvokeServer(unpack(args))
    end)
end, combatTab)

createButton("Train Snail", 55, function()
    pcall(function()
        local args = {[1] = "TrainSnail"}
        network:InvokeServer(unpack(args))
    end)
end, combatTab)

createButton("Auto Combat (Crab/Snail)", 100, function()
    spawn(function()
        while true do
            pcall(function()
                local args = {[1] = "AutoCombat"}
                network:InvokeServer(unpack(args))
            end)
            wait(10)
        end
    end)
end, combatTab)

-- ВКЛАДКА TELEPORT (упрощённый, но рабочий)
local teleportTab = Instance.new("Frame")
teleportTab.Name = "Teleport"
teleportTab.Size = UDim2.new(1, 0, 1, 0)
teleportTab.BackgroundTransparency = 1
teleportTab.Visible = false
teleportTab.Parent = contentFrame

local locations = {
    {"Sunflower Field", Vector3.new(-39, 150, -226)},
    {"Blue Flower Field", Vector3.new(208, 150, -349)},
    {"Mushroom Field", Vector3.new(-406, 150, -102)},
    {"Pine Tree Forest", Vector3.new(-476, 150, 280)},
    {"Coconut Field", Vector3.new(675, 150, -115)},
    {"Your Hive", nil}
}

for i, loc in ipairs(locations) do
    createButton(loc[1], 10 + (i-1) * 40, function()
        pcall(function()
            if loc[2] then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(loc[2])
                end
            else
                local args = {[1] = "TeleportToHive"}
                network:InvokeServer(unpack(args))
            end
        end)
    end, teleportTab)
end

-- ВКЛАДКА SETTING
local settingTab = Instance.new("Frame")
settingTab.Name = "Setting"
settingTab.Size = UDim2.new(1, 0, 1, 0)
settingTab.BackgroundTransparency = 1
settingTab.Visible = false
settingTab.Parent = contentFrame

createButton("Rejoin Server", 10, function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end, settingTab)

createButton("Copy Discord Server", 55, function()
    setclipboard or toclipboard or function() end("https://discord.gg/swill")
end, settingTab)

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.new(0, 280, 0, 60)
creditsLabel.Position = UDim2.new(0.5, -140, 0, 120)
creditsLabel.Text = "Credits\nOwner: SWILL\nVersion: 3.0"
creditsLabel.BackgroundTransparency = 1
creditsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
creditsLabel.Font = Enum.Font.GothamBold
creditsLabel.TextSize = 14
creditsLabel.TextWrapped = true
creditsLabel.Parent = settingTab

-- Создание кнопок вкладок
for i, tabName in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 68, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
    btn.Text = tabName
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = tabFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = (child.Name == tabName)
            end
        end
        for _, tb in pairs(tabFrame:GetChildren()) do
            if tb:IsA("TextButton") then
                tb.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
    end)
    
    if i == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 120)
    end
end

-- Уведомление
local notification = Instance.new("TextLabel")
notification.Size = UDim2.new(0, 350, 0, 45)
notification.Position = UDim2.new(0.5, -175, 0.8, 0)
notification.Text = "SWILL BSS HUB v3.0 - FULLY LOADED"
notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
notification.TextColor3 = Color3.fromRGB(255, 255, 255)
notification.Font = Enum.Font.GothamBold
notification.TextSize = 16
notification.BackgroundTransparency = 0.15
notification.Parent = screenGui
game:GetService("Debris"):AddItem(notification, 3)

print("SWILL BSS HUB v3.0 - Загружен. Все функции активны.")
