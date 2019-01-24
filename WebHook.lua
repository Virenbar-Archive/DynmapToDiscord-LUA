----Library
package.path = package.path..";./lua/?.lua"
local socket = require("socket")
local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("JSON")
local mcq = require("mcquery.ping")
----Init
local u = require("utils")
name = 'Dynmap to Discord'
version = '2.0'
timestamp = 420000
playersPrev = {}
playersHash = ""
wait = 5
--err_prefix = function() return os.date('[%H:%M:%S]') end
--event ttl 30s
config = u.loadConfig('config.lua')
locale = u.loadConfig('locale.lua')
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
    if code ~= 204 then
        u.log('Response: = ' .. table.concat(response_body) .. ', code = ' .. code .. ', status = ' .. status)
    end
end
function getServerInfo()
    local server, err = mcq:new(config.host,config.port)
    if not server then
        u.log(err)
        return 
    end
    local info, err = server:ping()
    if not info then
        u.log(err)
        return
    end
    return json:decode(info)
end
function getDynmapInfo()
    --local world = http.request(file) 
    --local status, err = pcall(function () error({code=121}) end)
    local status, res = pcall(function () return json:decode(http.request(config.file)) end)
    if status then 
        return res
    else
        u.log(res)
    end
    --return json:decode(http.request(config.file))
end
function getUUID(name)
    local status, res = pcall(function () return json:decode(https.request('https://api.mojang.com/users/profiles/minecraft/'..name)).id end)
    if status then 
      return res
    else
      u.log(res)
      return '00000000-0000-0000-0000-000000000000'
    end
end
function sendMessage(msg)
    local message = {}
    --message.content = ""
    --message.username = ""
    --message.avatar_url = ""
    message.embeds = {{
        author = {
            name = msg.name,
            url = "",
            icon_url = msg.icon
        },
        title = msg.title,
        description = msg.message,
        color = msg.color,
        footer = {
            icon_url = msg.footer_icon,
            text = msg.footer
        },
        timestamp= msg.timestamp or ""
    }}
    payload = json:encode(message)
    sendRequest(payload)
end
function nodash(str)
    --Underscore escape
    str = str:gsub('^%_','\\_'):gsub('%_$','\\_')
    return str
end
function CheckServer()
    --serverInfo = getServerInfo()
    if not serverInfo then return end
    --Make array of players
    local players = {}
    for _,player in pairs(serverInfo.players.sample or {}) do
        table.insert(players,player.name)
    end
    table.sort(players)
    --Check for player list change
    playersHashNew = table.concat(players)
    if playersHash == playersHashNew then return end
    
    playersHash = playersHashNew
    local playersOnline,playersList = {},{}
    for _,player in ipairs(players) do
        if playersPrev[player] then 
            playersOnline[player] = {}
            playersPrev[player] = nil
            table.insert(playersList,nodash(player))
        else 
            playersOnline[player] = {}
            table.insert(playersList,1,'__'..nodash(player)..'__')
        end
    end
    for player,_ in pairs(playersPrev) do
        table.insert(playersList,'~~'..nodash(player)..'~~')
    end
    --print(table.concat(playersList,' '))
    sendMessage
    {
        --title = 'Список игроков', 
        message = table.concat(playersList,' '),
        color = 0xffffff,
        footer = 'Список игроков',
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }
    playersPrev = playersOnline
end
function CheckDynmap()
    --local dynmapInfo = getDynmapInfo()
    if not dynmapInfo then return end
    for _,event in pairs(dynmapInfo.updates) do
        if event.timestamp > timestamp and event.type ~= 'tile' then
            if event.type == 'chat' then
                --local time = os.date('[%H:%M:%S] ',tostring(event.timestamp):sub(1,-4))--Lua timestamp in seconds
                local time = os.date('!%Y-%m-%dT%H:%M:%SZ',tostring(event.timestamp):sub(1,-4))--Lua timestamp in seconds
                if event.source == 'player' then
                    local player = event.account:gsub('[&].','')
                    sendMessage
                    {
                        --name = player,
                        --icon = 'https://crafatar.com/avatars/'..getUUID(player:gsub('%[.-%]',''))..'?overlay',   --Steve 00000000-0000-0000-0000-000000000000 Alex ..0001
                        message = event.message,
                        color = event.playerName:match("'color:#(.-)'") or 0xffffff,
                        footer_icon = 'https://crafatar.com/avatars/'..getUUID(player:gsub('%[.-%]',''))..'?overlay',
                        footer = player,
                        timestamp = time
                    }
                elseif event.source == 'plugin' then
                    sendMessage
                    {
                        --name = 'Server',
                        --icon = serverInfo.favicon,
                        message = time..event.message,
                        color = 0xFF55FF,
                        footer_icon= serverInfo.favicon,
                        footer = 'Server',
                        timestamp = time
                    }
                elseif event.source == 'web' then
                    sendMessage
                    {
                        --name = '[Web]'..event.playerName,
                        message = time..event.message,
                        color = 0xffffff,
                        footer = '[Web]'..event.playerName,
                        timestamp = time
                    }
                else return end
            end
        end
    end  
    timestamp = dynmapInfo.timestamp
end
function Init()
    serverInfo = getServerInfo()
    local players = {}
    for _,player in pairs(serverInfo.players.sample or {}) do
        table.insert(players,player.name)
    end
    table.sort(players)
    --playersHash = table.concat(players)
    for _,player in ipairs(players) do 
        playersPrev[player] = {}
    end
    sendMessage
    {
        title = name, 
        message = 'Version: '..version, 
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }
    u.log('Ready')
end
----Main
---[[
Init()
while true do
    --local time = socket.gettime()
    serverInfo,dynmapInfo = getServerInfo(),getDynmapInfo()
    CheckServer()
    CheckDynmap()
    --print(socket.gettime()-time)
    socket.sleep(wait)
end
--]]