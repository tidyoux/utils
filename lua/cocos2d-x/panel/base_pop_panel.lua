local TAG = "base_pop_panel"

base_pop_panel = class("base_pop_panel",
	function()
		return base_panel.new()
	end)

--[[-------------------------
-- style
--
@withBlackBackground, bool,
@isSwallowTouches, bool,
@withPopAction, bool,
@isAutoClose, bool,
@audio, string,
--]]
base_pop_panel.tPopStyle = {
	default = {
		withBlackBackground = true,
		isSwallowTouches = true,
	},
	autoClose = {
		isAutoClose = true,
	},
	autoCloseWithBlackBackground = {
		withBlackBackground = true,
		isAutoClose = true,
	},
}
--------------------------------------

function base_pop_panel:ctor(tStyle)
	self:setContentSize(gdConst.winSize)
	self:setAnchorPoint(0.5, 0.5)
	self:setPosition(gdConst.position.mid)
	self:initWithStyle(tStyle)
end

function base_pop_panel:initWithStyle(tStyle)
	tStyle = tStyle or base_pop_panel.tPopStyle.default
	if tStyle.withBlackBackground then
		self.m_pop_isPopPanel = true
		mj.PopBoard:show(self)
		self:addNodeEventHandler("cleanup",
		function()
			local panel = self:getTopPopPanel()
			if panel then
				mj.PopBoard:show(panel)
			else
				mj.PopBoard:hide()
			end
		end)
	end

	if tStyle.isSwallowTouches then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:setSwallowTouches(true)
	    listener:registerScriptHandler(
	        function(touch, event)
	            return true
	        end,
	        cc.Handler.EVENT_TOUCH_BEGAN)
	    local eventDispatcher = self:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
	end

	if tStyle.withPopAction then
		self:playPopAction()
	end

	if tStyle.isAutoClose then
		self:initAutoCloseTouchHandler()
	end

	if tStyle.audio then
		audio_helper.playEffect(tStyle.audio)
	end
end

function base_pop_panel:initAutoCloseTouchHandler()
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(
	function(touch, event)
		self.m_pop_isClick = ui_helper.isNodeVisible(self)
		return self.m_pop_isClick
	end,
	cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(
	function (touch, event)
		if (cc.pGetDistance(touch:getStartLocation(), touch:getLocation()) > 10) then
			self.m_pop_isClick = false
		end
	end,
	cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(
	function (touch, event)
		if self.m_pop_isClick then
			self.m_pop_isClick = false
			self:close()
		end
	end,
	cc.Handler.EVENT_TOUCH_ENDED)
	listener:registerScriptHandler(
	function(touch, event)
		if self.m_pop_isClick then
			self.m_pop_isClick = false
			self:close()
		end
	end,
	cc.Handler.EVENT_TOUCH_CANCELLED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function base_pop_panel:playPopAction()
	self:setScale(0.4)
	self:runAction(cc.Sequence:create(
	cc.EaseBackOut:create(cc.ScaleTo:create(0.1, 1)),
	cc.CallFunc:create(
	function()
		local handler = self.m_base_tNodeEventHandler.action_done
		if (type(handler) == "function") then
			handler(self)
		end
	end)
	))
end

function base_pop_panel:setDefaultNodeEventHandler(panelName)
	self:setNodeEventHandler({
		action_done = function()
			print(panelName, "action_done")
			event_helper.dispatchEvent(gdEvent.ui_open,{panelname = panelName})
		end,
		exit = function()
			print(panelName, "exit")
			event_helper.dispatchEvent(gdEvent.ui_close, {panelname = panelName})
		end,
	})
end

function base_pop_panel:getTopPopPanel()
	return panel_manager.getTopPanel(
		function(p)
			return p.m_pop_isPopPanel
		end)
end
