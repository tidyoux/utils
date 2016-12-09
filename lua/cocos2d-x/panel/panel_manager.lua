local TAG = "panel_manager"

panel_manager = initTableSafely(panel_manager)

local tPanelStack = {}
local makePanelKey = function(folder, panelName)
	folder = folder or ""
	panelName = panelName or ""
	return folder .. "-" .. panelName
end

panel_manager.createByConf = function(panelConfPath, ...)
	local tPanelConf = require("config.panel." .. panelConfPath)
	if type(tPanelConf) ~= "table" then
		printError("%s, createByConf, invalid panelConfPath: %s", TAG, tostring(panelConfPath))
		return nil
	end

	local Panel = class(tPanelConf.name,
		function(...)
			return tPanelConf.super.new(...)
		end)
	local p = Panel.new(...)
	p:setName(tPanelConf.name)
	p:initByConf(tPanelConf)
	safelyCall(tPanelConf.init, p)
	return p
end

panel_manager.create = function(folder, panelName, ...)
	folder = folder or ""
	panelName = panelName or ""

	local Panel = nil
	if (string.len(folder) > 0) then
		Panel = require("panel." .. folder .. "." .. panelName)
	else
		Panel = require("panel." .. panelName)
	end

	if Panel then
		local ret = Panel.new(...)
		ret:setName(makePanelKey(folder, panelName))
		return ret
	end
	printError("panel_manager.create, unknown panel name:", panelName)
	return nil
end

panel_manager.addPanel = function(folder, panelName, ...)
	folder = folder or ""
	panelName = panelName or ""
	local panel = panel_manager.create(folder, panelName, ...)
	if panel then
		local currentScene = gdConst.director:getRunningScene()
		if currentScene then
			currentScene:addChild(panel, 1)
			table.insert(tPanelStack, {
					folder = folder,
					panelName = panelName,
				})
		end
	end
	return panel
end

panel_manager.removePanel = function(folder, panelName)
	local panel = panel_manager.getPanel(folder, panelName)
	if panel then
		panel:removeFromParent()
	end
end

panel_manager.getPanel = function(folder, panelName)
	folder = folder or ""
	panelName = panelName or ""
	local currentScene = gdConst.director:getRunningScene()
	if currentScene then
		local key = makePanelKey(folder, panelName)
		local panel = currentScene:getChildByName(key)
		return panel
	end
	return nil
end

panel_manager.getTopPanel = function(tester)
	if (type(tester) ~= "function") then
		tester = function(p) return true end
	end

	local curPanelStack = {}
	local ret = nil
	for k, v in ipairs(tPanelStack) do
		local panel = panel_manager.getPanel(v.folder, v.panelName)
		if panel and panel:isRunning() then
			if tester(panel) then
				ret = panel
			end

			table.insert(curPanelStack, {
					folder = v.folder,
					panelName = v.panelName,
				})
		end
	end
	tPanelStack = curPanelStack
	return ret
end

panel_manager.getPanelByNames = function( panelNames )
	if not panelNames or type(panelNames) ~= "table" then
		return nil
	end

	local ret = gdConst.director:getRunningScene()
	for k,v in ipairs(panelNames) do
		if ret then
			if type(v) == "number" then
				ret = ret:getChildByTag(v)
			elseif type(v) == "string" then
				ret = ret:getChildByName(v)
			end
		else
			return nil
		end
	end
	return ret
end

panel_manager.getPanelByTag = function(panelTag)
	local currentScene = gdConst.director:getRunningScene()
	if currentScene and type(panelTag) == "number" then
		local panel = currentScene:getChildByTag(panelTag)
		return panel
	end
	return nil
end

panel_manager.clearAllPanels = function()
	local currentScene = gdConst.director:getRunningScene()
	if currentScene then
		for k, v in ipairs(tPanelStack) do
			local key = makePanelKey(v.folder, v.panelName)
			local panel = currentScene:getChildByName(key)
			if panel then
				panel:removeFromParent()
			end
		end
	end
	tPanelStack = {}
end
