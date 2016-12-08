local TAG = "base_scene"

base_scene = class("base_scene",
	function()
		return cc.Scene:create()
	end)

function base_scene:ctor()
	self.m_tNodeEventHandler = {}

    self:registerScriptHandler(
    	function(evtName) -- enter exit cleanup
    		if (type(self.m_tNodeEventHandler) == "table") then
    			local handler = self.m_tNodeEventHandler[evtName]
    			if (type(handler) == "function") then
    				handler(self)
    			end
    		end
    	end)
end

function base_scene:setNodeEventHandler(tHandler)
	if (type(tHandler) == "table") then
		for k, v in pairs(tHandler) do
			self.m_tNodeEventHandler[k] = v
		end
	end
end

function base_scene:setDefaultNodeEventHandler(sceneName)
	self:setNodeEventHandler({
		    enter = function()
		        print(sceneName, "enter")
		        event_helper.dispatchEvent(gdEvent.ui_open, {sceneName = sceneName})
		    end,
		    exit = function()
		        print(sceneName, "exit")
		        event_helper.dispatchEvent(gdEvent.ui_close, {sceneName = sceneName})
		    end,
		})
end
