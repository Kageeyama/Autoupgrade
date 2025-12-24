--==============================
-- SERVICES & VARIABLES
--==============================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")
local collectRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("CollectCash")

-- Global Settings
local enabledUpgrade, enabledCollect, enabledESP, enabledGrab = false, false, false, false
local flying = false
local flySpeed = 50
local NPC_IDS = {}
local espObjects = {}
local basePos = nil

-- Toggles Per Kategori
local showLegendary, showMythic, showSecret, showGod, showLucky = true, true, true, true, true
local grabLegendary, grabMythic, grabSecret, grabGod, grabLucky = true, true, true, true, true

--==============================
-- GUI MAIN STRUCTURE
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MyzoarnTabs_V7_Final"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 420)
frame.Position = UDim2.new(0.5, -140, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

-- TAB SYSTEM HEADERS
local tabContainer = Instance.new("Frame", frame)
tabContainer.Size = UDim2.new(1, 0, 0, 35)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", tabContainer)

local function createTabBtn(name, pos, width)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(width, -4, 1, -4)
    btn.Position = UDim2.new(pos, 2, 0, 2)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    Instance.new("UICorner", btn)
    return btn
end

local btnFarm = createTabBtn("FARMING", 0, 0.25)
local btnGrab = createTabBtn("GRAB", 0.25, 0.25)
local btnEsp = createTabBtn("ESP", 0.5, 0.25)
local btnMove = createTabBtn("MOVE", 0.75, 0.25)

-- PAGE CONTAINERS
local pages = Instance.new("Frame", frame)
pages.Size = UDim2.new(1, -20, 1, -50)
pages.Position = UDim2.new(0, 10, 0, 45)
pages.BackgroundTransparency = 1

local function createPage()
    local p = Instance.new("Frame", pages)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    local list = Instance.new("UIListLayout", p)
    list.Padding = UDim.new(0, 5)
    return p
end

local pageFarm = createPage(); pageFarm.Visible = true
local pageGrab = createPage()
local pageEsp = createPage()
local pageMove = createPage()

-- NAVIGATION
local function showPage(target)
    pageFarm.Visible = (target == pageFarm)
    pageGrab.Visible = (target == pageGrab)
    pageEsp.Visible = (target == pageEsp)
    pageMove.Visible = (target == pageMove)
end
btnFarm.MouseButton1Click:Connect(function() showPage(pageFarm) end)
btnGrab.MouseButton1Click:Connect(function() showPage(pageGrab) end)
btnEsp.MouseButton1Click:Connect(function() showPage(pageEsp) end)
btnMove.MouseButton1Click:Connect(function() showPage(pageMove) end)

-- UI HELPERS
local function addToggle(parent, text, default, colorOn, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = default and colorOn or Color3.fromRGB(35, 35, 35)
    btn.Text = text .. (default and ": ON" or ": OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10
    Instance.new("UICorner", btn)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and colorOn or Color3.fromRGB(35, 35, 35)
        callback(state)
    end)
    return btn
end

--==============================
-- TAB 1: FARMING
--==============================
local statusLabel = Instance.new("TextLabel", pageFarm)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Text = "Captured IDs: 0"
statusLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
statusLabel.BackgroundTransparency = 1

local clrBtn = Instance.new("TextButton", pageFarm)
clrBtn.Size = UDim2.new(1, 0, 0, 30)
clrBtn.Text = "CLEAR CAPTURED DATA"
clrBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
clrBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", clrBtn)
clrBtn.MouseButton1Click:Connect(function() table.clear(NPC_IDS) statusLabel.Text = "Captured IDs: 0" end)

addToggle(pageFarm, "Auto Upgrade", false, Color3.fromRGB(40, 150, 60), function(s) enabledUpgrade = s end)
addToggle(pageFarm, "Auto Collect", false, Color3.fromRGB(40, 150, 60), function(s) enabledCollect = s end)

--==============================
-- TAB 2: GRAB (TELEPORT)
--==============================
addToggle(pageGrab, "MASTER AUTO GRAB", false, Color3.fromRGB(200, 50, 50), function(s) 
    enabledGrab = s 
    if s then basePos = player.Character.HumanoidRootPart.CFrame end
end)
addToggle(pageGrab, "Grab Lucky Block", true, Color3.fromRGB(100, 100, 100), function(s) grabLucky = s end)
addToggle(pageGrab, "Grab Legendary", true, Color3.fromRGB(180, 180, 0), function(s) grabLegendary = s end)
addToggle(pageGrab, "Grab Mythic", true, Color3.fromRGB(180, 90, 0), function(s) grabMythic = s end)
addToggle(pageGrab, "Grab Secret", true, Color3.fromRGB(130, 0, 180), function(s) grabSecret = s end)
addToggle(pageGrab, "Grab God", true, Color3.fromRGB(180, 0, 0), function(s) grabGod = s end)

--==============================
-- TAB 3: ESP
--==============================
addToggle(pageEsp, "MASTER ESP", false, Color3.fromRGB(100, 100, 200), function(s) enabledESP = s refreshESP() end)
addToggle(pageEsp, "ESP Lucky Block", true, Color3.fromRGB(100, 100, 100), function(s) showLucky = s end)
addToggle(pageEsp, "ESP Legendary", true, Color3.fromRGB(180, 180, 0), function(s) showLegendary = s end)
addToggle(pageEsp, "ESP Mythic", true, Color3.fromRGB(180, 90, 0), function(s) showMythic = s end)
addToggle(pageEsp, "ESP Secret", true, Color3.fromRGB(130, 0, 180), function(s) showSecret = s end)
addToggle(pageEsp, "ESP God", true, Color3.fromRGB(180, 0, 0), function(s) showGod = s end)

--==============================
-- TAB 4: MOVE
--==============================
addToggle(pageMove, "Fly Mode", false, Color3.fromRGB(40, 150, 60), function(s) 
    flying = s 
    gui.FlyControls.Visible = s
    if s then startFly() end 
end)

--==============================
-- LOGIC: GRAB & TELEPORT
--==============================
local function doTweenGrab(target)
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not target:FindFirstChild("HumanoidRootPart") then return end
    
    local originalCF = basePos or hrp.CFrame
    -- Tween ke Target
    local tw = TweenService:Create(hrp, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {CFrame = target.HumanoidRootPart.CFrame})
    tw:Play() tw.Completed:Wait()
    task.wait(0.5) -- Jeda ambil
    
    -- Tween Balik ke Base
    local twBack = TweenService:Create(hrp, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {CFrame = originalCF})
    twBack:Play() twBack.Completed:Wait()
end

task.spawn(function()
    while task.wait(3) do
        if enabledGrab and player.Character then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and #v.Name > 20 then
                    local lbl = v:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl then
                        local t = lbl.Text:lower()
                        local shouldGrab = false
                        if t:find("lucky") and grabLucky then shouldGrab = true
                        elseif t:find("god") and grabGod then shouldGrab = true
                        elseif t:find("secret") and grabSecret then shouldGrab = true
                        elseif t:find("myth") and grabMythic then shouldGrab = true
                        elseif t:find("legend") and grabLegendary then shouldGrab = true end
                        
                        if shouldGrab then doTweenGrab(v) break end
                    end
                end
            end
        end
    end
end)

--==============================
-- LOGIC: ESP
--==============================
function refreshESP()
    for _, obj in pairs(espObjects) do pcall(function() obj[1]:Destroy() obj[2]:Destroy() end) end
    espObjects = {}
    if not enabledESP then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and #v.Name > 20 then
            for _, child in pairs(v:GetDescendants()) do
                if child:IsA("TextLabel") then
                    local t = child.Text:lower()
                    local col = nil
                    
                    if t:find("lucky") and showLucky then col = Color3.fromRGB(200, 200, 200)
                    elseif t:find("god") and showGod then col = Color3.fromRGB(255, 0, 0)
                    elseif t:find("secret") and showSecret then col = Color3.fromRGB(170, 0, 255)
                    elseif t:find("myth") and showMythic then col = Color3.fromRGB(255, 120, 0)
                    elseif t:find("legend") and showLegendary then col = Color3.fromRGB(255, 255, 0) end
                    
                    if col then
                        local box = Instance.new("BoxHandleAdornment", v)
                        box.Size = v:GetExtentsSize(); box.Adornee = v; box.AlwaysOnTop = true; box.ZIndex = 10; box.Color3 = col; box.Transparency = 0.5
                        local bb = Instance.new("BillboardGui", v)
                        bb.Size = UDim2.new(0,120,0,40); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0,5,0)
                        local l = Instance.new("TextLabel", bb)
                        l.Size = UDim2.new(1,0,1,0); l.Text = "★ "..child.Text:upper().." ★"; l.TextColor3 = col; l.Font = Enum.Font.GothamBold; l.TextSize = 13; l.BackgroundTransparency = 1; l.TextStrokeTransparency = 0
                        table.insert(espObjects, {box, bb})
                    end
                end
            end
        end
    end
end

--==============================
-- FLY & SYSTEM LOGIC
--==============================
local flyCtrl = Instance.new("Frame", gui); flyCtrl.Name = "FlyControls"; flyCtrl.Size = UDim2.new(0, 50, 0, 110); flyCtrl.Position = UDim2.new(0.9, -30, 0.5, -55); flyCtrl.BackgroundTransparency = 1; flyCtrl.Visible = false
local function flyBtn(txt, y)
    local b = Instance.new("TextButton", flyCtrl); b.Size = UDim2.new(1, 0, 0, 50); b.Position = UDim2.new(0, 0, 0, y); b.Text = txt; b.BackgroundColor3 = Color3.new(0,0,0); b.BackgroundTransparency = 0.5; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b); return b
end
local upB = flyBtn("↑", 0); local downB = flyBtn("↓", 60); local mvUp, mvDown = false, false
upB.MouseButton1Down:Connect(function() mvUp = true end); upB.MouseButton1Up:Connect(function() mvUp = false end)
downB.MouseButton1Down:Connect(function() mvDown = true end); downB.MouseButton1Up:Connect(function() mvDown = false end)

function startFly()
    local char = player.Character or player.CharacterAdded:Wait(); local hrp = char:WaitForChild("HumanoidRootPart"); local hum = char:WaitForChild("Humanoid")
    local bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    hum.PlatformStand = true
    task.spawn(function()
        while flying and char.Parent do
            local dir = hum.MoveDirection; local v = mvUp and 1 or (mvDown and -1 or 0)
            bv.Velocity = (dir * flySpeed) + (Vector3.new(0, v, 0) * flySpeed); bg.CFrame = workspace.CurrentCamera.CFrame; RunService.RenderStepped:Wait()
        end
        bg:Destroy(); bv:Destroy(); hum.PlatformStand = false
    end)
end

-- LOOPS
task.spawn(function() while task.wait(0.1) do if enabledUpgrade then for _, id in ipairs(NPC_IDS) do pcall(function() upgradeRemote:InvokeServer(id) end) end end end end)
task.spawn(function() while task.wait(10) do if enabledCollect then for i = 1, 30 do pcall(function() collectRemote:FireServer(i) end) end end end end)
task.spawn(function() while task.wait(5) do if enabledESP then refreshESP() end end end)

-- MINIMIZE
local minBtn = Instance.new("TextButton", gui); minBtn.Size = UDim2.new(0, 50, 0, 50); minBtn.Position = UDim2.new(0, 10, 0.7, 0); minBtn.Text = "MENU"; minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); minBtn.TextColor3 = Color3.new(1,1,1); minBtn.Visible = false; Instance.new("UICorner", minBtn, {CornerRadius = UDim.new(1, 0)})
local hideMain = Instance.new("TextButton", frame); hideMain.Size = UDim2.new(0, 20, 0, 20); hideMain.Position = UDim2.new(1, -25, 0, 5); hideMain.Text = "-"; hideMain.BackgroundColor3 = Color3.fromRGB(100, 30, 30); hideMain.TextColor3 = Color3.new(1,1,1)
hideMain.MouseButton1Click:Connect(function() frame.Visible = false minBtn.Visible = true end); minBtn.MouseButton1Click:Connect(function() frame.Visible = true minBtn.Visible = false end)

-- REMOTE HOOK
local oldNc; oldNc = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if self == upgradeRemote and getnamecallmethod() == "InvokeServer" then
        if typeof(args[1]) == "string" and not table.find(NPC_IDS, args[1]) then
            table.insert(NPC_IDS, args[1])
            statusLabel.Text = "Captured IDs: " .. #NPC_IDS
        end
    end
    return oldNc(self, ...)
end)

-- Anti-AFK
player.Idled:Connect(function() game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
