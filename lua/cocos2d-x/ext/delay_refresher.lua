local TAG = "delay_refresher"

local delay_refresher = class("delay_refresher",
    function(...)
        return cc.Node:create()
    end)

function delay_refresher:create()
    local ret = delay_refresher.new()
    return ret
end

function delay_refresher:ctor()
    self.m_needRefresh = false
    self.m_callback = nil

    local onTimer = function(dt)
        if self.m_needRefresh then
            self.m_needRefresh = false
            if self.m_callback then
                self.m_callback()
            end
        end
    end
    
    local timer = ui_helper.createTimer(0.1)
    timer:setCallback(onTimer)
    self:addChild(timer)
end

function delay_refresher:setCallback(callback)
    if (type(callback) == "function") then
        self.m_callback = callback
    end
end

function delay_refresher:refresh()
    self.m_needRefresh = true
end

return delay_refresher


