local begin = function(tag)
    print("begin " .. tostring(tag) .. "...")
end

local done = function(tag)
    print(tostring(tag) .. " done.\n")
end

trace_back = function()
    print(debug.traceback("", 2))
end

join_tostring = function(...)
	local ret = ""
	for k, v in ipairs({...}) do
		if k == 1 then
			ret = tostring(v)
		else
			ret = ret .. " " .. tostring(v)
		end
	end
	return ret
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

--[[
帮助匿名函数递归调用。
e.g.
make_recursion(function(func)
		return function(n)
			if n <= 0 then return 1 end
			return n * func(func)(n - 1)
		end
	end)(5)
==> 120
--]]
make_recursion = function(fn)
	if (type(fn) == "function") then
        return fn(fn)
    else
        print_err("make_recursion", "invalid fn!")
		return nil
    end
end

func_list_call = function(tFn, ...)
	if type(tFn) == "table" then
		for _, fn in pairs(tFn) do
			safely_call(fn, ...)
		end
	else
		print_err("func_list_call", "invalid tFn:", tFn)
	end
end

-- for mac
mac_say = function(...)
	os.execute("say " .. join_tostring(...))
end

-- for mac
mac_notify = function(...)
	local cmd = [[osascript -e 'display notification "]] .. join_tostring(...) .. [[" with title "Note:"']]
	os.execute(cmd)
end

-- for mac
mac_multi_print = function(...)
	func_list_call({print, mac_notify, mac_say}, ...)
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
