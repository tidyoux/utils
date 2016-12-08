local TAG = "listener"

local listener = class("listener",
    function(...)
        return cc.Node:create()
    end)

function listener:create(eventName)
    local ret = listener.new(eventName)
    return ret
end

function listener:ctor(eventName)
    eventName = tostring(eventName) or "event-name"
    self.m_callback = nil
    self.m_pause = false

    local listener = nil
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local onNodeEvent = function(event)
        if (event == "enter") then
            if (listener == nil) then
                listener = cc.EventListenerCustom:create(eventName,
                    function(event)
                        if (self.m_pause == false) then
                            if (self.m_callback ~= nil) then
                                local bundleData = nil
                                if event and event.getBundleData then
                                    bundleData = event:getBundleData()
                                end
                                self.m_callback(eventName, bundleData)
                            end
                        end
                    end)
                dispatcher:addEventListenerWithFixedPriority(listener, 1)
            end
        elseif (event == "cleanup") then
            if (listener ~= nil) then
                dispatcher:removeEventListener(listener)
            end
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function listener:setCallback(callback)
    if (type(callback) == "function") then
        self.m_callback = callback
    end
end

function listener:pause()
    self.m_pause = true
end

function listener:resume()
    self.m_pause = false
end

function listener:isPause()
    return self.m_pause
end

return listener


