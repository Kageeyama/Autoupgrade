--==============================
-- SERVICES
--==============================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")
local collectRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("CollectCash")

--==============================
-- DATA & LOGIC
--==============================
local enabledUpgrade = false
local enabledCollect = false
local enabledESP = false
local flying = false
local flySpeed = 50
local NPC_IDS = {}
local espObjects = {}
_G.NPC_IDS = NPC_IDS

--==============================
-- MODERN GUI CREATION
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MyzoarnHub_V3_Final"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 420)
frame.Position = UDim2.new(0.5, -140, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 2

-- HEADER
local header = Instance.new("TextLabel", frame)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.Text = "MYZOARN HUB V3 (MOBILE)"
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBold
header.TextSize = 15
Instance.new("UICorner", header)

-- CONTAINER
local container = Instance.new("Frame", frame)
container.Size = UDim2.new(1, -20, 1, -60)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- STATUS
local status = Instance.new("TextLabel", container)
status.Size = UDim2.new(1, 0, 0, 20)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Text = "Captured IDs: 0"

-- BUTTON CREATOR
local function createBtn(text, color)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local toggleUpgrade = createBtn("Auto Upgrade: OFF", Color3.fromRGB(40, 40, 40))
local toggleCollect = createBtn("Auto Collect: OFF", Color3.fromRGB(40, 40, 40))
local toggleFly = createBtn("Fly Mode: OFF", Color3.fromRGB(40, 40, 40))
local toggleESP = createBtn("Secret/God ESP: OFF", Color3.fromRGB(40, 40, 40))
local clearBtn = createBtn("Clear NPC IDs", Color3.fromRGB(60, 30, 30))
local hideBtn = createBtn("Minimize GUI", Color3.fromRGB(30, 30, 30))

-- FLY CONTROLS
local flyControls = Instance.new("Frame", gui)
flyControls.Size = UDim2.new(0, 60, 0, 130)
flyControls.Position = UDim2.new(0.85, 0, 0.5, -65)
flyControls.BackgroundTransparency = 1
flyControls.Visible = false

local function createFlyArrow(text, pos)
    local btn = Instance.new("TextButton", flyControls)
    btn.Size = UDim2.new(0, 55, 0, 55)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.5
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 30
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end
local upBtn = createFlyArrow("↑", UDim2.new(0, 0, 0, 0))
local downBtn = createFlyArrow("↓", UDim2.new(0, 0, 0, 65))

local showBtn = Instance.new("TextButton", gui)
showBtn.Size = UDim2.new(0, 60, 0, 60)
showBtn.Position = UDim2.new(0, 20, 0.7, 0)
showBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
showBtn.Text = "OPEN"
showBtn.TextColor3 = Color3.new(1, 1, 1)
showBtn.Visible = false
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(1, 0)

--==============================
-- UPDATED SMART ESP LOGIC
--==============================
local function createESP(parent, rarityText)
    local t = rarityText:lower()
    local color = Color3.fromRGB(255, 255, 255)
    
    if t:find("god") then
        color = Color3.fromRGB(255, 0, 0) -- Merah untuk God
    elseif t:find("secret") then
        color = Color3.fromRGB(255, 85, 255) -- Ungu untuk Secret
    elseif t:find("brainrot") then
        color = Color3.fromRGB(0, 255, 255) -- Cyan untuk Brainrot
    end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = parent:GetExtentsSize()
    box.Parent = parent
    box.Adornee = parent
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.4
    box.Color3 = color
    
    local bb = Instance.new("BillboardGui", parent)
    bb.Size = UDim2.new(0, 160, 0, 40)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 5, 0)
    
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "★ " .. rarityText:upper() .. " ★"
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 15
    lbl.TextStrokeTransparency = 0

    table.insert(espObjects, {box, bb})
end

local function refreshESP()
    for _, obj in pairs(espObjects) do
        if obj[1] then obj[1]:Destroy() end
        if obj[2] then obj[2]:Destroy() end
    end
    espObjects = {}

    if enabledESP then
        for _, v in pairs(workspace:GetDescendants()) do
            -- Deteksi ID panjang dari gambar
            if v:IsA("Model") and #v.Name > 20 then
                for _, child in pairs(v:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        local textValue = child.Text:lower()
                        if textValue:find("god") or textValue:find("secret") or textValue:find("brainrot") then
                            createESP(v, child.Text)
                            break
                        end
                    end
                end
            end
        end
    end
end

--==============================
-- FLY LOGIC
--==============================
local movingUp, movingDown = false, false
upBtn.MouseButton1Down:Connect(function() movingUp = true end)
upBtn.MouseButton1Up:Connect(function() movingUp = false end)
downBtn.MouseButton1Down:Connect(function() movingDown = true end)
downBtn.MouseButton1Up:Connect(function() movingDown = false end)

local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    hum.PlatformStand = true
    task.spawn(function()
        while flying and char.Parent do
            local dir = hum.MoveDirection
            local v = movingUp and 1 or (movingDown and -1 or 0)
            bv.Velocity = (dir * flySpeed) + (Vector3.new(0, v, 0) * flySpeed)
            bg.CFrame = workspace.CurrentCamera.CFrame
            RunService.RenderStepped:Wait()
        end
        bg:Destroy() bv:Destroy() hum.PlatformStand = false
    end)
end

--==============================
-- ANTI-AFK
--==============================
player.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(0.5)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--==============================
-- BUTTON ACTIONS
--==============================
toggleESP.MouseButton1Click:Connect(function()
    enabledESP = not enabledESP
    toggleESP.Text = enabledESP and "ESP: ON (SCANNING)" or "ESP: OFF"
    TweenService:Create(toggleESP, TweenInfo.new(0.3), {BackgroundColor3 = enabledESP and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(40, 40, 40)}):Play()
    refreshESP()
end)

task.spawn(function()
    while task.wait(5) do
        if enabledESP then refreshESP() end
    end
end)

toggleFly.MouseButton1Click:Connect(function()
    flying = not flying
    flyControls.Visible = flying
    toggleFly.Text = flying and "Fly: ON" or "Fly: OFF"
    TweenService:Create(toggleFly, TweenInfo.new(0.3), {BackgroundColor3 = flying and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(40, 40, 40)}):Play()
    if flying then startFly() end
end)

toggleUpgrade.MouseButton1Click:Connect(function()
    enabledUpgrade = not enabledUpgrade
    toggleUpgrade.Text = enabledUpgrade and "Upgrade: ON" or "Upgrade: OFF"
    TweenService:Create(toggleUpgrade, TweenInfo.new(0.3), {BackgroundColor3 = enabledUpgrade and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(40, 40, 40)}):Play()
end)

toggleCollect.MouseButton1Click:Connect(function()
    enabledCollect = not enabledCollect
    toggleCollect.Text = enabledCollect and "Collect: ON" or "Collect: OFF"
    TweenService:Create(toggleCollect, TweenInfo.new(0.3), {BackgroundColor3 = enabledCollect and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(40, 40, 40)}):Play()
end)

clearBtn.MouseButton1Click:Connect(function() table.clear(NPC_IDS) status.Text = "Captured IDs: 0" end)
hideBtn.MouseButton1Click:Connect(function() frame.Visible = false showBtn.Visible = true end)
showBtn.MouseButton1Click:Connect(function() frame.Visible = true showBtn.Visible = false end)

--==============================
-- CORE LOOPS
--==============================
task.spawn(function()
    while task.wait(0.1) do
        if enabledUpgrade then
            for _, id in ipairs(NPC_IDS) do
                if not enabledUpgrade then break end
                pcall(function() upgradeRemote:InvokeServer(id) end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(10) do -- Interval dipercepat menjadi 10 detik
        if enabledCollect then
            for i = 1, 30 do pcall(function() collectRemote:FireServer(i) end) end
        end
    end
end)

local oldNc
oldNc = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if self == upgradeRemote and method == "InvokeServer" then
        if typeof(args[1]) == "string" and not table.find(NPC_IDS, args[1]) then
            table.insert(NPC_IDS, args[1])
            status.Text = "Captured IDs: " .. #NPC_IDS
        end
    end
    return oldNc(self, ...)
end)
