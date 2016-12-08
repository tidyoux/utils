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

function base_component:getMsgRequester()
	return ui_helper.getTemporaryMsgRequester()
end
