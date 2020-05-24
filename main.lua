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

SLASH_NEPNEPSCORE1 = "/nepnepscore"
SLASH_NEPNEPSCORE2 = "/nns"
SlashCmdList["NEPNEPSCORE"] = function(message)
    print(score)
end


SLASH_NEPNEPRESET1 = "/nepnepreset"
SLASH_NEPNEPRESET2 = "/nnr"
SlashCmdList["NEPNEPRESET"] = function(message)
    score = 0
end

print("NepNep  Loaded")

function NepNep_OnUpdate(self, elapsed)
    Meow:SetText(score)
end

function NepNep_OnMouseDown(self, button)
end

function f:OnEvent(event, ...)
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()

    if sourceGUID == playerGUID or destGUID == playerGUID  then
        print("Event " .. event)
    end

    if sourceGUID == playerGUID and damageEvents[event] then
        local amount = 0
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

end

function C(v)
    if v == nil then
        return "nil"
    else
        return v
    end
end


