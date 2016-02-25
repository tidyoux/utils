local compare = function(a, b)
    if (type(a) == "number" or type(a) == "string") and (type(b) == "number" or type(b) == "string") then
        if (type(a) == type(b)) then
            if tonumber(a) and tonumber(b) then
                return tonumber(a) < tonumber(b)
            end
            return a < b
        end
        return (type(a) == "number")
    end
    return false
end

local pairs_by_keys = function(inTable)
    local temp = {}
    for k, v in pairs(inTable) do
        temp[#temp + 1] = k
    end

    table.sort(temp, compare)

    local i = 0
    return function()
        i = i + 1
        return temp[i], inTable[temp[i]]
    end
end

local pairs_by_values = function(inTable)
    local temp = {}
    local v2k = {}
    for k, v in pairs(inTable) do
        temp[#temp + 1] = v
        v2k[v] = k
    end

    table.sort(temp, compare)

    local i = 0
    return function()
        i = i + 1
        return v2k[temp[i]], temp[i]
    end
end

local get_space_string = function(n)
    n = n or 0
    return string.rep("    ", n)
end

local STAND_STRING = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
local NUM_STRING = "0123456789"
local hasSpecialChar = function(s)
    if (string.len(s) == 0) then
        return true
    end

    for k = 1, string.len(s) do
        if not(string.find(STAND_STRING, string.sub(s, k, k))) then
            return true
        end
    end

    if string.find(NUM_STRING, string.sub(s, 1, 1)) then
        return true
    end

    return false
end

-----------------------------------------------------
local write_table_head = function(tableName, writer)
    if writer then
        tableName = tableName or "gdTable"
        writer(tableName .. " = initTableSafely(" .. tableName .. ")\n\n")
    end
end

local function write_table_body(tableName, inTable, writer, orderByValue, deep)
    if inTable and writer then
        tableName = tableName or "gdTable"
        deep = deep or 0

        local space = get_space_string(deep)

        -- head
        writer(space .. tableName .. " = {\n")

        -- body
        local spaceEx = get_space_string(deep + 1)
        local pairs_func = pairs_by_keys
        if orderByValue then
            pairs_func = pairs_by_values
        end
        for k, v in pairs_func(inTable) do
            if (type(k) == "number") then
                k = "[" .. k .. "]"
            elseif (type(k) == "string") then
                if hasSpecialChar(k) then
                    k = '["' .. k .. '"]'
                end
            end


            if (type(v) == "table") then
                write_table_body(k, v, writer, orderByValue, deep + 1)
            elseif (type(v) == "string") then
                writer(spaceEx .. k .. " = \"" .. v .. "\",\n")
            elseif (type(v) == "function") then
                writer(spaceEx .. k .. " = " .. v() .. ",\n")
            else
                writer(spaceEx .. k .. " = " .. tostring(v) .. ",\n")
            end
        end

        -- tail
        if deep > 0 then
            writer(space .. "},\n")
        else
            writer(space .. "}\n")
        end
    end
end

----------------------------------------------------------
-- interface
--
write_table = function(inTable, tableName, filePath, orderByValue)
    local writer = io.write
    if filePath then
        local file = io.open(tostring(filePath), "w")
        if file then
            writer = function(s)
                file:write(s)
            end
        end
    end

    write_table_head(tableName, writer)
    write_table_body(tableName, inTable, writer, orderByValue)

    if file then
        file:close()
    end
end
