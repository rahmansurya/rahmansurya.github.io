-- =============================================
--     MANCING HUB - WindUI + Minimize + Floating Icon
--     Support Mobile & F3 Toggle
-- =============================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "🎣 Mancing HUB",
    Size = UDim2.fromOffset(420, 320),
    Position = UDim2.fromScale(0.5, 0.5),
    ToggleKey = Enum.KeyCode.F3,   -- Tekan F3 untuk buka/tutup UI
})

-- Variable global
local isMinimized = false
local FloatingIcon = nil
local Connections = {}

-- ==================== TAB INFO ====================
local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })
InfoTab:Section({ Title = "Tentang HUB" }):Label({
    Title = "Mancing HUB",
    Desc = "Masih tahap pengembangan\nUpdate akan terus ditambahkan.\nTerima kasih sudah pakai!"
})

-- ==================== TAB MAIN ====================
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local FishingSection = MainTab:Section({ Title = "Auto Fishing" })

FishingSection:Toggle({
    Title = "Legit Tap Fishing",
    Desc = "Mode tapping natural",
    Default = false,
    Callback = function(state) print("Legit:", state) end
})

FishingSection:Toggle({
    Title = "Fast Tap Fishing",
    Desc = "Mode cepat (risky)",
    Default = false,
    Callback = function(state) print("Fast:", state) end
})

-- ==================== TAB TELEPORT ====================
local TpTab = Window:Tab({ Title = "Teleport", Icon = "map" })
local TpSection = TpTab:Section({ Title = "Pilih Lokasi" })

local selectedLocation = "Spawn"

TpSection:Dropdown({
    Title = "Pilih Lokasi",
    Options = {"Spawn", "Dock", "Deep Sea", "Secret Island", "Boss Area", "Shop"},
    Default = "Spawn",
    Callback = function(v) selectedLocation = v end
})

TpSection:Button({
    Title = "Teleport Sekarang",
    Callback = function()
        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            print("Teleport ke", selectedLocation)
            -- Ganti CFrame sesuai game lo (Fish It! / Fisch)
        end
    end
})

-- ==================== FLOATING ICON FUNCTION ====================
local function CreateFloatingIcon()
    if FloatingIcon then FloatingIcon:Destroy() end
    
    FloatingIcon = Instance.new("ScreenGui")
    FloatingIcon.Name = "MancingHubFloat"
    FloatingIcon.ResetOnSpawn = false
    FloatingIcon.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(50, 50)
    Frame.Position = UDim2.fromOffset(20, 20)  -- Pojok kiri atas
    Frame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Frame.BorderSizePixel = 0
    Frame.Parent = FloatingIcon

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Frame)

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.fromScale(1,1)
    Icon.BackgroundTransparency = 1
    Icon.Text = "🐟"
    Icon.TextSize = 28
    Icon.Font = Enum.Font.GothamBold
    Icon.Parent = Frame

    -- Buat draggable
    local dragging, dragInput, dragStart, startPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Klik icon = toggle UI
    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Window:Toggle()  -- atau logic show/hide sesuai WindUI
            isMinimized = false
            FloatingIcon.Enabled = false
        end
    end)
end

-- ==================== MINIMIZE & CLOSE LOGIC ====================
Window:CreateTopbarButton({  -- Kalau ada method ini, atau tambah manual
    Title = "Minimize",
    Callback = function()
        isMinimized = true
        Window:Close()           -- atau hide window
        CreateFloatingIcon()
        FloatingIcon.Enabled = true
    end
})

-- Close dengan popup (sesuai request sebelumnya)
Window.OnClose = function()
    -- Popup konfirmasi
    WindUI:CreateDialog({
        Title = "Konfirmasi",
        Content = "Yakin ingin keluar dari Mancing HUB?",
        Buttons = {
            {
                Title = "Ya",
                Callback = function()
                    -- Matikan semua script
                    isMinimized = false
                    if FloatingIcon then FloatingIcon:Destroy() end
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Mancing HUB",
                        Text = "HUB ditutup. Execute loader lagi untuk membuka.",
                        Duration = 5
                    })
                    
                    Window:Destroy()  -- Full destroy
                end
            },
            { Title = "Tidak", Callback = function() end }
        }
    })
end

print("✅ Mancing HUB loaded! Tekan F3 untuk toggle UI | Minimize = Floating Icon pojok kiri 🐟")
