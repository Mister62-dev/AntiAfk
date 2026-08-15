local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = true
local clickCount = 0

local function isGreen(color)
    return color.G > 0.35 and color.R < 0.45 and color.B < 0.45
end

local function clickNon()
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui.Name ~= "AntiAFKUI" then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj.Visible then
                    local bg = false
                    local textOk = false

                    if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        pcall(function() bg = isGreen(obj.BackgroundColor3) end)
                    end

                    if obj:IsA("TextButton") or obj:IsA("TextLabel") then
                        pcall(function()
                            textOk = obj.Text:lower():gsub("%s+", "") == "non"
                        end)
                    end

                    if bg or textOk then
                        local pos = obj.AbsolutePosition
                        local size = obj.AbsoluteSize
                        local cx = pos.X + size.X / 2
                        local cy = pos.Y + size.Y / 2

                        pcall(function()
                            VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                            task.wait(0.05)
                            VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                        end)

                        pcall(function()
                            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                obj.MouseButton1Click:Fire()
                            end
                        end)

                        clickCount += 1
                        return true
                    end
                end
            end
        end
    end
    return false
end

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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 28)
toggleBtn.Position = UDim2.new(0, 10, 0, 76)
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
