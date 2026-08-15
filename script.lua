local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = true
local clickCount = 0

local function isGreen(color)
    return color.G > 0.35 and color.R < 0.45 and color.B < 0.45
end

local function tryClick(obj)
    -- Méthode 1 : Fire direct
    pcall(function() obj.MouseButton1Click:Fire() end)
    -- Méthode 2 : executor functions
    pcall(function() firebutton(obj) end)
    pcall(function() mouse1click(obj) end)
    pcall(function() mouse1press(obj) end)
    -- Méthode 3 : VIM
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        local pos = obj.AbsolutePosition
        local size = obj.AbsoluteSize
        local cx = pos.X + size.X / 2
        local cy = pos.Y + size.Y / 2
        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
    end)
end

-- Label debug
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiAFKUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 130)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Thickness = 1

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚙ Anti-AFK"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Statut : ACTIF"
statusLabel.TextColor3 = Color3.fromRGB(100, 220, 130)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 16)
countLabel.Position = UDim2.new(0, 10, 0, 60)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Clics : 0"
countLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
countLabel.TextSize = 11
countLabel.Font = Enum.Font.Gotham
countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.Parent = frame

-- Label debug
local debugLabel = Instance.new("TextLabel")
debugLabel.Size = UDim2.new(1, -20, 0, 16)
debugLabel.Position = UDim2.new(0, 10, 0, 78)
debugLabel.BackgroundTransparency = 1
debugLabel.Text = "Debug : scan..."
debugLabel.TextColor3 = Color3.fromRGB(180, 180, 100)
debugLabel.TextSize = 10
debugLabel.Font = Enum.Font.Gotham
debugLabel.TextXAlignment = Enum.TextXAlignment.Left
debugLabel.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 28)
toggleBtn.Position = UDim2.new(0, 10, 0, 96)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Désactiver"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local function updateUI()
    if enabled then
        statusLabel.Text = "Statut : ACTIF"
        statusLabel.TextColor3 = Color3.fromRGB(100, 220, 130)
        toggleBtn.Text = "Désactiver"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
    else
        statusLabel.Text = "Statut : INACTIF"
        statusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
        toggleBtn.Text = "Activer"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    end
    countLabel.Text = "Clics : " .. clickCount
end

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    updateUI()
end)

local function clickNon()
    local found = 0
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name ~= "AntiAFKUI" then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj.Visible then
                    found += 1
                    local bg = false
                    local textOk = false

                    pcall(function()
                        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ImageButton") then
                            bg = isGreen(obj.BackgroundColor3)
                        end
                    end)

                    pcall(function()
                        if obj:IsA("TextButton") or obj:IsA("TextLabel") then
                            textOk = obj.Text:lower():gsub("%s+", "") == "non"
                        end
                    end)

                    if bg or textOk then
                        debugLabel.Text = "Trouvé: " .. obj.ClassName .. " " .. obj.Name
                        tryClick(obj)
                        clickCount += 1
                        return true
                    end
                end
            end
        end
    end
    debugLabel.Text = "Scan: " .. found .. " éléments"
    return false
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if enabled then
            local found = clickNon()
            if found then
                updateUI()
                task.wait(3)
            end
        end
    end
end)

updateUI()
