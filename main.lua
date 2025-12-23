local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = RS.Remotes.Plot.UpgradeNPC
local enabled = false

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,220,0,50)
btn.Position = UDim2.new(0,20,0,200)
btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Text = "AUTO UPGRADE ALL : OFF"

btn.MouseButton1Click:Connect(function()
    enabled = not enabled
    btn.Text = enabled and "AUTO UPGRADE ALL : ON" or "AUTO UPGRADE ALL : OFF"
end)

-- Ambil plot
local plot = workspace.Plots:WaitForChild(player.Name)

-- Fungsi ambil NPC ID
local function getNpcId(npc)
    return npc:GetAttribute("Id")
        or npc:GetAttribute("ID")
        or npc:GetAttribute("NpcId")
        or npc:GetAttribute("UUID")
        or (npc:FindFirstChild("Id") and npc.Id.Value)
end

-- LOOP UPGRADE SEMUA NPC
task.spawn(function()
    while task.wait(1) do
        if not enabled then continue end

        for _,npc in pairs(plot:GetChildren()) do
            if not enabled then break end

            local npcId = getNpcId(npc)
            if npcId then
                pcall(function()
                    remote:InvokeServer(npcId)
                end)
                task.wait(0.25) -- delay penting
            end
        end
    end
end)