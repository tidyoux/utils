--[[
ui资源加载管理。
--]]

local TAG = "ui_res_manager"

local CSB_TAIL = ".csb"

ui_res_manager = initTableSafely(ui_res_manager)

local textureCache = cc.Director:getInstance():getTextureCache()

local getAllImagesByModuleNames = function(tModuleName, errTag)
    errTag = tostring(errTag)

    local ret = {}
    local tRes = {}
    for k, v in ipairs(tModuleName) do
        local t = gdUIResConf[v]
        if not(t) then
            printError("%s, %s, invalid module name: %s", TAG, errTag, v)
            return ret
        end
        table.insert(tRes, t)
    end

    for k, v in ipairs(tRes) do
        for kk, vv in pairs(v) do
            for kkk, vvv in ipairs(vv) do
                table.insert(ret, vvv)
            end
        end
    end
    return ret
end

local getAllImagesByJsonName = function(moduleName, jsonName, errTag)
    errTag = tostring(errTag)

    local ret = {}
    local tRes = gdUIResConf[moduleName]
    if not(tRes) then
        printError("%s, %s, invalid module name: %s", TAG, errTag, v)
        return ret
    end

    jsonName = tostring(jsonName)
    local pos = string.find(jsonName, "%" .. CSB_TAIL)
    if pos then
        jsonName = string.sub(jsonName, 1, pos - 1)
    end
    local tModuleJson = tRes[jsonName]
    if tModuleJson then
        for k, v in ipairs(tModuleJson) do
            table.insert(ret, v)
        end
    end

    return ret
end

--------------------------------------------------------------
--------------------------------------------------------------
ui_res_manager.preload = function(tModuleName, onProgress)
    tModuleName = tModuleName or {}
    local tAllImg = getAllImagesByModuleNames(tModuleName, "preload")
    ui_res_manager.preloadByAllImages(tAllImg, onProgress)
end

ui_res_manager.preloadByJson = function(moduleName, jsonName, onProgress)
    moduleName = moduleName or "uiextres"
    jsonName = jsonName or ""
    local tAllImg = getAllImagesByJsonName(moduleName, jsonName, "preloadByJson")
    ui_res_manager.preloadByAllImages(tAllImg, onProgress)
end

ui_res_manager.preloadByAllImages = function(tAllImg, onProgress)
    local total = #tAllImg
    if (total > 0) then
        local k = 1
        local function callback()
            safelyCall(onProgress, k, total)

            k = k + 1
            if (k <= total) then
                if textureCache:getTextureForKey(tAllImg[k]) == nil then
                    textureCache:addImageAsync(tAllImg[k], callback)
                else
                    callback()
                end
            end
        end
        textureCache:addImageAsync(tAllImg[k], callback)
    else
        safelyCall(onProgress, 0, 0)
    end
end

ui_res_manager.unload = function(tModuleName)
    tModuleName = tModuleName or {}
    local tAllImg = getAllImagesByModuleNames(tModuleName)
    ui_res_manager.unloadByAllImages(tAllImg)
end

ui_res_manager.unloadByJson = function(moduleName, jsonName)
    moduleName = moduleName or "uiextres"
    jsonName = jsonName or ""
    local tAllImg = getAllImagesByJsonName(moduleName, jsonName, "unloadByJson")
    ui_res_manager.unloadByAllImages(tAllImg)
end

ui_res_manager.unloadByAllImages = function(tAllImg)
    tAllImg = tAllImg or {}
    for k, v in ipairs(tAllImg) do
        textureCache:removeTextureForKey(v)
    end
end
