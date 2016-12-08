local TAG = "http_requester"


local HTTP_SUCCESS_CODE = 200
local DEFAULT_MAX_TIME = 6

local http_requester = class("http_requester",
    function(...)
        return cc.Node:create()
    end)

function http_requester:create(method, url, isString)
    local ret = http_requester.new(method, url, isString)
    return ret
end

function http_requester:ctor(method, url, isString)
    method = tostring(method) or "POST"
    url = tostring(url) or ""

    self.m_httpRequest = nil
    self.m_callback = nil
    self.m_toBeSended = nil
    self.m_finishSended = false
    self.m_timer = nil
    self.m_timeoutCallback = nil
    self.m_isTimeout = false
    self.m_maxTime = DEFAULT_MAX_TIME

    local onNodeEvent = function(event)
        if (event == "enter") then
            if (self.m_httpRequest == nil) then
                local xhr = cc.XMLHttpRequest:new()
                if not(isString) then
                    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
                else
                    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
                end
                xhr:open(method, url)
                xhr:registerScriptHandler(
                    function()
                        if (self.m_httpRequest == nil) then
                            return
                        end
                        
                        if (xhr.status ~= HTTP_SUCCESS_CODE) then
                            print(TAG, "Error: http status:", xhr.statusText)
                            return
                        end

                        if not(self.m_isTimeout) then
                            self:clearTimer()

                            if self.m_callback then
                                local output = xhr.response
                                if not(isString) then
                                    output = json.decode(tostring(xhr.response))
                                end
                                self.m_callback(output)
                            end
                        end
                    end)
                
                if self.m_toBeSended then
                    self:doSender(xhr, self.m_toBeSended.data)
                    self.m_toBeSended = nil
                end
                self.m_httpRequest = xhr
            end
        elseif (event == "cleanup") then
            if (self.m_httpRequest ~= nil) then
                event_helper.hideWaiting()
                if not(self.m_finishSended) then
                    self.m_httpRequest:unregisterScriptHandler()
                end
                self.m_httpRequest = nil
            end
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function http_requester:setCallback(callback)
    if (type(callback) == "function") then
        self.m_callback = callback
    end
end

function http_requester:setTimeoutCallback(callback)
    if (type(callback) == "function") then
        self.m_timeoutCallback = callback
    end
end

function http_requester:setMaxTime(maxTime)
    self.m_maxTime = tonumber(maxTime) or DEFAULT_MAX_TIME
end

function http_requester:send(data)
    if self.m_httpRequest then
        self:doSender(self.m_httpRequest, data)
    else
        self.m_toBeSended = {
            data = data,
        }
    end
end

function http_requester:doSender(httpRequester, data)
    if httpRequester then
        httpRequester:send(data)
        event_helper.showWaiting()

        self.m_finishSended = true
        self.m_isTimeout = false

        self:clearTimer()
        if (self.m_maxTime > 0) then
            self.m_timer = ui_helper.createTimer(self.m_maxTime)
            self:addChild(self.m_timer)
    
            self.m_timer:setCallback(
                function()
                    self.m_isTimeout = true
                    self:clearTimer()
    
                    if (self.m_timeoutCallback ~= nil) then
                        self.m_timeoutCallback()
                    else
                        event_helper.addNotify("", nil, gdErrOp.errcode.timeout)
                    end
                end)
        end
    end
end

function http_requester:clearTimer()
    if self.m_timer then
        self.m_timer:removeFromParent()
        self.m_timer = nil
    end
end

return http_requester


