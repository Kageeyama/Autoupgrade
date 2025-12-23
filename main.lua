--==============================
-- SERVICES
--==============================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = RS:WaitForChild("Remotes"):WaitForChild("Plot"):WaitForChild("UpgradeNPC")

--==============================
-- DATA
--==============================
local enabled = false
local NPC_IDS = {}
_G.NPC_IDS = NPC_IDS

--==============================
-- GUI ROOT
--==============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

-- MAIN FRAME
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,300)
frame.Position = UDim2.new(0.5,-150,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.Text = "AUTO UPGRADE NPC"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- INFO
local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1,-20,0,30)
info.Position = UDim2.new(0,10,0,45)
info.BackgroundTransparency = 1
info.Text = "Upgrade NPC manual → ID auto masuk"
info.TextColor3 = Color3.fromRGB(200,200,200)
info.TextScaled = true

-- STATUS
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,25)
status.Position = UDim2.new(0,10,0,75)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200,200,200)
status.TextScaled = true
status.Text = "Total ID: 0"

-- TOGGLE AUTO
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1,-20,0,45)
toggle.Position = UDim2.new(0,10,0,105)
toggle.Text = "AUTO : OFF"
toggle.TextScaled = true
toggle.BackgroundColor3 = Color3.fromRGB(120,40,40)
toggle.TextColor3 = Color3.new(1,1,1)

-- CLEAR ID
local clear = Instance.new("TextButton", frame)
clear.Size = UDim2.new(1,-20,0,35)
clear.Position = UDim2.new(0,10,0,155)
clear.Text = "CLEAR ID"
clear.TextScaled = true
clear.BackgroundColor3 = Color3.fromRGB(80,40,40)
clear.TextColor3 = Color3.new(1,1,1)

-- HIDE GUI
local hideBtn = Instance.new("TextButton", frame)
hideBtn.Size = UDim2.new(1,-20,0,30)
hideBtn.Position = UDim2.new(0,10,0,195)
hideBtn.Text = "HIDE GUI"
hideBtn.TextScaled = true
hideBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
hideBtn.TextColor3 = Color3.new(1,1,1)

-- SHOW FLOATING
local showBtn = Instance.new("TextButton", gui)
showBtn.Size = UDim2.new(0,80,0,35)
showBtn.Position = UDim2.new(0,20,0.5,0)
showBtn.Text = "SHOW"
showBtn.TextScaled = true
showBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
showBtn.TextColor3 = Color3.new(1,1,1)
showBtn.Visible = false
showBtn.Active = true
showBtn.Draggable = true

--==============================
-- FUNCTIONS
--==============================
local function updateStatus()
	status.Text = "Total ID: "..#NPC_IDS
end

toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggle.Text = enabled and "AUTO : ON" or "AUTO : OFF"
	toggle.BackgroundColor3 = enabled
		and Color3.fromRGB(40,120,40)
		or Color3.fromRGB(120,40,40)
end)

clear.MouseButton1Click:Connect(function()
	table.clear(NPC_IDS)
	updateStatus()
end)

hideBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	showBtn.Visible = true
end)

showBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	showBtn.Visible = false
end)

--==============================
-- AUTO UPGRADE LOOP
--==============================
task.spawn(function()
	while task.wait(0.1) do
		if not enabled then continue end
		for _,id in ipairs(NPC_IDS) do
			if not enabled then break end
			pcall(function()
				remote:InvokeServer(id)
			end)
		end
	end
end)

--==============================
-- REMOTE SPY (AUTO CAPTURE ID)
--==============================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local args = {...}
	local method = getnamecallmethod()

	if self == remote and method == "InvokeServer" then
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
