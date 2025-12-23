--==============================
-- SERVICES
--==============================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")
local collectRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("CollectCash")

--==============================
-- DATA & LOGIC
--==============================
local enabledUpgrade = false
local enabledCollect = false
local NPC_IDS = {}
_G.NPC_IDS = NPC_IDS

--==============================
-- MODERN GUI CREATION
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ModernAutoFarm"
gui.ResetOnSpawn = false

-- MAIN FRAME
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 320)
frame.Position = UDim2.new(0.5, -140, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

-- DROP SHADOW (Glow effect)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- HEADER
local header = Instance.new("TextLabel", frame)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
header.Text = "MYZOARN HUB"
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBold
header.TextSize = 16

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 10)

-- CONTAINER FOR BUTTONS
local container = Instance.new("Frame", frame)
container.Size = UDim2.new(1, -20, 1, -60)
container.Position = UDim2.new(0, 10, 0, 50)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- STATUS LABEL
local status = Instance.new("TextLabel", container)
status.Size = UDim2.new(1, 0, 0, 25)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.Text = "Captured IDs: 0"

-- HELPER FUNCTION FOR BUTTONS
local function createModernBtn(text, color)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.AutoButtonColor = true
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    
    return btn
end

local toggleUpgrade = createModernBtn("Auto Upgrade: OFF", Color3.fromRGB(45, 45, 45))
local toggleCollect = createModernBtn("Auto Collect: OFF", Color3.fromRGB(45, 45, 45))
local clearBtn = createModernBtn("Clear NPC IDs", Color3.fromRGB(70, 30, 30))
local hideBtn = createModernBtn("Minimize GUI", Color3.fromRGB(35, 35, 35))

-- FLOATING OPEN BUTTON
local showBtn = Instance.new("TextButton", gui)
showBtn.Size = UDim2.new(0, 60, 0, 60)
showBtn.Position = UDim2.new(0, 20, 0.8, 0)
showBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
showBtn.Text = "OPEN"
showBtn.TextColor3 = Color3.new(1, 1, 1)
showBtn.Font = Enum.Font.GothamBold
showBtn.Visible = false

local showCorner = Instance.new("UICorner", showBtn)
showCorner.CornerRadius = UDim.new(1, 0) -- Circle

--==============================
-- FUNCTIONS & LOGIC
--==============================
local function updateStatus()
    status.Text = "Captured IDs: " .. #NPC_IDS
end

toggleUpgrade.MouseButton1Click:Connect(function()
    enabledUpgrade = not enabledUpgrade
    toggleUpgrade.Text = enabledUpgrade and "Auto Upgrade: ON" or "Auto Upgrade: OFF"
    TweenService:Create(toggleUpgrade, TweenInfo.new(0.3), {
        BackgroundColor3 = enabledUpgrade and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(45, 45, 45)
    }):Play()
end)

toggleCollect.MouseButton1Click:Connect(function()
    enabledCollect = not enabledCollect
    toggleCollect.Text = enabledCollect and "Auto Collect: ON" or "Auto Collect: OFF"
    TweenService:Create(toggleCollect, TweenInfo.new(0.3), {
        BackgroundColor3 = enabledCollect and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(45, 45, 45)
    }):Play()
end)

clearBtn.MouseButton1Click:Connect(function()
    table.clear(NPC_IDS)
    updateStatus()
end)

hideBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    showBtn.Visible = true
end)

showBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    showBtn.Visible = false
end)

--==============================
-- LOOPS (CORE LOGIC)
--==============================
task.spawn(function()
    while task.wait(0.1) do
        if not enabledUpgrade then continue end
        for _, id in ipairs(NPC_IDS) do
            if not enabledUpgrade then break end
            pcall(function()
                upgradeRemote:InvokeServer(id)
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if not enabledCollect then continue end
        for i = 1, 30 do
            pcall(function()
                collectRemote:FireServer(i)
            end)
        end
    end
end)

--==============================
-- REMOTE SPY (HOOK)
--==============================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if self == upgradeRemote and method == "InvokeServer" then
        local npcId = args[1]
        if typeof(npcId) == "string" then
            if not table.find(NPC_IDS, npcId) then
                table.insert(NPC_IDS, npcId)
                updateStatus()
                warn("[CAPTURED NPC ID]:", npcId)
            end
        end
    end

    return oldNamecall(self, ...)
end)
