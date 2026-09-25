-- LocalScript
-- ใส่ใน StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- =========================
-- ตั้งค่า
-- =========================
local speed = 16
local infiniteJump = false

-- =========================
-- UI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControlUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 190)
frame.Position = UDim2.new(0.5, -140, 0.5, -95)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

-- =========================
-- หัวข้อ / จุดลาก UI
-- =========================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Player Control"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- =========================
-- Speed
-- =========================
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 100, 0, 30)
speedLabel.Position = UDim2.new(0, 15, 0, 50)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed"
speedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = frame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 100, 0, 35)
speedBox.Position = UDim2.new(1, -115, 0, 47)
speedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
speedBox.BorderSizePixel = 0
speedBox.Text = "16"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 16
speedBox.Font = Enum.Font.Gotham
speedBox.ClearTextOnFocus = false
speedBox.Parent = frame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 9)
speedCorner.Parent = speedBox

-- =========================
-- Infinite Jump
-- =========================
local jumpButton = Instance.new("TextButton")
jumpButton.Size = UDim2.new(1, -30, 0, 45)
jumpButton.Position = UDim2.new(0, 15, 0, 95)
jumpButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
jumpButton.BorderSizePixel = 0
jumpButton.Text = "Infinite Jump : OFF"
jumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpButton.TextSize = 16
jumpButton.Font = Enum.Font.GothamBold
jumpButton.Parent = frame

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 10)
jumpCorner.Parent = jumpButton

-- =========================
-- ปุ่ม Apply
-- =========================
local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(1, -30, 0, 35)
applyButton.Position = UDim2.new(0, 15, 0, 145)
applyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
applyButton.BorderSizePixel = 0
applyButton.Text = "Apply Speed"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.TextSize = 15
applyButton.Font = Enum.Font.GothamBold
applyButton.Parent = frame

local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 9)
applyCorner.Parent = applyButton

-- =========================
-- ตั้งความเร็ว
-- =========================
local function applySpeed()
	local value = tonumber(speedBox.Text)

	if value then
		speed = math.clamp(math.floor(value), 1, 100)
		speedBox.Text = tostring(speed)

		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = speed
			end
		end
	else
		speedBox.Text = tostring(speed)
	end
end

applyButton.MouseButton1Click:Connect(applySpeed)

-- ใช้ Enter เพื่อ Apply
speedBox.FocusLost:Connect(function()
	applySpeed()
end)

-- =========================
-- Infinite Jump
-- =========================
jumpButton.MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump

	if infiniteJump then
		jumpButton.Text = "Infinite Jump : ON"
	else
		jumpButton.Text = "Infinite Jump : OFF"
	end
end)

UserInputService.JumpRequest:Connect(function()
	if infiniteJump then
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

-- =========================
-- ตั้ง Speed หลังเกิดใหม่
-- =========================
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = speed
end)

-- =========================
-- ทำให้ UI ลากได้
-- =========================
local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
