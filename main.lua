
-- /console scriptErrors 1

local playerGUID = UnitGUID("player")

local damageEvents = {
    SWING_DAMAGE = true,
    SPELL_DAMAGE = true,
}

local score = 0
local runallowed = 1
local visible = 1
local debugprint = 0

local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

frame:SetScript("OnEvent", function(self, event)
    self:OnEvent(event)
end)

local combatframe = CreateFrame("FRAME"); -- Need a frame to respond to events
combatframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatframe:SetScript("OnEvent", function(self, event)
    self:OnEvent(event, CombatLogGetCurrentEventInfo())
end)

local questframe = CreateFrame("FRAME"); -- Need a frame to respond to events
questframe:RegisterEvent("QUEST_TURNED_IN")
questframe:SetScript("OnEvent", function(self, event, questID, xpReward, moneyReward)
    self:OnEvent(event, questID, xpReward, moneyReward)
end)


SLASH_NEPNEPSCORE1 = "/nepnepscore"
SLASH_NEPNEPSCORE2 = "/nnscore"
SlashCmdList["NEPNEPSCORE"] = function(message)
    print(score)
end


SLASH_NEPNEPRESET1 = "/nepnepreset"
SLASH_NEPNEPRESET2 = "/nnreset"
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

SLASH_NEPNEPPRINTDEBUG1 = "/nepnepprintdebug"
SLASH_NEPNEPPRINTDEBUG2 = "/nndbgon"
SlashCmdList["NEPNEPPRINTDEBUG"] = function(message)
    debugprint = 1
    print("NepNep printing debug")
end

SLASH_NEPNEPSTOPPRINTDEBUG1 = "/nepnepstopprintdebug"
SLASH_NEPNEPSTOPPRINTDEBUG2 = "/nndbgoff"
SlashCmdList["NEPNEPSTOPPRINTDEBUG"] = function(message)
    debugprint = 0
    print("NepNep stopped printing debug")
end

--------------------------------------------------------------------------------------------------------------------------------
--                                                UTILITY FUNCTIONS
--------------------------------------------------------------------------------------------------------------------------------
local t = {}

local function isempty(s)
  return s == nil or s == ''
end


local function C(v)
    if v == nil then
        return "nil"
    else
        return v
    end
end

local function dprint(msg)
    if debugprint == 1 then
        print(msg)
    end
end

local function parseInt(s)
    if s == nil then
        return 0
    else 
        return tonumber(string.format("%.0f", s))
    end
end



local LARGE_NUMBER_SEPERATOR, DECIMAL_SEPERATOR = LARGE_NUMBER_SEPERATOR, DECIMAL_SEPERATOR
local function SeparateDigits(number, thousands, decimal)
    local symbol
    if type(number) == "string" then
        local value
        value, symbol = number:match("^([-%d.]+)(.*)")
        if not value then
            return number
        end
        number = tonumber(value)
    end
    local int = math.abs(math.floor(number))
    local rest = tostring(number):match("^[-%d.]+%.(%d+)") -- fuck off precision errors
    if number < 0 then
        t[#t+1] = "-"
    end
    if int < 1000 then
        t[#t+1] = int
    else
        local digits = math.log10(int)
        local segments = math.floor(digits / 3)
        t[#t+1] = math.floor(int / 1000^segments)
        for i = segments-1, 0, -1 do
            t[#t+1] = thousands or LARGE_NUMBER_SEPERATOR
            t[#t+1] = ("%03d"):format(math.floor(int / 1000^i) % 1000)
        end
    end
    if rest then
        t[#t+1] = decimal or DECIMAL_SEPERATOR
        t[#t+1] = rest
    end
    if symbol then
        t[#t+1] = symbol
    end
    local s = table.concat(t)
    wipe(t)
    return s
end


function NepNep_OnUpdate(self, elapsed)
    if isempty(score) then
        return
    end
    Meow:SetText(SeparateDigits(score," ",  ","))
end

function NepNep_OnMouseDown(self, button)
end


--------------------------------------------------------------------------------------------------------------------------------
--                                                PERSISTANCE MANAGEMENT
--------------------------------------------------------------------------------------------------------------------------------
function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" then
    -- Our saved variables are ready at this point. If there are none, both variables will set to nil.
    print("NepNep ADDON_LOADED")

    if isempty(NepNepScore) then
        --NepNepScore = score
    else
        score = NepNepScore
    end

    if isempty(NepNepEnabled) then
        --NepNepEnabled = runallowed
    else
        runallowed = NepNepEnabled
    end

    if isempty(NepNepVisible) then
        --NepNepVisible = visible
    else
        visible = NepNepVisible
    end

    if isempty(NepNepDebugPrint) then
        --NepNepDebugPrint = debugprint
    else
        debugprint = NepNepDebugPrint
    end


    elseif event == "PLAYER_LOGOUT" then
        NepNepScore = score
        NepNepEnabled = runallowed
        NepNepVisible = visible
    else
        print(event)
    end
end


--------------------------------------------------------------------------------------------------------------------------------
--                                                     EVENTS
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------
--                    Quest turned in
--------------------------------------------------------------
function questframe:OnEvent(event, questID, xpReward, moneyReward)
    print(event)
    print("Event : QUEST_TURNED_IN - QuestID :" .. C(questID).. " - xpReward :" .. C(xpReward) .. " - moneyReward :".. C(moneyReward))

end

--------------------------------------------------------------
--                   Combat management
--------------------------------------------------------------
function combatframe:OnEvent(event, ...)
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()

    if runallowed == 0 then
        return
    end

    local amount = 0


    if sourceGUID == playerGUID or destGUID == playerGUID  then
        print("Event " .. event)
    end

    -------------------------------
    --       Damage dealt
    -------------------------------
    if sourceGUID == playerGUID and damageEvents[event] then
        local damagedealt = 0
        local overkill = 0
        if event == "SWING_DAMAGE" then
            --dprint("[" .. timestamp .."] " .. "Player swing dealt " .. extraArg1 .. " with " .. extraArg2 .. " overkill")

            damagedealt = parseInt(extraArg1)
            local tmp = parseInt(extraArg2)
            if tmp >= 0 then
                overkill = tmp
            end
            dprint("[" .. timestamp .."] " .. "Player swing dealt " .. damagedealt .. " with " .. extraArg2 .. " overkill")
        end
        if event == "SPELL_DAMAGE" then
            --dprint("[" .. timestamp .."] " .. "Player spell dealt " .. extraArg4 .. " with " .. extraArg5 .. " overkill")

            damagedealt = parseInt(extraArg4)
            local tmp = parseInt(extraArg5)
            if tmp >= 0 then
                overkill = tmp
            end
            dprint("[" .. timestamp .."] " .. "Player spell dealt " .. extraArg4 .. " with " .. extraArg5 .. " overkill")
        end
        amount = damagedealt - overkill
        score = score + amount
    end
    
    -------------------------------
    --     Damage received
    -------------------------------
    if destGUID == playerGUID and damageEvents[event] then
        local damagedealt = 0
        local overkill = 0
        if event == "SWING_DAMAGE" then
            --dprint("[" .. timestamp .."] " .. "Player swing dealt " .. extraArg1 .. " with " .. extraArg2 .. " overkill")

            damagedealt = parseInt(extraArg1)
            local tmp = parseInt(extraArg2)
            if tmp >= 0 then
                overkill = tmp
            end
            dprint("[" .. timestamp .."] " .. "Ennemy swing dealt " .. damagedealt .. " with " .. extraArg2 .. " overkill")
        end
        if event == "SPELL_DAMAGE" then
            --dprint("[" .. timestamp .."] " .. "Player spell dealt " .. extraArg4 .. " with " .. extraArg5 .. " overkill")

            damagedealt = parseInt(extraArg4)
            local tmp = parseInt(extraArg5)
            if tmp >= 0 then
                overkill = tmp
            end
            dprint("[" .. timestamp .."] " .. "Ennemy spell dealt " .. extraArg4 .. " with " .. extraArg5 .. " overkill")
        end
        amount = damagedealt - overkill
        score = score - (amount * 2)
    end


    -------------------------------
    --     Heals received
    -------------------------------
    if destGUID == playerGUID and event == "SPELL_HEAL" then
        local healed = 0
        local overhealed = 0
        if sourceGUID == playerGUID then
            --dprint("[" .. timestamp .."] " .. "Player self healed for " .. extraArg4 .. " with " .. extraArg5 .. " overheal" )

            healed = parseInt(extraArg4)
            local tmp = parseInt(extraArg5)
            if tmp >= 0 then
                overhealed = tmp
            end
            dprint("[" .. timestamp .."] " .. "Player self healed for " .. healed .. " with " .. overhealed .. " overheal" )
        --[[else
            --dprint("[" .. timestamp .."] " .. sourceName .." healed player for " .. extraArg4 .. " with " .. extraArg5 .. " overheal" )
            
            healed = parseInt(extraArg4)
            local tmp = parseInt(extraArg5)
            if tmp >= 0 then
                overhealed = tmp
            end
            dprint("[" .. timestamp .."] " .. sourceName .." healed player for " .. healed .. " with " .. overhealed .. " overheal" )
        ]]--
        end

        amount = healed - overhealed
        score = score - (amount * 2)
    end


    -- extraArg1 = Falling
    if destGUID == playerGUID and event == "ENVIRONMENTAL_DAMAGE" then
        dprint("[" .. timestamp .."] " .. "ENVIRONMENT damaged " .. C(destName) .. " for " .. C(extraArg2))
        amount = extraArg2
        score = score - (amount * 2)
    end

    if destGUID == playerGUID and event == "UNIT_DIED" then
        dprint("[" .. timestamp .."] " .. "Player died")
        score = score - 1000000
    end


    if destGUID == playerGUID and event == "SPELL_AURA_APPLIED" then
        --dprint(C(sourceName) .. " applied aura on " .. C(destName) .. " of type " .. C(extraArg4) .. " for " .. C(extraArg5))

        if extraArg4 == "BUFF" then
            if isempty(extraArg5) then
                return
            else
                dprint(C(sourceName) .. " applied aura on " .. C(destName) .. " of type " .. C(extraArg4) .. " for " .. C(extraArg5))

                local auraAmount = parseInt(extraArg5)

                score = score - ( auraAmount * 2 )
            end
        end

    end
    if destGUID == playerGUID and event == "SPELL_AURA_REFRESH" then
        --dprint(C(sourceName) .. " refreshed aura on " .. C(destName) .. " of type " .. C(extraArg4) .. " for " .. C(extraArg5))
    end
    if destGUID == playerGUID and event == "SPELL_AURA_REMOVED" then
        --dprint(C(sourceName) .. " removed aura on " .. C(destName) .. " of type " .. C(extraArg4) .. " for " .. C(extraArg5))
    end
    if destGUID == playerGUID and event == "SPELL_AURA_STOLEN" then
        --dprint(C(sourceName) .. " stole aura on " .. C(destName) .. " of type " .. C(extraArg4) .. " for " .. C(extraArg5))
    end


    -------------------------------
    --           Kills 
    -------------------------------
    --[[
    if event == "PARTY_KILL" then
        if sourceGUID == playerGUID then
            dprint("[" .. timestamp .."] " .. "Player killed " .. C(destName))
        else
            dprint("[" .. timestamp .."] " .. C(sourceName) .. " killed " .. C(destName))
        end
    end
    ]]--

    -------------------------------
    --         No damage 
    -------------------------------
    --[[
    if destGUID == playerGUID then
        if event == "SWING_MISS" then
            dprint("[" .. timestamp .."] " .. "Ennemy swing missed. Type =" .. C(extraArg1) .. " - Amount " .. C(extraArg3) .. " overkill")
        end
        if event == "SPELL_ABSORBED" then
            dprint("[" .. timestamp .."] " .. "Ennemy spell was absorbed " .. C(extraArg4))
        end
    end
    ]]--

end

print("NepNep Loaded")