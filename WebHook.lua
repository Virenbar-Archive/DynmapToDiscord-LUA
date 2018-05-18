----------------------------------------------------------
--package.path = package.path..";./modules/?.lua"
local socket = require("socket")
local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("JSON")
file = 'http://178.33.4.202:65000/up/world/ebs/'
--file = 'http://map.minecrafting.ru/standalone/dynmap_world.json'
timestamp = 0

config = {}
local f,err = loadfile('config.lua', "t", config)
if f then f() else print(err) end
--functions
function printtable(_t)
  for k,v in pairs(_t) do
    print(k..':'..tostring(v))
  end 
end
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
  return json:decode(http.request(file))
end
function getUUID(name)
    return json:decode(https.request('https://api.mojang.com/users/profiles/minecraft/'..name)).id
end
function log()
  local world = getWorld()
  for _,event in pairs(world.updates) do
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