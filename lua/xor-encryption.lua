
local bit = require 'bit'

local encode = function(inpath, outpath, key)
    local inf = assert(io.open(inpath, "rb"))
    local outf = assert(io.open(outpath, "wb"))

    if (type(key) ~= "string") or (string.len(key) == 0) then
        key = "x"
    end

    local temp = nil
    local data = inf:read(1)
    while data do
        temp = bit.bxor(string.byte(data), string.byte(string.sub(key, 1, 1)))
        for i = 2, string.len(key) do
            temp = bit.bxor(temp, string.byte(string.sub(key, i, i)))
        end
        outf:write(string.char(temp))
        data = inf:read(1)
    end

    assert(inf:close())
    assert(outf:close())
end