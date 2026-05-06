-- SWILL BSS HUB v3.1 - XENO FIX
local player = game.Players.LocalPlayer
local guiService = game:GetService("GuiService")
local userInputService = game:GetService("UserInputService")
local teleportService = game:GetService("TeleportService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Проверка на Xeno
local isXeno = syn and syn.crypt or false

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SWILL_BSS"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 520)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 5, 0, 0)
titleText.Text = "SWILL BSS HUB v3.1"
titleText.TextColor3 = Color3.fromRGB(255, 200, 0)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Вкладки
local tabButtons = {"Farming", "Items", "Combat", "Teleport", "Settings"}
local currentTab = "Farming"

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 35)
tabBar.BackgroundTransparency = 1
tabBar.Parent = mainFrame

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -90)
contentContainer.Position = UDim2.new(0, 10, 0, 80)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Таблицы для хранения состояний
local toggles = {}
local loops = {}

-- Функция остановки всех лупов
local function stopAllLoops()
    for k, v in pairs(loops) do
        if v then
            v = false
        end
    end
    loops = {}
end

-- Функция безопасного вызова
local function safeCall(func)
    local success, err = pcall(func)
    if not success and isXeno then
        warn("SWILL Error: " .. tostring(err))
    end
    return success
end

-- Функция создания кнопки
local function createButton(parent, text, y, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 300, 0, 35)
    btn.Position = UDim2.new(0.5, -150, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(55, 55, 70)
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

-- Функция создания переключателя
local function createToggle(parent, text, y, callback, default)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 300, 0, 35)
    btn.Position = UDim2.new(0.5, -150, 0, y)
    btn.Text = text .. " [OFF]"
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    
    local state = default or false
    local loopActive = false
    
    local updateUI = function()
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(55, 55, 70)
    end
    updateUI()
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateUI()
        callback(state)
    end)
    
    return btn, function() return state end
end

-- Функция создания выпадающего списка
local function createDropdown(parent, text, y, options, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 300, 0, 35)
    btn.Position = UDim2.new(0.5, -150, 0, y)
    btn.Text = text .. ": " .. options[1]
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
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
            return
        end
        
        dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(0, 300, 0, #options * 32)
        dropdownFrame.Position = UDim2.new(0.5, -150, 0, 35)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        dropdownFrame.BackgroundTransparency = 0.05
        dropdownFrame.Parent = parent
        local dfCorner = Instance.new("UICorner")
        dfCorner.CornerRadius = UDim.new(0, 6)
        dfCorner.Parent = dropdownFrame
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 32)
            optBtn.Position = UDim2.new(0, 0, 0, (i-1)*32)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 62)
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 13
            optBtn.Parent = dropdownFrame
            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 4)
            optCorner.Parent = optBtn
            
            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                btn.Text = text .. ": " .. selected
                callback(selected)
                dropdownFrame:Destroy()
                expanded = false
            end)
        end
        expanded = true
    end)
    
    return btn, function() return selected end
end

-- === ВКЛАДКА FARMING ===
local farmingTab = Instance.new("ScrollingFrame")
farmingTab.Name = "Farming"
farmingTab.Size = UDim2.new(1, 0, 1, 0)
farmingTab.BackgroundTransparency = 1
farmingTab.CanvasSize = UDim2.new(0, 0, 0, 500)
farmingTab.ScrollBarThickness = 6
farmingTab.Visible = true
farmingTab.Parent = contentContainer

local fieldsList = {
    "Sunflower", "Dandelion", "Mushroom", "Blue Flower",
    "Clover", "Spider", "Bamboo", "Pineapple",
    "Strawberry", "Pine Tree", "Coconut", "Pepper",
    "Rose", "Tiger", "Mountain Top", "Cactus"
}

local selectedField = "Sunflower"
local autoFarmActive = false
local autoDigActive = false
local autoSprinklerActive = false
local autoConvertActive = false
local autoBubbleActive = false

-- Автофарм
local farmLoop = nil
createToggle(farmingTab, "Auto Farm", 10, function(state)
    autoFarmActive = state
    if farmLoop then
        farmLoop = false
        farmLoop = nil
    end
    if state then
        farmLoop = true
        task.spawn(function()
            while farmLoop do
                safeCall(function()
                    -- Симуляция фарма
                    local args = {[1] = "AutoFarm", [2] = selectedField}
                    replicatedStorage:FindFirstChild("Network"):InvokeServer(unpack(args))
                end)
                task.wait(0.5)
            end
        end)
    end
end)

local fieldSelect, getField = createDropdown(farmingTab, "Select Field", 55, fieldsList, function(value)
    selectedField = value
end)

createToggle(farmingTab, "Auto Dig", 100, function(state)
    autoDigActive = state
    if autoDigActive then
        task.spawn(function()
            while autoDigActive do
                safeCall(function()
                    local args = {[1] = "AutoDig"}
                    replicatedStorage:FindFirstChild("Network"):InvokeServer(unpack(args))
                end)
                task.wait(3)
            end
        end)
    end
end)

createToggle(farmingTab, "Sprinkler", 145, function(state)
    autoSprinklerActive = state
    if autoSprinklerActive then
        task.spawn(function()
            while autoSprinklerActive do
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Sprinkler" and v:FindFirstChild("ClickDetector") then
                        safeCall(function() v.ClickDetector:Click() end)
                    end
                end
                task.wait(30)
            end
        end)
    end
end)

createToggle(farmingTab, "Convert Balloons", 190, function(state)
    autoConvertActive = state
    if autoConvertActive then
        task.spawn(function()
            while autoConvertActive do
                safeCall(function()
                    local args = {[1] = "ConvertBalloons"}
                    replicatedStorage:FindFirstChild("Network"):InvokeServer(unpack(args))
                end)
                task.wait(5)
            end
        end)
    end
end)

createToggle(farmingTab, "Farm Bubble", 235, function(state)
    autoBubbleActive = state
    if autoBubbleActive then
        task.spawn(function()
            while autoBubbleActive do
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Bubble" and v:FindFirstChild("ClickDetector") then
                        safeCall(function() v.ClickDetector:Click() end)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- === ВКЛАДКА ITEMS ===
local itemsTab = Instance.new("ScrollingFrame")
itemsTab.Name = "Items"
itemsTab.Size = UDim2.new(1, 0, 1, 0)
itemsTab.BackgroundTransparency = 1
itemsTab.CanvasSize = UDim2.new(0, 0, 0, 600)
itemsTab.ScrollBarThickness = 6
itemsTab.Visible = false
itemsTab.Parent = contentContainer

local items = {
    "Use All Buffs [Blue Pollen]", "Use All Buffs [Red Pollen]",
    "Use Blue Extract", "Use Red Extract", "Use Glitter",
    "Use Glue", "Use Oil", "Use Enzymes", "Use Tropical Drink",
    "Use Purple Potion", "Use Super Smoothie", "Use Marshmallow Bee",
    "Dispensers", "Use All Dispensers"
}

for i, itemName in ipairs(items) do
    createButton(itemsTab, itemName, 10 + (i-1) * 40, function()
        safeCall(function()
            local args = {[1] = "UseItem", [2] = itemName:gsub(" ", "")}
            replicatedStorage:FindFirstChild("Network"):InvokeServer(unpack(args))
        end)
    end)
end

-- === ВКЛАДКА COMBAT ===
local combatTab = Instance.new("ScrollingFrame")
combatTab.Name = "Combat"
combatTab.Size = UDim2.new(1, 0, 1, 0)
combatTab.BackgroundTransparency = 1
combatTab.CanvasSize = UDim2.new(0, 0, 0, 200)
combatTab.ScrollBarThickness = 6
combatTab.Visible = false
combatTab.Parent = contentContainer

createButton(combatTab, "Train Crab", 10, function()
    safeCall(function()
        local args = {[1] = "TrainCrab"}
        replicatedStorage:FindFirstChild("Network"):InvokeServer(unpack(args))
    end)
end)

createButton(combatTab, "Train Snail", 55, function()
    safeCall(function()
        local args = {[1] = "TrainSnail"}
        replicatedStorage:FindFirstChild("Network"):InvokeServer(unpack(args))
    end)
end)

local autoCombatActive = false
createToggle(combatTab, "Auto Combat", 100, function(state)
    autoCombatActive = state
    if autoCombatActive then
        task.spawn(function()
            while autoCombatActive do
                safeCall(function()
                    local args = {[1] = "AutoCombat"}
                    replicatedStorage:FindFirstChild("Network"):InvokeServer(unpack(args))
                end)
                task.wait(10)
            end
        end)
    end
end)

-- === ВКЛАДКА TELEPORT ===
local teleportTab = Instance.new("ScrollingFrame")
teleportTab.Name = "Teleport"
teleportTab.Size = UDim2.new(1, 0, 1, 0)
teleportTab.BackgroundTransparency = 1
teleportTab.CanvasSize = UDim2.new(0, 0, 0, 400)
teleportTab.ScrollBarThickness = 6
teleportTab.Visible = false
teleportTab.Parent = contentContainer

local teleportLocations = {
    {"Sunflower Field", CFrame.new(-39, 200, -226)},
    {"Blue Flower Field", CFrame.new(208, 200, -349)},
    {"Mushroom Field", CFrame.new(-406, 200, -102)},
    {"Pine Tree Forest", CFrame.new(-476, 200, 280)},
    {"Coconut Field", CFrame.new(675, 200, -115)},
    {"Your Hive", nil}
}

for i, loc in ipairs(teleportLocations) do
    createButton(teleportTab, loc[1], 10 + (i-1) * 40, function()
        safeCall(function()
            if loc[2] then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = loc[2]
                end
            else
                local args = {[1] = "TeleportToHive"}
                replicatedStorage:FindFirstChild("Network"):InvokeServer(unpack(args))
            end
        end)
    end)
end

-- === ВКЛАДКА SETTINGS ===
local settingsTab = Instance.new("ScrollingFrame")
settingsTab.Name = "Settings"
settingsTab.Size = UDim2.new(1, 0, 1, 0)
settingsTab.BackgroundTransparency = 1
settingsTab.CanvasSize = UDim2.new(0, 0, 0, 250)
settingsTab.ScrollBarThickness = 6
settingsTab.Visible = false
settingsTab.Parent = contentContainer

createButton(settingsTab, "Rejoin Server", 10, function()
    teleportService:Teleport(game.PlaceId, player)
end)

createButton(settingsTab, "Copy Discord", 55, function()
    local discordLink = "https://discord.gg/swill"
    if setclipboard then
        setclipboard(discordLink)
    elseif toclipboard then
        toclipboard(discordLink)
    end
end)

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(0, 300, 0, 80)
credits.Position = UDim2.new(0.5, -150, 0, 120)
credits.Text = "SWILL BSS HUB v3.1\nFor Xeno & Other Executors"
credits.TextColor3 = Color3.fromRGB(255, 200, 0)
credits.BackgroundTransparency = 1
credits.Font = Enum.Font.GothamBold
credits.TextSize = 14
credits.TextWrapped = true
credits.Parent = settingsTab

-- Переключение вкладок
for i, tabName in ipairs(tabButtons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
    btn.Text = tabName
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = tabBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(contentContainer:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = (child.Name == tabName)
            end
        end
        for _, tb in pairs(tabBar:GetChildren()) do
            if tb:IsA("TextButton") then
                tb.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
    end)
    
    if i == 1 then
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
    end
end

-- Уведомление
local notif = Instance.new("TextLabel")
notif.Size = UDim2.new(0, 300, 0, 40)
notif.Position = UDim2.new(0.5, -150, 0.85, 0)
notif.Text = "SWILL BSS HUB v3.1 - LOADED"
notif.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
notif.TextColor3 = Color3.fromRGB(255, 255, 255)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 14
notif.BackgroundTransparency = 0.2
notif.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notif

task.wait(3)
notif:Destroy()

print("SWILL BSS HUB v3.1 - Successfully loaded for Xeno")
