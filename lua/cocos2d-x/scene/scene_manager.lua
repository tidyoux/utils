local TAG = "scene_manager"

scene_manager = initTableSafely(scene_manager)

scene_manager.preSceneConf = nil
scene_manager.curSceneConf = nil
scene_manager.nextSceneData = nil
scene_manager.create = function(sceneName, ...)
	sceneName = sceneName or ""

	if package.loaded["scene/" .. sceneName .. ".lua"] then
		local Scene = require("scene." .. sceneName)
		if Scene then
			local scene = Scene.new(...)
			scene:setName(sceneName)
			return scene
		end
	end
	printError("scene_manager.create, unknown scene name: %s", sceneName)
	return nil
end


scene_manager.change = function(sceneName, ...)
	if package.loaded["scene/" .. sceneName .. ".lua"] then
		scene_manager.doChange("loading_scene", sceneName, {...})
		scene_manager.nextSceneData = {sceneName, {...}}
	else
		printError("scene_manager.change, unknown scene name: %s", sceneName)
	end
end

scene_manager.push = function(sceneName, ...)
	local scene = scene_manager.create(sceneName, ...)
	if scene then
		scene_manager.setCurSceneConf(sceneName, ...)
		scene_manager.pushByScene(scene)
	end
end

scene_manager.doChange = function(sceneName, ...)
	local scene = scene_manager.create(sceneName, ...)
	if scene then
		scene_manager.setCurSceneConf(sceneName, ...)
		scene_manager.changeByScene(scene)
	end
end

scene_manager.getCurSceneName = function()
	local curScene = gdConst.director:getRunningScene()
	if curScene then
		return curScene:getName()
	end
	return ""
end

scene_manager.backToPreScene = function()
	local tConf = scene_manager.preSceneConf
	if tConf then
		scene_manager.change(tConf.name, unpack(tConf.tArgs))
	end
end

scene_manager.getPreSceneName = function()
	local tConf = scene_manager.preSceneConf
	if tConf then
		return tConf.name or ""
	end
	return ""
end

scene_manager.changeByScene = function(scene)
	if scene then
		local curScene = gdConst.director:getRunningScene()
		if curScene then
			gdConst.director:replaceScene(scene)
		else
			gdConst.director:runWithScene(scene)
		end

		-- test panel
		local testPanel = panel_manager.create("test", "test_panel")
		scene:addChild(testPanel, 1)
	end
end

scene_manager.pushByScene = function(scene)
	if scene then
		gdConst.director:pushScene(scene)
	end
end

scene_manager.pop = function()
	gdConst.director:popScene()
end

scene_manager.backToLogin = function()
	mj.net_disconnect()
	gdConst.gameDataMnger:clear()
    scene_manager.doChange("login_scene")
end

scene_manager.logout = function()
    data_helper.setIsFirstLogin(true)
    scene_manager.backToLogin()
end

scene_manager.exit = function()
	gdConst.director:endToLua()
    os.exit(0)
end

scene_manager.setCurSceneConf = function(sceneName, ...)
	if (sceneName ~= "loading_scene") then
		if scene_manager.curSceneConf then
			scene_manager.preSceneConf = scene_manager.curSceneConf
		end
		scene_manager.curSceneConf = {
			name = sceneName,
			tArgs = {...},
		}
	end
end
