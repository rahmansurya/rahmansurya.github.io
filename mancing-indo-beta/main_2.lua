	-- // MANCING INDO - Mobile V7.0 (Stable Clean Edition)
	local ScriptName = "MancingIndo_Mobile_V7.0"

	if game.CoreGui:FindFirstChild(ScriptName) then
		game.CoreGui[ScriptName]:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = ScriptName
	ScreenGui.Parent = game.CoreGui
	ScreenGui.ResetOnSpawn = false

	local Players = game:GetService("Players")
	local RS = game:GetService("ReplicatedStorage")
	local LogService = game:GetService("LogService")
	local UIS = game:GetService("UserInputService")

	local player = Players.LocalPlayer
	local remotes = RS:WaitForChild("Remotes", 3)
	local CMGR = remotes and remotes:FindFirstChild("CMGR")
	local MGR = remotes and remotes:FindFirstChild("MGR")
	local CastRod = remotes and remotes:FindFirstChild("CastRod")


	-- ================== UTILITIES ==================
	local waterWalkEnabled = false
	local waterFloor = nil
	local defaultSpeed = 16
	local headlightEnabled = false
	local currentHeadlight = nil
	local fullbrightEnabled = false
	local Lighting = game:GetService("Lighting")
	local originalLighting = {
		Ambient = Lighting.Ambient,
		Brightness = Lighting.Brightness,
		OutdoorAmbient = Lighting.OutdoorAmbient
	}
	local mouse = player:GetMouse()
	local clickTPEnabled = false
	local clickTPConnection = nil

	-- ================================================

	local currentMode = "OFF"
	local isCasting = false
	local running = true
	local connections = {}

	-- ================== MANCING LOGIC ==================
	local function stopFishingAnimation()
		currentMode = "OFF"
		isCasting = false
		
		-- Update Status Label secara aman
		pcall(function()
			if ScreenGui:FindFirstChild("MainFrame") then
				local status = ScreenGui.MainFrame.Content.MainPage:FindFirstChild("StatusLbl")
				if status then
					status.Text = "STATUS: OFF"
					status.TextColor3 = Color3.fromRGB(255, 80, 80)
				end
			end
		end)

		pcall(function()
			local char = player.Character
			local hum = char and char:FindFirstChild("Humanoid")
			
			-- 1. Beritahu Server untuk Stop
			if CastRod then CastRod:FireServer("Stop") end
			if CMGR then CMGR:FireServer("Stop") end
			
			-- 2. Lepas Pancingan dari Tangan
			if hum then
				hum:UnequipTools()
				-- Hentikan animasi yang sedang berjalan
				local animator = hum:FindFirstChildOfClass("Animator")
				if animator then
					for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
						if track.Priority ~= Enum.AnimationPriority.Core then
							track:Stop(0.1)
						end
					end
				end
			end
		end)
	end

	local function ensureRodEquipped()
		local char = player.Character
		if not char then return false end
		
		-- Cek apakah sudah pegang rod
		local currentTool = char:FindFirstChildOfClass("Tool")
		if currentTool and currentTool:GetAttribute("FishingRod") then
			return true
		end
		
		-- Jika tidak pegang, cari di backpack
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			for _, tool in ipairs(backpack:GetChildren()) do
				if tool:IsA("Tool") and tool:GetAttribute("FishingRod") then
					-- Paksa Equip
					local hum = char:FindFirstChild("Humanoid")
					if hum then
						hum:EquipTool(tool)
						task.wait(0.3) -- Beri jeda animasi equip
						return true
					end
				end
			end
		end
		return false
	end

	local function getBackpackCount()
		local count = 0
		pcall(function()
			local bp = player.PlayerGui:FindFirstChild("Backpack")
			if bp and bp:FindFirstChild("Canvas") then
				local scroll = bp.Canvas.Container.Body:FindFirstChild("ScrollingFrame")
				if scroll then
					for _, v in ipairs(scroll:GetChildren()) do
						if v:IsA("GuiObject") and v:GetAttribute("UID") then count += 1 end
					end
				end
			end
		end)
		return count
	end

	local function performCast()
		if currentMode == "OFF" or isCasting or not CastRod then return end
		
		-- Tambahan: Re-check rod di dalam loop biar gak macet
		if not player.Character:FindFirstChildOfClass("Tool") then
			ensureRodEquipped()
		end

		isCasting = true
		pcall(function()
			CastRod:FireServer()
			-- Mode Blatant biasanya butuh charge sangat sebentar agar server tidak curiga
			local chargeWait = (currentMode == "BLATANT") and 0.05 or 0.2
			task.wait(chargeWait)
			
			-- Beritahu server kita sudah cast
			if CMGR then CMGR:FireServer("Result", 1) end
		end)
		task.wait(0.8) -- Jeda antar lemparan
		isCasting = false
	end


	local function toggleWaterWalk()
		waterWalkEnabled = not waterWalkEnabled
		
		if waterWalkEnabled then
			-- 1. Tentukan Ketinggian Air (Ganti angka ini kalau masih kurang pas)
			local LockedHeight = -0.8 -- Biasanya air di Mancing Indo ada di sekitar sini
			
			waterFloor = Instance.new("Part")
			waterFloor.Name = "WaterWalkFloor"
			waterFloor.Size = Vector3.new(15, 1, 15) -- Dibuat lebih lebar biar aman
			waterFloor.Transparency = 1
			waterFloor.Anchored = true
			waterFloor.CanCollide = true
			waterFloor.Parent = workspace
			
			task.spawn(function()
				while waterWalkEnabled and task.wait() do
					pcall(function()
						local char = player.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")
						if hrp and waterFloor then
							-- KUNCI POSISI Y: Lantai tidak akan ikut naik kalau kamu lompat/terbang
							waterFloor.Position = Vector3.new(hrp.Position.X, LockedHeight, hrp.Position.Z)
						end
					end)
				end
				if waterFloor then waterFloor:Destroy() end
			end)
		else
			if waterFloor then
				waterFloor:Destroy()
				waterFloor = nil
			end
		end
	end

	-- ================== UI MAIN SYSTEM ==================
	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 460, 0, 320)
	MainFrame.Position = UDim2.new(0.5, -230, 0.5, -160)
	MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	MainFrame.Active = true
	MainFrame.Draggable = true
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

	local Stroke = Instance.new("UIStroke", MainFrame)
	Stroke.Color = Color3.fromRGB(0, 170, 255)
	Stroke.Thickness = 1.5

	local TitleBar = Instance.new("Frame", MainFrame)
	TitleBar.Size = UDim2.new(1, 0, 0, 42)
	TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
	Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

	local Title = Instance.new("TextLabel", TitleBar)
	Title.Size = UDim2.new(1, -110, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.Text = "PRIV8 Tersesat - Mancing Indo"
	Title.TextColor3 = Color3.fromRGB(0, 195, 255)
	Title.Font = Enum.Font.GothamBlack
	Title.TextSize = 15
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = Enum.TextXAlignment.Left


	-- Tombol Minimize (-)
	local MiniBtn = Instance.new("TextButton", TitleBar)
	MiniBtn.Size = UDim2.new(0, 30, 0, 30)
	MiniBtn.Position = UDim2.new(1, -70, 0, 6) -- Di sebelah kiri tombol close
	MiniBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	MiniBtn.Text = "—"
	MiniBtn.TextColor3 = Color3.new(1,1,1)
	MiniBtn.Font = Enum.Font.GothamBold
	MiniBtn.TextSize = 14
	Instance.new("UICorner", MiniBtn)

	-- Fungsi Minimize
	MiniBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = false
		FloatingIcon.Visible = true
	end)

	local CloseBtn = Instance.new("TextButton", TitleBar)
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Position = UDim2.new(1, -35, 0, 6)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
	CloseBtn.Text = "x"
	CloseBtn.TextColor3 = Color3.new(1,1,1)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 18
	Instance.new("UICorner", CloseBtn)

	-- Sidebar
	local Sidebar = Instance.new("ScrollingFrame", MainFrame)
	Sidebar.Size = UDim2.new(0, 130, 1, -55)
	Sidebar.Position = UDim2.new(0, 8, 0, 48)
	Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	Sidebar.ScrollBarThickness = 0
	Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

	local SidebarLayout = Instance.new("UIListLayout", Sidebar)
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local Content = Instance.new("Frame", MainFrame)
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -155, 1, -55)
	Content.Position = UDim2.new(0, 145, 0, 50)
	Content.BackgroundTransparency = 1

	local function CreateTab(name, order)
		local btn = Instance.new("TextButton", Sidebar)
		btn.Name = name .. "Tab"
		btn.Size = UDim2.new(0.9, 0, 0, 38)
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
		btn.Text = name
		btn.TextColor3 = Color3.fromRGB(200, 200, 220)
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 13
		btn.LayoutOrder = order
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		local page = Instance.new("Frame", Content)
		page.Name = name .. "Page"
		page.Size = UDim2.new(1,1,1,1)
		page.BackgroundTransparency = 1
		page.Visible = false

		btn.MouseButton1Click:Connect(function()
			for _, p in pairs(Content:GetChildren()) do if p:IsA("Frame") then p.Visible = false end end
			page.Visible = true
			for _, b in pairs(Sidebar:GetChildren()) do
				if b:IsA("TextButton") then
					b.BackgroundColor3 = Color3.fromRGB(30,30,48)
					b.TextColor3 = Color3.fromRGB(200,200,220)
				end
			end
			btn.BackgroundColor3 = Color3.fromRGB(0,140,255)
			btn.TextColor3 = Color3.new(1,1,1)
		end)
		return page
	end

	local MainPage      = CreateTab("Main", 1)
	local TeleportPage  = CreateTab("Teleport", 2)
	local UtilitiesPage = CreateTab("Utilities", 3)

	MainPage.Visible = true
	Sidebar:FindFirstChild("MainTab").BackgroundColor3 = Color3.fromRGB(0,140,255)

	-- ================== ISI TAB MAIN ==================
	local InstantBtn = Instance.new("TextButton", MainPage)
	InstantBtn.Size = UDim2.new(0.92, 0, 0, 45)
	InstantBtn.Position = UDim2.new(0.04, 0, 0.05, 0)
	InstantBtn.BackgroundColor3 = Color3.fromRGB(35, 55, 80)
	InstantBtn.Text = "INSTANT FISHING"
	InstantBtn.TextColor3 = Color3.new(1,1,1)
	InstantBtn.Font = Enum.Font.GothamBold
	InstantBtn.TextSize = 14
	Instance.new("UICorner", InstantBtn).CornerRadius = UDim.new(0, 10)

	local BlatantBtn = Instance.new("TextButton", MainPage)
	BlatantBtn.Size = UDim2.new(0.92, 0, 0, 45)
	BlatantBtn.Position = UDim2.new(0.04, 0, 0.22, 0)
	BlatantBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 80)
	BlatantBtn.Text = "BLATANT FISHING"
	BlatantBtn.TextColor3 = Color3.new(1,1,1)
	BlatantBtn.Font = Enum.Font.GothamBold
	BlatantBtn.TextSize = 14
	Instance.new("UICorner", BlatantBtn).CornerRadius = UDim.new(0, 10)

	local StopBtn = Instance.new("TextButton", MainPage)
	StopBtn.Size = UDim2.new(0.92, 0, 0, 45)
	StopBtn.Position = UDim2.new(0.04, 0, 0.39, 0)
	StopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	StopBtn.Text = "STOP MANCING"
	StopBtn.TextColor3 = Color3.new(1,1,1)
	StopBtn.Font = Enum.Font.GothamBold
	StopBtn.TextSize = 14
	Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 10)

	local StatusLbl = Instance.new("TextLabel", MainPage)
	StatusLbl.Name = "StatusLbl"
	StatusLbl.Size = UDim2.new(0.92, 0, 0, 30)
	StatusLbl.Position = UDim2.new(0.04, 0, 0.58, 0)
	StatusLbl.BackgroundTransparency = 1
	StatusLbl.Text = "STATUS: OFF"
	StatusLbl.TextColor3 = Color3.fromRGB(100, 255, 140)
	StatusLbl.Font = Enum.Font.GothamBold
	StatusLbl.TextSize = 14

	local FishCountLbl = Instance.new("TextLabel", MainPage)
	FishCountLbl.Size = UDim2.new(0.92, 0, 0, 30)
	FishCountLbl.Position = UDim2.new(0.04, 0, 0.70, 0)
	FishCountLbl.BackgroundTransparency = 1
	FishCountLbl.Text = "Fish in Bag: 0"
	FishCountLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
	FishCountLbl.Font = Enum.Font.GothamSemibold
	FishCountLbl.TextSize = 14

	-- ================== LOGIKA TOMBOL MAIN (FIXED STOP) ==================

	InstantBtn.MouseButton1Click:Connect(function()
		if currentMode == "INSTANT" then
			-- Jika diklik saat sedang aktif, jalankan fungsi STOP total
			stopFishingAnimation()
		else
			-- Jika sedang mati, aktifkan mode Instant
			currentMode = "INSTANT"
			StatusLbl.Text = "STATUS: INSTANT"
			StatusLbl.TextColor3 = Color3.fromRGB(100, 255, 140)
			
			-- Pastikan pegang rod dulu, lalu lempar
			if ensureRodEquipped() then
				performCast()
			else
				StatusLbl.Text = "ERROR: NO ROD"
				currentMode = "OFF"
			end
		end
	end)

	BlatantBtn.MouseButton1Click:Connect(function()
		if currentMode == "BLATANT" then
			-- Jika diklik saat sedang aktif, jalankan fungsi STOP total
			stopFishingAnimation()
		else
			-- Jika sedang mati, aktifkan mode Blatant
			currentMode = "BLATANT"
			StatusLbl.Text = "STATUS: BLATANT"
			StatusLbl.TextColor3 = Color3.fromRGB(100, 255, 140)
			
			-- Pastikan pegang rod dulu, lalu lempar
			if ensureRodEquipped() then
				performCast()
			else
				StatusLbl.Text = "ERROR: NO ROD"
				currentMode = "OFF"
			end
		end
	end)

	StopBtn.MouseButton1Click:Connect(function()
		stopFishingAnimation()
	end)

	-- ================== ISI TAB TELEPORT ==================
	local TP_Y = 0
	local TeleportList = {
		{Name = "Pulau Raja Kepiting", Pos = Vector3.new(2341.05, -0.27, -1034.77)}, 
		{Name = "Pulau Seribu",        Pos = Vector3.new(500, 50, 1000)},
		{Name = "Pulau Boomerang",     Pos = Vector3.new(-800, 50, -600)},
	}
	for _, island in ipairs(TeleportList) do
		local Btn = Instance.new("TextButton", TeleportPage)
		Btn.Size = UDim2.new(0.92, 0, 0, 35)
		Btn.Position = UDim2.new(0.04, 0, 0, TP_Y)
		Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		Btn.Text = island.Name
		Btn.TextColor3 = Color3.new(1,1,1)
		Btn.Font = Enum.Font.GothamSemibold
		Btn.TextSize = 12
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		Btn.MouseButton1Click:Connect(function()
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = CFrame.new(island.Pos + Vector3.new(0, 5, 0))
			end
		end)
		TP_Y = TP_Y + 40
	end


	-- ================== ISI TAB UTILITIES (V7.5) ==================

	-- 1. TOMBOL WATER WALK
	local WaterWalkBtn = Instance.new("TextButton", UtilitiesPage)
	WaterWalkBtn.Size = UDim2.new(0.92, 0, 0, 35)
	WaterWalkBtn.Position = UDim2.new(0.04, 0, 0.05, 0)
	WaterWalkBtn.BackgroundColor3 = Color3.fromRGB(35, 80, 55)
	WaterWalkBtn.Text = "WALK ON WATER: OFF"
	WaterWalkBtn.TextColor3 = Color3.new(1,1,1)
	WaterWalkBtn.Font = Enum.Font.GothamBold
	WaterWalkBtn.TextSize = 12
	Instance.new("UICorner", WaterWalkBtn).CornerRadius = UDim.new(0, 8)

	-- 2. SPEED MENU
	local SpeedFrame = Instance.new("Frame", UtilitiesPage)
	SpeedFrame.Size = UDim2.new(0.92, 0, 0, 40)
	SpeedFrame.Position = UDim2.new(0.04, 0, 0.20, 0)
	SpeedFrame.BackgroundTransparency = 1

	local SpeedInput = Instance.new("TextBox", SpeedFrame)
	SpeedInput.Size = UDim2.new(0.35, 0, 1, 0)
	SpeedInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SpeedInput.Text = "16"
	SpeedInput.TextColor3 = Color3.new(0, 0, 0)
	SpeedInput.Font = Enum.Font.GothamBold
	SpeedInput.TextSize = 14
	Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 6)

	local SetSpeedBtn = Instance.new("TextButton", SpeedFrame)
	SetSpeedBtn.Size = UDim2.new(0.3, -5, 1, 0)
	SetSpeedBtn.Position = UDim2.new(0.35, 5, 0, 0)
	SetSpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	SetSpeedBtn.Text = "Set Speed"
	SetSpeedBtn.TextColor3 = Color3.new(1, 1, 1)
	SetSpeedBtn.Font = Enum.Font.GothamBold
	SetSpeedBtn.TextSize = 11
	Instance.new("UICorner", SetSpeedBtn).CornerRadius = UDim.new(0, 6)

	local DefaultSpeedBtn = Instance.new("TextButton", SpeedFrame)
	DefaultSpeedBtn.Size = UDim2.new(0.35, -5, 1, 0)
	DefaultSpeedBtn.Position = UDim2.new(0.65, 5, 0, 0)
	DefaultSpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	DefaultSpeedBtn.Text = "Default (16)"
	DefaultSpeedBtn.TextColor3 = Color3.new(1, 1, 1)
	DefaultSpeedBtn.Font = Enum.Font.GothamBold
	DefaultSpeedBtn.TextSize = 11
	Instance.new("UICorner", DefaultSpeedBtn).CornerRadius = UDim.new(0, 6)

	-- 3. TOMBOL ORB LIGHT
	local OrbLightBtn = Instance.new("TextButton", UtilitiesPage)
	OrbLightBtn.Size = UDim2.new(0.92, 0, 0, 35)
	OrbLightBtn.Position = UDim2.new(0.04, 0, 0.38, 0)
	OrbLightBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
	OrbLightBtn.Text = "ORB LIGHT: OFF"
	OrbLightBtn.TextColor3 = Color3.new(1,1,1)
	OrbLightBtn.Font = Enum.Font.GothamBold
	OrbLightBtn.TextSize = 12
	Instance.new("UICorner", OrbLightBtn).CornerRadius = UDim.new(0, 8)

	-- 4. TOMBOL FULLBRIGHT
	local FullbrightBtn = Instance.new("TextButton", UtilitiesPage)
	FullbrightBtn.Size = UDim2.new(0.92, 0, 0, 35)
	FullbrightBtn.Position = UDim2.new(0.04, 0, 0.54, 0)
	FullbrightBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
	FullbrightBtn.Text = "FULLBRIGHT: OFF"
	FullbrightBtn.TextColor3 = Color3.new(1,1,1)
	FullbrightBtn.Font = Enum.Font.GothamBold
	FullbrightBtn.TextSize = 12
	Instance.new("UICorner", FullbrightBtn).CornerRadius = UDim.new(0, 8)

	-- ================== LOGIC FUNCTIONS ==================

	-- [WATER WALK LOGIC]
	local function toggleWaterWalk()
		waterWalkEnabled = not waterWalkEnabled
		if waterWalkEnabled then
			local LockedHeight = -0.8
			waterFloor = Instance.new("Part", workspace)
			waterFloor.Name = "WaterWalkFloor"
			waterFloor.Size = Vector3.new(15, 1, 15)
			waterFloor.Transparency = 1
			waterFloor.Anchored = true
			waterFloor.CanCollide = true
			task.spawn(function()
				while waterWalkEnabled and task.wait() do
					pcall(function()
						local hrp = player.Character.HumanoidRootPart
						waterFloor.Position = Vector3.new(hrp.Position.X, LockedHeight, hrp.Position.Z)
					end)
				end
				if waterFloor then waterFloor:Destroy() end
			end)
			WaterWalkBtn.Text = "WALK ON WATER: ON"
			WaterWalkBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
		else
			if waterFloor then waterFloor:Destroy(); waterFloor = nil end
			WaterWalkBtn.Text = "WALK ON WATER: OFF"
			WaterWalkBtn.BackgroundColor3 = Color3.fromRGB(35, 80, 55)
		end
	end

	-- [ORB LIGHT LOGIC]
	local function toggleOrbLight()
		headlightEnabled = not headlightEnabled
		if headlightEnabled then
			local char = player.Character
			if char and char:FindFirstChild("Head") then
				currentHeadlight = Instance.new("PointLight", char.Head)
				currentHeadlight.Name = "OrbLight"
				currentHeadlight.Brightness = 5
				currentHeadlight.Color = Color3.new(1, 1, 1)
				currentHeadlight.Range = 100
				OrbLightBtn.Text = "ORB LIGHT: ON"
				OrbLightBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
				OrbLightBtn.TextColor3 = Color3.new(0,0,0)
			end
		else
			if currentHeadlight then currentHeadlight:Destroy(); currentHeadlight = nil end
			OrbLightBtn.Text = "ORB LIGHT: OFF"
			OrbLightBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
			OrbLightBtn.TextColor3 = Color3.new(1,1,1)
		end
	end

	-- [FULLBRIGHT LOGIC]
	local function toggleFullbright()
		fullbrightEnabled = not fullbrightEnabled
		if fullbrightEnabled then
			-- Backup
			originalLighting.Ambient = Lighting.Ambient
			originalLighting.Brightness = Lighting.Brightness
			originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
			-- Set Bright
			Lighting.Ambient = Color3.new(1, 1, 1)
			Lighting.Brightness = 2
			Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
			
			FullbrightBtn.Text = "FULLBRIGHT: ON"
			FullbrightBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
		else
			-- Restore
			Lighting.Ambient = originalLighting.Ambient
			Lighting.Brightness = originalLighting.Brightness
			Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
			
			FullbrightBtn.Text = "FULLBRIGHT: OFF"
			FullbrightBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
		end
	end

	-- ================== CONNECTIONS ==================
	WaterWalkBtn.MouseButton1Click:Connect(toggleWaterWalk)
	OrbLightBtn.MouseButton1Click:Connect(toggleOrbLight)
	FullbrightBtn.MouseButton1Click:Connect(toggleFullbright)

	SetSpeedBtn.MouseButton1Click:Connect(function()
		local val = tonumber(SpeedInput.Text)
		if val and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = val
		end
	end)

	DefaultSpeedBtn.MouseButton1Click:Connect(function()
		SpeedInput.Text = "16"
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 16
		end
	end)

	-- 5. TOMBOL CLICK TP
	local ClickTPBtn = Instance.new("TextButton", UtilitiesPage)
	ClickTPBtn.Size = UDim2.new(0.92, 0, 0, 35)
	ClickTPBtn.Position = UDim2.new(0.04, 0, 0.70, 0) -- Posisi di bawah Fullbright
	ClickTPBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 60)
	ClickTPBtn.Text = "CLICK TP: OFF"
	ClickTPBtn.TextColor3 = Color3.new(1,1,1)
	ClickTPBtn.Font = Enum.Font.GothamBold
	ClickTPBtn.TextSize = 12
	Instance.new("UICorner", ClickTPBtn).CornerRadius = UDim.new(0, 8)

	-- ================== CLICK TP LOGIC (STRICT LEFT CLICK) ==================

	local function toggleClickTP()
		clickTPEnabled = not clickTPEnabled
		
		if clickTPEnabled then
			ClickTPBtn.Text = "CLICK TP: ON"
			ClickTPBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
			
			-- Gunakan UserInputService untuk kontrol spesifik
			clickTPConnection = UIS.InputBegan:Connect(function(input, processed)
				-- 1. Jangan TP kalau lagi mencet tombol UI / Menu Game
				if processed then return end 
				
				-- 2. FILTER KETAT: Hanya Klik Kiri (PC) atau Tap Layar (Mobile)
				local isLeftClick = (input.UserInputType == Enum.UserInputType.MouseButton1)
				local isTouch = (input.UserInputType == Enum.UserInputType.Touch)
				
				if isLeftClick or isTouch then
					if not clickTPEnabled then return end
					
					local char = player.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					
					-- 3. Pastikan ada target yang diklik (bukan langit kosong)
					if hrp and mouse.Hit and mouse.Target then
						-- Teleport ke titik klik + offset tinggi agar tidak stuck
						hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
					end
				end
				
				-- Klik Kanan (MouseButton2) tidak akan masuk ke logika di atas
			end)
		else
			ClickTPBtn.Text = "CLICK TP: OFF"
			ClickTPBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 60)
			
			if clickTPConnection then
				clickTPConnection:Disconnect()
				clickTPConnection = nil
			end
		end
	end

	-- Koneksikan tombol ke fungsi
	ClickTPBtn.MouseButton1Click:Connect(toggleClickTP)

	-- ================== FLOATING ICON ==================
	local FloatingIcon = Instance.new("ImageButton", ScreenGui)
	FloatingIcon.Size = UDim2.new(0, 45, 0, 45)
	FloatingIcon.Position = UDim2.new(0, 20, 0.4, 0)
	FloatingIcon.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
	FloatingIcon.Image = "rbxassetid://82658194019329"
	Instance.new("UICorner", FloatingIcon).CornerRadius = UDim.new(0, 12)
	Instance.new("UIStroke", FloatingIcon).Color = Color3.fromRGB(0, 170, 255)

	FloatingIcon.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
	CloseBtn.MouseButton1Click:Connect(function() running = false; currentMode = "OFF"; ScreenGui:Destroy() end)

	-- ================== AUTOMATION LOGIC ==================
	local function startAutomation()
		if not CMGR or not MGR or not CastRod then return end
		table.insert(connections, LogService.MessageOut:Connect(function(msg)
			if currentMode ~= "OFF" and msg:find("Aduh enak") then
				task.wait(0.1)
				performCast()
			end
		end))
		table.insert(connections, MGR.OnClientEvent:Connect(function(...)
			if currentMode == "OFF" then return end
			local args = {...}
			if args[1] == "Spawn" then
				local mgrID = args[3]
				task.spawn(function()
					task.wait(currentMode == "INSTANT" and 0.25 or 0.05)
					pcall(function() MGR:FireServer("Click", mgrID) end)
				end)
			end
		end))
		table.insert(connections, CastRod.OnClientEvent:Connect(function(cmd)
			if currentMode ~= "OFF" and cmd == "Stop" then
				task.wait(0.5)
				performCast()
			end
		end))
	end

	startAutomation()
	task.spawn(function()
		while running and task.wait(1.5) do
			pcall(function()
				FishCountLbl.Text = "Fish in Bag: " .. getBackpackCount()
				if currentMode ~= "OFF" and not isCasting then performCast() end
			end)
		end
	end)

	print("=== Mancing Indo V7.0 Stable Loaded ===")
