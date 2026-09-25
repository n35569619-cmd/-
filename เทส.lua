-- LocalScript
-- ใส่ใน StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local speed = 16
local infiniteJump = false
local noclip = false

-- =========================
-- GUI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControlUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 190)
frame.Position = UDim2.new(0.5, -150, 0.5, -95)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

-- =========================
-- Header
-- =========================
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -50, 0, 42)
header.Position = UDim2.new(0, 45, 0, 0)
header.BackgroundTransparency = 1
header.Text = "Player Control"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.TextSize = 19
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = frame

-- X
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(0, 8, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(255,70,70)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.TextSize = 23
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0,8)
closeCorner.Parent = close

-- =========================
-- ฟังก์ชันสร้างแถว
-- =========================
local function createRow(text, y)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 160, 0, 38)
	label.Position = UDim2.new(0, 15, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(235,235,235)
	label.TextSize = 16
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	return label
end

-- =========================
-- ความเร็ว
-- =========================
createRow("ความเร็ว", 50)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 90, 0, 34)
speedBox.Position = UDim2.new(1, -105, 0, 52)
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,60)
speedBox.Text = "16"
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.TextSize = 16
speedBox.Font = Enum.Font.GothamBold
speedBox.BorderSizePixel = 0
speedBox.ClearTextOnFocus = false
speedBox.Parent = frame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0,9)
speedCorner.Parent = speedBox

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

speedBox.FocusLost:Connect(applySpeed)

-- =========================
-- ปุ่ม Toggle
-- =========================
local function createToggle(y, offText, onText)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(0, 90, 0, 34)
	button.Position = UDim2.new(1, -105, 0, y)
	button.BackgroundColor3 = Color3.fromRGB(55,55,65)
	button.Text = offText
	button.TextColor3 = Color3.fromRGB(255,255,255)
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold
	button.BorderSizePixel = 0
	button.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,9)
	corner.Parent = button

	local enabled = false

	button.MouseButton1Click:Connect(function()
		enabled = not enabled

		if enabled then
			button.Text = onText
			button.BackgroundColor3 = Color3.fromRGB(255,140,0)
		else
			button.Text = offText
			button.BackgroundColor3 = Color3.fromRGB(55,55,65)
		end
	end)

	return button, function()
		return enabled
	end
end

-- =========================
-- กระโดดไม่จำกัด
-- =========================
createRow("กระโดดไม่จำกัด", 92)

local jumpButton, getJumpState =
	createToggle(94, "ปิด", "เปิด")

jumpButton.MouseButton1Click:Connect(function()
	infiniteJump = getJumpState()
end)

-- =========================
-- ทะลุกำแพง
-- =========================
createRow("ทะลุกำแพง", 134)

local noclipButton, getNoclipState =
	createToggle(136, "ปิด", "เปิด")

noclipButton.MouseButton1Click:Connect(function()
	noclip = getNoclipState()
end)

-- =========================
-- Infinite Jump
-- =========================
UserInputService.JumpRequest:Connect(function()
	if infiniteJump then
		local character = player.Character

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)
			end
		end
	end
end)

-- =========================
-- Noclip
-- =========================
RunService.Stepped:Connect(function()
	if noclip then
		local character = player.Character

		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- =========================
-- Respawn
-- =========================
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = speed
end)

-- =========================
-- ลาก UI
-- =========================
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

header.InputEnded:Connect(function(input)
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

-- =========================
-- ย่อ UI
-- =========================
local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(0,55,0,55)
miniButton.Position = frame.Position
miniButton.BackgroundColor3 = Color3.fromRGB(255,140,0)
miniButton.Text = "+"
miniButton.TextColor3 = Color3.fromRGB(255,255,255)
miniButton.TextSize = 27
miniButton.Font = Enum.Font.GothamBold
miniButton.BorderSizePixel = 0
miniButton.Visible = false
miniButton.Parent = gui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0,15)
miniCorner.Parent = miniButton

close.MouseButton1Click:Connect(function()
	miniButton.Position = frame.Position
	frame.Visible = false
	miniButton.Visible = true
end)

miniButton.MouseButton1Click:Connect(function()
	frame.Position = miniButton.Position
	miniButton.Visible = false
	frame.Visible = true
end)
