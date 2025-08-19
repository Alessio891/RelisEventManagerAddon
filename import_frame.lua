
function RelisEventManager:CreateJSONFrame()
    if self.jsonFrame then
        self.jsonFrame:Show()
        return
    end

    local f = CreateFrame("Frame", "REM_JSONFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(500, 400)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("CENTER", f.TitleBg, "CENTER", 0, 0)
    f.title:SetText("RelisEventManager - JSON Import")

    local scrollFrame = CreateFrame("ScrollFrame", "REM_JSONScrollFrame", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    local editBox = CreateFrame("EditBox", "REM_JSONEditBox", scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetAutoFocus(true)
    editBox:EnableMouse(true)

    local bg = editBox:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(scrollFrame)
    bg:SetColorTexture(0, 0, 0, 0.3)

    editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
    editBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    editBox:SetWidth(scrollFrame:GetWidth())
    editBox:SetHeight(scrollFrame:GetHeight())

    scrollFrame:SetScrollChild(editBox)

    f.editBox = editBox

    local parseButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    parseButton:SetSize(100, 25)
    parseButton:SetPoint("BOTTOMRIGHT", -10, 10)
    parseButton:SetText("Parse")

    parseButton:SetScript("OnClick", function()
        local text = f.editBox:GetText()
        if text and text ~= "" then
            local ok, result = pcall(function()
                local data = json.parse(text)
                return data
            end)

            if ok and result then
                self:Print("JSON parsed successfully!")
                RelisEventManagerDB.current_event_data = result
                if RelisEventManager.DisplayFrame:IsShown() then
                    RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data)
                end
                f:Hide()
            else
                self:Print("JSON parse failed: " .. tostring(result))
            end
        else
            self:Print("No text entered.")
        end
    end)

    f:Hide()
    self.jsonFrame = f
end
