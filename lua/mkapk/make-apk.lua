--[[
根据channel-config导出各渠道debug包和release包，拷贝到外层目录，并重命名。

注意：1.需要修改GRADLE_HOMED为自己gradle的实际目录。
     2.需要修改GAME_VERSION为当前游戏版本号。
     3.GAME_GIT_VERSION为默认git版本号，当通过git命令获取版本号失败时会使用默认值。
     4.NEED_UPDATE_RES用于控制是否重新拷贝资源。
     5.NEED_COMPILE_NO_SDK用于控制是否重新编译base版本的包。

提示：打包apk的实现流程为，先打no_sdk包，期间会执行ndk-build，用于编译c++代码。然后打其他渠道包，期间
不会执行ndk-build，而是把no_sdk中的ndk-build的结果直接拷贝过来，
--]]


require "common.utils"
require "channel-config"

----------------------------------
-- config
--

local GRADLE_HOME = "/Users/haitao/workspace/android/gradle-2.4"
local GAME_VERSION = 1.0
local GAME_GIT_VERSION = 1

local NEED_UPDATE_RES = true
local NEED_COMPILE_NO_SDK = true

----------------------------------

local get_git_version = function()
    local tempFile = "temp_git_version.txt"

    local ret = GAME_GIT_VERSION
    local success = os.execute("git log --pretty=oneline > " .. tempFile)
    if success then
        local f = io.open(tempFile, "r")
        if f then
            local info = f:read("*line")
            f:close()
            os.execute("rm " .. tempFile)

            ret = string.sub(info, 1, 7)
        end
    end
    return ret
end

local mkapk_withlog = function(channelName)
    local cmd = "export PATH=$PATH:" .. GRADLE_HOME .. "/bin;"
    print("*** build " .. channelName .. ":")

    os.execute(cmd .. "cd ../" .. channelName .. ";gradle clean;gradle build")

    print("*** build " .. channelName .. " finish! ***")
    print("********************************************")
end

local mkapk = function()
    local base = "base"
    if NEED_COMPILE_NO_SDK then
        mkapk_withlog(base)
    end

    for k, v in pairs(tChannelConfig) do
        if (k ~= base) then
            os.execute("cp -r ../" .. base .. "/libs/armeabi/ ../" .. k .. "/libs/armeabi/")
            mkapk_withlog(k)
        end
    end
end

local cp_and_rename = function()
    local date = os.date("%Y") .. os.date("%m") .. os.date("%d") .. os.date("%H") .. os.date("%M") .. os.date("%S")
    local nameTail = GAME_VERSION .. "." .. get_git_version() .. "-" .. date .. ".apk"
    for k, v in pairs(tChannelConfig) do
        local fname = v.app .. "-" .. k .. "-" .. nameTail
        os.execute("cp ../" .. k .. "/build/outputs/apk/" .. k .. "-release.apk ../" .. fname)
    end
end

local make = function()
    -- copy assets
    if NEED_UPDATE_RES then
        require("copy-assets")
    end

    -- make apk
    call_with_log(mkapk, "mkapk")

    -- copy and rename
    call_with_log(cp_and_rename, "cp_and_rename")
end

make()


