package.path = package.path..";./modules/?.lua"
local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")
local json = require("JSON")

function printtable(_t)
  for k,v in pairs(_t) do
    print(k..':'..tostring(v))
  end 
end
print(os.date("!%Y-%m-%dT%TZ"))
message = {}
message.content = "content"
message.username = ""
message.avatar_url = ""
message.embeds = {{
  author = {
    name = "author name",
    url = "https://discordapp.com",
    icon_url = "https://cdn.discordapp.com/embed/avatars/0.png"
  },
  title = "title",
  url = "https://discordapp.com",
  color = 10547795,
  description = "description",
  thumbnail = {url = "https://cdn.discordapp.com/embed/avatars/0.png"},
  fields = {
    {name="title1",value="text1"},
    {name="title2",value="text2"}
  },
  image = {url = "https://cdn.discordapp.com/embed/avatars/0.png"},
  footer = {icon_url = "https://cdn.discordapp.com/embed/avatars/0.png",text = "footer text"},
  timestamp = "2018-05-01T19:05:02.442Z"
}}
payload = json:encode(message)
print(payload)

function sendRequest()
  local path = "https://discordapp.com/api/webhooks/"
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
  print('Response: = ' .. table.concat(response_body) .. ', code = ' .. code .. ', status = ' .. status)
end
sendRequest()
--webhook = https.request("http://discordapp.com/api/webhooks/440187420219277313/SOTb-8Iftpb-gaOKFsPIucR54L-gmF4kXjVFnJHe0ftH-zjMhkohBEn2vVt-YaVifknS")
--webhook = json:decode(webhook)
--printtable(webhook)