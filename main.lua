--[[
    MYZOARNHUB V6 - COMPACT ENGLISH VERSION
    MODERN UI EDITION
]]--

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")
local collectRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("CollectCash")

local enabledUpgrade, enabledCollect, enabledESP = false, false, false
local flying, flySpeed = false, 50
local NPC_IDS, espObjects = {}, {}
local showLegendary, showMythic, showSecret, showGod, showLucky = true, true, true, true, true

--==============================
-- MODERN UI ELEMENTS
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MyzoarnHub_V6_MODERN"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Background blur effect
local blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 0
blur.Name = "MyzoarnHubBlur"

-- Main container with modern styling
local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 360, 0, 420)
container.Position = UDim2.new(0.5, -180, 0.5, -210)
container.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
container.BackgroundTransparency = 0.05
container.BorderSizePixel = 0
container.Active = true
container.Draggable = true
container.ClipsDescendants = true

local corner = Instance.new("UICorner", container)
corner.CornerRadius = UDim.new(0, 12)

-- Glassmorphism effect
local gradient = Instance.new("UIGradient", container)
gradient.Rotation = 90
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 36)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(24, 24, 32)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 28))
})

local border = Instance.new("Frame", container)
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundTransparency = 1
border.BorderSizePixel = 0
local stroke = Instance.new("UIStroke", border)
stroke.Color = Color3.fromRGB(80, 80, 100)
stroke.Thickness = 1.5
stroke.Transparency = 0.7
Instance.new("UICorner", border).CornerRadius = UDim.new(0, 12)

-- Header with gradient
local header = Instance.new("Frame", container)
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundTransparency = 1

local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 200))
})

local headerBg = Instance.new("Frame", header)
headerBg.Size = UDim2.new(1, 0, 1, 0)
headerBg.BackgroundColor3 = Color3.new(1, 1, 1)
headerBg.BackgroundTransparency = 0.9
headerBg.BorderSizePixel = 0

local mask = Instance.new("Frame", headerBg)
mask.Size = UDim2.new(1, 0, 1, 0)
mask.BackgroundColor3 = Color3.new(1, 1, 1)
mask.BorderSizePixel = 0
headerGradient.Parent = mask
mask:ClearAllChildren()

-- Title with icon
local titleContainer = Instance.new("Frame", header)
titleContainer.Size = UDim2.new(1, -40, 1, 0)
titleContainer.Position = UDim2.new(0, 20, 0, 0)
titleContainer.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleContainer)
title.Size = UDim2.new(1, 0, 0.6, 0)
title.Position = UDim2.new(0, 0, 0.2, 0)
title.Text = "MYZOARNHUB V6"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextStrokeTransparency = 0.7
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local subtitle = Instance.new("TextLabel", titleContainer)
subtitle.Size = UDim2.new(1, 0, 0.4, 0)
subtitle.Position = UDim2.new(0, 0, 0.6, 0)
subtitle.Text = "PREMIUM AUTOMATION SUITE"
subtitle.TextColor3 = Color3.fromRGB(200, 200, 220)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Status indicator
local statusIndicator = Instance.new("Frame", header)
statusIndicator.Size = UDim2.new(0, 6, 0, 6)
statusIndicator.Position = UDim2.new(1, -30, 0.5, -3)
statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
statusIndicator.BorderSizePixel = 0
Instance.new("UICorner", statusIndicator).CornerRadius = UDim.new(1, 0)

local statusText = Instance.new("TextLabel", header)
statusText.Size = UDim2.new(0, 80, 0, 12)
statusText.Position = UDim2.new(1, -100, 0.5, -6)
statusText.Text = "ACTIVE"
statusText.TextColor3 = Color3.fromRGB(200, 200, 220)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamMedium
statusText.TextSize = 10
statusText.TextXAlignment = Enum.TextXAlignment.Right

-- Tab navigation
local tabContainer = Instance.new("Frame", container)
tabContainer.Size = UDim2.new(1, -40, 0, 36)
tabContainer.Position = UDim2.new(0, 20, 0, 70)
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tabContainer.BackgroundTransparency = 0.1
Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 8)

local tabHighlight = Instance.new("Frame", tabContainer)
tabHighlight.Size = UDim2.new(0.333, 0, 1, 0)
tabHighlight.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
tabHighlight.BackgroundTransparency = 0.2
tabHighlight.BorderSizePixel = 0
Instance.new("UICorner", tabHighlight).CornerRadius = UDim.new(0, 8)

local function createTab(name, pos)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.Position = UDim2.new(pos, 0, 0, 0)
    btn.Text = name
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    return btn
end

local tabNames = {"FARMING", "MOVEMENT", "ESP"}
local tabs = {}
for i, name in ipairs(tabNames) do
    local tab = createTab(name, (i-1) * 0.333)
    table.insert(tabs, tab)
end

-- Content area
local contentContainer = Instance.new("Frame", container)
contentContainer.Size = UDim2.new(1, -40, 1, -120)
contentContainer.Position = UDim2.new(0, 20, 0, 110)
contentContainer.BackgroundTransparency = 1

-- Content pages
local function createPage()
    local page = Instance.new("ScrollingFrame", contentContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    page.ScrollBarThickness = 3
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    
    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    
    return page
end

local pages = {
    farming = createPage(),
    movement = createPage(),
    esp = createPage()
}
pages.farming.Visible = true

-- Tab switching with animation
local function switchTab(tabIndex)
    for _, page in pairs(pages) do
        page.Visible = false
    end
    
    local targetPage = pages[({"farming", "movement", "esp"})[tabIndex]]
    targetPage.Visible = true
    
    -- Animate tab highlight
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(tabHighlight, tweenInfo, {
        Position = UDim2.new((tabIndex-1) * 0.333, 0, 0, 0)
    })
    tween:Play()
end

for i, tab in ipairs(tabs) do
    tab.MouseButton1Click:Connect(function()
        switchTab(i)
    end)
end

-- Modern toggle button
local function createModernToggle(parent, text, description, default, colorOn, callback)
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.Size = UDim2.new(1, 0, 0, 56)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    toggleFrame.BackgroundTransparency = 0.1
    toggleFrame.LayoutOrder = #parent:GetChildren()
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", toggleFrame)
    stroke.Color = Color3.fromRGB(60, 60, 75)
    stroke.Thickness = 1
    
    local textContainer = Instance.new("Frame", toggleFrame)
    textContainer.Size = UDim2.new(0.7, 0, 1, 0)
    textContainer.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", textContainer)
    label.Size = UDim2.new(1, -20, 0.6, 0)
    label.Position = UDim2.new(0, 15, 0.2, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local desc = Instance.new("TextLabel", textContainer)
    desc.Size = UDim2.new(1, -20, 0.4, 0)
    desc.Position = UDim2.new(0, 15, 0.6, 0)
    desc.Text = description
    desc.TextColor3 = Color3.fromRGB(180, 180, 200)
    desc.BackgroundTransparency = 1
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 10
    desc.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleContainer = Instance.new("Frame", toggleFrame)
    toggleContainer.Size = UDim2.new(0.3, 0, 1, 0)
    toggleContainer.Position = UDim2.new(0.7, 0, 0, 0)
    toggleContainer.BackgroundTransparency = 1
    
    local toggleBg = Instance.new("Frame", toggleContainer)
    toggleBg.Size = UDim2.new(0, 44, 0, 24)
    toggleBg.Position = UDim2.new(0.5, -22, 0.5, -12)
    toggleBg.BackgroundColor3 = default and colorOn or Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local toggleCircle = Instance.new("Frame", toggleBg)
    toggleCircle.Size = UDim2.new(0, 20, 0, 20)
    toggleCircle.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleCircle.BorderSizePixel = 0
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    
    local function updateToggle()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        local bgTween = TweenService:Create(toggleBg, tweenInfo, {
            BackgroundColor3 = state and colorOn or Color3.fromRGB(60, 60, 70)
        })
        
        local circleTween = TweenService:Create(toggleCircle, tweenInfo, {
            Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        })
        
        bgTween:Play()
        circleTween:Play()
        callback(state)
    end
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateToggle()
        end
    end)
    
    return toggleFrame
end

-- Modern button
local function createModernButton(parent, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = #parent:GetChildren()
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(100, 100, 120)
    stroke.Thickness = 1
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        local clickTween = TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.new(1, 1, 1)
        })
        clickTween:Play()
        clickTween.Completed:Wait()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = color
        }):Play()
        callback()
    end)
    
    return btn
end

--==============================
-- PAGE CONTENT (MODERN)
--==============================

-- FARMING PAGE
local statsContainer = Instance.new("Frame", pages.farming)
statsContainer.Size = UDim2.new(1, 0, 0, 70)
statsContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
statsContainer.BackgroundTransparency = 0.1
Instance.new("UICorner", statsContainer).CornerRadius = UDim.new(0, 8)

local statsText = Instance.new("TextLabel", statsContainer)
statsText.Size = UDim2.new(1, -20, 1, -20)
statsText.Position = UDim2.new(0, 10, 0, 10)
statsText.Text = "CAPTURED IDS: 0\nREADY FOR AUTOMATION"
statsText.TextColor3 = Color3.fromRGB(0, 255, 150)
statsText.BackgroundTransparency = 1
statsText.Font = Enum.Font.GothamMedium
statsText.TextSize = 12
statsText.TextXAlignment = Enum.TextXAlignment.Left
statsText.TextYAlignment = Enum.TextYAlignment.Top
statsText.TextWrapped = true
statsText.Name = "StatusText"

createModernButton(pages.farming, "CLEAR CAPTURED DATA", Color3.fromRGB(180, 50, 50), function()
    table.clear(NPC_IDS)
    statsText.Text = "CAPTURED IDS: 0\nREADY FOR AUTOMATION"
end)

createModernToggle(pages.farming, "Auto Upgrade", "Automatically upgrade captured NPCs", false, Color3.fromRGB(0, 200, 100), function(v)
    enabledUpgrade = v
end)

createModernToggle(pages.farming, "Auto Collect", "Automatically collect cash from plots", false, Color3.fromRGB(0, 180, 200), function(v)
    enabledCollect = v
end)

-- MOVEMENT PAGE
createModernToggle(pages.movement, "Fly Mode", "Enable flying movement", false, Color3.fromRGB(0, 150, 220), function(v)
    flying = v
    if v then
        startFly()
    end
end)

-- ESP PAGE
createModernToggle(pages.esp, "Master ESP", "Toggle all ESP features", false, Color3.fromRGB(120, 80, 220), function(v)
    enabledESP = v
    refreshESP()
end)

local espColors = {
    {"Legendary", "Highlight legendary items", showLegendary, Color3.fromRGB(255, 215, 0)},
    {"Mythic", "Highlight mythic items", showMythic, Color3.fromRGB(255, 100, 0)},
    {"Secret", "Highlight secret items", showSecret, Color3.fromRGB(150, 0, 220)},
    {"God", "Highlight god items", showGod, Color3.fromRGB(220, 0, 0)},
    {"Lucky Block", "Highlight lucky blocks", showLucky, Color3.fromRGB(0, 220, 0)}
}

for _, espData in ipairs(espColors) do
    createModernToggle(pages.esp, espData[1], espData[2], espData[3], espData[4], function(v)
        if espData[1] == "Legendary" then showLegendary = v
        elseif espData[1] == "Mythic" then showMythic = v
        elseif espData[1] == "Secret" then showSecret = v
        elseif espData[1] == "God" then showGod = v
        elseif espData[1] == "Lucky Block" then showLucky = v end
        if enabledESP then refreshESP() end
    end)
end

--==============================
-- MODERN CONTROLS
--==============================

-- Close/Minimize buttons
local closeBtn = Instance.new("TextButton", container)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 8)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.BackgroundTransparency = 0.1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local minimizeBtn = Instance.new("TextButton", container)
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -62, 0, 8)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
minimizeBtn.BackgroundTransparency = 0.1
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

-- Floating button
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.Position = UDim2.new(1, -60, 0.5, -25)
floatBtn.Text = "MZ"
floatBtn.TextColor3 = Color3.new(1, 1, 1)
floatBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
floatBtn.BackgroundTransparency = 0.1
floatBtn.Font = Enum.Font.GothamBlack
floatBtn.TextSize = 14
floatBtn.Visible = false
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local floatGlow = Instance.new("Frame", floatBtn)
floatGlow.Size = UDim2.new(1, 0, 1, 0)
floatGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
floatGlow.BackgroundTransparency = 0.9
floatGlow.BorderSizePixel = 0
Instance.new("UICorner", floatGlow).CornerRadius = UDim.new(1, 0)

-- Button interactions
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    blur.Size = 0
end)

minimizeBtn.MouseButton1Click:Connect(function()
    container.Visible = false
    floatBtn.Visible = true
    TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
end)

floatBtn.MouseButton1Click:Connect(function()
    container.Visible = true
    floatBtn.Visible = false
    TweenService:Create(blur, TweenInfo.new(0.3), {Size = 10}):Play()
end)

-- Initial blur effect
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 10}):Play()

--==============================
-- ORIGINAL LOGIC (UNCHANGED)
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

-- FLYING LOGIC (with modern controls)
local flyCtrl = Instance.new("Frame", gui)
flyCtrl.Name = "FlyControls"; flyCtrl.Size = UDim2.new(0, 60, 0, 100); flyCtrl.Position = UDim2.new(0.9, -10, 0.5, -50); flyCtrl.Visible = false; flyCtrl.BackgroundColor3 = Color3.fromRGB(30, 30, 40); flyCtrl.BackgroundTransparency = 0.2; Instance.new("UICorner", flyCtrl).CornerRadius = UDim.new(0, 8)

local function fBtn(t, y)
    local b = Instance.new("TextButton", flyCtrl); b.Size = UDim2.new(1, -10, 0, 45); b.Position = UDim2.new(0, 5, 0, y); b.Text = t; b.BackgroundColor3 = Color3.fromRGB(60, 140, 220); b.BackgroundTransparency = 0.1; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 16; Instance.new("UICorner", b); return b
end
local uB, dB = fBtn("↑", 5), fBtn("↓", 50)
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
            table.insert(NPC_IDS, args[1])
            statsText.Text = "CAPTURED IDS: " .. #NPC_IDS .. "\nREADY FOR AUTOMATION"
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

player.Idled:Connect(function() game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
