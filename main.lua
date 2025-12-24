--[[
    MYZOARNHUB V6 - COMPACT ENGLISH VERSION
]]--

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")
local collectRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("CollectCash")

local enabledUpgrade, enabledCollect, enabledESP = false, false, false
local flying, flySpeed = false, 50
local NPC_IDS, espObjects = {}, {}
local showLegendary, showMythic, showSecret, showGod, showLucky = true, true, true, true, true

--==============================
-- GUI COMPACT STRUCTURE
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MyzoarnHub_V6_EN"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 210, 0, 340) 
frame.Position = UDim2.new(0.5, -105, 0.5, -170)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.Text = "  MYZOARN HUB"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", title)

-- TABS
local tabContainer = Instance.new("Frame", frame)
tabContainer.Size = UDim2.new(1, -10, 0, 25)
tabContainer.Position = UDim2.new(0, 5, 0, 33)
tabContainer.BackgroundTransparency = 1

local function createTab(name, pos)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0.32, 0, 1, 0)
    btn.Position = UDim2.new(pos, 0, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    Instance.new("UICorner", btn)
    return btn
end

local bF, bM, bE = createTab("FARMING", 0), createTab("MOVEMENT", 0.34), createTab("ESP MENU", 0.68)

-- PAGES
local pages = Instance.new("Frame", frame)
pages.Size = UDim2.new(1, -10, 1, -75)
pages.Position = UDim2.new(0, 5, 0, 65)
pages.BackgroundTransparency = 1

local function createPage()
    local p = Instance.new("ScrollingFrame", pages)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 2
    p.Visible = false
    local list = Instance.new("UIListLayout", p)
    list.Padding = UDim.new(0, 4)
    return p
end

local pFarm, pMove, pEsp = createPage(), createPage(), createPage()
pFarm.Visible = true

bF.MouseButton1Click:Connect(function() pFarm.Visible = true pMove.Visible = false pEsp.Visible = false end)
bM.MouseButton1Click:Connect(function() pFarm.Visible = false pMove.Visible = true pEsp.Visible = false end)
bE.MouseButton1Click:Connect(function() pFarm.Visible = false pMove.Visible = false pEsp.Visible = true end)

-- TOGGLE HELPER
local function addToggle(parent, text, default, colorOn, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -5, 0, 26)
    btn.BackgroundColor3 = default and colorOn or Color3.fromRGB(35, 35, 35)
    btn.Text = text .. (default and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    Instance.new("UICorner", btn)
    
    local s = default
    btn.MouseButton1Click:Connect(function()
        s = not s
        btn.Text = text .. (s and ": ON" or ": OFF")
        btn.BackgroundColor3 = s and colorOn or Color3.fromRGB(35, 35, 35)
        callback(s)
        if enabledESP then refreshESP() end
    end)
end

--==============================
-- PAGE CONTENT (ENGLISH)
--==============================

-- FARM PAGE
local status = Instance.new("TextLabel", pFarm)
status.Size = UDim2.new(1, 0, 0, 18)
status.Text = "Captured IDs: 0"; status.TextSize = 10; status.TextColor3 = Color3.new(0.8,0.8,0.8); status.BackgroundTransparency = 1

local clrBtn = Instance.new("TextButton", pFarm)
clrBtn.Size = UDim2.new(1, -5, 0, 26)
clrBtn.Text = "CLEAR CAPTURED DATA"
clrBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
clrBtn.TextColor3 = Color3.new(1, 1, 1)
clrBtn.Font = Enum.Font.GothamBold; clrBtn.TextSize = 9
Instance.new("UICorner", clrBtn)
clrBtn.MouseButton1Click:Connect(function() table.clear(NPC_IDS) status.Text = "Captured IDs: 0" end)

addToggle(pFarm, "Auto Upgrade", false, Color3.fromRGB(40, 150, 60), function(v) enabledUpgrade = v end)
addToggle(pFarm, "Auto Collect", false, Color3.fromRGB(40, 150, 60), function(v) enabledCollect = v end)

-- MOVE PAGE
addToggle(pMove, "Fly Mode", false, Color3.fromRGB(40, 150, 60), function(v) 
    flying = v; gui.FlyControls.Visible = v
    if v then startFly() end 
end)

-- ESP PAGE
addToggle(pEsp, "MASTER ESP", false, Color3.fromRGB(100, 100, 200), function(v) enabledESP = v; refreshESP() end)
addToggle(pEsp, "Legendary (Yellow)", true, Color3.fromRGB(180, 180, 0), function(v) showLegendary = v end)
addToggle(pEsp, "Mythic (Orange)", true, Color3.fromRGB(180, 90, 0), function(v) showMythic = v end)
addToggle(pEsp, "Secret (Purple)", true, Color3.fromRGB(130, 0, 180), function(v) showSecret = v end)
addToggle(pEsp, "God (Red)", true, Color3.fromRGB(180, 0, 0), function(v) showGod = v end)
addToggle(pEsp, "Lucky Block (Green)", true, Color3.fromRGB(0, 180, 0), function(v) showLucky = v end)

--==============================
-- LOGIC (ESP, FLY, LOOPS)
--==============================

function refreshESP()
    for _, obj in pairs(espObjects) do pcall(function() obj[1]:Destroy() obj[2]:Destroy() end) end
    espObjects = {}
    if not enabledESP then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") then
            local isL = v.Name:lower():find("lucky") or v.Name:lower():find("block")
            for _, child in pairs(v:GetDescendants()) do
                if child:IsA("TextLabel") or (isL and child:IsA("BasePart")) then
                    local t = child:IsA("TextLabel") and child.Text:lower() or v.Name:lower()
                    local col, label = nil, ""
                    
                    if t:find("god") and showGod then col = Color3.new(1,0,0); label = "GOD"
                    elseif t:find("secret") and showSecret then col = Color3.new(0.6,0,1); label = "SECRET"
                    elseif t:find("myth") and showMythic then col = Color3.new(1,0.5,0); label = "MYTHIC"
                    elseif t:find("legend") and showLegendary then col = Color3.new(1,1,0); label = "LEGENDARY"
                    elseif (t:find("lucky") or t:find("block")) and showLucky then col = Color3.new(0,1,0); label = "LUCKY BLOCK" end
                    
                    if col and (#v.Name > 20 or isL) then
                        local box = Instance.new("BoxHandleAdornment", v)
                        box.Size = v:GetExtentsSize(); box.Adornee = v; box.AlwaysOnTop = true; box.Color3 = col; box.Transparency = 0.6; box.ZIndex = 10
                        local bb = Instance.new("BillboardGui", v)
                        bb.Size = UDim2.new(0,100,0,25); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0,4,0)
                        local l = Instance.new("TextLabel", bb)
                        l.Size = UDim2.new(1,0,1,0); l.Text = "★ "..label.." ★"; l.TextColor3 = col; l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.BackgroundTransparency = 1; l.TextStrokeTransparency = 0
                        table.insert(espObjects, {box, bb}); break
                    end
                end
            end
        end
    end
end

-- FLYING LOGIC
local flyCtrl = Instance.new("Frame", gui)
flyCtrl.Name = "FlyControls"; flyCtrl.Size = UDim2.new(0, 40, 0, 80); flyCtrl.Position = UDim2.new(0.9, -10, 0.5, -40); flyCtrl.Visible = false
local function fBtn(t, y)
    local b = Instance.new("TextButton", flyCtrl); b.Size = UDim2.new(1,0,0,38); b.Position = UDim2.new(0,0,0,y); b.Text = t; b.BackgroundColor3 = Color3.new(0,0,0); b.BackgroundTransparency = 0.5; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b); return b
end
local uB, dB = fBtn("↑", 0), fBtn("↓", 42)
local mvU, mvD = false, false
uB.MouseButton1Down:Connect(function() mvU = true end); uB.MouseButton1Up:Connect(function() mvU = false end)
dB.MouseButton1Down:Connect(function() mvD = true end); dB.MouseButton1Up:Connect(function() mvD = false end)

function startFly()
    local c = player.Character or player.CharacterAdded:Wait()
    local hrp, hum = c:WaitForChild("HumanoidRootPart"), c:WaitForChild("Humanoid")
    local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    hum.PlatformStand = true
    task.spawn(function()
        while flying and c.Parent do
            bv.Velocity = (hum.MoveDirection * flySpeed) + (Vector3.new(0, (mvU and 1 or (mvD and -1 or 0)), 0) * flySpeed)
            bg.CFrame = workspace.CurrentCamera.CFrame
            RunService.RenderStepped:Wait()
        end
        bg:Destroy(); bv:Destroy(); hum.PlatformStand = false
    end)
end

-- REMOTE HOOK & TASKS
local oldNc
oldNc = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if self == upgradeRemote and getnamecallmethod() == "InvokeServer" then
        if typeof(args[1]) == "string" and not table.find(NPC_IDS, args[1]) then
            table.insert(NPC_IDS, args[1]); status.Text = "Captured IDs: " .. #NPC_IDS
        end
    end
    return oldNc(self, ...)
end)

task.spawn(function()
    while task.wait(0.5) do
        if enabledUpgrade then for _, id in ipairs(NPC_IDS) do pcall(function() upgradeRemote:InvokeServer(id) end) end end
    end
end)
task.spawn(function()
    while task.wait(10) do
        if enabledCollect then for i = 1, 30 do pcall(function() collectRemote:FireServer(i) end) end end
    end
end)
task.spawn(function()
    while task.wait(5) do if enabledESP then refreshESP() end end
end)

-- MINIMIZE SYSTEM
local min = Instance.new("TextButton", gui)
min.Size = UDim2.new(0, 75, 0, 28); min.Position = UDim2.new(0, 10, 0, 10); min.Text = "MYZOARN"; min.Visible = false; min.BackgroundColor3 = Color3.fromRGB(20,20,20); min.TextColor3 = Color3.new(0,1,0.6); Instance.new("UICorner", min)

local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0, 22, 0, 22); close.Position = UDim2.new(1, -25, 0, 3); close.Text = "-"; close.BackgroundColor3 = Color3.fromRGB(100, 30, 30); close.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function() frame.Visible = false min.Visible = true end)
min.MouseButton1Click:Connect(function() frame.Visible = true min.Visible = false end)

player.Idled:Connect(function() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
