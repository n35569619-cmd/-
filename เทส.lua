-- LocalScript
-- ใส่ใน StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local speed = 16
local infiniteJump = false
local noclip = false
local flying = false
local flySpeed = 50

-- =========================
-- GUI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControlUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 232)
frame.Position = UDim2.new(0.5, -170, 0.5, -116)
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
local function createRow(text, y, width)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, width or 160, 0, 38)
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

local function getHumanoid()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

-- =========================
-- ปุ่ม Toggle (ใช้ x/width เพื่อจัดวางในแถวเดียวกับตัวควบคุมอื่นได้)
-- =========================
local function createToggle(x, y, width, offText, onText, onChanged)
	local button = Instance.new("TextButton")

	button.Size = UDim2.new(0, width, 0, 34)
	button.Position = UDim2.new(1, x, 0, y)
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

		if onChanged then
			onChanged(enabled)
		end
	end)

	return button
end

local function createSpeedBox(x, y, width, defaultValue, onApply)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, width, 0, 34)
	box.Position = UDim2.new(1, x, 0, y)
	box.BackgroundColor3 = Color3.fromRGB(50,50,60)
	box.Text = tostring(defaultValue)
	box.TextColor3 = Color3.fromRGB(255,255,255)
	box.TextSize = 16
	box.Font = Enum.Font.GothamBold
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,9)
	corner.Parent = box

	box.FocusLost:Connect(function()
		onApply(box)
	end)

	return box
end

-- =========================
-- ความเร็ว
-- =========================
createRow("ความเร็ว", 50)

local speedBox = createSpeedBox(-105, 52, 90, speed, function(box)
	local value = tonumber(box.Text)

	if value then
		speed = math.clamp(math.floor(value), 1, 100)
		box.Text = tostring(speed)

		local humanoid = getHumanoid()
		if humanoid then
			humanoid.WalkSpeed = speed
		end
	else
		box.Text = tostring(speed)
	end
end)

-- =========================
-- บิน (ปรับความเร็ว + toggle อยู่แถวเดียวกัน)
-- =========================
createRow("บิน", 92, 100)

local flyKeys = { W = false, A = false, S = false, D = false, Up = false, Down = false }
local flyConnection = nil

local function setPlatformStand(state)
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.PlatformStand = state
	end
end

local function setRootAnchored(state)
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.Anchored = state
	end
end

local function startFly()
	setPlatformStand(true)
	-- ล็อกร่างกายไม่ให้ฟิสิกส์/แรงโน้มถ่วงดึงตก แล้วขยับเองด้วยโค้ดแทน
	setRootAnchored(true)

	flyConnection = RunService.RenderStepped:Connect(function(dt)
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local camera = workspace.CurrentCamera
		if not camera then return end

		local moveVector = Vector3.new()

		if flyKeys.W then moveVector += camera.CFrame.LookVector end
		if flyKeys.S then moveVector -= camera.CFrame.LookVector end
		if flyKeys.A then moveVector -= camera.CFrame.RightVector end
		if flyKeys.D then moveVector += camera.CFrame.RightVector end
		if flyKeys.Up then moveVector += Vector3.new(0, 1, 0) end
		if flyKeys.Down then moveVector -= Vector3.new(0, 1, 0) end

		if moveVector.Magnitude > 0 then
			hrp.CFrame = hrp.CFrame + moveVector.Unit * flySpeed * dt
		end
	end)
end

local function stopFly()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	setRootAnchored(false)
	setPlatformStand(false)
end

createSpeedBox(-195, 94, 80, flySpeed, function(box)
	local value = tonumber(box.Text)

	if value then
		flySpeed = math.clamp(math.floor(value), 1, 300)
		box.Text = tostring(flySpeed)
	else
		box.Text = tostring(flySpeed)
	end
end)

createToggle(-105, 94, 90, "ปิด", "เปิด", function(enabled)
	flying = enabled

	if flying then
		startFly()
	else
		stopFly()
	end
end)

-- ปุ่มบังคับบิน: W/A/S/D เดิน, Space ขึ้น, Shift ลง (ใช้ทิศตามกล้อง)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true
	elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = true
	elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = true
	elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = true
	elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Up = true
	elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then flyKeys.Down = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false
	elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = false
	elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = false
	elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = false
	elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Up = false
	elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then flyKeys.Down = false
	end
end)

-- =========================
-- กระโดดไม่จำกัด
-- =========================
createRow("กระโดดไม่จำกัด", 134)

createToggle(-105, 136, 90, "ปิด", "เปิด", function(enabled)
	infiniteJump = enabled
end)

-- =========================
-- ทะลุกำแพง (แก้บั๊ก: คืนค่า CanCollide ตอนปิด, ทำงานเบาลง)
-- =========================
createRow("ทะลุกำแพง", 176)

local function setCharacterCollisions(character, canCollide)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = canCollide
		end
	end
end

createToggle(-105, 178, 90, "ปิด", "เปิด", function(enabled)
	noclip = enabled

	local character = player.Character
	if character then
		setCharacterCollisions(character, not enabled)
	end
end)

-- =========================
-- Infinite Jump
-- =========================
UserInputService.JumpRequest:Connect(function()
	if infiniteJump then
		local humanoid = getHumanoid()

		if humanoid then
			humanoid:ChangeState(
				Enum.HumanoidStateType.Jumping
			)
		end
	end
end)

-- =========================
-- Noclip
-- บังคับ CanCollide=false เฉพาะตอนเปิดอยู่ (กันของใหม่ที่เพิ่มเข้ามา
-- เช่น เครื่องมือ/accessory) แทนที่จะวนลูปทุกเฟรมโดยไม่จำเป็น
-- =========================
RunService.Stepped:Connect(function()
	if noclip then
		local character = player.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- =========================
-- Respawn: sync ค่าความเร็ว + noclip + บิน ให้ตัวละครใหม่
-- =========================
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = speed

	if noclip then
		setCharacterCollisions(character, false)
	end

	if flying then
		humanoid.PlatformStand = true
		local hrp = character:WaitForChild("HumanoidRootPart")
		hrp.Anchored = true
	end
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
