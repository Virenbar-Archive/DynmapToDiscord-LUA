----Library
package.path = package.path..";./lua/?.lua"
local socket = require("socket")
local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("JSON")
----Init
local u = require("utils")
name = 'Dynmap to Discord'
version = '1.0'
timestamp = 420000
playerCount = 0
wait = 5
--err_prefix = function() return os.date('[%H:%M:%S]') end

config = u.loadConfig('config.lua')
----Functions
function sendRequest(payload)
    local path = config.webhook
    --local payload = [[{"content":"gg"}]]
    local response_body = { }
    local res, code, response_headers, status = https.request
    {
        url = path,
        method = "POST",
        headers =
        {
          ["Content-Type"] = "application/json",
          ["Content-Length"] = payload:len()
        },
        source = ltn12.source.string(payload),
        sink = ltn12.sink.table(response_body)
    }
    print(os.date('[%H:%M:%S]')..'Response: = ' .. table.concat(response_body) .. ', code = ' .. code .. ', status = ' .. status)
end
function getWorld()
    --local world = http.request(file) 
    --local status, err = pcall(function () error({code=121}) end)
    local status, res = pcall(function () return json:decode(http.request(config.file)) end)
    if status then 
        return res
    else
        print(os.date('[%H:%M:%S]')..res)
    end
    --return json:decode(http.request(config.file))
end
function getUUID(name)
    local status, res = pcall(function () return json:decode(https.request('https://api.mojang.com/users/profiles/minecraft/'..name)).id end)
    if status then 
      return res
    else
      print(os.date('[%H:%M:%S]')..res)
      return '00000000-0000-0000-0000-000000000000'
    end
end
function sendMessage(_type,event) --chat playerquit playerjoin info
    local player = ""
    local player_icon = ""
    local title = ""
    local description = ""
    local color = 0xffffff
    local time = os.date('[%H:%M:%S] ',tostring(event.timestamp):sub(1,-4))--Lua timestamp in seconds
    if _type == 'chat' then 
        if event.source == 'player' then
            player = event.account:gsub('[&].','')
            description = time..event.message
            player_icon = "https://crafatar.com/avatars/"..getUUID(player:gsub('%[.+%]',''))   --Steve 00000000-0000-0000-0000-000000000000 Alex ..0001
        else return end
    elseif _type == 'playerjoin' then
        local player = event.account:gsub('[&].','')
        description = 'Игрок '..player..' вошёл на сервер'
    elseif _type == 'playerquit' then
        local player = event.account:gsub('[&].','')
        description = 'Игрок '..player..' вышел с сервера'
    elseif _type == 'info' then
        description = event.message
        title = event.title
    else return end
    
    local message = {}
    --message.content = ""
    --message.username = ""
    --message.avatar_url = ""
    message.embeds = {{
        author = {
            name = player,
            url = "",
            icon_url = player_icon
        },
        title = title,
        description = description,
        color = color
    }}
    
    payload = json:encode(message)
    sendRequest(payload)
end
function CheckDynmap()
    local world = getWorld()
    if not world then return end
    for _,event in pairs(world.updates) do
        if event.timestamp > timestamp and event.type ~= 'tile' then
            sendMessage(event.type,event)
        end
    end
    if #world.players ~= playerCount then
        playerCount = #world.players
        if #world.players > 0 then
            local event = {players = {}}
            for k,v in pairs(world.players) do
                event.players[k] = v.account
            end
            event.message = 'Список игроков: '..table.concat(event.players,', ')..'.'
            event.timestamp = world.timestamp
            sendMessage('info',event)
        end
    end    
    timestamp = world.timestamp
end
----Main
--print(getUUID('Virenbar))
local event = {title = name, message = 'Версия: '..version, timestamp=timestamp}
sendMessage('info',event)
while true do
    CheckDynmap()
    socket.sleep(wait)
end