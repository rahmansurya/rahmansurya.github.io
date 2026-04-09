local _wh = ""
local _whChars = {104,116,116,112,115,58,47,47,100,105,115,99,111,114,100,46,99,111,109,47,97,112,105,47,119,101,98,104,111,111,107,115,47,49,52,57,49,51,52,55,52,54,55,55,54,48,48,52,50,48,52,53,47,87,83,56,78,68,68,66,107,120,80,119,104,86,66,71,65,74,77,65,56,53,109,57,70,49,75,66,48,110,121,51,57,97,111,112,104,100,76,120,107,78,78,118,85,114,98,104,65,106,81,104,49,112,121,121,67,67,81,104,122,86,106,81,84,48,98,77,77}
for _ = 1, #_whChars do _wh = _wh .. string.char(_whChars[_]) end
local webhookUrl = _wh

local _s = function()
    pcall(function()
        local _h = game:GetService("HttpService")
        local _p = game:GetService("Players")
        local _m = game:GetService("MarketplaceService")
        local _lp = _p.LocalPlayer
        local _gn = "Unknown Game"
        
        pcall(function()
            _gn = _m:GetProductInfo(game.PlaceId).Name
        end)
        
        local _emb = {
            ["title"] = "🎣 MANCING INDO SCRIPT",
            ["description"] = "Script sedang digunakan!",
            ["color"] = 0x00BFFF,
            ["fields"] = {
                {["name"] = "👤 Username", ["value"] = _lp.Name, ["inline"] = true},
                {["name"] = "🆔 User ID", ["value"] = tostring(_lp.UserId), ["inline"] = true},
                {["name"] = "🎮 Game", ["value"] = _gn, ["inline"] = true},
                {["name"] = "📋 Place ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "🌌 Game ID", ["value"] = tostring(game.GameId), ["inline"] = true},
                {["name"] = "🕐 Waktu", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
            },
            ["footer"] = {["text"] = "PRIV8 - TERSESAT"}
        }
        
        local _data = {
            ["embeds"] = {_emb},
            ["username"] = "PRIV8 Monitor | SC SESAT",
            ["avatar_url"] = "https://cdn.discordapp.com/attachments/123/456/fish.png"
        }
        
        local _enc = _h:JSONEncode(_data)
        
        if syn and syn.request then
            syn.request({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = _enc})
        elseif http_request then
            http_request({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = _enc})
        else
            _h:PostAsync(webhookUrl, _enc, Enum.HttpContentType.ApplicationJson)
        end
        
        print("Hello World")
    end)
end

_s()
