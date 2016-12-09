local TAG = "base_component"

base_component = class("base_component",
	function(...)
		return cc.Node:create()
	end)

function base_component:ctor(context)
	if not(context)then
		printError("%s, invalid context.", TAG)
		return
	end

	self.m_context = context
end

function base_component:getContext()
	return self.m_context
end

function base_component:getCustomComponent(key)
	return self.m_context:getCustomComponent(key)
end

function base_component:addTobeReleasedRes(tUi, tAnim, tImg)
	self.m_context:addTobeReleasedRes(tUi, tAnim, tImg)
end

function base_component:loadImageAsync(imgName, callback)
	self.m_context:loadImageAsync(imgName, callback)
end

function base_component:getMsgRequester()
	return ui_helper.getTemporaryMsgRequester()
end
