local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = true
local clickCount = 0

local function clickNo(gui)
    if not enabled then return end
    -- Attend que les boutons soient chargés
    task.wait(1)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Text == "No" and obj.Visible then
            warn("Bouton No trouve!")
            pcall(function() obj.MouseButton1Click:Fire() end)
            pcall(function()
                for _, c in ipairs(getconnections(obj.MouseButton1Click)) do
                    c:Fire()
                end
            end)
            clickCount += 1
            return true
        end
    end
    warn("No introuvable")
end

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiAFKUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 110)
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
titleLabel.Text = "Anti-AFK"
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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 28)
toggleBtn.Position = UDim2.new(0, 10, 0, 76)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Desactiver"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local function updateUI()
    if enabled then
        statusLabel.Text = "Statut : ACTIF"
        statusLabel.TextColor3 = Color3.fromRGB(100, 220, 130)
        toggleBtn.Text = "Desactiver"
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

-- Ecoute AntiAFKGUI via DescendantAdded du bouton No
playerGui.ChildAdded:Connect(function(child)
    if child.Name == "AntiAFKGUI" then
        warn("AntiAFKGUI detecte!")
        -- Attend le bouton No directement
        child.DescendantAdded:Connect(function(obj)
            if obj:IsA("TextButton") and obj.Text == "No" then
                warn("Bouton No ajoute!")
                task.wait(0.3)
                pcall(function() obj.MouseButton1Click:Fire() end)
                pcall(function()
                    for _, c in ipairs(getconnections(obj.MouseButton1Click)) do
                        c:Fire()
                    end
                end)
                clickCount += 1
                updateUI()
            end
        end)
        -- Check si deja present
        task.spawn(function()
            local clicked = clickNo(child)
            if clicked then updateUI() end
        end)
    end
end)

local existing = playerGui:FindFirstChild("AntiAFKGUI")
if existing then
    task.spawn(function()
        local clicked = clickNo(existing)
        if clicked then updateUI() end
    end)
end

updateUI()
