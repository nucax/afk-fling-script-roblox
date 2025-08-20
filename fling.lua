local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Wait for PlayerGui
local playerGui = player:WaitForChild("PlayerGui")

-- GUI setup
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "FlingGui"
gui.Parent = playerGui

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0, 200, 0, 50)
timerLabel.Position = UDim2.new(0, 20, 0, 20)
timerLabel.TextScaled = true
timerLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
timerLabel.TextColor3 = Color3.fromRGB(255,255,255)
timerLabel.Text = "Time: 0"
timerLabel.Parent = gui

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(0, 200, 0, 50)
counterLabel.Position = UDim2.new(0, 20, 0, 80)
counterLabel.TextScaled = true
counterLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
counterLabel.TextColor3 = Color3.fromRGB(255,255,255)
counterLabel.Text = "Players Flung: 0"
counterLabel.Parent = gui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 140)
toggleButton.TextScaled = true
toggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Text = "Start Fling"
toggleButton.Parent = gui

-- Minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(0, 230, 0, 20)
minimizeButton.Text = "-"
minimizeButton.TextScaled = true
minimizeButton.BackgroundColor3 = Color3.fromRGB(100,100,100)
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.Parent = gui

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(0, 270, 0, 20)
closeButton.Text = "X"
closeButton.TextScaled = true
closeButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Parent = gui

-- GitHub button (rainbow)
local githubButton = Instance.new("TextButton")
githubButton.Size = UDim2.new(0, 250, 0, 40)
githubButton.Position = UDim2.new(0, 20, 0, 200)
githubButton.TextScaled = true
githubButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
githubButton.TextColor3 = Color3.fromRGB(255,255,255)
githubButton.Text = "https://github.com/nucax"
githubButton.Parent = gui

-- Rainbow effect for GitHub button
spawn(function()
    local hue = 0
    while githubButton.Parent do
        hue = (hue + 0.01) % 1
        githubButton.TextColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.05)
    end
end)

-- Copy GitHub link on click
githubButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://github.com/nucax")
    end
end)

-- Close functionality
closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Minimize functionality
local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        timerLabel.Visible = false
        counterLabel.Visible = false
        toggleButton.Visible = false
        githubButton.Visible = false
        minimizeButton.Text = "+"
    else
        timerLabel.Visible = true
        counterLabel.Visible = true
        toggleButton.Visible = true
        githubButton.Visible = true
        minimizeButton.Text = "-"
    end
end)

-- Variables
local startTime = 0
local FlingActive = false
local flungCount = 0

-- Timer update
RunService.RenderStepped:Connect(function()
	if startTime > 0 then
		timerLabel.Text = string.format("Time: %.1f", tick() - startTime)
	end
end)

-- Toggle button
toggleButton.MouseButton1Click:Connect(function()
	FlingActive = not FlingActive
	if FlingActive then
		startTime = tick()
		flungCount = 0
		counterLabel.Text = "Players Flung: 0"
		toggleButton.Text = "Stop Fling"
	else
		toggleButton.Text = "Start Fling"
	end
end)

-- SkidFling function
local function SkidFling(TargetPlayer)
	local Character = player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart
	local TCharacter = TargetPlayer.Character
	if not TCharacter then return false end
	
	local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = THumanoid and THumanoid.RootPart
	local THead = TCharacter:FindFirstChild("Head")
	local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
	local Handle = Accessory and Accessory:FindFirstChild("Handle")

	if Character and Humanoid and RootPart then
		if RootPart.Velocity.Magnitude < 50 then
			getgenv().OldPos = RootPart.CFrame
		end

		if THumanoid and THumanoid.Sit then return false end

		if THead then
			workspace.CurrentCamera.CameraSubject = THead
		elseif Handle then
			workspace.CurrentCamera.CameraSubject = Handle
		elseif THumanoid and TRootPart then
			workspace.CurrentCamera.CameraSubject = THumanoid
		end

		if not TCharacter:FindFirstChildWhichIsA("BasePart") then return false end

		local FPos = function(BasePart, Pos, Ang)
			RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
			Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
			RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
			RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
		end

		local SFBasePart = function(BasePart)
			local TimeToWait = 2
			local Time = tick()
			local Angle = 0
			repeat
				if RootPart and THumanoid then
					if BasePart.Velocity.Magnitude < 50 then
						Angle = Angle + 100
						FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0))
						task.wait()
						FPos(BasePart, CFrame.new(0,-1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0))
						task.wait()
					end
				end
			until Time + TimeToWait < tick() or not FlingActive
		end

		local BV = Instance.new("BodyVelocity")
		BV.Parent = RootPart
		BV.Velocity = Vector3.new(0,0,0)
		BV.MaxForce = Vector3.new(9e9,9e9,9e9)

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)

		if TRootPart then
			SFBasePart(TRootPart)
		elseif THead then
			SFBasePart(THead)
		elseif Handle then
			SFBasePart(Handle)
		end

		BV:Destroy()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		workspace.CurrentCamera.CameraSubject = Humanoid

		return true
	end
	return false
end

-- Main fling loop
spawn(function()
	while true do
		if FlingActive then
			local targets = {}
			for _, otherPlayer in pairs(Players:GetPlayers()) do
				if otherPlayer ~= player then
					table.insert(targets, otherPlayer)
				end
			end

			if #targets > 0 then
				local randomPlayer = targets[math.random(1,#targets)]
				local success = pcall(SkidFling, randomPlayer)
				if success then
					flungCount = flungCount + 1
					counterLabel.Text = "Players Flung: " .. flungCount
				end
				task.wait(0.7)
			else
				task.wait(1)
			end
		else
			task.wait(0.5)
		end
	end
end)
