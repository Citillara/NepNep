local playerGUID = UnitGUID("player")

local damageEvents = {
    SWING_DAMAGE = true,
    SPELL_DAMAGE = true,
}

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
    self:OnEvent(event, CombatLogGetCurrentEventInfo())
end)

local score = 0
local runallowed = 1
local visible = 1


local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out



local function isempty(s)
  return s == nil or s == ''
end


function frame:OnEvent(event, arg1)
 if event == "ADDON_LOADED" then
  -- Our saved variables are ready at this point. If there are none, both variables will set to nil.
    if isempty(NepNepScore) then
        NepNepScore = score
    else
        score = NepNepScore
    end

    if isempty(NepNepEnabled) then
        NepNepEnabled = runallowed
    else
        runallowed = NepNepEnabled
    end

    if isempty(NepNepVisible) then
        NepNepVisible = visible
    else
        visible = NepNepVisible
    end

 elseif event == "PLAYER_LOGOUT" then
    NepNepScore = score
    NepNepEnabled = runallowed
    NepNepVisible = visible
 end
end

frame:SetScript("OnEvent", frame.OnEvent);


SLASH_HAVEWEMET1 = "/hwm";
function SlashCmdList.HAVEWEMET(msg)
 print("HaveWeMet has met " .. HaveWeMetCount .. " characters.");
end

SLASH_NEPNEPSCORE1 = "/nepnepscore"
SLASH_NEPNEPSCORE2 = "/nns"
SlashCmdList["NEPNEPSCORE"] = function(message)
    print(score)
end


SLASH_NEPNEPRESET1 = "/nepnepreset"
SLASH_NEPNEPRESET2 = "/nnr"
SlashCmdList["NEPNEPRESET"] = function(message)
    score = 0
    NepNepScore = 0
    print("NepNep score reset")
end

SLASH_NEPNEPSTART1 = "/nepnepstart"
SLASH_NEPNEPSTART2 = "/nnstart"
SlashCmdList["NEPNEPSTART"] = function(message)
    runallowed = 1
    print("NepNep score started")
end

SLASH_NEPNEPSTOP1 = "/nepnepstop"
SLASH_NEPNEPSTOP2 = "/nnstop"
SlashCmdList["NEPNEPSTOP"] = function(message)
    runallowed = 0
    print("NepNep score stopped")
end

SLASH_NEPNEPSHOW1 = "/nepnepshow"
SLASH_NEPNEPSHOW2 = "/nnshow"
SlashCmdList["NEPNEPSHOW"] = function(message)
    visible = 1
    NepNep:Show()
end

SLASH_NEPNEPHIDE1 = "/nepnephide"
SLASH_NEPNEPHIDE2 = "/nnhide"
SlashCmdList["NEPNEPHIDE"] = function(message)
    visible = 0
    NepNep:Hide()
end

print("NepNep  Loaded")

function NepNep_OnUpdate(self, elapsed)
    Meow:SetText(score)
end

function NepNep_OnMouseDown(self, button)
end

function f:OnEvent(event, ...)
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()

    if runallowed == 0 then
        return
    end

    local amount = 0


    if sourceGUID == playerGUID or destGUID == playerGUID  then
        print("Event " .. event)
    end

    if sourceGUID == playerGUID and damageEvents[event] then
        if event == "SWING_DAMAGE" then
            print("Player swing dealt " .. extraArg1 .. " with " .. extraArg2 .. " overkill")
            amount = extraArg1 - extraArg2
        end
        if event == "SPELL_DAMAGE" then
            print("Player spell dealt " .. extraArg4 .. " with " .. extraArg5 .. " overkill")
            amount = extraArg4 - extraArg5
        end
        score = score + amount
    end


    if destGUID == playerGUID and damageEvents[event] then
        if event == "SWING_DAMAGE" then
            print("Ennemy swing dealt " .. extraArg1 .. " with " .. extraArg2 .. " overkill")
        end
        if event == "SPELL_DAMAGE" then
            print("Ennemy spell dealt " .. extraArg4 .. " with " .. extraArg5 .. " overkill")
        end
    end



    if destGUID == playerGUID and event == "SPELL_HEAL" then

        if sourceGUID == playerGUID then
            print("Player self healed for " .. extraArg4 .. " with " .. extraArg5 .. " overheal" )
        else
            print(sourceName .." healed player for " .. extraArg4 .. " with " .. extraArg5 .. " overheal" )
        end
    end

    if event == "PARTY_KILL" then
        if sourceGUID == playerGUID then
            print("Player killed " .. C(destName))
        else
            print(C(sourceName) .. " killed " .. C(destName))
        end
    end

    -- extraArg1 = Falling
    if destGUID == playerGUID and event == "ENVIRONMENTAL_DAMAGE" then
        print("ENVIRONMENT damaged " .. C(destName) .. " for " .. C(extraArg2)) 
    end

    if destGUID == playerGUID and event == "UNIT_DIED" then
        print("Player died")
    end


    --[[
if event == "SPELL_AURA_APPLIED" then
        print(C(sourceName) .. " applied aura on " .. C(destName))
    end
    if event == "SPELL_AURA_REFRESH" then
        print(C(sourceName) .. " refreshed aura on " .. C(destName))
    end
    if event == "SPELL_AURA_REMOVED" then
        print(C(sourceName) .. " removed aura on " .. C(destName))
    end
    if event == "SPELL_AURA_STOLEN" then
        print(C(sourceName) .. " stole aura on " .. C(destName))
    end
    ]]--

    if amount ~= 0 then
        NepNepScore = score
    end

end

function C(v)
    if v == nil then
        return "nil"
    else
        return v
    end
end
