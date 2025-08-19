RelisEventManager.ControlPanel = CreateFrame("Frame", "RelisEventManagerControlPanel", UIParent, "BasicFrameTemplateWithInset")
RelisEventManager.ControlPanel:SetSize(240, 120)
RelisEventManager.ControlPanel:SetPoint("CENTER")
RelisEventManager.ControlPanel:SetMovable(true)
RelisEventManager.ControlPanel:EnableMouse(true)
RelisEventManager.ControlPanel:RegisterForDrag("LeftButton")
RelisEventManager.ControlPanel:SetScript("OnDragStart", RelisEventManager.ControlPanel.StartMoving)
RelisEventManager.ControlPanel:SetScript("OnDragStop", RelisEventManager.ControlPanel.StopMovingOrSizing)

RelisEventManager.ControlPanel.title = RelisEventManager.ControlPanel:CreateFontString(nil, "OVERLAY")
RelisEventManager.ControlPanel.title:SetFontObject("GameFontHighlight")
RelisEventManager.ControlPanel.title:SetPoint("TOP", RelisEventManager.ControlPanel.TitleBg, "TOP", 0, -5)
RelisEventManager.ControlPanel.title:SetText("REM - Control Panel")

RelisEventManager.ControlPanel:Hide()

local function ToggleFrame(frame, refreshFunc)
    if frame:IsShown() then
        frame:Hide()
    else
        if refreshFunc then
            refreshFunc()
        end
        frame:Show()
    end
end

local function CreateControlButton(parent, text, point, x, y, frameToToggle, refreshFunc)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(90, 30)
    btn:SetPoint(point, x, y)
    btn:SetText(text)
    btn:SetScript("OnClick", function()
        ToggleFrame(frameToToggle, refreshFunc)
    end)
    return btn
end

RelisEventManager.ControlPanel.btnMain = CreateControlButton(
    RelisEventManager.ControlPanel,
    "Roster",
    "TOPLEFT", 20, -30,
    RelisEventManager.DisplayFrame,
    function() RelisEventManager:RefreshEventDisplay(RelisEventManagerDB.current_event_data) end
)

RelisEventManager.ControlPanel.btnDiscord = CreateControlButton(
    RelisEventManager.ControlPanel,
    "Discord Map",
    "TOPLEFT", 120, -30,
    RelisEventManager.discordMapFrame,
    function() RelisEventManager.RefreshDiscordMap() end
)

RelisEventManager.ControlPanel.btnRoster = CreateControlButton(
    RelisEventManager.ControlPanel,
    "Invites",
    "TOPLEFT", 20, -70,
    RelisEventManagerRosterFrame,
    function() RelisEventManager:RefreshRosterFrame() end
)
