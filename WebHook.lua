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
--playerCount = 0
P_online = {}
wait = 5
--err_prefix = function() return os.date('[%H:%M:%S]') end
--event ttl 30s
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
    local P_join = {}
    local P_quit = {}
    --local P_online = {}
    local world = getWorld()
    if not world then return end
    for _,event in pairs(world.updates) do
        if event.timestamp > timestamp and event.type ~= 'tile' then
            if event.type == 'chat' then 
                sendMessage(event.type,event)
            elseif event.type == 'playerjoin' then
                P_join[#P_join+1] = '__'..event.account..'__'
            elseif event.type == 'playerquit' then
                P_quit[#P_quit+1] = '~~'..event.account..'~~'
            end
        end
    end
    if #world.players ~= #P_online or #P_join>0 or #P_quit>0 then
        --playerCount = #world.players
        if #P_join==0 and #P_quit==0 then
        --WAT
        end
        P_online = {}
        for k,v in pairs(world.players) do
            P_online[k] = v.account
        end
        
        local event = {}
        event.message = 'Список игроков: '..table.concat(P_join,' ')..' '.. table.concat(P_online,' ')..' '..table.concat(P_quit,' ')..'.'
        event.timestamp = world.timestamp
        sendMessage('info',event)
    end    
    timestamp = world.timestamp
end
----Main
---[[
local event = {title = name, message = 'Версия: '..version, timestamp=timestamp}
sendMessage('info',event)
while true do
    local time = socket.gettime()
    CheckDynmap()
    print(socket.gettime()-time)
    socket.sleep(wait)
end
--]]