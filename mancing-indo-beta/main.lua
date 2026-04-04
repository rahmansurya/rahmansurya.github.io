-- =============================================
--     🎣 MANCING HUB - WindUI (FIXED Floating Icon)
--     F3 Toggle + Minimize ke Floating Icon Pojok Kiri
-- =============================================

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "🎣 Mancing HUB",
    Size = UDim2.fromOffset(440, 340),
    Position = UDim2.fromScale(0.5, 0.5),
    ToggleKey = Enum.KeyCode.F3,   -- Tekan F3 buka/tutup
    Theme = "Dark",
})

-- Variable
local LegitEnabled = false
local FastEnabled = false
local FloatingGui = nil

-- ==================== TAB INFO ====================
local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })
InfoTab:Section({ Title = "Tentang HUB" }):Label({
    Title = "Mancing HUB",
    Desc = "Masih tahap pengembangan\n\nUpdate akan terus ditambahkan.\nTerima kasih sudah pakai!"
})

-- ==================== TAB MAIN ====================
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local FishingSection = MainTab:Section({ Title = "Auto Fishing" })

FishingSection:Toggle({
    Title = "Legit Tap Fishing",
    Desc = "Mode tapping natural (lebih aman)",
    Value = false,
    Callback = function(state)
        LegitEnabled = state
        print("Legit Tap Fishing:", state)
        -- Taruh script legit fishing di sini
    end
})

FishingSection:Toggle({
    Title = "Fast Tap Fishing",
    Desc = "Mode tapping cepat (lebih risky)",
    Value = false,
    Callback = function(state)
        FastEnabled = state
        print("Fast Tap Fishing:", state)
        -- Taruh script fast fishing di sini
    end
})

-- ==================== TAB TELEPORT ====================
local TpTab = Window:Tab({ Title = "Teleport", Icon = "map" })
local TpSection = TpTab:Section({ Title = "Pilih Lokasi" })

local selectedLoc = "Spawn"

TpSection:Dropdown({
    Title = "Pilih Lokasi",
    Options = {"Spawn", "Dock", "Deep Sea", "Secret Island", "Boss Area", "Shop"},
    Value = "Spawn",
    Callback = function(value)
        selectedLoc = value
    end
})

TpSection:Button({
    Title = "Teleport Sekarang",
    Callback = function()
        local HRP = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            print("Teleport ke " .. selectedLoc)
            -- GANTI CFRAME SESUAI GAME LO (Fish It! / Fisch)
            if selectedLoc == "Spawn" then
                HRP.CFrame = CFrame.new(0, 50, 0)
            elseif selectedLoc == "Dock" then
                HRP.CFrame = CFrame.new(120, 15, 250)
            elseif selectedLoc == "Deep Sea" then
                HRP.CFrame = CFrame.new(600, -40, 900)
            end
        end
    end
})

-- ==================== FLOATING ICON (FIXED) ====================
local function CreateFloatingIcon()
    if FloatingGui then FloatingGui:Destroy() end

    FloatingGui = Instance.new("ScreenGui")
    FloatingGui.Name = "MancingFloat"
    FloatingGui.ResetOnSpawn = false
    FloatingGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(65, 65)
    Frame.Position = UDim2.fromOffset(30, 150)  -- Pojok kiri
    Frame.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    Frame.BorderSizePixel = 0
    Frame.Parent = FloatingGui

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 20)
    Instance.new("UIStroke", Frame).Thickness = 2.5

    local Image = Instance.new("ImageLabel")
    Image.Size = UDim2.fromScale(0.7, 0.7)
    Image.Position = UDim2.fromScale(0.5, 0.5)
    Image.AnchorPoint = Vector2.new(0.5, 0.5)
    Image.BackgroundTransparency = 1
    Image.Image = "rbxassetid://6031094678"   -- Icon ikan (bisa diganti)
    Image.ImageColor3 = Color3.new(1, 1, 1)
    Image.Parent = Frame

    -- Draggable
    local dragging = false
    local dragStart, startPos

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

    -- Klik icon = buka UI
    Frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Window:Toggle()   -- Toggle UI WindUI
            FloatingGui.Enabled = false
        end
    end)
end

-- ==================== MINIMIZE BUTTON (Manual di Main Tab) ====================
MainTab:Section({ Title = "Control" }):Button({
    Title = "Minimize ke Floating Icon",
    Callback = function()
        Window:Toggle()          -- Sembunyikan UI utama
        CreateFloatingIcon()
        if FloatingGui then
            FloatingGui.Enabled = true
        end
    end
})

-- ==================== CLOSE CONFIRMATION ====================
Window.OnClose = function()
    WindUI:CreateDialog({
        Title = "Konfirmasi Keluar",
        Content = "Yakin ingin keluar dari Mancing HUB?\nSemua auto fishing akan dimatikan.",
        Buttons = {
            {
                Title = "Ya",
                Callback = function()
                    LegitEnabled = false
                    FastEnabled = false
                    if FloatingGui then FloatingGui:Destroy() end
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Mancing HUB",
                        Text = "HUB ditutup.\nExecute loader lagi untuk membuka.",
                        Duration = 6
                    })
                    Window:Destroy()
                end
            },
            { Title = "Tidak", Callback = function() end }
        }
    })
end

print("✅ Mancing HUB FIXED & Loaded!")
print("   • Tekan F3 untuk toggle UI")
print("   • Klik 'Minimize ke Floating Icon' di tab Main")
print("   • Floating icon harus muncul di pojok kiri (bisa di-drag)")
print("   • Gas mancing bro! 🐟")
