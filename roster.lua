RelisEventManagerRosterFrame = CreateFrame("Frame", "RelisEventManagerRosterFrame", UIParent, "BasicFrameTemplateWithInset")
RelisEventManagerRosterFrame:SetSize(480, 600)
RelisEventManagerRosterFrame:SetPoint("CENTER")
RelisEventManagerRosterFrame:Hide()
RelisEventManagerRosterFrame:SetMovable(true)
RelisEventManagerRosterFrame:EnableMouse(true)
RelisEventManagerRosterFrame:RegisterForDrag("LeftButton")
RelisEventManagerRosterFrame:SetScript("OnDragStart", RelisEventManagerRosterFrame.StartMoving)
RelisEventManagerRosterFrame:SetScript("OnDragStop", RelisEventManagerRosterFrame.StopMovingOrSizing)

RelisEventManagerRosterFrame.title = RelisEventManagerRosterFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
RelisEventManagerRosterFrame.title:SetPoint("CENTER", RelisEventManagerRosterFrame.TitleBg, "CENTER", 0, 0)
RelisEventManagerRosterFrame.title:SetText("REM - Roster Manager")

RelisEventManagerRosterFrame.MassInviteButton = CreateFrame("Button", nil, RelisEventManagerRosterFrame, "UIPanelButtonTemplate")
RelisEventManagerRosterFrame.MassInviteButton:SetSize(100, 24)
RelisEventManagerRosterFrame.MassInviteButton:SetText("Mass Invite")

RelisEventManagerRosterFrame.MassInviteButton:SetPoint("TOPLEFT", 10, -30)

RelisEventManagerRosterFrame.MassInviteButton:SetScript("OnClick", function()
     RelisEventManager:MassInviteSignedPlayers()
end)


RelisEventManagerRosterFrame.MassInviteButton:Show()

RelisEventManagerRosterFrame.InviteEnabledCheckbox = CreateFrame("CheckButton", nil, RelisEventManagerRosterFrame, "UICheckButtonTemplate")
RelisEventManagerRosterFrame.InviteEnabledCheckbox:SetPoint("TOPRIGHT", -100, -25)  -- Adjust position
RelisEventManagerRosterFrame.InviteEnabledCheckbox.text:SetText("Enable Invite")

RelisEventManagerRosterFrame.InviteEnabledCheckbox:SetChecked(RelisEventManager.InviteEnabled)

RelisEventManagerRosterFrame.InviteEnabledCheckbox:SetScript("OnClick", function(self)
    RelisEventManager.InviteEnabled = self:GetChecked()
end)
RelisEventManagerRosterFrame.InviteEnabledCheckbox:SetChecked(RelisEventManager.InviteEnabled)

local scrollFrame = CreateFrame("ScrollFrame", nil, RelisEventManagerRosterFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(1, 1)
scrollFrame:SetScrollChild(content)

RelisEventManagerRosterFrame.headers = {}
local headers = {
    { text = "Character Name", x = 0,  width = 140 },
    { text = "Status",         x = 130, width = 90  },
    { text = " ",         x = 260, width = 60  },
    { text = " ",   x = 360, width = 60  },
}
for _, h in ipairs(headers) do
    local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("TOPLEFT", content, "TOPLEFT", h.x, -30)
    fs:SetWidth(h.width)
    fs:SetJustifyH("CENTER")
    fs:SetText(h.text)
    table.insert(RelisEventManagerRosterFrame.headers, fs)
end

RelisEventManagerRosterFrame.rows = {}
RelisEventManagerRosterFrame.scroll = scroll
RelisEventManagerRosterFrame.content = content

local function NormalizeName(name)
    if not name then return nil end
    return name:match("([^%-]+)") -- always strip realm if present
end

local function IsInRaidGroup(playerName)
    local normalized = NormalizeName(playerName)

    if IsInRaid() or IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
            if NormalizeName(name) == normalized then
                return true, online
            end
        end
    end

    local numMembers = GetNumGuildMembers()
    for i = 1, numMembers do
        local fullName, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
        if NormalizeName(fullName) == normalized then
            return false, online
        end
    end

    return false, false
end

function RelisEventManager:RefreshRosterFrame()
    if not RelisEventManagerRosterFrame or not RelisEventManagerRosterFrame.content then return end

    for _, row in ipairs(RelisEventManagerRosterFrame.rows) do row:Hide() end
    wipe(RelisEventManagerRosterFrame.rows)

    local content = RelisEventManagerRosterFrame.content
    local y = -50

    if not (RelisEventManagerDB.current_event_data and RelisEventManagerDB.current_event_data.signUps) then
        content:SetHeight(1)
        return
    end

     for _, signup in pairs(RelisEventManagerDB.current_event_data.signUps) do
        if signup.joined == true and signup.name then
            local row = CreateFrame("Frame", nil, content)
            row:SetSize(440, 30)
            row:SetPoint("TOPLEFT", 0, y)

            local bg = row:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(row)
            local n = RelisEventManagerDB.discordUserMap[signup.name] or signup.name

            local inRaid, online, afk = IsInRaidGroup(n)

            if inRaid then
                bg:SetColorTexture(0, 1, 0, 0.2)
            elseif online then
                if afk then
                    bg:SetColorTexture(1, 1, 0, 0.2)
                else
                    bg:SetColorTexture(1, 0, 0, 0.2)
                end
            else
                bg:SetColorTexture(0.5, 0.5, 0.5, 0.2)
            end
            row.roleIcon = row:CreateTexture(nil, "ARTWORK")
            row.roleIcon:SetSize(16,16)
            row.roleIcon:SetPoint("LEFT", 5, 0)

            if RelisEventManager.classIcons[signup.className] then
                row.roleIcon:SetTexture(RelisEventManager.classIcons[signup.className])
            else
                row.roleIcon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
            end

            row.specIcon = row:CreateTexture(nil, "ARTWORK")
            row.specIcon:SetSize(16,16)
            row.specIcon:SetPoint("LEFT", row.roleIcon, "RIGHT", 1, 0)

            if RelisEventManager.specIcons[signup.className] then
                row.specIcon:SetTexture(RelisEventManager.specIcons[signup.className][signup.specName] or "Interface\\ICONS\\INV_Misc_QuestionMark")
            else
                row.specIcon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
            end
            

            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("LEFT", row.specIcon, "RIGHT", -20, 0)
            nameText:SetWidth(140)
            nameText:SetJustifyH("CENTER")
            nameText:SetText(n)

            local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            statusText:SetPoint("LEFT", row, "LEFT", 160, 0)
            if inRaid then
                statusText:SetText("In Raid")
            elseif online then
                statusText:SetText(afk and "AFK" or "Not in Group")
            else
                statusText:SetText("Offline")
            end

            local inviteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            inviteBtn:SetSize(60, 18)
            inviteBtn:SetPoint("LEFT", row, "LEFT", 260, 0)
            inviteBtn:SetText("Invite")
            inviteBtn:SetScript("OnClick", function()
                if online and not inRaid then
                    C_PartyInfo.InviteUnit(n)
                end
            end)
            if not RelisEventManagerDB.discordUserMap[signup.name] then
                local addButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                addButton:SetSize(80, 20)
                addButton:SetPoint("RIGHT", -10, 0)
                addButton:SetText("Map User")
                addButton:SetScript("OnClick", function()
                    RelisEventManagerDB.discordUserMap[signup.name] = signup.name
                    addButton:Hide()
                    RelisEventManager.discordMapFrame:Show()
                    RelisEventManager.RefreshDiscordMap()
                end)
            else
                local discName = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                discName:SetPoint("RIGHT", -10, 0)
                discName:SetText(signup.name)
                discName:SetWidth(80)
                discName:SetJustifyH("CENTER")
            end

            table.insert(RelisEventManagerRosterFrame.rows, row)
            y = y - 32
        end
    end

    content:SetHeight(-y)
end
function GetPlayerStatus(playerName)
    if IsInRaid() or IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local name, _, _, _, _, class, _, online = GetRaidRosterInfo(i)
            if name and name:find("-") then
                name = name:match("([^%-]+)")
            end
            if name == playerName then
                local unit = "raid"..i
                local afk = UnitIsAFK(unit)
                local dnd = UnitIsDND(unit)
                return "RAID", online, afk, dnd
            end
        end
    end

    local numMembers = GetNumGuildMembers()
    for i = 1, numMembers do
        local fullName, _, _, _, _, _, _, _, online, _, class, _, _, _, isMobile, _, _, _, guid, _, afk, dnd = GetGuildRosterInfo(i)
        if fullName then
            local shortName = fullName:match("([^%-]+)")
            if shortName == playerName then
                return "GUILD", online, afk, dnd
            end
        end
    end

    return "UNKNOWN", false, false, false
end

local f = CreateFrame("Frame")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("GUILD_ROSTER_UPDATE")

f:SetScript("OnEvent", function(self, event, ...)
    -- Refresh your signup GUI
    if RelisEventManagerRosterFrame and RelisEventManagerRosterFrame:IsShown() then
        RelisEventManager:RefreshRosterFrame()
    end
end)