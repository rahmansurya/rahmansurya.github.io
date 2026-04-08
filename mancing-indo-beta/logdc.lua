local webhookUrl = "https://discord.com/api/webhooks/1491347467760042045/WS8NDDBkxPwhVBGAJMA85m9F1KB0ny39aophdLxkNNvUrbhAjQh1pyyCCQhzVjQT0bMM"

local function sendToDiscord()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local Marketplace = game:GetService("MarketplaceService")
        local LocalPlayer = Players.LocalPlayer
        
        -- ========== COUNTER EKSEKUSI ==========
        local userId = LocalPlayer.UserId
        local storageKey = "MancingIndo_ExecCount_" .. userId
        
        -- Ambil counter terakhir
        local executionCount = 1
        local success, data = pcall(function()
            return syn and syn.crypt and syn.crypt.base64.decode or nil
        end)
        
        -- Simpen counter di berbagai tempat biar persisten
        pcall(function()
            -- Coba dari HttpService dulu
            if game:GetService("HttpService"):GetAsync(storageKey) then
                executionCount = tonumber(game:GetService("HttpService"):GetAsync(storageKey)) + 1
            end
        end)
        
        -- Simpan counter yang baru
        pcall(function()
            game:GetService("HttpService"):PostAsync(storageKey, tostring(executionCount))
        end)
        
        -- ========== AMBIL INFO GAME ==========
        local gameName = "Unknown Game"
        pcall(function()
            local info = Marketplace:GetProductInfo(game.PlaceId)
            gameName = info.Name
        end)
        
        -- ========== BUAT EMBED ==========
        local embed = {
            ["title"] = "🎣 MANCING INDO SCRIPT",
            ["description"] = "Script sedang digunakan!",
            ["color"] = 0x00BFFF,
            ["fields"] = {
                {["name"] = "👤 Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "🆔 User ID", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true},
                {["name"] = "🎮 Game", ["value"] = gameName, ["inline"] = true},
                {["name"] = "📋 Place ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "🔢 Eksekusi Ke-", ["value"] = tostring(executionCount), ["inline"] = true},
                {["name"] = "🕐 Waktu", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
            },
            ["footer"] = {
                ["text"] = "Total eksekusi user ini: " .. executionCount .. " kali"
            }
        }
        
        local data = {
            ["embeds"] = {embed},
            ["username"] = "PRIV8 Monitor SC",
            ["avatar_url"] = "https://cdn.discordapp.com/attachments/123/456/fish.png"
        }
        
        local encoded = HttpService:JSONEncode(data)
        
        -- ========== KIRIM PAKE METHOD EXECUTOR ==========
        if syn and syn.request then
            syn.request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = encoded
            })
        elseif http_request then
            http_request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = encoded
            })
        else
            HttpService:PostAsync(webhookUrl, encoded, Enum.HttpContentType.ApplicationJson)
        end
        
        print("✅ Notif terkirim! Eksekusi ke-" .. executionCount)
    end)
end

-- Eksekusi
sendToDiscord()
