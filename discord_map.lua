RelisEventManagerDB.discordUserMap = RelisEventManagerDB.discordUserMap or {}

local frame = CreateFrame("Frame", "RelisEventManagerNameMapFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(500, 500)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
frame.title:SetText("REM Discord User Map")

local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 50)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(480, 1)
scrollFrame:SetScrollChild(content)

local rows = {}

local function RefreshList()
    for i, row in ipairs(rows) do
        row:Hide()
        row:ClearAllPoints()
    end

    local index = 0
    for discordName, charName in pairs(RelisEventManagerDB.discordUserMap) do
        index = index + 1
        local row = rows[index]
        if not row then
            row = CreateFrame("Frame", nil, content)
            row:SetSize(460, 25)

            row.discordEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            row.discordEdit:SetSize(190, 20)
            row.discordEdit:SetAutoFocus(false)
            row.discordEdit:SetTextInsets(5, 5, 0, 0)
            row.discordEdit:SetMaxLetters(50)

            row.charEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
            row.charEdit:SetSize(190, 20)
            row.charEdit:SetAutoFocus(false)
            row.charEdit:SetTextInsets(5, 5, 0, 0)
            row.charEdit:SetMaxLetters(50)

            row.removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            row.removeBtn:SetSize(30, 20)
            row.removeBtn:SetText("X")

            row.discordEdit:SetPoint("LEFT", row, "LEFT", 10, 0)
            row.charEdit:SetPoint("LEFT", row.discordEdit, "RIGHT", 10, 0)
            row.removeBtn:SetPoint("LEFT", row.charEdit, "RIGHT", 10, 0)

            rows[index] = row
        end

        row:Show()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((index - 1) * 30))

        row.discordEdit:SetText(discordName)
        row.charEdit:SetText(charName)
        row.oldKey = discordName

        row.discordEdit:SetScript("OnEnterPressed", nil)
        row.discordEdit:SetScript("OnEditFocusLost", nil)
        row.charEdit:SetScript("OnEnterPressed", nil)
        row.charEdit:SetScript("OnEditFocusLost", nil)
        row.removeBtn:SetScript("OnClick", nil)

        row.discordEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)
        row.discordEdit:SetScript("OnEditFocusLost", function(self)
            local newKey = self:GetText()
            if newKey ~= row.oldKey then
                if newKey == "" then
                    print("|cffff0000Discord name cannot be empty!|r")
                    self:SetText(row.oldKey)
                    return
                end
                if RelisEventManagerDB.discordUserMap[newKey] then
                    print("|cffff0000That Discord name already exists!|r")
                    self:SetText(row.oldKey)
                    return
                end
                RelisEventManagerDB.discordUserMap[newKey] = RelisEventManagerDB.discordUserMap[row.oldKey]
                RelisEventManagerDB.discordUserMap[row.oldKey] = nil
                row.oldKey = newKey
                RefreshList()
                if RelisEventManagerRosterFrame:IsShown() then
                    RelisEventManager:RefreshRosterFrame()
                end
                if RelisEventManager.DisplayFrame:IsShown() then
                    RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data)
                end
            end
        end)

        row.charEdit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)
        row.charEdit:SetScript("OnEditFocusLost", function(self)
            local newVal = self:GetText()
            RelisEventManagerDB.discordUserMap[row.oldKey] = newVal
            if RelisEventManagerRosterFrame:IsShown() then
                RelisEventManager:RefreshRosterFrame()
            end
            if RelisEventManager.DisplayFrame:IsShown() then
                RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data)
            end
        end)

        row.removeBtn:SetScript("OnClick", function()
            RelisEventManagerDB.discordUserMap[row.oldKey] = nil
            RefreshList()
            if RelisEventManagerRosterFrame:IsShown() then
                RelisEventManager:RefreshRosterFrame()
            end
            if RelisEventManager.DisplayFrame:IsShown() then
                RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data)
            end
        end)
    end

    content:SetHeight(math.max(index * 30, 300))
end

local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addBtn:SetSize(120, 25)
addBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
addBtn:SetText("Add New Entry")
addBtn:SetScript("OnClick", function()
    local tempKey = "NewDiscordName#0000"
    local suffix = 1
    while RelisEventManagerDB.discordUserMap[tempKey] do
        suffix = suffix + 1
        tempKey = "NewDiscordName"..suffix
    end
    RelisEventManagerDB.discordUserMap[tempKey] = "CharacterName"
    RefreshList()
end)

local sendBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
sendBtn:SetSize(120, 25)
sendBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 200, 10)
sendBtn:SetText("Send Map to Target")
sendBtn:SetScript("OnClick", function()
    local targetName = UnitName("target")
    print("Target is " .. targetName)
    if targetName then
        RelisEventManager:SendMapToPlayer(targetName)
    end
end)

local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
closeBtn:SetSize(80, 25)
closeBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
closeBtn:SetText("Close")
closeBtn:SetScript("OnClick", function()
    frame:Hide()
end)

frame:Hide()

RelisEventManager.discordMapFrame = frame
RelisEventManager.RefreshDiscordMap = RefreshList