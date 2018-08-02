local utils = require("utils")
arr = {{"one","two",{tr = "three"}},"four","five"}
--utils.printtable(arr)
--utils.printTable(arr)

config = utils.loadConfig('config.lua')

utils.printtable(config)
--print(os.date("!%Y-%m-%dT%TZ"))
--print(os.date('[%H:%M:%S]',tostring(1519828431804):sub(1,-4)))
--print(os.date('%Y-%m-%dT%H:%M:%SZ',tostring(1519828431804):sub(1,-4)))
--webhook = https.request("http://discordapp.com/api/webhooks/")
--webhook = json:decode(webhook)
--printtable(webhook)