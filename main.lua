local P = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local remote = RS.Remotes.Plot.UpgradeNPC

local enabled = true
local running = true

-- ===== GUI =====
local gui = Instance.new("ScreenGui", P.PlayerGui)
gui.Name = "AutoUpgradeGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,230,0,140)
frame.Position = UDim2.new(0,20,0,200)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.Text = "AUTO UPGRADE (LIAR)"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- TOGGLE
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-20,0,35)
toggle.Position = UDim2.new(0,10,0,40)
toggle.Text = "STATUS : ON"
toggle.TextScaled = true
toggle.BackgroundColor3 = Color3.fromRGB(120,20,20)
toggle.TextColor3 = Color3.new(1,1,1)

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "STATUS : ON" or "STATUS : OFF"
end)

-- HIDE BUTTON
local hide = Instance.new("TextButton", frame)
hide.Size = UDim2.new(0.45,0,0,30)
hide.Position = UDim2.new(0.05,0,0,85)
hide.Text = "HIDE"
hide.TextScaled = true
hide.BackgroundColor3 = Color3.fromRGB(70,70,70)
hide.TextColor3 = Color3.new(1,1,1)

hide.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- EXIT BUTTON
local exit = Instance.new("TextButton", frame)
exit.Size = UDim2.new(0.45,0,0,30)
exit.Position = UDim2.new(0.5,0,0,85)
exit.Text = "EXIT"
exit.TextScaled = true
exit.BackgroundColor3 = Color3.fromRGB(150,40,40)
exit.TextColor3 = Color3.new(1,1,1)

exit.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
end)

-- SHOW AGAIN (klik layar)
gui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        frame.Visible = true
    end
end)

-- ===== AUTO DETECT PLOT =====
local plot
for _,v in pairs(workspace:GetChildren()) do
    if v:IsA("Folder") and v:FindFirstChild(P.Name) then
        plot = v[P.Name]
        break
    end
end
if not plot then return end

-- GET NPC ID
local function getId(npc)
    return npc:GetAttribute("Id")
        or npc:GetAttribute("ID")
        or npc:GetAttribute("NpcId")
        or npc:GetAttribute("UUID")
        or (npc:FindFirstChild("Id") and npc.Id.Value)
end

-- ===== MODE LIAR =====
task.spawn(function()
    while task.wait(0.15) do
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
