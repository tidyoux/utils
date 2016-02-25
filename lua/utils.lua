local begin = function(tag)
    print("begin " .. tostring(tag) .. "...")
end

local done = function(tag)
    print(tostring(tag) .. " done.\n")
end

trace_back = function()
    print(debug.traceback("", 2))
end

print_err = function(...)
    print("error:", ...)
    trace_back()
end

safely_call = function(fn, ...)
    if (type(fn) == "function") then
        fn(...)
    else
        print_err("safely_call", "invalid fn!")
    end
end

call_with_log = function(fn, fnName)
    begin(fnName)
    safely_call(fn)
    done(fnName)
end

table.clone = function(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

io.with_open = function(path, mode, fn)
    local f = io.open(path, mode)
    if f then
        safely_call(fn, f)
        f:close()
    end
end

io.exists = function(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

io.cp_auto_mkdir = function(fromPath, toPath, fileName)
    if not(os.execute("cd " .. toPath .. " >nul 2>nul")) then
        os.execute("mkdir -p " .. toPath)
    end
    os.execute("cp " .. fromPath .. fileName .. " " .. toPath)
    os.execute("rm nul")
end

string.split = function(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end




