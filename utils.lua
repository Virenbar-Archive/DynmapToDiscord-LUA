u = {}
function u.printtable(_t,prefix)
    prefix = prefix or ""
    for k,v in pairs(_t) do
        if type(v) == "table" then 
            u.printtable(v,prefix..k..":")
        else
            io.write(prefix,k,':',tostring(v),"\n")
        end
    end 
end
local function printTable(obj, cnt) --https://gist.github.com/marcotrosi/163b9e890e012c6a460a
    local cnt = cnt or 0
    local t = "  "
    if type(obj) == "table" then
        io.write("{\n")
        cnt = cnt + 1
        for k,v in pairs(obj) do
            if type(k) == "string" then
                io.write(string.rep(t,cnt), '["'..k..'"]', ' = ')
            end
            if type(k) == "number" then
                io.write(string.rep(t,cnt), "["..k.."]", " = ")
            end
            u.printTable(v, cnt)
            io.write(",\n")
        end
        cnt = cnt-1
        io.write(string.rep(t, cnt), "}")
    elseif type(obj) == "string" then
        io.write(string.format("%q", obj))
    else
        io.write(tostring(obj))
    end 
end
function u.saveConfig()
    --
end
function u.loadConfig(_name)
    local config = {}
    local f,err = loadfile(_name, "t", config)
    if f then f() else print(err) end
    return config
end
function u.log(message)
    print(os.date('[%H:%M:%S]')..message)
end
return u