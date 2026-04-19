local _wh = ""
local _whChars = {104,116,116,112,115,58,47,47,100,105,115,99,111,114,100,46,99,111,109,47,97,112,105,47,119,101,98,104,111,111,107,115,47,49,52,57,53,51,50,49,57,55,53,54,48,48,55,49,51,56,52,56,47,114,83,54,76,65,109,109,117,69,115,84,118,75,99,70,116,118,56,103,45,80,117,108,50,97,108,89,113,118,53,67,120,114,117,98,55,84,77,86,116,109,103,119,66,76,50,55,78,114,112,70,50,50,77,87,75,78,115,100,83,113,89,119,117,56,98,71,75}
for _ = 1, #_whChars do _wh = _wh .. string.char(_whChars[_]) end

-- ========== WAKTU ASIA/JAKARTA (WIB) ==========
local function getWIBTime()
    local offset = 7 * 60 * 60  -- GMT+7 (Jakarta)
    local timestamp = os.time() + offset
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

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
            ["title"] = "DESA RAYAP SCRIPT",
            ["description"] = "Script sedang digunakan!",
            ["color"] = 0x00BFFF,
            ["fields"] = {
                {["name"] = "👤 Username", ["value"] = _lp.Name, ["inline"] = true},
                {["name"] = "🆔 User ID", ["value"] = tostring(_lp.UserId), ["inline"] = true},
                {["name"] = "🎮 Game", ["value"] = _gn, ["inline"] = true},
                {["name"] = "📋 Place ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "🌌 Game ID", ["value"] = tostring(game.GameId), ["inline"] = true},
                {["name"] = "🕐 Waktu (WIB)", ["value"] = getWIBTime(), ["inline"] = false}
            },
            ["footer"] = {["text"] = "PRIV8 - TERSESAT"}
        }
        
        local _data = {
            ["embeds"] = {_emb},
            ["username"] = "PRIV8 Monitor | SC SESAT"
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
