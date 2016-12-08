local TAG = "base_panel"

base_panel = class("base_panel",
	function()
		return ccui.Layout:create()
	end)

function base_panel:ctor(...)
	self.m_base_tArg = {...}
	self.m_base_rootNode = nil
	self.m_base_tNodeEventHandler = {}
	self.m_base_tAsyncImage = {}
	self.m_base_tResTobeReleased = {}
	self.m_base_isClosing = false
	self.m_base_tComponent = {}
	self:initBase()
end

function base_panel:initBase()
	self:setCascadeColorEnabled(true)
	self:setCascadeOpacityEnabled(true)
	self:registerScriptHandler(
    	function(evtName) -- enter exit cleanup
    		if (type(self.m_base_tNodeEventHandler) == "table") then
    			local handler = self.m_base_tNodeEventHandler[evtName]
    			if (type(handler) == "function") then
    				handler(self)
    			end
    		end
    	end)

	-- res release
	self:addNodeEventHandler("cleanup",
		function()
			for k, v in ipairs(self.m_base_tAsyncImage) do
				gdConst.director:getTextureCache():unbindImageAsync(v)
			end

			if self.m_base_tResTobeReleased.tUi then
				for k, v in ipairs(self.m_base_tResTobeReleased.tUi) do
					ui_res_manager.unloadByJson("uiextres", v)
				end
			end
			ui_res_manager.unloadByAllImages(self.m_base_tResTobeReleased.tImg)
			anim_res_manager.unload(self.m_base_tResTobeReleased.tAnim)
		end)
end

function base_panel:initByConf(tConf)
	if type(tConf) ~= "table" then
		printError("%s, initByConf, invalid conf.", TAG)
		return
	end

	self:setRootNode(tConf.rootNode, tConf.isDoLayout)

	if tConf.tMember then
		self:makeMemberRefs(tConf.tMember)
	end

	if tConf.tMenu then
		self:setTouchEndedByTable(tConf.tMenu)
	end

	if tConf.tListener then
		self:addEventListener(tConf.tListener)
	end

	if tConf.tComponent then
		self:addCustomComponent(tConf.tComponent)
	end
end

function base_panel:getArgs()
	return self.m_base_tArg
end

function base_panel:setRootNode(resFile, isDoLayout)
	local rootNode = ui_helper.createWidget(resFile, isDoLayout)
	self:addChild(rootNode)
	self.m_base_rootNode = rootNode
end

function base_panel:getRootNode()
	return self.m_base_rootNode
end

function base_panel:makeMemberRefs(tMember)
	if type(tMember) ~= "table" then
		printError("%s, makeMemberRefs, invalid tMember.", TAG)
		return
	end
	ui_helper.makeMemberRefs(self, self.m_base_rootNode, tMember)
end

function base_panel:setTouchEndedByTable(tMenu)
	if type(tMenu) ~= "table" then
		printError("%s, setTouchEndedByTable, invalid tMenu.", TAG)
		return
	end
	ui_helper.setTouchEndedByTable(self.m_base_rootNode, tMenu, self)
end

function base_panel:addEventListener(tListener)
	if type(tListener) ~= "table" then
		printError("%s, addEventListener, invalid tListener.", TAG)
		return
	end
	ui_helper.addEventListener(self, tListener)
end

function base_panel:addCustomComponent(tComponent)
	if type(tComponent) ~= "table" then
		printError("%s, addCustomComponent, invalid tComponent.", TAG)
		return
	end

	for k, v in pairs(tComponent) do
		local Component = require("component." .. v)
		if Component then
			local component = Component.new(self)
			self:addChild(component)
			self.m_base_tComponent[k] = component
		else
			printError("%s, addCustomComponent, invalid component path: %s.", TAG, tostring(v))
		end
	end
end

function base_panel:getCustomComponent(key)
	if type(key) ~= "string" then
		printError("%s, getCustomComponent, invalid component key", TAG)
		return
	end

	return self.m_base_tComponent[key]
end

function base_panel:addRadioGroup(tRadioGroup, callback, defaultItem)
	if type(tRadioGroup) ~= "table" then
		printError("%s, addRadioGroup, invalid tRadioGroup.", TAG)
		return
	end

	local radioGroup = ui_helper.createRadioGroup(self, self.m_base_rootNode, tRadioGroup)
	radioGroup:setCallback(callback)
	self:addChild(radioGroup)

	radioGroup:selectItem(defaultItem)
end

function base_panel:setNodeEventHandler(tHandler)
	if (type(tHandler) == "table") then
		for k, v in pairs(tHandler) do
			self.m_base_tNodeEventHandler[k] = v
		end
	end
end

function base_panel:addNodeEventHandler(evtName, handler)
	if (type(handler) == "function") then
		local oldHandler = self.m_base_tNodeEventHandler[evtName] or function(self) end
		self.m_base_tNodeEventHandler[evtName] = function(self)
			oldHandler(self)
			handler(self)
		end
	end
end

function base_panel:getNodeEventHandler()
	local ret = {}
	if self.m_base_tNodeEventHandler then
		for k, v in pairs(self.m_base_tNodeEventHandler) do
			ret[k] = v
		end
	end
	return ret
end

function base_panel:setDefaultNodeEventHandler(panelName)
	self:setNodeEventHandler({
		    enter = function()
		        print(panelName, "enter")
		        event_helper.dispatchEvent(gdEvent.ui_open, {panelName = panelName})
		    end,
		    exit = function()
		        print(panelName, "exit")
		        event_helper.dispatchEvent(gdEvent.ui_close, {panelName = panelName})
		    end,
		})
end

function base_panel:setExitActionFunc(func)
	self.m_exitActFunc = func
end

function base_panel:loadImageAsync(imgName, callback)
	if (type(imgName) == "string") and (string.len(imgName) > 0) then
		gdConst.director:getTextureCache():addImageAsync(imgName, callback)
		table.insert(self.m_base_tAsyncImage, imgName)
	end
end

function base_panel:setTobeReleasedRes(tUi, tAnim, tImg)
	if (type(tUi) == "table") then
		self.m_base_tResTobeReleased.tUi = tUi
	end

	if (type(tAnim) == "table") then
		self.m_base_tResTobeReleased.tAnim = tAnim
	end

	if (type(tImg) == "table") then
		self.m_base_tResTobeReleased.tImg = tImg
	end
end

function base_panel:getMsgRequester()
	return ui_helper.getTemporaryMsgRequester()
end

function base_panel:close()
	if self.m_base_isClosing then
		return
	end
	self.m_base_isClosing = true

	if self.m_exitActFunc then
		self.m_exitActFunc(function()
			self:removeFromParent()
		end)
	else
		self:runAction(cc.Sequence:create(
			cc.FadeOut:create(0.03),
			cc.CallFunc:create(
				function()
					self:removeFromParent()
				end)
			))
	end
end
