
--[[
ui相关的快捷方法。
--]]

local TAG = "ui_helper"

ui_helper = initTableSafely(ui_helper)

-----------------------------------------------
-- visible
--
ui_helper.isNodeVisible = function(node)
    if not(node) then
        return false
    end

    local parent = node
    while parent do
        if not(parent:isVisible()) then
            return false
        end
        parent = parent:getParent()
    end
    return true
end

-----------------------------------------------
-- Touch
--
ui_helper.isTouchSelf = function(node, touch)
    if not(ui_helper.isNodeVisible(node)) then
        return false
    end

    if node and node.getParent and node:getParent() then
        return cc.rectContainsPoint(node:getBoundingBox(), node:getParent():convertTouchToNodeSpace(touch))
    end
    return false
end

ui_helper.isTouchInRect = function(baseNode, touch, rect)
    if not(ui_helper.isNodeVisible(baseNode)) then
        return false
    end

    if baseNode and touch and rect then
        return cc.rectContainsPoint(rect, baseNode:convertTouchToNodeSpace(touch))
    end
    return false
end

-----------------------------------------------
-- cocos studio
--
ui_helper.createWidget = function(confFile, isDoLayout)
    isDoLayout = (isDoLayout == nil) or (isDoLayout == true)
    if (type(confFile) == "string") and (string.len(confFile) > 0) then
        local ret = cc.CSLoader:createNode(confFile)
        if isDoLayout and ret then
            ret:setContentSize(gdConst.winSize)
            ccui.Helper:doLayout(ret)
        end
        return ret
    end
    printError("%s, createWidget, invalid ui conf file: %s", TAG, tostring(confFile))
    return nil
end

ui_helper.getChildByData = function(rootNode, tData)
    tData = tData or {}
    if (type(tData) ~= "table") then
        printError("%s, getChildByData, invalid names: %s", TAG, type(tData))
        return nil
    end

    local ret = rootNode
    for k, v in ipairs(tData) do
        if (ret == nil) then
            return nil
        end

        if (type(v) == "number") then
            if (type(ret.getChildByTag) == "function") then
                ret = ret:getChildByTag(v)
            end
        elseif (type(v) == "string") then
            if (type(ret.getChildByName) == "function") then
                ret = ret:getChildByName(v)
            end
        else
            printError("%s, getChildByData Err Type: %s", TAG, type(v))
        end
    end
    return ret
end

ui_helper.foreachChild = function(rootNode, tNodePath, handler)
    tNodePath = tNodePath or {}
    if (type(tNodePath) ~= "table") then
        printError("%s, foreachChild, invalid paths: %s", TAG, type(tNodePath))
        return
    end

    if (type(handler) == "function") then
        for k, v in pairs(tNodePath) do
            local node = ui_helper.getChildByData(rootNode, v)
            if node then
                handler(node, k)
            end
        end
    end
end

ui_helper.makeMemberRefs = function(targetNode, rootNode, tConfig)
    if targetNode and rootNode and (type(tConfig) == "table") then
        ui_helper.foreachChild(rootNode, tConfig,
            function(node, key)
                targetNode[key] = node
            end)
    end
end

ui_helper.createImage = function(file)
    local ret = ccui.ImageView:create(file)
    return ret
end

ui_helper.createArmature = function(tConfig)
    if (type(tConfig) == "table") then
        if (type(tConfig.name) == "string") then
            if tConfig.file and (type(tConfig.file) == "string") then
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(tConfig.file)
            end
            local ret = ccs.Armature:create(tConfig.name)
            return ret
        end
        printError("%s, createArmature, invalid name: %s", TAG, tostring(name))
        return nil
    end
    printError("%s, createArmature, invalid tConfig: %s", TAG, tostring(tConfig))
    return nil
end

ui_helper.createSpine = function(tConfig, scale)
    if (type(tConfig) == "table") then
        scale = tonumber(scale) or 1
        local ret = sp.SkeletonAnimation:create(tConfig.json, tConfig.atlas, scale)
        if not(ret) then
            printError("%s, createSpine, invalid config: %s, %s", TAG, tostring(tConfig.json), tostring(tConfig.atlas))
        end
        return ret
    end
    printError("%s, createSpine, invalid tConfig: %s", TAG, tostring(tConfig))
    return nil
end

-----------------------------------------------
-- node
--
ui_helper.resetParent = function(node, parent)
    if node and parent then
        node:retain()
        node:removeFromParent(false)
        parent:addChild(node)
        node:release()
        return
    end
    printError("%s, resetParent, node: %s, parent: %s", TAG, type(node), type(parent))
end

ui_helper.getBorderNode = function(w, h)
    w = tonumber(w) or 1
    h = tonumber(h) or 1
    local pts = {cc.p(0, 0), cc.p(w, 0), cc.p(w, h), cc.p(0, h)}
    local ret = cc.DrawNode:create()
    ret:drawPolygon(pts, #pts, cc.c4f(0, 0, 0, 0), 1, cc.c4f(1, 0, 0, 1))
    return ret
end

ui_helper.createClippingNode = function(stencilImgName, alphaThreshold)
    alphaThreshold = tonumber(alphaThreshold) or 0.01
    if (type(stencilImgName) == "string") and (string.len(stencilImgName) > 0) then
        local stencil = cc.Sprite:create(stencilImgName)
        local ret = cc.ClippingNode:create(stencil)
        ret:setAlphaThreshold(alphaThreshold)
        return ret
    end
    printError("%s, createClippingNode, invalid stencilImgName: %s", TAG, tostring(stencilImgName))
    return nil
end

-----------------------------------------------
-- menu / button
--

local callTouchHandler = function(handleFunc, sender, targetNode, tag)
    if (type(handleFunc) == "function") then
		-- if (type(tag) == "string") then
		-- 	local name = string.match(tag, "%[(.-)%]")
		-- 	if name then
		-- 		if (name ~= "silence") then
		-- 			audio_helper.playEffect(name)
		-- 		end
		-- 	else
		-- 		audio_helper.playEffect("click_button")
		-- 	end
		-- else
		-- 	audio_helper.playEffect("click_button")
		-- end

		if targetNode then
			handleFunc(targetNode, sender)
		else
			handleFunc(sender)
		end
	end
end

--[[
给ndoe绑定eventType 事件回调函数为handleFunc
@pram node               需要绑定事件的节点
@pram eventType          绑定的事件的类型
@pram handleFuc          回调函数
@pram targetNode         如果handleFuc 为成员函数调用回调函数时需传入（self）
--]]
local setTouchEventHandler = function(node, eventType, handleFunc, targetNode, tag)
	if node and node.addTouchEventListener then
		node:addTouchEventListener(
		function(sender, evtType)
		if (evtType == eventType) then
			callTouchHandler(handleFunc, sender, targetNode, tag)
		end
	end)
end
end

local bindTouchEventListener = function(node, tHandler)
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(
	function(touch, event)
		local isTouched = ui_helper.isTouchSelf(node, touch)
		if isTouched then
			local hander = tHandler.onBegan
			if hander then
				hander(touch)
			end
		end
		return isTouched
	end,
	cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(
	function(touch, event)
		local hander = tHandler.onEnded
		if hander then
			hander(touch)
		end
	end,
	cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = gdConst.director:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

ui_helper.setTouchBegan = function(rootNode, tPath, handleFunc, targetNode, tag)
	local node = ui_helper.getChildByData(rootNode, tPath)
	if node then
		if node.addTouchEventListener then
			setTouchEventHandler(node, ccui.TouchEventType.began, handleFunc, targetNode, tag)
		else
			bindTouchEventListener(node, {
				onBegan = function()
					callTouchHandler(handleFunc, node, targetNode, tag)
				end,
			})
		end
		return
	end
	printError("%s, setTouchBegan, rootNode: %s, tPath: %s, tag: %s", TAG, type(rootNode), type(tPath), tostring(tag))
end

ui_helper.setTouchBeganByTable = function(rootNode, tConfig, targetNode)
	if rootNode and (type(tConfig) == "table") and targetNode then
		for k, v in pairs(tConfig) do
			local funcName, tPath = next(v)
			if (type(tPath[1]) == "table") then
				ui_helper.setTouchBegan(rootNode, tPath[1], targetNode[funcName], targetNode, tPath[2])
			else
				ui_helper.setTouchBegan(rootNode, tPath, targetNode[funcName], targetNode, funcName)
			end
		end
	end
end

ui_helper.setTouchEnded = function(rootNode, tPath, handleFunc, targetNode, tag)
	local node = ui_helper.getChildByData(rootNode, tPath)
	if node then
		if node.addTouchEventListener then
			setTouchEventHandler(node, ccui.TouchEventType.ended, handleFunc, targetNode, tag)
		else
			bindTouchEventListener(node, {
				onEnded = function()
					callTouchHandler(handleFunc, node, targetNode, tag)
				end,
			})
		end
		return
	end
	printError("%s, setTouchEnded, rootNode: %s, tPath: %s, tag: %s", TAG, type(rootNode), type(tPath), tostring(tag))
end

ui_helper.setTouchEndedByTable = function(rootNode, tConfig, targetNode)
	if rootNode and (type(tConfig) == "table") and targetNode then
		for k, v in pairs(tConfig) do
			local funcName, tPath = next(v)
			if (type(tPath[1]) == "table") then
				ui_helper.setTouchEnded(rootNode, tPath[1], targetNode[funcName], targetNode, tPath[2])
			else
				ui_helper.setTouchEnded(rootNode, tPath, targetNode[funcName], targetNode, funcName)
			end
		end
	end
end

----------------------------------------------
-- layout
--
ui_helper.getCenterBySize = function(size)
	size = size or {width = 0, height = 0,}
	local w = tonumber(size.width) or 0
	local h = tonumber(size.height) or 0
	return cc.p(w/2, h/2)
end

-----------------------------------------------
-- action
--
ui_helper.delayRun = function(node, dt, func)
	dt = tonumber(dt) or 0.1
	if (node and node.runAction and (type(func) == "function")) then
		return node:runAction(cc.Sequence:create({
			cc.DelayTime:create(dt),
			cc.CallFunc:create(
			function()
				return func(dt)
			end),
		}))
	end
	return nil
end

----------------------------------------------
-- ui-action/armature/spine-anim
--
ui_helper.playArmature = function(parentNode, armConf, animKey, evtHandler, touchEnabled)
    if not(parentNode) then
        printError("%s, playArmature, parentNode is nil!", TAG)
    end

    animKey = animKey or 0
    local animNode = ui_helper.createArmature(armConf)
    if animNode then
        animNode:setPosition(ui_helper.getCenterBySize(parentNode:getContentSize()))
        parentNode:addChild(animNode)

		ui_helper.armaturePlayAnimOnce(animNode, animKey, evtHandler)

        if evtHandler and touchEnabled then
            if touchEnabled then
                local listener = cc.EventListenerTouchOneByOne:create()
                listener:setSwallowTouches(true)
                listener:registerScriptHandler(
                    function(touch, event)
                        evtHandler(animNode, "touch")
                        return true
                    end,
                    cc.Handler.EVENT_TOUCH_BEGAN)
                local eventDispatcher = gdConst.director:getEventDispatcher()
                eventDispatcher:addEventListenerWithSceneGraphPriority(listener, animNode)
            end
        end
    end
    return animNode
end

ui_helper.armaturePlayAnim = function(armature, animKey)
	local anim = armature:getAnimation()
	if (type(animKey) == "number") then
		anim:playWithIndex(animKey)
	else
		anim:play(tostring(animKey), -1, 1)
	end
end

ui_helper.armaturePlayAnimOnce = function(armature, animKey, evtHandler, frameHandler)
	local anim = armature:getAnimation()
	local animData = anim:getAnimationData()
	if animData then
		if (type(animKey) == "number") then
			anim:playWithIndex(animKey, -1, 0)
		else
			if animData:getMovement(animKey) then
				anim:play(tostring(animKey), -1, 0)
			else
				anim:play("vicy", -1, 0)
			end
		end

		if evtHandler then
			anim:setMovementEventCallFunc(function(armature, movementType, movementEvent)
				-- print(TAG, "212111", movementType, movementEvent)
				if (movementType ~= ccs.MovementEventType.start) then
					evtHandler(armature, anim, movementType, movementEvent)
				end
			end)
		end
		if frameHandler then
			anim:setFrameEventCallFunc(function(bone, evtName, originFrameIndex, currentFrameIndex)
				frameHandler(armature, bone, evtName, originFrameIndex, currentFrameIndex)
			end)
		end
	end
end

ui_helper.armatureTryPlayAnim = function(armature, animKeyGetter, maxTimes)
	local maxTimes = tonumber(maxTimes) or 3
	if armature and (type(animKeyGetter) == "function") then
		local anim = armature:getAnimation()
		if anim then
			local animData = anim:getAnimationData()
			if animData then
				local tryTimes = 1
				while (tryTimes <= maxTimes) do
					local animKey = animKeyGetter(tryTimes)
					if animKey and animData:getMovement(animKey) then
						anim:play(animKey)
						break
					end
					tryTimes = tryTimes + 1
				end
			end
		end
	end
end

ui_helper.playUIAction = function(targetNode, actionFile, actionName, isLoop, frameEvtHandler, lastEvtHandler)
	if not(targetNode) then
		printError("%s, playUIAction, targetNode is nil!", TAG)
		return nil
	end

	if (type(actionFile) ~= "string") then
		printError("%s, playUIAction, invalid actionFile: %s", TAG, tostring(actionFile))
		return nil
	end

	local action = cc.CSLoader:createTimeline(actionFile)
	if action then
		isLoop = checkbool(isLoop)
		targetNode:runAction(action)

		if (type(frameEvtHandler) == "function") then
			action:setFrameEventCallFunc(
			function(frame)
				frameEvtHandler(frame, action)
			end)
		end

		if (type(lastEvtHandler) == "function") then
			action:setLastFrameCallFunc(
			function()
				lastEvtHandler(action)
			end)
		end

		if (type(actionName) == "string") and (string.len(actionName) > 0) then
			action:play(actionName, isLoop)
		end
	end
	return action
end

ui_helper.playSpine = function(parentNode, tConfig, animName, isLoop, completeHandler, evtHandler, endHandler)
	if not(parentNode) then
		printError("%s, playSpine, parentNode is nil!", TAG)
		return nil
	end

	local spineNode = ui_helper.createSpine(tConfig)
	if spineNode then
		spineNode:setPosition(ui_helper.getCenterBySize(parentNode:getContentSize()))
		parentNode:addChild(spineNode)

		ui_helper.playSpineByAnimName(spineNode, animName, isLoop, completeHandler, evtHandler, endHandler)
	end
	return spineNode
end

ui_helper.playSpineByAnimName = function(spineNode, animName, isLoop, completeHandler, evtHandler, endHandler)
	if spineNode then
		isLoop = checkbool(isLoop)
		spineNode:setAnimation(0, animName, isLoop)

		if completeHandler then
			spineNode:registerSpineEventHandler(completeHandler, sp.EventType.ANIMATION_COMPLETE)
		end

		if evtHandler then
			spineNode:registerSpineEventHandler(evtHandler, sp.EventType.ANIMATION_EVENT)
		end

		if endHandler then
			spineNode:registerSpineEventHandler(endHandler, sp.EventType.ANIMATION_END)
		end
	end
end


----------------------------------------------
-- ext
--
ui_helper.createTimer = function(dt)
	local Timer = require("ext/timer.lua")
	return Timer:create(dt)
end

ui_helper.createUpdater = function(n)
	local Updater = require("ext/updater.lua")
	return Updater:create(n)
end

ui_helper.createDelayRefresher = function()
	local Refresher = require("ext/delay_refresher.lua")
	return Refresher:create()
end

ui_helper.createListener = function(eventName)
	local Listener = require("ext/listener.lua")
	return Listener:create(eventName)
end

ui_helper.addEventListener = function(targetNode, tConfig)
	if targetNode and (type(tConfig) == "table") then
		for k, v in pairs(tConfig) do
			local funcName, eventName = next(v)
			local func = targetNode[funcName]
			if func and (type(func) == "function") then
				local listener = ui_helper.createListener(eventName)
				listener:setCallback(
				function(evtName, evtData)
					targetNode[funcName](targetNode, evtName, evtData)
				end)
				targetNode:addChild(listener)
			else
				printError("%s, addEventListener, invalid funcName: %s", TAG, tostring(funcName))
			end
		end
	end
end

ui_helper.createHttpRequester = function(method, url, isString)
	local HttpRequester = require("ext/http_requester.lua")
	local ret = HttpRequester:create(method, url, isString)
	return ret
end

ui_helper.createRadioGroup = function(targetNode, rootNode, tConfig)
	local RadioGroup = require("ext/radio_group.lua")
	local ret = RadioGroup:create()
	if targetNode and rootNode and (type(tConfig) == "table") then
		ret:setItemListByConf(targetNode, rootNode, tConfig)
	end
	return ret
end

ui_helper.createRadioGroupByOtherBar = function(barTable)
	local RadioGroup = require("ext/radio_group.lua")
	local ret = RadioGroup:create()
	if type(barTable) == "table" then
		ret:setItemList(barTable)
	end
	return ret
end

