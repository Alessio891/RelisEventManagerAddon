RelisEventManager.DisplayFrame = CreateFrame("Frame", "RelisEventManagerDisplayFrame", UIParent, "BasicFrameTemplateWithInset")
local frame = RelisEventManager.DisplayFrame
frame:SetSize(700, 500)
frame:SetPoint("CENTER")
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
frame.title:SetText("REM - RaidHelper Event")

frame.scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
frame.scrollFrame:SetPoint("TOPLEFT", 10, -40)
frame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

frame.content = CreateFrame("Frame", nil, frame.scrollFrame)
frame.content:SetSize(460, 1)
frame.scrollFrame:SetScrollChild(frame.content)

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

local buttonWidth, buttonHeight = 80, 22
local spacing = 1
local buttons = {}



local selectAllBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
selectAllBtn:SetSize(160, buttonHeight)
selectAllBtn:SetText("Select All Accepted")
selectAllBtn:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -spacing)
selectAllBtn:SetScript("OnClick", function() 
    for i, player in ipairs(RelisEventManagerDB.current_event_data.signUps) do
        if player.className ~= "Absence" and player.className ~= "Tentative" then
            player.joined = true
        end
    end

    RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data)
    if RelisEventManagerRosterFrame:IsShown() then
        RelisEventManager:RefreshRosterFrame()
    end
end)

local deselectAllBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
deselectAllBtn:SetSize(160, buttonHeight)
deselectAllBtn:SetText("Deselct All")
deselectAllBtn:SetPoint("LEFT", selectAllBtn, "RIGHT", -spacing, 0)
deselectAllBtn:SetScript("OnClick", function() 
    for i, player in ipairs(RelisEventManagerDB.current_event_data.signUps) do
        player.joined = false
    end

    RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data)
    if RelisEventManagerRosterFrame:IsShown() then
        RelisEventManager:RefreshRosterFrame()
    end
end)

local mainFrame = frame
local parent = mainFrame:GetParent() or UIParent

local secWidth, secHeight = 180, 120
local secFrame = CreateFrame("Frame", nil, mainFrame, BackdropTemplateMixin and "BackdropTemplate")
local secWidth, secHeight = 150, 130
secFrame:SetSize(secWidth, secHeight)

secFrame:SetPoint("TOPRIGHT", mainFrame, "TOPLEFT", 0, 0)  

secFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left=4, right=4, top=4, bottom=4 }
})
secFrame:SetBackdropColor(0,0,0,0.6)

local title = secFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOP", secFrame, "TOP", 0, -8)
title:SetText("Group Counter")

local eventFrame = CreateFrame("Frame", nil, mainFrame, BackdropTemplateMixin and "BackdropTemplate")
eventFrame:SetSize(242, 110)

eventFrame:SetPoint("TOPLEFT", mainFrame, "TOPRIGHT", 0, 0)  

eventFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left=4, right=4, top=4, bottom=4 }
})
eventFrame:SetBackdropColor(0,0,0,0.6)

local buttonData = {
    { name = "Import", func = function() RelisEventManager:CreateJSONFrame() end },
    { name = "Clear", func = function() 
        RelisEventManagerDB.current_event_data = {}
        RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data)
        if RelisEventManagerRosterFrame:IsShown() then
            RelisEventManager:RefreshRosterFrame()
        end
    end },
    { name = "Invites", func = function() 
        RelisEventManagerRosterFrame:Show()
        RelisEventManager:RefreshRosterFrame()
    end },
}

for i, data in ipairs(buttonData) do
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(buttonWidth, buttonHeight)
    btn:SetText(data.name)
    
     if i == 1 then
        btn:SetPoint("TOPRIGHT", eventFrame, "BOTTOMRIGHT", 1, -spacing)
    else
        btn:SetPoint("RIGHT", buttons[i-1], "LEFT", -spacing, 0)
    end
    
    btn:SetScript("OnClick", data.func)
    
    buttons[i] = btn
end

local function contains(tbl, val)
    for _, v in pairs(tbl) do   -- pairs, not ipairs
        if v == val then
            return true
        end
    end
    return false
end

function RelisEventManager:UpdateEventInfo()
    for _, child in ipairs({ eventFrame:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
    

    
    local function makeRow(text, _icon, y)
        local f = CreateFrame("Frame", nil, eventFrame)
        f:SetAllPoints()

        local icon = f:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16,16)
        icon:SetPoint("TOPLEFT", 10, y)
        icon:SetTexture(_icon)
        
        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        label:SetText(text)
        label:SetWidth(190)
        label:SetJustifyH("LEFT")
    end
    
    if not RelisEventManagerDB.current_event_data.startTime then 
        makeRow("There's no event imported. Import one with json.", "Interface\\ICONS\\INV_Misc_Note_01", -20)
        return 
    end

    makeRow(RelisEventManagerDB.current_event_data.description, "Interface\\ICONS\\INV_Misc_Note_01", -10)

    local timestamp = RelisEventManagerDB.current_event_data.startTime
    local formatted = date("%d-%m-%Y %H:%M:%S", timestamp)
    makeRow("Start On: " .. formatted, "Interface\\Icons\\INV_Misc_Book_02", -32)
    
    local remaining = timestamp - time()
    local remFormatted = ""
    if remaining > 0 then
        local days = math.floor(remaining / 86400)  -- 86400 seconds in a day
        remaining = remaining % 86400
        
        local hours = math.floor(remaining / 3600)  -- 3600 seconds in an hour
        remaining = remaining % 3600 
        remFormatted = string.format("%d days and %02d hours", days, hours)
    else
        remFormatted = "Started"
    end
    makeRow("Remaining: " .. remFormatted, "Interface\\Icons\\INV_Misc_PocketWatch_01", -54)
    
    local leaderName = RelisEventManagerDB.current_event_data.leaderName
    local actualName = RelisEventManagerDB.discordUserMap[leaderName] or leaderName
    makeRow("RaidLead: " .. actualName, "Interface\\Icons\\INV_Misc_Cape_01", -76)
    

end

function RelisEventManager:UpdateRoleCounts()
    for _, child in ipairs({secFrame:GetChildren()}) do
        if child ~= title then child:Hide(); child:SetParent(nil) end
    end

    local counts = { Tanks = 0, Healers = 0, Ranged = 0, Melee = 0 }
    
    if not RelisEventManagerDB.current_event_data.signUps then return end

    for _, player in ipairs(RelisEventManagerDB.current_event_data.signUps) do
        if player.joined then
            if counts[player.roleName] then
                counts[player.roleName] = counts[player.roleName] + 1
            end
        end
    end

    local xOffset, yOffset = 10, -30
    local rowHeight = 22

    for role, count in pairs(counts) do
        local roleFrame = CreateFrame("Frame", nil, secFrame)
        roleFrame:SetSize(120, rowHeight)
        roleFrame:SetPoint("TOPLEFT", secFrame, "TOPLEFT", xOffset, yOffset)

        local icon = roleFrame:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16,16)
        icon:SetPoint("LEFT", 0, 0)
        icon:SetTexture(RelisEventManager.roleIcons[role] or "Interface\\ICONS\\INV_Misc_QuestionMark")

        local label = roleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        label:SetText(role..": "..count)

        yOffset = yOffset - rowHeight
    end
end


frame:Hide()

function RelisEventManager:RefreshEventDisplay(jsonData)
    RelisEventManager:UpdateEventInfo()
    local frame = self.DisplayFrame
    if frame.content then
        frame.content:Hide()
        frame.content:SetParent(nil)
    end
    frame.content = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.content:SetSize(1, 1)
    frame.scrollFrame:SetScrollChild(frame.content)

    local content = frame.content
    local frameWidth = 700
    local rowHeight = 32
    local sectionPadding = 10
    local startY = 0
    RelisEventManager:UpdateRoleCounts()
    if jsonData.title then
        frame.title:SetText("REM - " .. jsonData.title)
        secFrame:Show()
    else
        secFrame:Hide()
    end
    
    local accepted, tentative, absence = {}, {}, {}
    if jsonData.signUps then
        for _, signup in ipairs(jsonData.signUps) do
            local cls = signup.className or ""
            if cls == "Tentative" then
                table.insert(tentative, signup)
            elseif cls == "Absence" then
                table.insert(absence, signup)
            elseif cls ~= "" then
                accepted[cls] = accepted[cls] or {}
                table.insert(accepted[cls], signup)
            end
        end
    end

    local acceptedWidth = 400
    local otherWidth = (frameWidth - acceptedWidth - 3 * sectionPadding) / 2
    local contentHeight = 0

    -- === Helpers ===
    local function createSectionHeader(text, x, y)
        local header = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        header:SetPoint("TOPLEFT", content, "TOPLEFT", x, y)
        header:SetText(text)
        return header
    end

    local function createSectionBG(x, width, height, r,g,b,a, yOffset)
        local bg = content:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", content, "TOPLEFT", x, yOffset)
        bg:SetSize(width, height)
        bg:SetColorTexture(r,g,b,a)
        return bg
    end

    local function createPlayerButton(player, parent, x, y)
        local row = CreateFrame("Button", nil, parent)
        row:SetSize(115, rowHeight)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()
        
        if not player.joined then
            row.bg:SetColorTexture(0,0,0,0.1)
        else
            row.bg:SetColorTexture(0,0.6,0,0.4)
        end
        row.roleIcon = row:CreateTexture(nil, "ARTWORK")
        row.roleIcon:SetSize(16,16)
        row.roleIcon:SetPoint("LEFT", 5, 0)
        if player.className == "Tentative" or player.className == "Absence" then 
            row.roleIcon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
        else
            if RelisEventManager.specIcons[player.className] then
                row.roleIcon:SetTexture(RelisEventManager.specIcons[player.className][player.specName] or "Interface\\ICONS\\INV_Misc_QuestionMark")
            else
                row.roleIcon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
            end
        end

        local charName = RelisEventManagerDB.discordUserMap[player.name] or player.name
        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.label:SetPoint("LEFT", row.roleIcon, "RIGHT", 5, 0)
        local labelText  = charName:match("([^%-]+)")
        row.label:SetText(labelText)

        row:SetScript("OnClick", function() 
            if not player.joined then
                player.joined = true
            else
                player.joined = false
            end
            RelisEventManager:RefreshEventDisplay(jsonData)
            if RelisEventManagerRosterFrame:IsShown() then
                RelisEventManager:RefreshRosterFrame()
            end
            RelisEventManager:UpdateRoleCounts()
        end)
        row:SetScript("OnEnter", function() 
            if not player.joined then
                row.bg:SetColorTexture(0.2,0.2,0.2,0.3)
            else
                row.bg:SetColorTexture(0,0.6,0,0.7)
            end
            GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
            GameTooltip:SetText("Name: " .. charName, 1, 1, 1, 1, true)
            if RelisEventManagerDB.discordUserMap[player.name] then
                GameTooltip:AddLine("Discord User: " .. player.name, 0.8, 0.8, 0.8)
            end
            if player.specName then
                GameTooltip:AddLine("Class: " .. player.className .. " (" .. player.specName .. ")", 1, 1, 1, 1, true)
                GameTooltip:AddLine("Role: " .. player.roleName, 1, 1, 1, 1, true)
            end
            local timestamp = player.entryTime
            local formatted = date("%d-%m-%Y %H:%M:%S", timestamp)
            GameTooltip:AddLine("Signed: " .. formatted, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() 
            if not player.joined then
                row.bg:SetColorTexture(0,0,0,0.1)
            else
                row.bg:SetColorTexture(0,0.6,0,0.4)
            end
            GameTooltip:Hide()
        end)
        return row
    end

    -- === Accepted Section ===
    local acceptedX, acceptedY = sectionPadding, startY
    if next(accepted) then
        createSectionHeader("Accepted", acceptedX, acceptedY)
        acceptedY = acceptedY - 30

        local colWidth = 120
        local maxCols = math.floor((acceptedWidth - 20) / colWidth)

        local totalHeight = 0
        for _, players in pairs(accepted) do
            local rows = math.ceil(#players / maxCols)
            totalHeight = totalHeight + rows * rowHeight + 25 -- add space for class header
        end

        local y = acceptedY
        local xOffset = 10
        local playerPaddingX = 20   -- indent from left edge of class background
        local headerOffsetY = 5     -- negative padding to pull header up slightly
        local firstRowPadding = 20   -- reduce spacing between header and first player

        for className, players in pairs(accepted) do
            local rows = math.ceil(#players / maxCols)
            local classHeight = rows * rowHeight + rowHeight - 5

            local classBG = content:CreateTexture(nil, "BACKGROUND")
            classBG:SetPoint("TOPLEFT", content, "TOPLEFT", acceptedX + xOffset, y + 5)
            classBG:SetSize(acceptedWidth - 2*xOffset, classHeight)
            classBG:SetColorTexture(0.15, 0.15, 0.15, 0.25)

            local classHeader = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            classHeader:SetPoint("TOPLEFT", content, "TOPLEFT", acceptedX + xOffset + 20, y + headerOffsetY)
            classHeader:SetText(className .. "s")

            local classIcon = content:CreateTexture(nil, "ARTWORK")
            classIcon:SetSize(16,16)
            classIcon:SetPoint("RIGHT", classHeader, "LEFT", -5, 0)
            classIcon:SetTexture(RelisEventManager.classIcons[className])

            y = y - rowHeight + firstRowPadding 

            local col, row = 0, 0
            for _, p in ipairs(players) do
                local x = acceptedX + xOffset + playerPaddingX + col * colWidth
                local playerY = y - row * (rowHeight + 2)
                createPlayerButton(p, content, x, playerY)
                col = col + 1
                if col >= maxCols then col = 0; row = row + 1 end
            end

            y = y - rows * rowHeight - 30 -- spacing between classes
        end


        contentHeight = math.max(contentHeight, -y + startY)
    end

    -- === Tentative Section ===
    local tentativeX, tentativeY = acceptedX + acceptedWidth + sectionPadding, startY
    if #tentative > 0 then
        createSectionHeader("Tentative", tentativeX, tentativeY)
        tentativeY = tentativeY - 30
        createSectionBG(tentativeX, otherWidth, #tentative * rowHeight + 20, 0.1,0.1,0.2,0.4, tentativeY + 25)

        local y = tentativeY + 10
        for _, p in ipairs(tentative) do
            createPlayerButton(p, content, tentativeX + 5, y)
            y = y - rowHeight
        end
    end

    -- === Absence Section ===
    local absenceX, absenceY = tentativeX + otherWidth + sectionPadding, startY
    if #absence > 0 then
        createSectionHeader("Absence", absenceX, absenceY)
        absenceY = absenceY - 30
        createSectionBG(absenceX, otherWidth, #absence * rowHeight + 20, 0.2,0.1,0.1,0.4, absenceY + 25)

        local y = absenceY + 10
        for _, p in ipairs(absence) do
            createPlayerButton(p, content, absenceX + 5, y)
            y = y - rowHeight
        end
    end

    content:SetHeight(contentHeight + 50)
end
