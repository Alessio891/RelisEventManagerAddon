RelisEventManager = LibStub("AceAddon-3.0"):NewAddon("RelisEventManager", "AceConsole-3.0", "AceComm-3.0")

RelisEventManagerDB = RelisEventManagerDB or {}

RelisEventManagerDB.current_event_data = RelisEventManagerDB.current_event_data or {}
RelisEventManagerDB.discordUserMap = RelisEventManagerDB.discordUserMap or {}
RelisEventManagerDB.convertToRaid = true

RelisEventManager.InviteEnabled = true

local AceSerializer = LibStub("AceSerializer-3.0")

RelisEventManager.classIcons = {
    ["DK"] = "Interface\\ICONS\\ClassIcon_DeathKnight",
    ["DH"] = "Interface\\ICONS\\ClassIcon_DemonHunter",
    ["Druid"] = "Interface\\ICONS\\ClassIcon_Druid",
    ["Hunter"] = "Interface\\ICONS\\ClassIcon_Hunter",
    ["Mage"] = "Interface\\ICONS\\ClassIcon_Mage",
    ["Monk"] = "Interface\\ICONS\\ClassIcon_Monk",
    ["Paladin"] = "Interface\\ICONS\\ClassIcon_Paladin",
    ["Priest"] = "Interface\\ICONS\\ClassIcon_Priest",
    ["Rogue"] = "Interface\\ICONS\\ClassIcon_Rogue",
    ["Shaman"] = "Interface\\ICONS\\ClassIcon_Shaman",
    ["Warlock"] = "Interface\\ICONS\\ClassIcon_Warlock",
    ["Warrior"] = "Interface\\ICONS\\ClassIcon_Warrior",
    ["Evoker"] = "Interface\\ICONS\\ClassIcon_Evoker"
}

RelisEventManager.specIcons = {
    Warrior = {
        Arms = "Interface\\Icons\\Ability_Warrior_SwordAndBoard",
        Fury = "Interface\\Icons\\Ability_Warrior_InnerRage",
        Protection = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    },
    Mage = {
        Arcane = "Interface\\Icons\\Spell_Arcane_Arcane01",
        Fire = "Interface\\Icons\\Spell_Fire_FlameBolt",
        Frost = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    },
    Priest = {
        Discipline = "Interface\\Icons\\Spell_Holy_PowerWordShield",
        Holy = "Interface\\Icons\\Spell_Holy_HolyBolt",
        Shadow = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    },
    Hunter = {
        ["Beastmastery"] = "Interface\\Icons\\Ability_Hunter_BeastMastery",
        Marksmanship = "Interface\\Icons\\Ability_Hunter_Marksmanship",
        Survival = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
    },
    Rogue = {
        Assassination = "Interface\\Icons\\Ability_Rogue_DeadlyBrew",
        Outlaw = "Interface\\Icons\\Ability_Rogue_RuthlessStrikes",
        Subtlety = "Interface\\Icons\\Ability_Rogue_SlaughterFromTheShadows",
    },
    Paladin = {
        Holy = "Interface\\Icons\\Spell_Holy_HolyBolt",
        Protection = "Interface\\Icons\\Spell_Holy_DevotionAura",
        Retribution = "Interface\\Icons\\Spell_Holy_AvengersShield",
    },
    Warlock = {
        Affliction = "Interface\\Icons\\Spell_Shadow_DeathCoil",
        Demonology = "Interface\\Icons\\Spell_Shadow_SummonFelGuard",
        Destruction = "Interface\\Icons\\Spell_Fire_FlameBolt",
    },
    Shaman = {
        Elemental = "Interface\\Icons\\Spell_Nature_Lightning",
        Enhancement = "Interface\\Icons\\Ability_Shaman_Stormstrike",
        Restoration1 = "Interface\\Icons\\Spell_Nature_ManaRegenTotem",
    },
    Druid = {
        Balance = "Interface\\Icons\\Spell_Nature_StarFall",
        ["Feral (Cat)"] = "Interface\\Icons\\Ability_Druid_CatForm",
        Guardian = "Interface\\Icons\\Ability_Druid_Defend",
        Restoration = "Interface\\Icons\\Spell_Nature_HealingTouch",
    },
    Monk = {
        Brewmaster = "Interface\\Icons\\Ability_Monk_Brewing",
        Mistweaver = "Interface\\Icons\\Ability_Monk_HealingSphere",
        Windwalker = "Interface\\Icons\\Ability_Monk_Windwalker",
    },
    Evoker = {
        Devastation = "Interface\\Icons\\Spell_Arcane_Arcane01",
        Preservation = "Interface\\Icons\\Spell_Holy_HolyBolt",
    },
    ["DK"] = {
        Blood = "Interface\\Icons\\Spell_DeathKnight_BloodPresence",
        Frost = "Interface\\Icons\\Spell_DeathKnight_FrostPresence",
        Unholy = "Interface\\Icons\\Spell_DeathKnight_UnholyPresence",
    },
    ["DH"] = {
        Havoc = "Interface\\Icons\\Ability_DemonHunter_EyeBeam",
        Vengeance = "Interface\\Icons\\Ability_DemonHunter_SoulCarver",
    },
}

RelisEventManager.roleIcons = {
    Healers = "Interface\\Icons\\Spell_Holy_HolyBolt",
    Tanks = "Interface\\Icons\\Ability_Defend",
    Melee = "Interface\\Icons\\Ability_Rogue_SliceDice",
    Ranged  = "Interface\\Icons\\INV_Weapon_Bow_07",
}

local defaults = {
    global = {
    }
}

function RelisEventManager:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RelisEventManagerDB", defaults, true)
    self:RegisterChatCommand("rem", "HandleSlashCommand")
    self:Print("RelisEventManager loaded. Type /rem for options.")
    self:RegisterComm("REMSync")
end

function RelisEventManager:HandleSlashCommand(input)
    input = input:lower()
   if input == "json" then
        if not self.jsonFrame then
            self:CreateJSONFrame()
        end
        if self.jsonFrame:IsShown() then
            self.jsonFrame:Hide()
        else
            self.jsonFrame:Show()
        end
    elseif input == "discord" then
    	RelisEventManager.discordMapFrame:Show()
    	RelisEventManager.RefreshDiscordMap()
    elseif input == "roster" then
    	RelisEventManager.DisplayFrame:Show()
    	RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data)
    else
        RelisEventManager.ControlPanel:Show()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
    if name == "RelisEventManager" then
        RelisEventManagerDB.discordUserMap = RelisEventManagerDB.discordUserMap or {}
        RelisEventManagerDB.current_event_data = RelisEventManagerDB.current_event_data or {}
    end
end)

StaticPopupDialogs["REM_DATA_RECEIVE"] = {
    text = "%s sent you a map of Discord Names for the Relis Event Manager Addon, do you want to accept them?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self, data)
        if data and data.onAccept then
            data.onAccept(data.payload, data.sender)
        end
    end,
    OnCancel = function(self, data)
        if data and data.onCancel then
            data.onCancel(data.payload, data.sender)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function RelisEventManager:SendMapToPlayer(playerName)
    if not playerName or playerName == "" then
        print("Please specify a player name to send data to.")
        return
    end

    if not RelisEventManagerDB.discordUserMap or next(RelisEventManagerDB.discordUserMap) == nil then
        print("Discord user map is empty, nothing to send.")
        return
    end

    local serialized = AceSerializer:Serialize(RelisEventManagerDB.discordUserMap)
    self:SendCommMessage("REMSync", serialized, "WHISPER", playerName)
    print("RelisEventManager: Sent discord map to " .. playerName)
end

function RelisEventManager:OnCommReceived(prefix, message, distribution, sender)
    
    if prefix ~= "REMSync" then return end

    local success, data = AceSerializer:Deserialize(message)
    if data then
        StaticPopup_Show("REM_DATA_RECEIVE", sender, nil, {
            sender = sender,
            payload = data,
            onAccept = function(data, sender)
    			
                for discordName, charName in pairs(data) do
                    RelisEventManagerDB.discordUserMap[discordName] = charName
                end
                print("RelisEventManager: Discord map updated from " .. sender)
            end,
            onCancel = function(data, sender)
                print("Declined data from:", sender)
            end,
        })
    end
end

local inviteWatcher = CreateFrame("Frame")

local function OnRosterUpdate(_, event)
    if event == "GROUP_ROSTER_UPDATE" then
        if IsInGroup() and not IsInRaid() and UnitIsGroupLeader("player") then
            if GetNumGroupMembers() > 1 and RelisEventManagerDB.convertToRaid then
                C_PartyInfo.ConvertToRaid()
                print("RelisEventManager: Converted to raid.")
                inviteWatcher:UnregisterEvent("GROUP_ROSTER_UPDATE")
            end
        end
    end
end

local inviteIndex = 1
local inviteList = {}

function RelisEventManager:MassInviteSignedPlayers()
    if not RelisEventManagerDB.current_event_data or not RelisEventManagerDB.current_event_data.signUps then
        print("No signup data available for invites.")
        return
    end

    local invitedCount = 0
    
    for position, signup in pairs(RelisEventManagerDB.current_event_data.signUps) do
        if signup.joined == true then
            local playerName = RelisEventManagerDB.discordUserMap[signup.name] or signup.name
            if playerName and playerName ~= "" then
                if not UnitInParty(playerName) and not UnitInRaid(playerName) then
                    table.insert(inviteList, playerName)
                end
                invitedCount = invitedCount + 1
            end
        end
    end

    print(string.format("RelisEventManager: Sending invites to %d players.", invitedCount))
    if not RelisEventManager.InviteEnabled then
        print("RelisEventManager: WARNING! Invites are disabled. Enable them from the invites ui")
    elseif invitedCount > 0 then
        inviteWatcher:SetScript("OnEvent", OnRosterUpdate)
        inviteWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
    end
    invitingActive = true
    SendNextInvite()
end

function SendNextInvite()
    if not invitingActive then
        print("Invite process stopped.")
        return
    end

    local name = inviteList[inviteIndex]
    if not name then
        print("Invite process finished.")
        invitingActive = false
        return
    end

    if RelisEventManager.InviteEnabled then
        C_PartyInfo.InviteUnit(name)
    end
    print("Inviting", name)

    inviteIndex = inviteIndex + 1
    if inviteList[inviteIndex] then
        C_Timer.After(delayBetweenInvites, SendNextInvite)
    else
        print("Invite process finished.")
        invitingActive = false
    end
end

SLASH_STOPINVITES1 = "/remabort"
SlashCmdList["STOPINVITES"] = function(msg)
    invitingActive = false
    inviteWatcher:UnregisterEvent("GROUP_ROSTER_UPDATE")
end