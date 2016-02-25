local LINUX = "linux"
local WIN = "win"
local platform = LINUX

local need_the_filetype = function(tfiletype, filename)
    for k, v in pairs(tfiletype) do
        if (v == ".") or (v == ".*") then
            local name = string.sub(filename, 1, string.len(filename) - string.len(v))
            return true, name
        end

        if (string.sub(filename, -string.len(v)) == v) then
            local name = string.sub(filename, 1, string.len(filename) - string.len(v))
            return true, name
        end
    end
    return false
end

local function scan_dir_file(path, tfiletype, tfilename)
    path = path or "./"
    tfiletype = tfiletype or {"."}
    tfilename = tfilename or {}

    local cmd = "ls " .. path
    if (platform == WIN) then
        cmd = 'dir "' .. path .. '" /b'
    end
    local popen = io.popen(cmd)
    if popen then
        for filename in popen:lines() do
            if (string.find(filename, "%.")) then
                local isNeed, noTailName = need_the_filetype(tfiletype, filename)
                if isNeed then
                    tfilename[#tfilename + 1] = {path = path, name = filename, noTailName = noTailName}
                end
            else
                scan_dir_file(path .. filename .. "/", tfiletype, tfilename)
            end
        end
    end
    return tfilename
end

---------------------------------
-- interface
--
scan = {
    walk = function(path, tfiletype, tfilename)
        return scan_dir_file(path, tfiletype, tfilename)
    end,
    set_platform = function(p)
        platform = p or LINUX
    end,
}
