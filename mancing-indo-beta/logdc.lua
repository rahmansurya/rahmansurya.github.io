-- discord_notif.lua (simpan di GitHub)
local webhookUrl = "https://discord.com/api/webhooks/1491344154293174382/9hgc2NLtJ3M5-cRELqUoncoi0mCY7_052BrCP6RkEI0YaL2bX6ms7jMHOQnl2U9bQCUl"

local function sendNotif()
    local player = game:GetService("Players").LocalPlayer
    local marketplace = game:GetService("MarketplaceService")
    
    local gameName = "Unknown"
    pcall(function()
        gameName = marketplace:GetProductInfo(game.PlaceId).Name
    end)
    
    local data = {
        ["content"] = string.format(
            "**🎣 MANCING INDO DIPAKAI!**\n\n👤 **User:** %s\n🆔 **ID:** %d\n🎮 **Game:** %s\n🕐 **Time:** %s",
            player.Name,
            player.UserId,
            gameName,
            os.date("%Y-%m-%d %H:%M:%S")
        ),
        ["username"] = "Mancing Monitor"
    }
    
    pcall(function()
        game:GetService("HttpService"):PostAsync(
            webhookUrl,
            game:GetService("HttpService"):JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

sendNotif()
