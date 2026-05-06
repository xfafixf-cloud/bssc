-- SWILL Bee Swarm Simulator Script v2.0
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeeSwarmSWILL"
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "SWILL BSS HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = title
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Вкладки
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 30)
tabFrame.Position = UDim2.new(0, 0, 0, 30)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabs = {"Фарм", "Авто-игры", "Телепорты"}
local selectedTab = 1

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -60)
contentFrame.Position = UDim2.new(0, 0, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Функция создания кнопок
local function createButton(text, y, callback, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 35)
    btn.Position = UDim2.new(0.5, -130, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 5)
    cornerBtn.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggle(text, y, callback, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 35)
    btn.Position = UDim2.new(0.5, -130, 0, y)
    btn.Text = text .. ": ❌"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 5)
    cornerBtn.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "✅" or "❌")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
    return btn
end

-- Вкладка: Фарм
local farmTab = Instance.new("Frame")
farmTab.Name = "Фарм"
farmTab.Size = UDim2.new(1, 0, 1, 0)
farmTab.BackgroundTransparency = 1
farmTab.Parent = contentFrame

local autoPollen = false
local autoConvert = false

createToggle("Авто-пыльца", 10, function(state)
    autoPollen = state
    if state then
        game:GetService("RunService").RenderStepped:Connect(function()
            if autoPollen then
                pcall(function()
                    local args = {[1] = "AutoPollen"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):InvokeServer(unpack(args))
                end)
            end
        end)
    end
end, farmTab)

createToggle("Авто-конверт", 60, function(state)
    autoConvert = state
    if state then
        spawn(function()
            while autoConvert do
                pcall(function()
                    local args = {[1] = "AutoConvert"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):InvokeServer(unpack(args))
                end)
                wait(2)
            end
        end)
    end
end, farmTab)

createButton("🔧 Использовать способности 🔧", 110, function()
    pcall(function()
        for _, v in pairs(player.Character:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Ability") then
                v.Ability:FireServer()
            end
        end
    end)
end, farmTab)

-- Вкладка: Авто-игры
local gamesTab = Instance.new("Frame")
gamesTab.Name = "Авто-игры"
gamesTab.Size = UDim2.new(1, 0, 1, 0)
gamesTab.BackgroundTransparency = 1
gamesTab.Visible = false
gamesTab.Parent = contentFrame

local autoBlackBear = false
createToggle("Авто-квесты: Чёрный медведь", 10, function(state)
    autoBlackBear = state
    if state then
        spawn(function()
            while autoBlackBear do
                pcall(function()
                    local args = {[1] = "BlackBear"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):InvokeServer(unpack(args))
                end)
                wait(30)
            end
        end)
    end
end, gamesTab)

createButton("📦 Собрать пам. вещи 📦", 60, function()
    pcall(function()
        for _, v in pairs(workspace.MemoryMatches:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                v.ClickDetector:Click()
            end
        end
    end)
end, gamesTab)

createButton("🍯 Собрать мед 🍯", 110, function()
    pcall(function()
        for _, v in pairs(workspace.Honey:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                v.ClickDetector:Click()
            end
        end
    end)
end, gamesTab)

-- Вкладка: Телепорты
local teleportTab = Instance.new("Frame")
teleportTab.Name = "Телепорты"
teleportTab.Size = UDim2.new(1, 0, 1, 0)
teleportTab.BackgroundTransparency = 1
teleportTab.Visible = false
teleportTab.Parent = contentFrame

local locations = {
    {"🌸 Поле №1", Vector3.new(-100, 10, -200)},
    {"🍯 Поле №2", Vector3.new(150, 10, 50)},
    {"🐻 Дом медведя", Vector3.new(-300, 10, 300)},
    {"💎 Горная вершина", Vector3.new(500, 100, -400)},
    {"🕷️ Паутинное поле", Vector3.new(-400, 10, -500)},
    {"🍀 Удача поле", Vector3.new(-200, 10, 400)}
}

for i, loc in ipairs(locations) do
    createButton(loc[1], 10 + (i-1) * 45, function()
        pcall(function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(loc[2])
            end
        end)
    end, teleportTab)
end

-- Создание вкладок
local function createTabButton(name, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(pos, 0, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = tabFrame
    
    local cornerBtn = Instance.new("UICorner")
    cornerBtn.CornerRadius = UDim.new(0, 5)
    cornerBtn.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") then
                child.Visible = (child.Name == name)
            end
        end
    end)
end

for i, tabName in ipairs(tabs) do
    createTabButton(tabName, (i-1) * 0.33)
end

-- Уведомление
local notification = Instance.new("TextLabel")
notification.Size = UDim2.new(0, 300, 0, 40)
notification.Position = UDim2.new(0.5, -150, 0.8, 0)
notification.Text = "SWILL BSS HUB ✅"
notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
notification.TextColor3 = Color3.fromRGB(255, 255, 255)
notification.Font = Enum.Font.GothamBold
notification.TextSize = 16
notification.BackgroundTransparency = 0.2
notification.Parent = screenGui
game:GetService("Debris"):AddItem(notification, 2)

print("SWILL BSS HUB - Загружен")