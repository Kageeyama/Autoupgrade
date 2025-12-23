local P = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local remote = RS.Remotes.Plot.UpgradeNPC

local enabled = true
local running = true

-- ===== GUI ROOT =====
local gui = Instance.new("ScreenGui", P.PlayerGui)
gui.Name = "AutoUpgradeHP"
gui.ResetOnSpawn = false

-- ===== FLOATING BUTTON =====
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0,55,0,55)
floatBtn.Position = UDim2.new(0,20,0.5,-27)
floatBtn.BackgroundColor3 = Color3.fromRGB(120,20,20)
floatBtn.Text = "UP"
floatBtn.TextScaled = true
floatBtn.TextColor3 = Color3.new(1,1,1)
floatBtn.BorderSizePixel = 0
floatBtn.AutoButtonColor = true
floatBtn.Active = true
floatBtn.Draggable = true

-- bikin bulat
local corner = Instance.new("UICorner", floatBtn)
corner.CornerRadius = UDim.new(1,0)

-- ===== MAIN PANEL =====
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,240,0,160)
frame.Position = UDim2.new(0,90,0.5,-80)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Visible = true
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local fc = Instance.new("UICorner", frame)
fc.CornerRadius = UDim.new(0,12)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.Text = "AUTO UPGRADE (HP)"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)

-- TOGGLE
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-20,0,40)
toggle.Position = UDim2.new(0,10,0,45)
toggle.Text = "STATUS : ON"
toggle.TextScaled = true
toggle.BackgroundColor3 = Color3.fromRGB(120,20,20)
toggle.TextColor3 = Color3.new(1,1,1)

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "STATUS : ON" or "STATUS : OFF"
end)

-- EXIT
local exit = Instance.new("TextButton", frame)
exit.Size = UDim2.new(1,-20,0,35)
exit.Position = UDim2.new(0,10,0,95)
exit.Text = "EXIT SCRIPT"
exit.TextScaled = true
exit.BackgroundColor3 = Color3.fromRGB(150,40,40)
exit.TextColor3 = Color3.new(1,1,1)

exit.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
end)

-- FLOAT BUTTON FUNCTION
floatBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ===== AUTO DETECT PLOT =====
local plot
for _,v in pairs(workspace:GetChildren()) do
    if v:IsA("Folder") and v:FindFirstChild(P.Name) then
        plot = v[P.Name]
        break
    end
end
if not plot then
    warn("PLOT TIDAK KETEMU")
    return
end

-- GET NPC ID
local function getId(npc)
    return npc:GetAttribute("Id")
        or npc:GetAttribute("ID")
        or npc:GetAttribute("NpcId")
        or npc:GetAttribute("UUID")
        or (npc:FindFirstChild("Id") and npc.Id.Value)
end

-- ===== AUTO UPGRADE LOOP =====
task.spawn(function()
    while task.wait(0.2) do
        if not running then break end
        if not enabled then continue end

        for _,npc in ipairs(plot:GetDescendants()) do
            if npc:IsA("Model") then
                local id = getId(npc)
                if id then
                    pcall(function()
                        remote:InvokeServer(id)
                    end)
                end
            end
        end
    end
end)
