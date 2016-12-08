local TAG = "radio_group"

local radio_group = class("radio_group",
    function(...)
        return cc.Node:create()
    end)

function radio_group:create()
    local ret = radio_group.new()
    return ret
end

function radio_group:ctor()
    self.m_tItemList = {}
    self.m_callback = nil
    self.m_curSelectedItem = nil
end

--[[
the tConfig form:
local tConfig = {
    someKey = {
        path = {},
        data = someData,
    },
    ...
}
--]]
function radio_group:setItemListByConf(targetNode, rootNode, tConfig)
    local tItems = {}
    for k, v in pairs(tConfig) do
        local checkBox = ui_helper.getChildByData(rootNode, v.path)
        targetNode[k] = checkBox
        tItems[k] = {
            node = checkBox,
            data = v.data,
        }
        checkBox:addEventListener(
            function(box, eventType)
                if (eventType == ccui.CheckBoxEventType.selected) then
                    self:selectItem(k)
                end
            end)
    end
    self.m_tItemList = tItems
    self.m_curSelectedItem = nil
end

function radio_group:setItemList(tItems)
    tItems = tItems or {}
    self.m_tItemList = {}
    for k, v in pairs(tItems) do
        self.m_tItemList[k] = {node = v.node, data = v.data}
        self.m_tItemList[k].node:addEventListener(
        function(box, eventType)
            if (eventType == ccui.CheckBoxEventType.selected) then
                self:selectItem(k)
            end
        end)
    end
    self.m_curSelectedItem = nil
end

function radio_group:setCallback(callback)
    if (type(callback) == "function") then
        self.m_callback = callback
    else
        self.m_callback = nil
    end
end

function radio_group:selectItem(itemKey)
    local itemInfo = self.m_tItemList[itemKey]
    if itemInfo then
        self:unselectCurrentItem()

        local node = itemInfo.node
        node:setSelected(true)
        node:setEnabled(false)
        
        self.m_curSelectedItem = node
        
        if self.m_callback then
            self.m_callback(itemKey, node, itemInfo.data)
        end
    else
        print(TAG, "selectItem, unknown itemKey:", itemKey)
    end
end

function radio_group:unselectCurrentItem()
    if self.m_curSelectedItem then
        self.m_curSelectedItem:setSelected(false)
        self.m_curSelectedItem:setEnabled(true)
        self.m_curSelectedItem = nil
        -- audio_helper.playEffect("click_button")
    end
end

function radio_group:getSelectedItem()
    return self.m_curSelectedItem
end

return radio_group


