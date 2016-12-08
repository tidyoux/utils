local TAG = "timer"

local timer = class("timer",
    function(...)
        return cc.Node:create()
    end)

function timer:create(dt)
    local ret = timer.new(dt)
    return ret
end

function timer:ctor(dt)
    dt = tonumber(dt) or 0
    if (dt < 0) then
        dt = 0
    end
    self.m_dt = dt
    self.m_callback = nil
    self.m_running = false
    self.m_schedulerEntry = nil

    local onNodeEvent = function(event)
        if (event == "enter") then
            self:resume()
        elseif (event == "cleanup") then
            self:pause()
        end
    end
    -------
    self:registerScriptHandler(onNodeEvent)
end

function timer:setCallback(callback)
    if (type(callback) == "function") then
        self.m_callback = callback
    end
end

function timer:pause()
    if (self.m_schedulerEntry ~= nil) then
        self:getScheduler():unscheduleScriptEntry(self.m_schedulerEntry)
        self.m_schedulerEntry = nil
    end
    self.m_running = false
end

function timer:resume()
    if (self.m_schedulerEntry == nil) then
        local onSchedule = function(dt)
            if self:isRunning() then
                if (self.m_callback ~= nil) then
                    self.m_callback(dt)
                end
            end
        end
        self.m_schedulerEntry = self:getScheduler():scheduleScriptFunc(onSchedule, self.m_dt, false)
    end
    self.m_running = true
end

function timer:isRunning()
    return self.m_running
end

return timer


