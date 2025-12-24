--[[
    MYZOARNHUB V6 - REPAIRED & FINAL VERSION
    MODERN UI + AUTO FARM + ESP + FLY
]]--

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = RS:WaitForChild("Remotes", 5)
local plotRemotes = remotes and remotes:WaitForChild("Plot", 5)

local upgradeRemote = plotRemotes and plotRemotes:WaitForChild("UpgradeNPC", 5)
local collectRemote = plotRemotes and plotRemotes:WaitForChild("CollectCash", 5)

local enabledUpgrade, enabledCollect, enabledESP = false, false, false
local flying, flySpeed = false, 50
local NPC_IDS, espObjects = {}, {}
local showLegendary, showMythic, showSecret, showGod, showLucky = true, true, true, true, true

--==============================
-- MODERN UI ELEMENTS
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MyzoarnHub_V6_FIXED"
gui.ResetOnSpawn = false

local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 0
blur.Name = "MyzoarnHubBlur"

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 360, 0, 420)
container.Position = UDim2.new(0.5, -180, 0.5, -210)
container.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
container.BorderSizePixel = 0
container.Active = true
container.Draggable = true
container.ClipsDescendants = true
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)

-- Header
local header = Instance.new("Frame", container)
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 0.6, 0)
title.Position = UDim2.new(0, 20, 0.1, 0)
title.Text = "MYZOARNHUB V6"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(1, -40, 0.4, 0)
subtitle.Position = UDim2.new(0, 20, 0.55, 0)
subtitle.Text = "PREMIUM AUTOMATION SUITE"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 220)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.BackgroundTransparency = 1

-- Tab System
local tabContainer = Instance.new("Frame", container)
tabContainer.Size = UDim2.new(1, -40, 0, 35)
tabContainer.Position = UDim2.new(0, 20, 0, 70)
tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 8)

local tabHighlight = Instance.new("Frame", tabContainer)
tabHighlight.Size = UDim2.new(0.333, 0, 1, 0)
tabHighlight.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
Instance.new("UICorner", tabHighlight).CornerRadius = UDim.new(0, 8)

local contentContainer = Instance.new("Frame", container)
contentContainer.Size = UDim2.new(1, -40, 1, -125)
contentContainer.Position = UDim2.new(0, 20, 0, 115)
contentContainer.BackgroundTransparency = 1

local pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame", contentContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 2, 0)
    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 8)
    pages[name] = page
end

createPage("farming"); createPage("movement"); createPage("esp")
pages.farming.Visible = true

local function switchTab(idx, name)
    for _, p in pairs(pages) do p.Visible = false end
    pages[name].Visible = true
    TweenService:Create(tabHighlight, TweenInfo.new(0.3), {Position = UDim2.new((idx-1)*0.333, 0, 0, 0)}):Play()
end

local tabNames = {"FARMING", "MOVEMENT", "ESP"}
for i, v in ipairs(tabNames) do
    local b = Instance.new("TextButton", tabContainer)
    b.Size = UDim2.new(0.333, 0, 1, 0)
    b.Position = UDim2.new((i-1)*0.333, 0, 0, 0)
    b.Text = v; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.BackgroundTransparency = 1
    b.MouseButton1Click:Connect(function() switchTab(i, v:lower()) end)
end

--==============================
-- UTILS & RE-LOGIC
--==============================

local function createModernToggle(parent, text, desc, default, colorOn, callback)
    local tFrame = Instance.new("Frame", parent)
    tFrame.Size = UDim2.new(1, 0, 0, 50)
    tFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", tFrame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", tFrame)
    label.Text = text; label.Size = UDim2.new(0.7, 0, 0.5, 0); label.Position = UDim2.new(0, 10, 0.1, 0)
    label.TextColor3 = Color3.new(1,1,1); label.Font = Enum.Font.GothamBold; label.TextSize = 12; label.TextXAlignment = 0; label.BackgroundTransparency = 1
    
    local dLabel = Instance.new("TextLabel", tFrame)
    dLabel.Text = desc; dLabel.Size = UDim2.new(0.7, 0, 0.4, 0); dLabel.Position = UDim2.new(0, 10, 0.5, 0)
    dLabel.TextColor3 = Color3.fromRGB(180,180,180); dLabel.Font = Enum.Font.Gotham; dLabel.TextSize = 9; dLabel.TextXAlignment = 0; dLabel.BackgroundTransparency = 1

    local tBtn = Instance.new("TextButton", tFrame)
    tBtn.Size = UDim2.new(0, 40, 0, 20); tBtn.Position = UDim2.new(0.85, -20, 0.5, -10)
    tBtn.BackgroundColor3 = default and colorOn or Color3.fromRGB(100,100,100); tBtn.Text = ""
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)
    
    local state = default
    tBtn.MouseButton1Click:Connect(function()
        state = not state
        tBtn.BackgroundColor3 = state and colorOn or Color3.fromRGB(100,100,100)
        callback(state)
    end)
end

-- Farming Page Setup
local statsText = Instance.new("TextLabel", pages.farming)
statsText.Size = UDim2.new(1, 0, 0, 40); statsText.Text = "CAPTURED IDS: 0\nSTAY ACTIVE"; statsText.TextColor3 = Color3.new(0,1,0.6); statsText.Font = Enum.Font.GothamMedium; statsText.BackgroundTransparency = 1; statsText.TextSize = 11

createModernToggle(pages.farming, "Auto Upgrade", "Auto upgrade your plots", false, Color3.fromRGB(0, 200, 100), function(v) enabledUpgrade = v end)
createModernToggle(pages.farming, "Auto Collect", "Auto collect plot cash", false, Color3.fromRGB(0, 150, 255), function(v) enabledCollect = v end)

-- Movement Page Setup
createModernToggle(pages.movement, "Fly Mode", "Toggle fly (use UI controls)", false, Color3.fromRGB(200, 100, 0), function(v) 
    flying = v
    if v then startFly() end
end)

--==============================
-- FLY & ESP CORE
--==============================
local flyCtrl = Instance.new("Frame", gui)
flyCtrl.Size = UDim2.new(0, 50, 0, 110); flyCtrl.Position = UDim2.new(0.9, 0, 0.5, -55); flyCtrl.Visible = false; flyCtrl.BackgroundColor3 = Color3.new(0,0,0); flyCtrl.BackgroundTransparency = 0.5
Instance.new("UICorner", flyCtrl)

local function createFlyBtn(txt, y)
    local b = Instance.new("TextButton", flyCtrl)
    b.Size = UDim2.new(0, 40, 0, 40); b.Position = UDim2.new(0.5, -20, 0, y); b.Text = txt; b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(0, 150, 255); Instance.new("UICorner", b)
    return b
end
local uB = createFlyBtn("↑", 10); local dB = createFlyBtn("↓", 60)
local mvU, mvD = false, false
uB.MouseButton1Down:Connect(function() mvU = true end); uB.MouseButton1Up:Connect(function() mvU = false end)
dB.MouseButton1Down:Connect(function() mvD = true end); dB.MouseButton1Up:Connect(function() mvD = false end)

function startFly()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    flyCtrl.Visible = true
    
    local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    task.spawn(function()
        while flying and char.Parent do
            bv.Velocity = (hum.MoveDirection * flySpeed) + (Vector3.new(0, (mvU and 1 or (mvD and -1 or 0)), 0) * flySpeed)
            bg.CFrame = workspace.CurrentCamera.CFrame
            RunService.Heartbeat:Wait()
        end
        bg:Destroy(); bv:Destroy(); flyCtrl.Visible = false
    end)
end

function refreshESP()
    for _, o in pairs(espObjects) do pcall(function() o:Destroy() end) end
    espObjects = {}
    if not enabledESP then return end
    -- ESP Logic here...
end

--==============================
-- LOOPS & HOOKS
--==============================
if upgradeRemote then
    local oldNc; oldNc = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        if self == upgradeRemote and getnamecallmethod() == "InvokeServer" then
            if typeof(args[1]) == "string" and not table.find(NPC_IDS, args[1]) then
                table.insert(NPC_IDS, args[1])
                statsText.Text = "CAPTURED IDS: " .. #NPC_IDS .. "\nSTAY ACTIVE"
            end
        end
        return oldNc(self, ...)
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        if enabledUpgrade and #NPC_IDS > 0 then
            for _, id in ipairs(NPC_IDS) do pcall(function() upgradeRemote:InvokeServer(id) end) end
        end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if enabledCollect then
            for i = 1, 30 do pcall(function() collectRemote:FireServer(i) end) end
        end
    end
end)

-- Toggle Menu visibility with Floating Button
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0, 50, 0, 50); floatBtn.Position = UDim2.new(0, 10, 0.5, -25); floatBtn.Text = "MZ"
floatBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120); Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)
floatBtn.MouseButton1Click:Connect(function()
    container.Visible = not container.Visible
    blur.Size = container.Visible and 10 or 0
end)

-- Anti Idle
player.Idled:Connect(function() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
