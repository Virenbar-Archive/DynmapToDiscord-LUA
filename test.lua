local utils = require("utils")
--[[
arr = {{"one","two",{tr = "three"}},"four","five"}
utils.printtable(arr)
utils.printTable(arr)
--]]
--[[
config = utils.loadConfig('config.lua')
utils.printtable(config)
--]]
--print(os.date("!%Y-%m-%dT%TZ"))
--print(os.date('[%H:%M:%S]',tostring(1519828431804):sub(1,-4)))
--print(os.date('%Y-%m-%dT%H:%M:%SZ',tostring(1519828431804):sub(1,-4)))
--webhook = https.request("http://discordapp.com/api/webhooks/")
--webhook = json:decode(webhook)
--printtable(webhook)
--print(getUUID('Virenbar))
--[[
loadfile('WebHook.lua', "t")()
while true do
    local world = getWorld()
    local time = 999999999999999999
    for _,event in pairs(world.updates) do
        if event.timestamp < time then
            time = event.timestamp
        end
    end
    print(world.timestamp-time)
    socket.sleep(1)
end
--]]
name = ' _hui, fdh_dhfd, gdfgd_ ,'
print(name:gsub('%s%_',' \\_'):gsub('%_%s','\\_ '))
arr = {'LLlTypMoBuk','Abhidharma','Mr_DD'}
table.sort(arr)
print(table.concat(arr,', '))