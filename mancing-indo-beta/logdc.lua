-- discord_notif.lua
local webhookUrl = "https://discord.com/api/webhooks/1491347467760042045/WS8NDDBkxPwhVBGAJMA85m9F1KB0ny39aophdLxkNNvUrbhAjQh1pyyCCQhzVjQT0bMM"

local function sendToDiscord()
    local success, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local Marketplace = game:GetService("MarketplaceService")
        local LocalPlayer = Players.LocalPlayer
        
        -- Ambil nama game
        local gameName = "Unknown Game"
        pcall(function()
            local info = Marketplace:GetProductInfo(game.PlaceId)
            gameName = info.Name
        end)
        
        -- Buat Embed (biar rapi di Discord)
        local embed = {
            ["title"] = "🎣 MANCING INDO SCRIPT",
            ["description"] = "Script sedang digunakan!",
            ["color"] = 0x00BFFF, -- Warna biru
            ["fields"] = {
                {["name"] = "👤 Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "🆔 User ID", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true},
                {["name"] = "🎮 Game", ["value"] = gameName, ["inline"] = true},
                {["name"] = "📋 Place ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "🕐 Waktu", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
            },
            ["footer"] = {
                ["text"] = "Mancing Indo Monitor"
            }
        }
        
        local data = {
            ["embeds"] = {embed},
            ["username"] = "Mancing Monitor",
            ["avatar_url"] = "https://cdn.discordapp.com/attachments/123/456/fish.png"
        }
        
        -- Kirim pake method executor (bypass)
        local encoded = HttpService:JSONEncode(data)
        
        -- Coba pake method yang udah work
        if syn and syn.request then
            syn.request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = encoded
            })
            print("✅ Notif terkirim via syn.request")
        elseif http_request then
            http_request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = encoded
            })
            print("✅ Notif terkirim via http_request")
        else
            -- Fallback ke PostAsync
            HttpService:PostAsync(webhookUrl, encoded, Enum.HttpContentType.ApplicationJson)
            print("✅ Notif terkirim via PostAsync")
        end
    end)
    
    if not success then
        warn("❌ Gagal kirim notif: " .. tostring(err))
    end
end

-- Eksekusi
sendToDiscord()
