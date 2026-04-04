-- =============================================
--     🎣 MANCING HUB - WindUI Full (Update Floating Icon pake rbxassetid)
--     F3 Toggle + Minimize ke Floating Icon + Close Confirmation
-- =============================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:NewWindow({
    Title = "🎣 Mancing HUB",
    Size = UDim2.fromOffset(440, 340),
    Position = UDim2.fromScale(0.5, 0.5),
    ToggleKey = Enum.KeyCode.F3,      -- Tekan F3 untuk toggle UI
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
        -- Taruh script Legit di sini
    end
})

FishingSection:Toggle({
    Title = "Fast Tap Fishing",
    Desc = "Mode tapping cepat (lebih risky)",
    Value = false,
    Callback = function(state)
        FastEnabled = state
        print("Fast Tap Fishing:", state)
        -- Taruh script Fast di sini
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
    Callback = function(value) selectedLoc = value end
})

TpSection:Button({
    Title = "Teleport Sekarang",
    Callback = function()
        local HRP = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            print("Teleport ke " .. selectedLoc)
            -- GANTI CFRAME SESUAI GAME LO
            if selectedLoc == "Spawn" then HRP.CFrame = CFrame.new(0, 50, 0)
            elseif selectedLoc == "Dock" then HRP.CFrame = CFrame.new(120, 15, 250)
            elseif selectedLoc == "Deep Sea" then HRP.CFrame = CFrame.new(600, -40, 900)
            end
        end
    end
})

-- ==================== FLOATING ICON PAKE RBXASSETID ====================
local function CreateFloatingIcon()
    if FloatingGui then FloatingGui:Destroy() end

    FloatingGui = Instance.new("ScreenGui")
    FloatingGui.Name = "MancingFloat"
    FloatingGui.ResetOnSpawn = false
    FloatingGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.fromOffset(60, 60)
    IconFrame.Position = UDim2.fromOffset(20, 100)
    IconFrame.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = FloatingGui

    Instance.new("UICorner", IconFrame).CornerRadius = UDim.new(0, 18)
    Instance.new("UIStroke", IconFrame).Thickness = 2

    local IconImage = Instance.new("ImageLabel")
    IconImage.Size = UDim2.fromScale(0.75, 0.75)
    IconImage.Position = UDim2.fromScale(0.5, 0.5)
    IconImage.AnchorPoint = Vector2.new(0.5, 0.5)
    IconImage.BackgroundTransparency = 1
    IconImage.Image = "rbxassetid://6031094678"   -- <<< GANTI ID INI KALAU MAU ICON LAIN
    IconImage.ImageColor3 = Color3.new(1, 1, 1)
    IconImage.Parent = IconFrame

    -- Draggable
    local dragging = false
    local dragStart, startPos

    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = IconFrame.Position
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            IconFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Klik icon = buka UI
    IconFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Window:Toggle()
            FloatingGui.Enabled = false
        end
    end)
end

-- ==================== MINIMIZE BUTTON ====================
Window:CreateTopbarButton({
    Name = "Minimize",
    Callback = function()
        Window:Close()
        CreateFloatingIcon()
        if FloatingGui then FloatingGui.Enabled = true end
    end
})

-- ==================== CLOSE CONFIRMATION ====================
Window.OnClose = function()
    WindUI:CreateDialog({
        Title = "Konfirmasi Keluar",
        Content = "Yakin ingin keluar dari Mancing HUB?\nSemua fitur akan dimatikan.",
        Buttons = {
            {
                Title = "Ya",
                Callback = function()
                    LegitEnabled = false
                    FastEnabled = false
                    if FloatingGui then FloatingGui:Destroy() end
                    
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Mancing HUB",
                        Text = "HUB ditutup. Execute loader lagi untuk membuka.",
                        Duration = 6
                    })
                    Window:Destroy()
                end
            },
            { Title = "Tidak", Callback = function() end }
        }
    })
end

print("✅ Mancing HUB Loaded dengan Floating Icon (rbxassetid)!")
print("Tekan F3 untuk toggle | Klik Minimize untuk floating icon pojok kiri 🐟")
