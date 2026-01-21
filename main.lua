--[[
    MYZOARN HUB V7 - COMPLETE SCRIPT
    Features: Auto Farm, Auto Grab with Price Detection, ESP, Fly with Mobile Support
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")
local collectRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("CollectCash")
local gearFolder = RS:WaitForChild("Assets"):WaitForChild("Gear")

local enabledUpgrade, enabledCollect, enabledESP = false, false, false
local flying = false
local flySpeed = 50
local NPC_IDS = {}
local espObjects = {}

local autoGrabEnabled = false
local spawnPosition = nil
local grabLegendary, grabMythic, grabSecret, grabGod, grabOG = false, false, false, false, false
local grabCandy, grabIced, grabLava, grabRainbow, grabGolden = false, false, false, false, false

local bypassMethod = "Smooth"
local teleportSpeed = 300
local useUnderground = true
local undergroundOffset = -15
local grabCooldown = 0.5

local showLegendary, showMythic, showSecret, showGod, showOG = true, true, true, true, true
local showCandy, showIced, showLava, showRainbow, showGolden = true, true, true, true, true

local flyUpBtn, flyDownBtn
local flyConnection
local flyVelocity = Vector3.new(0, 0, 0)

-- Utility Functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Color = color or Color3.fromRGB(60, 60, 60)
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

local function tweenButton(button, targetColor)
    TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
end

-- Fly System
function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e4
    
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    
    if flyUpBtn and flyDownBtn then
        flyUpBtn.Visible = true
        flyDownBtn.Visible = true
    end
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying then
            bg:Destroy()
            bv:Destroy()
            if flyUpBtn and flyDownBtn then
                flyUpBtn.Visible = false
                flyDownBtn.Visible = false
            end
            flyConnection:Disconnect()
            return
        end
        
        bg.CFrame = workspace.CurrentCamera.CFrame
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + (workspace.CurrentCamera.CFrame.LookVector * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - (workspace.CurrentCamera.CFrame.LookVector * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - (workspace.CurrentCamera.CFrame.RightVector * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + (workspace.CurrentCamera.CFrame.RightVector * flySpeed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, flySpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, flySpeed, 0)
        end
        
        moveDir = moveDir + flyVelocity
        bv.Velocity = moveDir
    end)
end

-- GUI Creation
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MyzoarnTabs_V7_Modern"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 480)
frame.Position = UDim2.new(0.5, -160, 0.5, -240)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
createCorner(frame, 12)
createStroke(frame, Color3.fromRGB(80, 80, 100), 2)

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
header.BorderSizePixel = 0
createCorner(header, 12)

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✦ MYZOARN HUB ✦"
titleLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
minimizeBtn.Position = UDim2.new(1, -40, 0, 5)
minimizeBtn.Text = "─"
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
minimizeBtn.AutoButtonColor = false
createCorner(minimizeBtn, 8)

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 320, 0, 45) or UDim2.new(0, 320, 0, 480)
    local targetPos = isMinimized and UDim2.new(0.5, -160, 1, -55) or UDim2.new(0.5, -160, 0.5, -240)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize, Position = targetPos}):Play()
    minimizeBtn.Text = isMinimized and "+" or "─"
end)

local tabContainer = Instance.new("Frame", frame)
tabContainer.Size = UDim2.new(1, -20, 0, 40)
tabContainer.Position = UDim2.new(0, 10, 0, 55)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
tabContainer.BorderSizePixel = 0
createCorner(tabContainer, 8)

local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createTabBtn(name, icon)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0.24, 0, 0, 30)
    btn.Text = icon .. " " .. name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.AutoButtonColor = false
    createCorner(btn, 6)
    return btn
end

local btnFarm = createTabBtn("FARM", "⚡")
local btnMove = createTabBtn("MOVE", "✈")
local btnEsp = createTabBtn("ESP", "👁")
local btnGrab = createTabBtn("GRAB", "🎯")

local pages = Instance.new("Frame", frame)
pages.Size = UDim2.new(1, -20, 1, -110)
pages.Position = UDim2.new(0, 10, 0, 105)
pages.BackgroundTransparency = 1

local function createPage()
    local p = Instance.new("ScrollingFrame", pages)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = Color3.fromRGB(70, 120, 200)
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.BorderSizePixel = 0
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local list = Instance.new("UIListLayout", p)
    list.Padding = UDim.new(0, 6)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return p
end

local pageFarm = createPage()
local pageMove = createPage()
local pageEsp = createPage()
local pageGrab = createPage()
pageFarm.Visible = true

local currentTab = btnFarm
local function showPage(target, btn)
    pageFarm.Visible = (target == pageFarm)
    pageMove.Visible = (target == pageMove)
    pageEsp.Visible = (target == pageEsp)
    pageGrab.Visible = (target == pageGrab)
    tweenButton(currentTab, Color3.fromRGB(40, 40, 50))
    currentTab.TextColor3 = Color3.fromRGB(180, 180, 200)
    tweenButton(btn, Color3.fromRGB(70, 120, 200))
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    currentTab = btn
end

btnFarm.MouseButton1Click:Connect(function() showPage(pageFarm, btnFarm) end)
btnMove.MouseButton1Click:Connect(function() showPage(pageMove, btnMove) end)
btnEsp.MouseButton1Click:Connect(function() showPage(pageEsp, btnEsp) end)
btnGrab.MouseButton1Click:Connect(function() showPage(pageGrab, btnGrab) end)

tweenButton(btnFarm, Color3.fromRGB(70, 120, 200))
btnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)

local function addToggle(parent, text, icon, default, colorOn, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -10, 0, 32)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    container.BorderSizePixel = 0
    createCorner(container, 6)
    createStroke(container, Color3.fromRGB(50, 50, 65), 1)
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, -10, 1, -4)
    btn.Position = UDim2.new(0, 5, 0, 2)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("Frame", btn)
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -45, 0.5, -10)
    toggle.BackgroundColor3 = default and colorOn or Color3.fromRGB(60, 60, 75)
    createCorner(toggle, 10)
    
    local indicator = Instance.new("Frame", toggle)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    createCorner(indicator, 8)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.25), {BackgroundColor3 = state and colorOn or Color3.fromRGB(60, 60, 75)}):Play()
        TweenService:Create(indicator, TweenInfo.new(0.25), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
    return btn
end

local function addLabel(parent, text, textColor)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -10, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or Color3.fromRGB(150, 200, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local function addButton(parent, text, icon, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.BackgroundColor3 = color
    btn.Text = icon .. " " .. text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    createCorner(btn, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- TAB 1: FARMING
local statusLabel = addLabel(pageFarm, "📊 Captured IDs: 0", Color3.fromRGB(100, 255, 150))

addButton(pageFarm, "GET ALL GEARS", "🎒", Color3.fromRGB(70, 130, 255), function()
    pcall(function()
        local bp = player:FindFirstChild("Backpack")
        if bp and gearFolder then
            for _, i in pairs(gearFolder:GetChildren()) do i:Clone().Parent = bp end
        end
    end)
end)

addButton(pageFarm, "RESET CAPTURED IDS", "🔄", Color3.fromRGB(255, 100, 100), function()
    NPC_IDS = {}
    statusLabel.Text = "📊 Captured IDs: 0"
end)

addToggle(pageFarm, "Auto Upgrade", "⚙", false, Color3.fromRGB(80, 200, 120), function(s) enabledUpgrade = s end)
addToggle(pageFarm, "Auto Collect", "💰", false, Color3.fromRGB(255, 200, 80), function(s) enabledCollect = s end)

-- TAB 2: MOVEMENT
addToggle(pageMove, "Fly Mode", "✈", false, Color3.fromRGB(100, 180, 255), function(s) 
    flying = s 
    if s then startFly() end 
end)

flyUpBtn = Instance.new("TextButton", gui)
flyUpBtn.Size = UDim2.new(0, 60, 0, 60)
flyUpBtn.Position = UDim2.new(1, -70, 1, -140)
flyUpBtn.Text = "▲"
flyUpBtn.TextSize = 24
flyUpBtn.Font = Enum.Font.GothamBold
flyUpBtn.TextColor3 = Color3.new(1, 1, 1)
flyUpBtn.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
flyUpBtn.Visible = false
createCorner(flyUpBtn, 12)

flyDownBtn = Instance.new("TextButton", gui)
flyDownBtn.Size = UDim2.new(0, 60, 0, 60)
flyDownBtn.Position = UDim2.new(1, -70, 1, -70)
flyDownBtn.Text = "▼"
flyDownBtn.TextSize = 24
flyDownBtn.Font = Enum.Font.GothamBold
flyDownBtn.TextColor3 = Color3.new(1, 1, 1)
flyDownBtn.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
flyDownBtn.Visible = false
createCorner(flyDownBtn, 12)

flyUpBtn.MouseButton1Down:Connect(function() flyVelocity = Vector3.new(0, flySpeed, 0) end)
flyUpBtn.MouseButton1Up:Connect(function() flyVelocity = Vector3.new(0, 0, 0) end)
flyDownBtn.MouseButton1Down:Connect(function() flyVelocity = Vector3.new(0, -flySpeed, 0) end)
flyDownBtn.MouseButton1Up:Connect(function() flyVelocity = Vector3.new(0, 0, 0) end)

-- TAB 3: ESP
addToggle(pageEsp, "MASTER ESP", "👁", false, Color3.fromRGB(150, 100, 255), function(s) enabledESP = s end)
addLabel(pageEsp, "━━ CATEGORY ━━", Color3.fromRGB(255, 220, 100))
addToggle(pageEsp, "Legendary", "⭐", true, Color3.fromRGB(255, 230, 0), function(s) showLegendary = s end)
addToggle(pageEsp, "Mythic", "🔥", true, Color3.fromRGB(255, 120, 0), function(s) showMythic = s end)
addToggle(pageEsp, "Secret", "💎", true, Color3.fromRGB(180, 0, 255), function(s) showSecret = s end)
addToggle(pageEsp, "God", "👑", true, Color3.fromRGB(255, 50, 50), function(s) showGod = s end)
addToggle(pageEsp, "OG", "🏆", true, Color3.fromRGB(200, 200, 200), function(s) showOG = s end)
addLabel(pageEsp, "━━ MUTATION ━━", Color3.fromRGB(100, 255, 255))
addToggle(pageEsp, "Candy", "🍬", true, Color3.fromRGB(255, 105, 180), function(s) showCandy = s end)
addToggle(pageEsp, "Iced", "❄", true, Color3.fromRGB(0, 255, 255), function(s) showIced = s end)
addToggle(pageEsp, "Lava", "🌋", true, Color3.fromRGB(255, 50, 0), function(s) showLava = s end)
addToggle(pageEsp, "Rainbow", "🌈", true, Color3.fromRGB(255, 0, 255), function(s) showRainbow = s end)
addToggle(pageEsp, "Golden", "✨", true, Color3.fromRGB(255, 215, 0), function(s) showGolden = s end)

-- TAB 4: AUTO GRAB
local spawnLabel = addLabel(pageGrab, "📍 Spawn: Not Set", Color3.fromRGB(255, 150, 150))
local grabStatusLabel = addLabel(pageGrab, "🎯 Status: Idle", Color3.fromRGB(150, 150, 150))

addButton(pageGrab, "SET SPAWN POINT", "📌", Color3.fromRGB(80, 200, 120), function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        spawnPosition = char.HumanoidRootPart.CFrame
        spawnLabel.Text = "📍 Spawn: ✓ Saved"
        spawnLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    end
end)

addToggle(pageGrab, "AUTO GRAB", "🎯", false, Color3.fromRGB(255, 100, 100), function(s) 
    autoGrabEnabled = s 
    if s and not spawnPosition then
        autoGrabEnabled = false
        spawnLabel.Text = "📍 Spawn: ⚠ Set spawn first!"
    end
end)

addLabel(pageGrab, "━━ CATEGORY ━━", Color3.fromRGB(255, 220, 100))
addToggle(pageGrab, "Legendary", "⭐", false, Color3.fromRGB(255, 230, 0), function(s) grabLegendary = s end)
addToggle(pageGrab, "Mythic", "🔥", false, Color3.fromRGB(255, 120, 0), function(s) grabMythic = s end)
addToggle(pageGrab, "Secret", "💎", false, Color3.fromRGB(180, 0, 255), function(s) grabSecret = s end)
addToggle(pageGrab, "God", "👑", false, Color3.fromRGB(255, 50, 50), function(s) grabGod = s end)
addToggle(pageGrab, "OG", "🏆", false, Color3.fromRGB(200, 200, 200), function(s) grabOG = s end)
addLabel(pageGrab, "━━ MUTATION ━━", Color3.fromRGB(100, 255, 255))
addToggle(pageGrab, "Candy", "🍬", false, Color3.fromRGB(255, 105, 180), function(s) grabCandy = s end)
addToggle(pageGrab, "Iced", "❄", false, Color3.fromRGB(0, 255, 255), function(s) grabIced = s end)
addToggle(pageGrab, "Lava", "🌋", false, Color3.fromRGB(255, 50, 0), function(s) grabLava = s end)
addToggle(pageGrab, "Rainbow", "🌈", false, Color3.fromRGB(255, 0, 255), function(s) grabRainbow = s end)
addToggle(pageGrab, "Golden", "✨", false, Color3.fromRGB(255, 215, 0), function(s) grabGolden = s end)

addLabel(pageGrab, "━━ BYPASS SETTINGS ━━", Color3.fromRGB(255, 100, 100))
local bypassLabel = addLabel(pageGrab, "Mode: Smooth TP", Color3.fromRGB(150, 200, 255))

addButton(pageGrab, "CHANGE METHOD", "🔄", Color3.fromRGB(100, 100, 200), function()
    if bypassMethod == "Smooth" then
        bypassMethod = "Tween"
        bypassLabel.Text = "Mode: Tween TP"
    elseif bypassMethod == "Tween" then
        bypassMethod = "Instant"
        bypassLabel.Text = "Mode: Instant TP"
    else
        bypassMethod = "Smooth"
        bypassLabel.Text = "Mode: Smooth TP"
    end
end)

addToggle(pageGrab, "Underground TP", "⛏", true, Color3.fromRGB(150, 100, 50), function(s) useUnderground = s end)

-- Price Parser
local function getBrainrotValue(model)
    for _, desc in pairs(model:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Visible then
            local text = desc.Text
            if text:match("%$") then
                local value = text:match("%$([%d%.]+[KMB]?)")
                if value then
                    local num = tonumber(value:match("[%d%.]+"))
                    if value:find("K") then return num * 1000
                    elseif value:find("M") then return num * 1000000
                    elseif value:find("B") then return num * 1000000000
                    else return num end
                end
            end
        end
    end
    return 0
end

-- Smooth TP
local function smoothTeleport(targetCFrame)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    if useUnderground then
        targetCFrame = targetCFrame * CFrame.new(0, undergroundOffset, 0)
    end
    
    if bypassMethod == "Instant" then
        hrp.CFrame = targetCFrame
        return true
    elseif bypassMethod == "Tween" then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = distance / teleportSpeed
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
        return true
    else
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local steps = math.ceil(distance / 20)
        for i = 1, steps do
            if not autoGrabEnabled then return false end
            hrp.CFrame = hrp.CFrame:Lerp(targetCFrame, 1/steps)
            task.wait(0.03)
        end
        return true
    end
end

-- Check Grab Conditions
local function checkGrabConditions(model)
    if not model or not model:IsA("Model") then return false end
    if not model:FindFirstChildWhichIsA("Humanoid") then return false end
    
    local hasStealSell = false
    for _, desc in pairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local text = desc.ObjectText:lower()
            if text:find("steal") or text:find("sell") then
                hasStealSell = true
                break
            end
        end
    end
    if hasStealSell then return false end
    
    local validCategory = false
    local validMutation = false
    
    for _, desc in pairs(model:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Visible then
            local t = desc.Text:lower()
            if (grabLegendary and t:find("legend")) or (grabMythic and t:find("myth")) or
               (grabSecret and t:find("secret")) or (grabGod and t:find("god")) or (grabOG and t:find("og")) then
                validCategory = true
            end
            if (grabCandy and t:find("candy")) or (grabIced and t:find("iced")) or
               (grabLava and t:find("lava")) or (grabRainbow and t:find("rainbow")) or (grabGolden and t:find("golden")) then
                validMutation = true
            end
        end
    end
    return validCategory or validMutation
end

-- Find Best Target
local function findBestBrainrot()
    local bestModel = nil
    local highestValue = 0
    for _, model in pairs(workspace:GetDescendants()) do
        if checkGrabConditions(model) then
            local value = getBrainrotValue(model)
            if value > highestValue then
                highestValue = value
                bestModel = model
            end
        end
    end
    return bestModel, highestValue
end

-- AUTO GRAB LOOP (Lanjutan dari Part 1)
spawn(function()
    while task.wait(grabCooldown) do
        if autoGrabEnabled and spawnPosition then
            local target, value = findBestBrainrot()
            
            if target and target:FindFirstChild("HumanoidRootPart") then
                grabStatusLabel.Text = string.format("🎯 Grabbing: $%.2f", value)
                grabStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                
                -- TP ke target
                local success = smoothTeleport(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                
                if success then
                    task.wait(0.2)
                    
                    -- Cari dan aktivasi grab prompt
                    for _, desc in pairs(target:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                            local text = desc.ObjectText:lower()
                            if text:find("ambil") or text:find("grab") or text:find("take") then
                                fireproximityprompt(desc)
                                task.wait(0.1)
                                break
                            end
                        end
                    end
                    
                    task.wait(0.3)
                    
                    -- Kembali ke spawn
                    smoothTeleport(spawnPosition)
                    
                    grabStatusLabel.Text = "🎯 Status: Returned to spawn"
                    grabStatusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
                end
            else
                grabStatusLabel.Text = "🎯 Status: No targets found"
                grabStatusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
                task.wait(2)
            end
        end
    end
end)

--==============================
-- ESP LOGIC (DUAL LABEL)
--==============================
function refreshESP()
    for _, obj in pairs(espObjects) do 
        pcall(function() obj[1]:Destroy() obj[2]:Destroy() end) 
    end
    espObjects = {}
    if not enabledESP then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildWhichIsA("Humanoid") then
            local category, mutation = nil, nil
            local categoryColor, mutationColor = nil, nil
            
            -- Scan untuk kategori DAN mutasi
            for _, desc in pairs(v:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Visible then
                    local t = desc.Text:lower()
                    
                    -- Deteksi KATEGORI
                    if t:find("legend") and showLegendary then 
                        category = "LEGENDARY"
                        categoryColor = Color3.fromRGB(255, 255, 0)
                    elseif t:find("myth") and showMythic then 
                        category = "MYTHIC"
                        categoryColor = Color3.fromRGB(255, 120, 0)
                    elseif t:find("secret") and showSecret then 
                        category = "SECRET"
                        categoryColor = Color3.fromRGB(170, 0, 255)
                    elseif t:find("god") and showGod then 
                        category = "GOD"
                        categoryColor = Color3.fromRGB(255, 0, 0)
                    elseif t:find("og") and showOG then 
                        category = "OG"
                        categoryColor = Color3.fromRGB(255, 255, 255)
                    end
                    
                    -- Deteksi MUTASI
                    if t:find("candy") and showCandy then 
                        mutation = "CANDY"
                        mutationColor = Color3.fromRGB(255, 105, 180)
                    elseif t:find("iced") and showIced then 
                        mutation = "ICED"
                        mutationColor = Color3.fromRGB(0, 255, 255)
                    elseif t:find("lava") and showLava then 
                        mutation = "LAVA"
                        mutationColor = Color3.fromRGB(255, 50, 0)
                    elseif t:find("rainbow") and showRainbow then 
                        mutation = "RAINBOW"
                        mutationColor = Color3.fromRGB(255, 0, 255)
                    elseif t:find("golden") and showGolden then 
                        mutation = "GOLDEN"
                        mutationColor = Color3.fromRGB(255, 215, 0)
                    end
                end
            end

            if (category or mutation) and v:FindFirstChild("HumanoidRootPart") then
                local bbg = Instance.new("BillboardGui", v.HumanoidRootPart)
                bbg.Size = UDim2.new(0, 200, 0, 50)
                bbg.StudsOffset = Vector3.new(0, 3, 0)
                bbg.AlwaysOnTop = true
                
                local textLabel = Instance.new("TextLabel", bbg)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.GothamBold
                
                local displayText = ""
                if category then
                    displayText = category
                    textLabel.TextColor3 = categoryColor
                end
                if mutation then
                    displayText = displayText .. (category and "\n" or "") .. mutation
                    if not category then
                        textLabel.TextColor3 = mutationColor
                    end
                end
                
                textLabel.Text = displayText
                
                local highlight = Instance.new("Highlight", v)
                highlight.FillColor = categoryColor or mutationColor
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.5
                
                table.insert(espObjects, {bbg, highlight})
            end
        end
    end
end

-- ESP Update Loop
RunService.Heartbeat:Connect(function()
    if enabledESP then 
        refreshESP() 
    end
end)

--==============================
-- FARM LOOPS
--==============================
-- Auto Upgrade Loop
spawn(function()
    while task.wait(0.1) do
        if enabledUpgrade then
            pcall(function()
                for _, npc in pairs(workspace:GetDescendants()) do
                    if npc:IsA("Model") and npc.Name:find("NPC") then
                        local id = npc:GetAttribute("ID")
                        if id and not table.find(NPC_IDS, id) then
                            upgradeRemote:FireServer(id)
                            table.insert(NPC_IDS, id)
                            statusLabel.Text = "📊 Captured IDs: " .. #NPC_IDS
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Collect Loop
spawn(function()
    while task.wait(0.1) do
        if enabledCollect then
            pcall(function() 
                collectRemote:InvokeServer() 
            end)
        end
    end
end)

--==============================
-- NOTIFICATIONS
--==============================
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

-- Welcome notification
notify("MYZOARN HUB V7", "Loaded successfully! 🎯", 5)

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("MYZOARN HUB V7 LOADED")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("Features:")
print("✓ Auto Farm (Upgrade & Collect)")
print("✓ Auto Grab with Price Detection")
print("✓ ESP (Category + Mutation)")
print("✓ Fly Mode (PC + Mobile)")
print("✓ Anti-TP Detection Bypass")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
