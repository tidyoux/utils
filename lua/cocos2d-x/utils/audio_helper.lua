local TAG = "audio_helper"

local AUDIO = ccexp.AudioEngine

audio_helper = initTableSafely(audio_helper)
local AH = audio_helper

AH.hasLoaded = false

AH.musicPaused = false
AH.effctPaused = false
AH.musicVolume = 1
AH.effectVolume = 1

AH.currentMusicId = -1
AH.tCurrentEffect = {}
AH.currentWordId = -1

--
-- common
--
AH.preload = function()
    if not(AH.hasLoaded) then
        for k, v in pairs(gdAudio.music) do
            AUDIO:preload(v)
        end
        AH.hasLoaded = true
    end
end

AH.updateVolume = function()
    if (AH.currentWordId >= 0) then
        if not(AH.musicPaused) then
            AH.setMusicVolume(0.5)
        end
        AH.setAllEffectVolume(0.6)
    else
        if not(AH.musicPaused) then
            AH.setMusicVolume(1)
        end
        AH.setAllEffectVolume(1)
    end
end

--
-- music
--
AH.playMusic = function(name)
    if not(data_helper.getIsMusicOn()) then
        return
    end

    local file = gdAudio.music[name]
    if file then
        return AH.playMusicByFile(file)
    end
    printError("%s, playMusic, unknown name: %s", TAG, name)
end

AH.playMusicByFile = function(music)
    AH.stopMusic()
	AH.currentMusicId = AUDIO:play2d(music, true, AH.musicVolume)
    AUDIO:setFinishCallback(AH.currentMusicId,
        function(id, path)
            if (id == AH.currentMusicId) then
				-- nothing to do.
            end
        end)
    if AH.musicPaused then
        AH.pauseMusic()
    end
end

AH.pauseMusic = function()
    if (AH.currentMusicId >= 0) then
        AH.setMusicVolume(0)
    end
    AH.musicPaused = true
end

AH.resumeMusic = function()
    if (AH.currentMusicId >= 0) then
        AH.setMusicVolume(1)
    end
    AH.musicPaused = false
end

AH.stopMusic = function()
    if (AH.currentMusicId >= 0) then
        AUDIO:stop(AH.currentMusicId)
        AH.currentMusicId = -1
    end
end

AH.setMusicVolume = function(volume)
    if (volume == AH.musicVolume) then
        return
    end

    volume = tonumber(volume) or 1
    AH.musicVolume = volume
    if (AH.currentMusicId >= 0) then
        AUDIO:setVolume(AH.currentMusicId, volume)
    end
end

AH.getMusicState = function()
    if (AH.currentMusicId >= 0) then
        return AUDIO:getState(AH.currentMusicId)
    end
    return -1
end

--
-- effect
--
AH.playEffect = function(name)
    if not(data_helper.getIsEffectOn()) then
        return
    end

    local file = gdAudio.effect[name]
    if file then
        return AH.playEffectByFile(file)
    end
    printError("%s, playEffect, unknown name: %s", TAG, name)
end

AH.playEffectByFile = function(effect)
    if not(AH.effctPaused) then
        local effectId = AUDIO:play2d(effect, false, AH.effectVolume)
        local count = AH.tCurrentEffect[effectId] or 0
        AH.tCurrentEffect[effectId] = count + 1

        AUDIO:setFinishCallback(effectId,
            function(id, path)
                local n = AH.tCurrentEffect[id]
                if n then
                    n = n - 1
                    if (n > 0) then
                        AH.tCurrentEffect[id] = n
                    else
                        AH.tCurrentEffect[id] = nil
                    end
                end
            end)
    end
end

AH.pauseEffect = function()
    AH.stopAllEffect()
    AH.stopCurrentWord()
    AH.effctPaused = true
end

AH.resumeEffect = function()
    AH.effctPaused = false
end

AH.stopAllEffect = function()
    for k, v in pairs(AH.tCurrentEffect) do
        if (k >= 0) and (v > 0) then
            AUDIO:stop(k)
        end
    end
    AH.tCurrentEffect = {}
end

AH.setAllEffectVolume = function(volume)
    if (volume == AH.effectVolume) then
        return
    end

    volume = tonumber(volume) or 1
    AH.effectVolume = volume
    for k, v in pairs(AH.tCurrentEffect) do
        if (k >= 0) and (v > 0) then
            AUDIO:setVolume(k, volume)
        end
    end
end

AH.unloadEffect = function(...)
    AH.unloadEffectByTable({...})
end

AH.unloadEffectByTable = function(tEffectNames)
    tEffectNames = tEffectNames or {}
    for k, v in pairs(tEffectNames) do
        AUDIO:uncache(v)
    end
end

--
-- word
--
AH.playWord = function(name)
    if not(data_helper.getIsEffectOn()) then
        return
    end

    local file = gdAudio.word[name]
    if file then
        return AH.playWordByFile(file)
    end
    printError("%s, playWord, unknown name: %s", TAG, name)
end

AH.playWordByFile = function(word)
    if not(AH.effctPaused) then
        AH.stopCurrentWord()
        AH.currentWordId = AUDIO:play2d(word)
        AH.updateVolume()
        AUDIO:setFinishCallback(AH.currentWordId,
            function(id, path)
                AH.currentWordId = -1
                AH.updateVolume()
            end)
    end
end

AH.stopCurrentWord = function()
    if (AH.currentWordId >= 0) then
        AUDIO:stop(AH.currentWordId)
        AH.currentWordId = -1
        AH.updateVolume()
    end
end
