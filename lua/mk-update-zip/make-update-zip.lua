loadfile("../client/tools/common/scan.lua")()

local PROJECT_DIR = "../client/"
local GIT_DIR_HEAD = "client/"

local FROM_GIT_VERSION = "5ab20cb"
local TO_GIT_VERSION = "251815b"
local GAME_VERSION = 1.09

------------------------------------------------------------
local getPathAndName = function(fullPath)
	local path, name = string.match(fullPath, "(.+/)(.+)")
	path = string.sub(path, string.len(GIT_DIR_HEAD))
	return {path = path, name = name,}
end

local getGITDiff = function(fromVersion, toVersion)
    local tempFile = "temp_git_diff.txt"

    local ret = {src = {}, res = {},}
    local success = os.execute("cd " .. PROJECT_DIR .."; git diff " .. fromVersion .. " " ..  toVersion .. " --stat ./ > " .. tempFile)
    if success then
        local f = io.open(PROJECT_DIR .. tempFile, "r")
        if f then
            local txt = f:read("*all")
            f:close()
            os.execute("rm " .. PROJECT_DIR .. tempFile)

            for fpath in string.gmatch(txt, "client.- ") do
            	if (string.find(fpath, GIT_DIR_HEAD .. "src/") == 1) then
            		table.insert(ret.src, getPathAndName(fpath))
            	elseif (string.find(fpath, GIT_DIR_HEAD .. "res/") == 1) then
            		table.insert(ret.res, getPathAndName(fpath))
            	end
            end
        end
    end
    return ret
end

local copyDiff = function(tPath, outPathMaker)
	for k, v in ipairs(tPath) do
		local from = PROJECT_DIR .. v.path .. v.name
		local to = outPathMaker(v.path)
		if not(os.execute("cd " .. to .. " >nul 2>nul")) then
			os.execute("mkdir -p " .. to)
		end
		os.execute("cp " .. from .. " " .. to)
	end
	os.execute("rm nul")
end

local doDiff = function(fromVersion, toVersion, dir)
	os.execute("mkdir " .. dir)

	local tDiff = getGITDiff(fromVersion, toVersion)
	copyDiff(tDiff.src,
		function(path)
			return string.gsub(dir .. path, "/src/", "/src-orgin/")
		end)
	copyDiff(tDiff.res,
		function(path)
			return dir .. path
		end)
end

local doExport = function(in_dir, out_dir)
	local cmd = "/usr/local/bin/luajit -b"
	if true then
		cmd = "cp"
	end
	
	local tPath = scan.walk(in_dir, {".lua"})
	for k, v in pairs(tPath) do
		local outPath = out_dir .. string.sub(v.path, string.len(in_dir) + 1)
		if not(os.execute("cd " .. outPath .. " >nul 2>nul")) then
			os.execute("mkdir -p " .. outPath)
		end
		os.execute(cmd .. " " .. v.path .. v.name .. " " .. outPath .. v.name)
	end
	os.execute("rm nul")
end

local doZip = function(dir, zipName)
	zipName = zipName .. ".zip"
	local cmd = "cd " .. dir .. ";zip -r"
	os.execute(cmd .. " " .. zipName .. " " .. "res/ " .. "src/")
end

----------------------------------
local make_zip = function()
	local dir = GAME_VERSION .. "/"

	print("> do git diff...")
	doDiff(FROM_GIT_VERSION, TO_GIT_VERSION, dir)

	print("> do export src...")
	doExport(dir .. "src-orgin/", dir .. "src/")

	print("> do zip...")
	doZip(dir, GAME_VERSION)
end

make_zip()






