--==============================
-- SERVICES
--==============================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local upgradeRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")
local collectRemote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("CollectCash")

--==============================
-- DATA
--==============================
local enabledUpgrade = false
local enabledCollect = false
local enabledFly = false
local NPC_IDS = {}
_G.NPC_IDS = NPC_IDS
local speed = 50
local direction = Vector3.new()

--==============================
-- GUI ROOT
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

-- MAIN FRAME
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,400)
frame.Position = UDim2.new(0.5,-150,0.5,-200)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.Text = "AUTO UPGRADE & COLLECT MYZOARN"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- STATUS
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,25)
status.Position = UDim2.new(0,10,0,45)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200,200,200)
status.TextScaled = true
status.Text = "Total NPC ID: 0"

-- TOGGLE AUTO UPGRADE
local toggleUpgrade = Instance.new("TextButton", frame)
toggleUpgrade.Size = UDim2.new(1,-20,0,40)
toggleUpgrade.Position = UDim2.new(0,10,0,75)
toggleUpgrade.Text = "AUTO UPGRADE : OFF"
toggleUpgrade.TextScaled = true
toggleUpgrade.BackgroundColor3 = Color3.fromRGB(120,40,40)
toggleUpgrade.TextColor3 = Color3.new(1,1,1)

-- TOGGLE AUTO COLLECT
local toggleCollect = Instance.new("TextButton", frame)
toggleCollect.Size = UDim2.new(1,-20,0,40)
toggleCollect.Position = UDim2.new(0,10,0,120)
toggleCollect.Text = "AUTO COLLECT : OFF"
toggleCollect.TextScaled = true
toggleCollect.BackgroundColor3 = Color3.fromRGB(120,40,40)
toggleCollect.TextColor3 = Color3.new(1,1,1)

-- TOGGLE FLY
local toggleFly = Instance.new("TextButton", frame)
toggleFly.Size = UDim2.new(1,-20,0,40)
toggleFly.Position = UDim2.new(0,10,0,165)
toggleFly.Text = "FLY : OFF"
toggleFly.TextScaled = true
toggleFly.BackgroundColor3 = Color3.fromRGB(120,40,40)
toggleFly.TextColor3 = Color3.new(1,1,1)

-- CLEAR ID
local clear = Instance.new("TextButton", frame)
clear.Size = UDim2.new(1,-20,0,35)
clear.Position = UDim2.new(0,10,0,210)
clear.Text = "CLEAR NPC ID"
clear.TextScaled = true
clear.BackgroundColor3 = Color3.fromRGB(80,40,40)
clear.TextColor3 = Color3.new(1,1,1)

--==============================
-- FUNCTIONS
--==============================
local function updateStatus()
	status.Text = "Total NPC ID: "..#NPC_IDS
end

toggleUpgrade.MouseButton1Click:Connect(function()
	enabledUpgrade = not enabledUpgrade
	toggleUpgrade.Text = enabledUpgrade and "AUTO UPGRADE : ON" or "AUTO UPGRADE : OFF"
	toggleUpgrade.BackgroundColor3 = enabledUpgrade and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

toggleCollect.MouseButton1Click:Connect(function()
	enabledCollect = not enabledCollect
	toggleCollect.Text = enabledCollect and "AUTO COLLECT : ON" or "AUTO COLLECT : OFF"
	toggleCollect.BackgroundColor3 = enabledCollect and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

toggleFly.MouseButton1Click:Connect(function()
	enabledFly = not enabledFly
	toggleFly.Text = enabledFly and "FLY : ON" or "FLY : OFF"
	toggleFly.BackgroundColor3 = enabledFly and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)

clear.MouseButton1Click:Connect(function()
	table.clear(NPC_IDS)
	updateStatus()
end)

--==============================
-- AUTO UPGRADE LOOP
--==============================
task.spawn(function()
	while task.wait(0.1) do
		if not enabledUpgrade then continue end
		for _,id in ipairs(NPC_IDS) do
			if not enabledUpgrade then break end
			pcall(function()
				upgradeRemote:InvokeServer(id)
			end)
		end
	end
end)

--==============================
-- AUTO COLLECT LOOP
--==============================
task.spawn(function()
	while task.wait(0.3) do
		if not enabledCollect then continue end
		for i = 1,30 do
			pcall(function()
				collectRemote:FireServer(i)
			end)
		end
	end
end)

--==============================
-- FLY LOOP
--==============================
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

RunService.RenderStepped:Connect(function(delta)
	if enabledFly then
		local cam = workspace.CurrentCamera
		direction = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction - cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + cam.CFrame.RightVector end
		hrp.CFrame = hrp.CFrame + direction.Unit * speed * delta
	end
end)

--==============================
-- REMOTE SPY (AUTO CAPTURE ID)
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
