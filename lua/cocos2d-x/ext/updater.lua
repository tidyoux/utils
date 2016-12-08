local TAG = "updater"

local STATE = {
    READY = 0,
    RUNNING = 1,
}

local updater = class("updater",
    function(...)
        return cc.Node:create()
    end)

function updater:create(n)
    local ret = updater.new(n)
    return ret
end

function updater:ctor(n)
    n = checkint(n)
    if (n < 0) then
        n = 0
    end
    self.m_count = 0
    self.m_callback = nil
    self.m_state = STATE.READY

    local onTimer = function(dt)
        if self:isRunning() then
             if (n == 0) then
                 self:stop()
                 return
             end

             self.m_count = self.m_count + 1
             if (self.m_callback ~= nil) then
                 self.m_callback(self.m_count)
             end
             
             if (self.m_count >= n) then
                 self:stop()
             end
         end
    end
    
    local timer = ui_helper.createTimer()
    timer:setCallback(onTimer)
    self:addChild(timer)
end

function updater:setCallback(callback)
    if (type(callback) == "function") then
        self.m_callback = callback
    end
end

function updater:start()
    self.m_count = 0
    self.m_state = STATE.RUNNING
end

function updater:stop()
    self.m_count = 0
    self.m_state = STATE.READY
end

function updater:isRunning()
    return (self.m_state == STATE.RUNNING)
end

return updater


