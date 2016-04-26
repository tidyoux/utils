--[[
复制美术资源、引擎lua代码、项目lua代码到assets目录，并luajit项目lua代码。
--]]


require "common.scan"
require "common.utils"
require "channel-config"

----------------------------------

local lua2luajit = function(out_dir)
    local in_dir = "../../../../src/"
    local cmd = "/usr/local/bin/luajit -b"
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

-----------------------------------
--
--

local clear = function()
    for k, v in pairs(tChannelConfig) do
        os.execute("rm -r ../" .. k .. "/assets/")
    end
end

local mkdir = function()
    for k, v in pairs(tChannelConfig) do
        os.execute("mkdir ../" .. k .. "/assets/")
        os.execute("mkdir ../" .. k .. "/assets/res/")
        os.execute("mkdir ../" .. k .. "/assets/src/")
    end
end

local cpcocos = function()
    for k, v in pairs(tChannelConfig) do
        os.execute("cp -r ../../../cocos2d-x/cocos/scripting/lua-bindings/script/ ../" .. k .. "/assets/")
    end
end

local cpres = function()
    for k, v in pairs(tChannelConfig) do
        os.execute("cp -r ../../../../res/ ../" .. k .. "/assets/res/")
    end
end

local cpsrc = function()
    local tempDir = "temp/"
    os.execute("mkdir " .. tempDir)

    lua2luajit(tempDir)

    for k, v in pairs(tChannelConfig) do
        os.execute("cp -r " .. tempDir .. " ../" .. k .. "/assets/src/")
    end
    
    os.execute("rm -r " .. tempDir)
end

local cpsdkres = function()
    for k, v in pairs(tChannelConfig) do
        if (type(v.assets) == "table") then
            for kk, vv in pairs(v.assets) do
                os.execute("cp -r ../../../sdk/android/" .. vv .. "/assets/ ../" .. k .. "/assets/")
            end
        end
    end
end

local copy = function()
    call_with_log(clear, "clear")
    call_with_log(mkdir, "mkdir")

    call_with_log(cpcocos, "cpcocos")
    call_with_log(cpres, "cpres")
    call_with_log(cpsrc, "cpsrc")
    call_with_log(cpsdkres, "cpsdkres")
end

copy()


