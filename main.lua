--==============================
-- SERVICES & VARIABLES
--==============================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")
local collectRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("CollectCash")
local gearFolder = RS:WaitForChild("Assets"):WaitForChild("Gear")

-- Global Settings
local enabledUpgrade, enabledCollect, enabledESP = false, false, false
local flying = false
local flySpeed = 50
local NPC_IDS = {}
local espObjects = {}

-- ESP TOGGLES
local showLegendary, showMythic, showSecret, showGod, showOG = true, true, true, true, true
local showCandy, showIced, showLava, showRainbow, showGolden = true, true, true, true, true

-- Fly Controls
local flyForward, flyBackward, flyUp, flyDown = false, false, false, false

--==============================
-- GUI MAIN STRUCTURE (Compact & Modern)
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MyzoarnTabs_V8_Compact"
gui.ResetOnSpawn = false

-- Main Frame (Lebih kecil)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 420)
frame.Position = UDim2.new(0.5, -130, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 10)

-- Gradient Overlay
local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
gradient.Rotation = 45

-- Title Bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Text = "✨ MYZOARN HUB"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button (Square)
local minimized = false
local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -34, 0, 4)
minBtn.Text = "─"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.BorderSizePixel = 0
local minCorner = Instance.new("UICorner", minBtn)
minCorner.CornerRadius = UDim.new(0, 6)

-- Content Container (untuk hide saat minimize)
local contentContainer = Instance.new("Frame", frame)
contentContainer.Size = UDim2.new(1, 0, 1, -38)
contentContainer.Position = UDim2.new(0, 0, 0, 38)
contentContainer.BackgroundTransparency = 1

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentContainer.Visible = not minimized
    minBtn.Text = minimized and "+" or "─"
    
    local targetSize = minimized and UDim2.new(0, 260, 0, 38) or UDim2.new(0, 260, 0, 420)
    TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = targetSize}):Play()
end)

-- Tab Container
local tabContainer = Instance.new("Frame", contentContainer)
tabContainer.Size = UDim2.new(1, -16, 0, 34)
tabContainer.Position = UDim2.new(0, 8, 0, 6)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabContainer.BorderSizePixel = 0
local tabCorner = Instance.new("UICorner", tabContainer)
tabCorner.CornerRadius = UDim.new(0, 8)

local function createTabBtn(name, pos, icon)
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0.33, -4, 1, -4)
    btn.Position = UDim2.new(pos, 2, 0, 2)
    btn.Text = icon .. " " .. name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    return btn
end

local btnFarm = createTabBtn("FARM", 0, "⚡")
local btnMove = createTabBtn("MOVE", 0.33, "✈️")
local btnEsp = createTabBtn("ESP", 0.66, "👁️")

-- Pages Container
local pages = Instance.new("Frame", contentContainer)
pages.Size = UDim2.new(1, -16, 1, -50)
pages.Position = UDim2.new(0, 8, 0, 46)
pages.BackgroundTransparency = 1

local function createPage()
    local p = Instance.new("ScrollingFrame", pages)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
    p.CanvasSize = UDim2.new(0, 0, 1.8, 0)
    p.BorderSizePixel = 0
    local list = Instance.new("UIListLayout", p)
    list.Padding = UDim.new(0, 6)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return p
end

local pageFarm = createPage()
local pageMove = createPage()
local pageEsp = createPage()
pageFarm.Visible = true

local currentTab = btnFarm
local function showPage(target, btn)
    pageFarm.Visible = (target == pageFarm)
    pageMove.Visible = (target == pageMove)
    pageEsp.Visible = (target == pageEsp)
    
    -- Tab Animation
    TweenService:Create(currentTab, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        TextColor3 = Color3.fromRGB(200, 200, 200)
    }):Play()
    
    TweenService:Create(btn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(100, 200, 255),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    currentTab = btn
end

btnFarm.MouseButton1Click:Connect(function() showPage(pageFarm, btnFarm) end)
btnMove.MouseButton1Click:Connect(function() showPage(pageMove, btnMove) end)
btnEsp.MouseButton1Click:Connect(function() showPage(pageEsp, btnEsp) end)

-- Initialize first tab
showPage(pageFarm, btnFarm)

local function addToggle(parent, text, default, colorOn, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -8, 0, 30)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    container.BorderSizePixel = 0
    local containerCorner = Instance.new("UICorner", container)
    containerCorner.CornerRadius = UDim.new(0, 6)
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, -8, 1, -4)
    btn.Position = UDim2.new(0, 4, 0, 2)
    btn.BackgroundColor3 = default and colorOn or Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    local status = Instance.new("TextLabel", btn)
    status.Size = UDim2.new(0, 40, 1, 0)
    status.Position = UDim2.new(1, -44, 0, 0)
    status.Text = default and "ON" or "OFF"
    status.TextColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 9
    status.BackgroundTransparency = 1
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        status.Text = state and "ON" or "OFF"
        status.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and colorOn or Color3.fromRGB(45, 45, 55)
        }):Play()
        
        callback(state)
    end)
    return btn
end

local function addButton(parent, text, color, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -8, 0, 32)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    container.BorderSizePixel = 0
    local containerCorner = Instance.new("UICorner", container)
    containerCorner.CornerRadius = UDim.new(0, 6)
    
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, -8, 1, -4)
    btn.Position = UDim2.new(0, 4, 0, 2)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addLabel(parent, text, color)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -8, 0, 22)
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(100, 200, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.BackgroundTransparency = 1
    return label
end

--==============================
-- TAB 1: FARMING
--==============================
local statusLabel = Instance.new("TextLabel", pageFarm)
statusLabel.Size = UDim2.new(1, -8, 0, 22)
statusLabel.Text = "📊 Captured IDs: 0"
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 10

addButton(pageFarm, "🎁 GET ALL GEARS", Color3.fromRGB(100, 50, 200), function()
    pcall(function()
        local bp = player:FindFirstChild("Backpack")
        if bp and gearFolder then
            for _, i in pairs(gearFolder:GetChildren()) do i:Clone().Parent = bp end
        end
    end)
end)

addButton(pageFarm, "🔄 RESET CAPTURED IDs", Color3.fromRGB(200, 50, 50), function()
    NPC_IDS = {}
    statusLabel.Text = "📊 Captured IDs: 0"
end)

addToggle(pageFarm, "⚡ Auto Upgrade", false, Color3.fromRGB(0, 200, 100), function(s) enabledUpgrade = s end)
addToggle(pageFarm, "💰 Auto Collect", false, Color3.fromRGB(255, 200, 0), function(s) enabledCollect = s end)

--==============================
-- TAB 2: MOVEMENT
--==============================
addToggle(pageMove, "✈️ Fly Mode", false, Color3.fromRGB(100, 150, 255), function(s) 
    flying = s 
    if s then startFly() end 
end)

addLabel(pageMove, "🎮 FLY CONTROLS:", Color3.fromRGB(255, 200, 100))

local controlInfo = Instance.new("TextLabel", pageMove)
controlInfo.Size = UDim2.new(1, -8, 0, 70)
controlInfo.Text = "W/S: Forward/Back\nA/D: Left/Right\nSPACE: Up\nLSHIFT: Down\n\n📱 Mobile: Use joystick"
controlInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
controlInfo.Font = Enum.Font.Gotham
controlInfo.TextSize = 9
controlInfo.BackgroundTransparency = 1
controlInfo.TextYAlignment = Enum.TextYAlignment.Top

--==============================
-- TAB 3: ESP MENU
--==============================
addToggle(pageEsp, "👁️ MASTER ESP", false, Color3.fromRGB(255, 100, 255), function(s) 
    enabledESP = s 
    if not s then
        -- Hapus semua ESP saat dinonaktifkan
        for _, obj in pairs(espObjects) do 
            pcall(function() 
                obj[1]:Destroy() 
                obj[2]:Destroy() 
            end) 
        end
        espObjects = {}
    end
end)

addLabel(pageEsp, "━━━ CATEGORY ESP ━━━", Color3.fromRGB(255, 255, 100))
addToggle(pageEsp, "⭐ Legendary", true, Color3.fromRGB(255, 215, 0), function(s) showLegendary = s end)
addToggle(pageEsp, "🔥 Mythic", true, Color3.fromRGB(255, 100, 0), function(s) showMythic = s end)
addToggle(pageEsp, "🔮 Secret", true, Color3.fromRGB(170, 0, 255), function(s) showSecret = s end)
addToggle(pageEsp, "👑 God", true, Color3.fromRGB(255, 0, 0), function(s) showGod = s end)
addToggle(pageEsp, "💎 OG", true, Color3.fromRGB(200, 200, 200), function(s) showOG = s end)

addLabel(pageEsp, "━━━ MUTATION ESP ━━━", Color3.fromRGB(100, 255, 255))
addToggle(pageEsp, "🍬 Candy", true, Color3.fromRGB(255, 105, 180), function(s) showCandy = s end)
addToggle(pageEsp, "❄️ Iced", true, Color3.fromRGB(0, 255, 255), function(s) showIced = s end)
addToggle(pageEsp, "🌋 Lava", true, Color3.fromRGB(255, 50, 0), function(s) showLava = s end)
addToggle(pageEsp, "🌈 Rainbow", true, Color3.fromRGB(255, 0, 255), function(s) showRainbow = s end)
addToggle(pageEsp, "✨ Golden", true, Color3.fromRGB(255, 215, 0), function(s) showGolden = s end)

--==============================
-- ENHANCED ESP LOGIC (Kategori + Mutasi)
--==============================
function refreshESP()
    for _, obj in pairs(espObjects) do pcall(function() obj[1]:Destroy() obj[2]:Destroy() end) end
    espObjects = {}
    if not enabledESP then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildWhichIsA("Humanoid") then
            local categoryCol, mutationCol = nil, nil
            local categoryLabel, mutationLabel = "", ""
            
            -- Scan semua TextLabel di model
            for _, desc in pairs(v:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Visible then
                    local t = desc.Text:lower()
                    
                    -- Deteksi KATEGORI
                    if t:find("legend") and showLegendary then 
                        categoryCol = Color3.fromRGB(255, 215, 0)
                        categoryLabel = "LEGENDARY"
                    elseif t:find("myth") and showMythic then 
                        categoryCol = Color3.fromRGB(255, 100, 0)
                        categoryLabel = "MYTHIC"
                    elseif t:find("secret") and showSecret then 
                        categoryCol = Color3.fromRGB(170, 0, 255)
                        categoryLabel = "SECRET"
                    elseif t:find("god") and showGod then 
                        categoryCol = Color3.fromRGB(255, 0, 0)
                        categoryLabel = "GOD"
                    elseif t:find("og") and showOG then 
                        categoryCol = Color3.fromRGB(200, 200, 200)
                        categoryLabel = "OG"
                    end
                    
                    -- Deteksi MUTASI
                    if t:find("candy") and showCandy then 
                        mutationCol = Color3.fromRGB(255, 105, 180)
                        mutationLabel = "CANDY"
                    elseif t:find("iced") and showIced then 
                        mutationCol = Color3.fromRGB(0, 255, 255)
                        mutationLabel = "ICED"
                    elseif t:find("lava") and showLava then 
                        mutationCol = Color3.fromRGB(255, 50, 0)
                        mutationLabel = "LAVA"
                    elseif t:find("rainbow") and showRainbow then 
                        mutationCol = Color3.fromRGB(255, 0, 255)
                        mutationLabel = "RAINBOW"
                    elseif t:find("golden") and showGolden then 
                        mutationCol = Color3.fromRGB(255, 215, 0)
                        mutationLabel = "GOLDEN"
                    end
                end
            end
            
            -- Tampilkan ESP jika ada kategori ATAU mutasi
            if categoryCol or mutationCol then
                local finalCol = mutationCol or categoryCol
                local finalLabel = mutationLabel ~= "" and mutationLabel or categoryLabel
                
                -- Jika ada KEDUANYA, gabungkan label
                if categoryLabel ~= "" and mutationLabel ~= "" then
                    finalLabel = mutationLabel .. " " .. categoryLabel
                end
                
                -- Box Highlight
                local box = Instance.new("BoxHandleAdornment", v)
                box.Size = v:GetExtentsSize()
                box.Adornee = v
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Color3 = finalCol
                box.Transparency = 0.6
                
                -- Billboard Label
                local bb = Instance.new("BillboardGui", v)
                bb.Size = UDim2.new(0, 120, 0, 50)
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0, 6, 0)
                
                local l = Instance.new("TextLabel", bb)
                l.Size = UDim2.new(1, 0, 1, 0)
                l.Text = "★ " .. finalLabel .. " ★"
                l.TextColor3 = finalCol
                l.Font = Enum.Font.GothamBold
                l.TextSize = 14
                l.BackgroundTransparency = 1
                l.TextStrokeTransparency = 0.5
                
                table.insert(espObjects, {box, bb})
            end
        end
    end
end

--==============================
-- ENHANCED FLY SYSTEM (Mobile Support)
--==============================
local flyConnection, flyBV, flyBG

function startFly()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    flyBG = Instance.new("BodyGyro", hrp)
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 9e4
    
    flyBV = Instance.new("BodyVelocity", hrp)
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    
    hum.PlatformStand = true
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying or not char.Parent then
            if flyConnection then flyConnection:Disconnect() end
            if flyBG then flyBG:Destroy() end
            if flyBV then flyBV:Destroy() end
            hum.PlatformStand = false
            return
        end
        
        local cam = workspace.CurrentCamera
        local moveDir = hum.MoveDirection
        local velocity = Vector3.new()
        
        -- Forward/Backward/Left/Right (dari MoveDirection)
        if moveDir.Magnitude > 0 then
            velocity = velocity + (cam.CFrame.LookVector * -moveDir.Z * flySpeed)
            velocity = velocity + (cam.CFrame.RightVector * -moveDir.X * flySpeed)
        end
        
        -- Up/Down Controls
        if flyUp then
            velocity = velocity + Vector3.new(0, flySpeed, 0)
        end
        if flyDown then
            velocity = velocity + Vector3.new(0, -flySpeed, 0)
        end
        
        flyBV.Velocity = velocity
        flyBG.CFrame = cam.CFrame
    end)
end

-- Keyboard Controls untuk PC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not flying then return end
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        flyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        flyDown = false
    end
end)

--==============================
-- BACKGROUND LOOPS
--==============================
task.spawn(function()
    while task.wait(0.1) do
        if enabledUpgrade then 
            for _, id in ipairs(NPC_IDS) do 
                pcall(function() upgradeRemote:InvokeServer(id) end) 
            end 
        end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if enabledCollect then 
            for i = 1, 30 do 
                pcall(function() collectRemote:FireServer(i) end) 
            end 
        end
    end
end)

task.spawn(function()
    while task.wait(3) do 
        if enabledESP then refreshESP() end 
    end
end)

--==============================
-- NPC ID CAPTURE
--==============================
local oldNc
oldNc = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if self == upgradeRemote and getnamecallmethod() == "InvokeServer" then
        if typeof(args[1]) == "string" and not table.find(NPC_IDS, args[1]) then
            table.insert(NPC_IDS, args[1])
            statusLabel.Text = "📊 Captured IDs: " .. #NPC_IDS
        end
    end
    return oldNc(self, ...)
end)
