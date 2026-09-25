-- LocalScript
-- ใส่ใน StarterPlayer > StarterPlayerScripts
-- สำหรับเกม Roblox ที่คุณสร้าง/ควบคุมเอง

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- SETTINGS
-- =========================

local speed = 16
local infiniteJump = false
local noclip = false

local flying = false
local flySpeed = 50

local fovLock = false
local fovSize = 120
local lockedPlayer = nil
local lockConnection = nil

-- =========================
-- GUI
-- =========================

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControlUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 320)
frame.Position = UDim2.new(0.5, -170, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

-- =========================
-- HEADER
-- =========================

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -55, 0, 42)
header.Position = UDim2.fromOffset(45, 0)
header.BackgroundTransparency = 1
header.Text = "Player Control"
header.TextColor3 = Color3.new(1, 1, 1)
header.TextSize = 19
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.fromOffset(8, 5)
close.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 23
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

-- =========================
-- HELPERS
-- =========================

local function getHumanoid()

	local character = player.Character

	return character
		and character:FindFirstChildOfClass("Humanoid")

end


local function createRow(text, y)

	local label = Instance.new("TextLabel")

	label.Size =
		UDim2.fromOffset(170, 38)

	label.Position =
		UDim2.fromOffset(15, y)

	label.BackgroundTransparency = 1

	label.Text = text

	label.TextColor3 =
		Color3.fromRGB(235, 235, 235)

	label.TextSize = 16

	label.Font = Enum.Font.Gotham

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Parent = frame

	return label

end


local function createBox(
	x,
	y,
	width,
	value,
	callback
)

	local box = Instance.new("TextBox")

	box.Size =
		UDim2.fromOffset(width, 34)

	box.Position =
		UDim2.new(1, x, 0, y)

	box.BackgroundColor3 =
		Color3.fromRGB(50, 50, 60)

	box.Text = tostring(value)

	box.TextColor3 =
		Color3.new(1, 1, 1)

	box.TextSize = 16

	box.Font =
		Enum.Font.GothamBold

	box.BorderSizePixel = 0

	box.ClearTextOnFocus = false

	box.Parent = frame

	local corner = Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0, 9)

	corner.Parent = box

	box.FocusLost:Connect(function()

		callback(box)

	end)

	return box

end


local function createToggle(
	x,
	y,
	width,
	offText,
	onText,
	callback
)

	local button = Instance.new("TextButton")

	button.Size =
		UDim2.fromOffset(width, 34)

	button.Position =
		UDim2.new(1, x, 0, y)

	button.BackgroundColor3 =
		Color3.fromRGB(55, 55, 65)

	button.Text = offText

	button.TextColor3 =
		Color3.new(1, 1, 1)

	button.TextSize = 14

	button.Font =
		Enum.Font.GothamBold

	button.BorderSizePixel = 0

	button.Parent = frame

	local corner = Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0, 9)

	corner.Parent = button

	local enabled = false

	button.MouseButton1Click:Connect(function()

		enabled = not enabled

		if enabled then

			button.Text = onText

			button.BackgroundColor3 =
				Color3.fromRGB(255, 140, 0)

		else

			button.Text = offText

			button.BackgroundColor3 =
				Color3.fromRGB(55, 55, 65)

		end

		callback(enabled)

	end)

	return button

end

-- =========================
-- SPEED
-- =========================

createRow("ความเร็ว", 50)

createBox(
	-105,
	52,
	90,
	speed,
	function(box)

		local value =
			tonumber(box.Text)

		if value then

			speed =
				math.clamp(
					math.floor(value),
					1,
					100
				)

			box.Text =
				tostring(speed)

			local humanoid =
				getHumanoid()

			if humanoid then
				humanoid.WalkSpeed =
					speed
			end

		else

			box.Text =
				tostring(speed)

		end

	end
)

-- =========================
-- FLY
-- =========================

createRow("บิน", 92)

createBox(
	-195,
	94,
	80,
	flySpeed,
	function(box)

		local value =
			tonumber(box.Text)

		if value then

			flySpeed =
				math.clamp(
					math.floor(value),
					1,
					300
				)

			box.Text =
				tostring(flySpeed)

		else

			box.Text =
				tostring(flySpeed)

		end

	end
)

local flyUp = false
local flyDown = false
local flyConnection = nil


local function startFly()

	local humanoid =
		getHumanoid()

	local character =
		player.Character

	local root =
		character
		and character:FindFirstChild(
			"HumanoidRootPart"
		)

	if humanoid then
		humanoid.PlatformStand = true
	end

	if root then
		root.Anchored = true
	end

	flyConnection =
		RunService.RenderStepped:Connect(
			function(dt)

				local character =
					player.Character

				local humanoid =
					character
					and character:FindFirstChildOfClass(
						"Humanoid"
					)

				local root =
					character
					and character:FindFirstChild(
						"HumanoidRootPart"
					)

				if not humanoid or not root then
					return
				end

				local camera =
					workspace.CurrentCamera

				if not camera then
					return
				end

				local movement =
					humanoid.MoveDirection

				if flyUp then
					movement +=
						Vector3.new(0, 1, 0)
				end

				if flyDown then
					movement -=
						Vector3.new(0, 1, 0)
				end

				if movement.Magnitude > 0 then

					root.CFrame =
						root.CFrame
						+ movement.Unit
						* flySpeed
						* dt

				end

			end
		)

end


local function stopFly()

	if flyConnection then

		flyConnection:Disconnect()

		flyConnection = nil

	end

	local humanoid =
		getHumanoid()

	local character =
		player.Character

	local root =
		character
		and character:FindFirstChild(
			"HumanoidRootPart"
		)

	if humanoid then
		humanoid.PlatformStand = false
	end

	if root then
		root.Anchored = false
	end

end


createToggle(
	-105,
	94,
	90,
	"ปิด",
	"เปิด",
	function(enabled)

		flying = enabled

		if enabled then
			startFly()
		else
			stopFly()
		end

	end
)


UserInputService.InputBegan:Connect(
	function(input, processed)

		if processed then
			return
		end

		if input.KeyCode ==
			Enum.KeyCode.Space then

			flyUp = true

		elseif input.KeyCode ==
			Enum.KeyCode.LeftShift then

			flyDown = true

		end

	end
)


UserInputService.InputEnded:Connect(
	function(input)

		if input.KeyCode ==
			Enum.KeyCode.Space then

			flyUp = false

		elseif input.KeyCode ==
			Enum.KeyCode.LeftShift then

			flyDown = false

		end

	end
)

-- =========================
-- INFINITE JUMP
-- =========================

createRow(
	"กระโดดไม่จำกัด",
	134
)

createToggle(
	-105,
	136,
	90,
	"ปิด",
	"เปิด",
	function(enabled)

		infiniteJump = enabled

	end
)


UserInputService.JumpRequest:Connect(
	function()

		if not infiniteJump then
			return
		end

		local humanoid =
			getHumanoid()

		if humanoid then

			humanoid:ChangeState(
				Enum.HumanoidStateType.Jumping
			)

		end

	end
)

-- =========================
-- NOCLIP
-- =========================

createRow(
	"ทะลุกำแพง",
	176
)

createToggle(
	-105,
	178,
	90,
	"ปิด",
	"เปิด",
	function(enabled)

		noclip = enabled

	end
)


RunService.Stepped:Connect(
	function()

		if not noclip then
			return
		end

		local character =
			player.Character

		if not character then
			return
		end

		for _, part in ipairs(
			character:GetDescendants()
		) do

			if part:IsA("BasePart") then
				part.CanCollide = false
			end

		end

	end
)

-- =========================
-- FOV CIRCLE
-- =========================

local fovCircle = Instance.new("Frame")

fovCircle.Name =
	"FOVCircle"

fovCircle.Size =
	UDim2.fromOffset(
		fovSize * 2,
		fovSize * 2
	)

fovCircle.AnchorPoint =
	Vector2.new(0.5, 0.5)

-- กลางจอจริง
fovCircle.Position =
	UDim2.fromScale(0.5, 0.5)

fovCircle.BackgroundTransparency = 1

fovCircle.BorderSizePixel = 0

fovCircle.Visible = false

fovCircle.ZIndex = 10

fovCircle.Parent = gui


local fovCorner =
	Instance.new("UICorner")

fovCorner.CornerRadius =
	UDim.new(1, 0)

fovCorner.Parent =
	fovCircle


local fovStroke =
	Instance.new("UIStroke")

fovStroke.Thickness = 2

fovStroke.Color =
	Color3.fromRGB(
		255,
		140,
		0
	)

fovStroke.Parent =
	fovCircle

-- =========================
-- ตรวจว่ามองเห็นหัวหรือไม่
-- =========================

local function canSeeTarget(head)

	local camera =
		workspace.CurrentCamera

	if not camera or not head then
		return false
	end

	local origin =
		camera.CFrame.Position

	local direction =
		head.Position - origin

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		player.Character
	}

	params.IgnoreWater = true

	local result =
		workspace:Raycast(
			origin,
			direction,
			params
		)

	-- ไม่มีอะไรบัง
	if not result then
		return true
	end

	-- Ray ชนตัวเป้าหมายเอง
	if result.Instance:IsDescendantOf(
		head.Parent
	) then

		return true

	end

	-- มีกำแพง/วัตถุบัง
	return false

end

-- =========================
-- หาเป้าหมายที่ใกล้กลางวงที่สุด
-- =========================

local function getBestFOVTarget()

	local camera =
		workspace.CurrentCamera

	if not camera then
		return nil
	end

	local center =
		Vector2.new(
			camera.ViewportSize.X / 2,
			camera.ViewportSize.Y / 2
		)

	local bestPlayer = nil
	local bestDistance = math.huge

	for _, otherPlayer in ipairs(
		Players:GetPlayers()
	) do

		if otherPlayer ~= player then

			local character =
				otherPlayer.Character

			local humanoid =
				character
				and character:FindFirstChildOfClass(
					"Humanoid"
				)

			local head =
				character
				and character:FindFirstChild(
					"Head"
				)

			if humanoid
				and head
				and humanoid.Health > 0 then

				local screenPos, visible =
					camera:WorldToViewportPoint(
						head.Position
					)

				if visible
					and screenPos.Z > 0 then

					local distance =
						(
							Vector2.new(
								screenPos.X,
								screenPos.Y
							) - center
						).Magnitude

					-- ต้องอยู่ในวง
					if distance <= fovSize then

						-- ต้องไม่มีอะไรมาบัง
						if canSeeTarget(head) then

							-- ใกล้กลางวงที่สุด
							if distance <
								bestDistance then

								bestDistance =
									distance

								bestPlayer =
									otherPlayer

							end

						end

					end

				end

			end

		end

	end

	return bestPlayer

end

-- =========================
-- ตรวจเป้าหมายเดิม
-- =========================

local function isTargetValid(target)

	if not target then
		return false
	end

	local character =
		target.Character

	if not character then
		return false
	end

	local humanoid =
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	local head =
		character:FindFirstChild("Head")

	if not humanoid
		or not head
		or humanoid.Health <= 0 then

		return false

	end

	local camera =
		workspace.CurrentCamera

	if not camera then
		return false
	end

	local screenPos, visible =
		camera:WorldToViewportPoint(
			head.Position
		)

	if not visible
		or screenPos.Z <= 0 then

		return false

	end

	local center =
		Vector2.new(
			camera.ViewportSize.X / 2,
			camera.ViewportSize.Y / 2
		)

	local distance =
		(
			Vector2.new(
				screenPos.X,
				screenPos.Y
			) - center
		).Magnitude

	-- ออกจากวง
	if distance > fovSize then
		return false
	end

	-- มีกำแพงบัง
	if not canSeeTarget(head) then
		return false
	end

	return true

end

-- =========================
-- STOP LOCK
-- =========================

local function stopTargetLock()

	if lockConnection then

		lockConnection:Disconnect()

		lockConnection = nil

	end

	lockedPlayer = nil

end

-- =========================
-- START LOCK
-- =========================

local function startTargetLock()

	stopTargetLock()

	-- เลือกคนที่ใกล้กลางวงที่สุด
	lockedPlayer =
		getBestFOVTarget()

	if not lockedPlayer then
		return
	end

	lockConnection =
		RunService.RenderStepped:Connect(
			function()

				if not fovLock then
					return
				end

				local camera =
					workspace.CurrentCamera

				if not camera then
					return
				end

				-- ถ้าเป้าหมายเดิมยังใช้ได้
				-- จะไม่เปลี่ยนเป้าหมาย
				if not isTargetValid(
					lockedPlayer
				) then

					-- หาใหม่เฉพาะเมื่อเป้าหมายเดิมใช้ไม่ได้
					lockedPlayer =
						getBestFOVTarget()

				end

				if not lockedPlayer then
					return
				end

				local character =
					lockedPlayer.Character

				local head =
					character
					and character:FindFirstChild(
						"Head"
					)

				if not head then
					return
				end

				-- ล็อคตรงหัว
				camera.CFrame =
					CFrame.lookAt(
						camera.CFrame.Position,
						head.Position
					)

			end
		)

end

-- =========================
-- LOCK UI
-- =========================

createRow(
	"ล็อคหัว",
	218
)


createBox(
	-195,
	220,
	80,
	fovSize,
	function(box)

		local value =
			tonumber(box.Text)

		if value then

			fovSize =
				math.clamp(
					math.floor(value),
					30,
					400
				)

			box.Text =
				tostring(fovSize)

			fovCircle.Size =
				UDim2.fromOffset(
					fovSize * 2,
					fovSize * 2
				)

		else

			box.Text =
				tostring(fovSize)

		end

	end
)


createToggle(
	-105,
	220,
	90,
	"ปิด",
	"เปิด",
	function(enabled)

		fovLock = enabled

		fovCircle.Visible =
			enabled

		if enabled then

			startTargetLock()

		else

			stopTargetLock()

		end

	end
)

-- =========================
-- RESPAWN
-- =========================

player.CharacterAdded:Connect(
	function(character)

		local humanoid =
			character:WaitForChild(
				"Humanoid"
			)

		humanoid.WalkSpeed =
			speed

		task.wait(0.3)

		if noclip then

			for _, part in ipairs(
				character:GetDescendants()
			) do

				if part:IsA("BasePart") then
					part.CanCollide = false
				end

			end

		end

		if fovLock then

			task.wait(0.3)

			startTargetLock()

		end

	end
)

-- =========================
-- DRAG UI
-- =========================

local dragging = false
local dragStart
local startPos


header.InputBegan:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or input.UserInputType ==
			Enum.UserInputType.Touch then

			dragging = true

			dragStart =
				input.Position

			startPos =
				frame.Position

		end

	end
)


header.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or input.UserInputType ==
			Enum.UserInputType.Touch then

			dragging = false

		end

	end
)


UserInputService.InputChanged:Connect(
	function(input)

		if not dragging then
			return
		end

		if input.UserInputType ==
			Enum.UserInputType.MouseMovement
			or input.UserInputType ==
			Enum.UserInputType.Touch then

			local delta =
				input.Position -
				dragStart

			frame.Position =
				UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset +
						delta.X,

					startPos.Y.Scale,
					startPos.Y.Offset +
						delta.Y
				)

		end

	end
)

-- =========================
-- MINIMIZE
-- =========================

local miniButton =
	Instance.new("TextButton")

miniButton.Size =
	UDim2.fromOffset(
		55,
		55
	)

miniButton.Position =
	frame.Position

miniButton.BackgroundColor3 =
	Color3.fromRGB(
		255,
		140,
		0
	)

miniButton.Text = "+"

miniButton.TextColor3 =
	Color3.new(1, 1, 1)

miniButton.TextSize = 27

miniButton.Font =
	Enum.Font.GothamBold

miniButton.BorderSizePixel = 0

miniButton.Visible = false

miniButton.Parent = gui


local miniCorner =
	Instance.new("UICorner")

miniCorner.CornerRadius =
	UDim.new(0, 15)

miniCorner.Parent =
	miniButton


close.MouseButton1Click:Connect(
	function()

		miniButton.Position =
			frame.Position

		frame.Visible = false

		miniButton.Visible = true

	end
)


miniButton.MouseButton1Click:Connect(
	function()

		frame.Position =
			miniButton.Position

		miniButton.Visible = false

		frame.Visible = true

	end
)
