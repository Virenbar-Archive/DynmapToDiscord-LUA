----------------------------------------------------------
--package.path = package.path..";./modules/?.lua"
local socket = require("socket")
local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("JSON")
local u = require("utils")
timestamp = 0

config = u.loadConfig('config.lua')
--functions
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
    return json:decode(http.request(config.file))
end
function getUUID(name)
    return json:decode(https.request('https://api.mojang.com/users/profiles/minecraft/'..name)).id
end
function sendMessage(_type,_event) --playerquit playerjoin
    local message = {}

    if _type == 'chat' then 
        player = event.account:gsub('[&].','')
        description = event.message
    end
    if _type == 'playerjoin' then
        player = event.account:gsub('[&].','')
        description = player
    end
    if _type == 'playerquit' then

    end

    message.content = ""
    message.username = ""
    message.avatar_url = ""
    message.embeds = {{
        author = {
            name = player,
            url = "",
            icon_url = "https://crafatar.com/avatars/"..getUUID(player:gsub('%[.+%]',''))   --Steve 00000000-0000-0000-0000-000000000000 Alex ..0001
        },
        title = os.date('[%H:%M:%S] ',tostring(event.timestamp):sub(1,-4)),--Lua timestamp in seconds 
        description = event.message
    }}
    
    payload = json:encode(message)
    sendRequest(payload)
end
function log()
    local world = getWorld()
    for _,event in pairs(world.updates) do
        if event.timestamp > timestamp then
            if event.type == 'chat' and event.timestamp > timestamp then 
                if event.source == 'player' then
                    local player = event.account:gsub('[&].','')
                    message = {}
                    message.content = ""
                    message.username = ""
                    message.avatar_url = ""
                    message.embeds = {{
                        author = {
                            name = player,
                            url = "",
                            icon_url = "https://crafatar.com/avatars/"..getUUID(player:gsub('%[.+%]',''))
                        },
                        title = os.date('[%H:%M:%S] ',tostring(event.timestamp):sub(1,-4)),--Lua timestamp in seconds 
                        description = event.message
                    }}
                    
                    payload = json:encode(message)
                    sendRequest(payload)
                end
            end
        end
    end
    timestamp = world.timestamp
end
function list()
    world = getWorld()
    io.write('Список игроков: ')
    for k,v in pairs(world.players) do
        io.write(v.account,' ')
    end
    io.write('\n')
end
--MAIN
------------------------------------------------------------------------------------------------------------------
--print(getUUID('Virenbar))
---[[
list()
while true do
    log()
    socket.sleep(5)
end
--]]
--print(os.date("!%Y-%m-%dT%TZ"))
--print(os.date('[%H:%M:%S]',tostring(1519828431804):sub(1,-4)))
--print(os.date('%Y-%m-%dT%H:%M:%SZ',tostring(1519828431804):sub(1,-4)))
--sendRequest(payload)
--webhook = https.request("http://discordapp.com/api/webhooks/")
--webhook = json:decode(webhook)
--printtable(webhook)