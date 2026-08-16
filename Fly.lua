local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 50
local bodyVelocity
local bodyGyro
local moveDir = Vector3.zero

local function startFly()
    flying = true
    humanoid.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = rootPart
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 1e4
    bodyGyro.Parent = rootPart
end

local function stopFly()
    flying = false
    humanoid.PlatformStand = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

RunService.Heartbeat:Connect(function()
    if not flying then return end
    local camera = workspace.CurrentCamera
    local dir = Vector3.zero
    if moveDir.X ~= 0 or moveDir.Z ~= 0 then
        dir += camera.CFrame.LookVector * -moveDir.Z
        dir += camera.CFrame.RightVector * moveDir.X
    end
    dir += Vector3.new(0, moveDir.Y, 0)
    if dir.Magnitude > 0 then
        bodyVelocity.Velocity = dir.Unit * speed
    else
        bodyVelocity.Velocity = Vector3.zero
    end
    bodyGyro.CFrame = camera.CFrame
end)

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "FlyUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
toggleBtn.Text = "Vol : OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

toggleBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        moveDir = Vector3.zero
        toggleBtn.Text = "Vol : OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    else
        startFly()
        toggleBtn.Text = "Vol : ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
    end
end)

local function makeBtn(text, pos, onDown, onUp)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Parent = gui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    btn.MouseButton1Down:Connect(onDown)
    btn.MouseButton1Up:Connect(onUp)
    return btn
end

-- Haut / Bas
makeBtn("▲", UDim2.new(1, -90, 1, -240),
    function() moveDir = Vector3.new(moveDir.X, 1, moveDir.Z) end,
    function() moveDir = Vector3.new(moveDir.X, 0, moveDir.Z) end)

makeBtn("▼", UDim2.new(1, -90, 1, -160),
    function() moveDir = Vector3.new(moveDir.X, -1, moveDir.Z) end,
    function() moveDir = Vector3.new(moveDir.X, 0, moveDir.Z) end)

-- Avant / Arrière
makeBtn("↑", UDim2.new(1, -170, 1, -200),
    function() moveDir = Vector3.new(moveDir.X, moveDir.Y, -1) end,
    function() moveDir = Vector3.new(moveDir.X, moveDir.Y, 0) end)

makeBtn("↓", UDim2.new(1, -170, 1, -120),
    function() moveDir = Vector3.new(moveDir.X, moveDir.Y, 1) end,
    function() moveDir = Vector3.new(moveDir.X, moveDir.Y, 0) end)

-- Gauche / Droite
makeBtn("←", UDim2.new(1, -250, 1, -160),
    function() moveDir = Vector3.new(-1, moveDir.Y, moveDir.Z) end,
    function() moveDir = Vector3.new(0, moveDir.Y, moveDir.Z) end)

makeBtn("→", UDim2.new(1, -90, 1, -160),
    function() moveDir = Vector3.new(1, moveDir.Y, moveDir.Z) end,
    function() moveDir = Vector3.new(0, moveDir.Y, moveDir.Z) end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    flying = false
    moveDir = Vector3.zero
    toggleBtn.Text = "Vol : OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
end)
