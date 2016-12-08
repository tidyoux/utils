--[[
骨骼动画资源加载管理。
--]]

local TAG = "anim_res_manager"

anim_res_manager = initTableSafely(anim_res_manager)


local textureCache = cc.Director:getInstance():getTextureCache()


local getAnimConfigByKey = function(animKey, errTag)
    errTag = errTag or ""
    local tConfig = gdSpine[animKey]
    if tConfig then
        return tConfig
    end
    printError("%s, %s, invalid anim key: %s", TAG, errTag, tostring(animKey))
    return nil
end

--------------------------------------------------------------
--------------------------------------------------------------
anim_res_manager.preload = function(tAnimKey, onProgress)
    tAnimKey = tAnimKey or {}
    local total = #tAnimKey
    if (total > 0) then
        local k = 1
        local tConfig = getAnimConfigByKey(tAnimKey[k], "preload")
        local function callback(pngCur, pngTotal)
            if (pngCur < pngTotal) then
                return
            end

            safelyCall(onProgress, k, total)

            k = k + 1
            if (k <= total) then
                tConfig = getAnimConfigByKey(tAnimKey[k], "preload")
                if tConfig then
                    ui_res_manager.preloadByAllImages(tConfig.res, callback)
                else
                    callback(0, 0)
                end
            end
        end

        if tConfig then
            ui_res_manager.preloadByAllImages(tConfig.res, callback)
        else
            safelyCall(onProgress, 0, 0)
        end
    else
        safelyCall(onProgress, 0, 0)
    end
end

anim_res_manager.unload = function(tAnimKey)
    tAnimKey = tAnimKey or {}
    for k, v in ipairs(tAnimKey) do
        local tConfig = getAnimConfigByKey(v, "unloadByKey")
        if tConfig then
            ui_res_manager.unloadByAllImages(tConfig.res)
        end
    end
end

anim_res_manager.unloadByNames = function(...)
    anim_res_manager.unload({...})
end

