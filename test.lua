local utils = require("utils")
arr = {{"one","two",{tr = "three"}},"four","five"}
--utils.printtable(arr)
--utils.printTable(arr)

config = utils.loadConfig('config.lua')

utils.printtable(config)