-- [[ SAUSAGECOMP - Raid Architect Addon ]] --
-- Version: 1.0.0
-- Author: Sausage Party / Kokotiar

local SAUSAGE_VERSION = "1.0.0"
local addonName = "SAUSAGECOMP"
local frame = CreateFrame("Frame", "SausageCompFrame", UIParent)

-- Tables for data tracking
local raidData = {
    missingFlasks = {},
    missingFood = {},
    synergyConflicts = {},
    utilityReady = {}
}

-- UI Constants from Design System
local BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
}

local CONTENT_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

-------------------------------------------------------------------------------
-- UI INITIALIZATION
-------------------------------------------------------------------------------
local function CreateSausageUI()
    frame:SetSize(600, 450)
    frame:SetPoint("CENTER")
    frame:SetBackdrop(BACKDROP)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    tinsert(UISpecialFrames, "SausageCompFrame")
    frame:Hide()

    -- Header
    local header = frame:CreateTexture(nil, "OVERLAY")
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    header:SetSize(300, 64)
    header:SetPoint("TOP", 0, 12)
    
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", header, "TOP", 0, -14)
    title:SetText("SAUSAGE RAID COMP")

    -- Close Button
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -8, -8)

    -- --- CONTENT BOXES ---
    
    -- 1. Gold Box (Utility & CD - Priority)
    local goldBox = CreateFrame("Frame", nil, frame)
    goldBox:SetSize(180, 320)
    goldBox:SetPoint("TOPLEFT", 20, -60)
    goldBox:SetBackdrop(CONTENT_BACKDROP)
    goldBox:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    goldBox:SetBackdropBorderColor(1, 0.8, 0, 1)
    
    local goldTitle = goldBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    goldTitle:SetPoint("TOP", 0, -10)
    goldTitle:SetText("RAID UTILITY")

    -- 2. Blue Box (Synergy & Conflicts)
    local blueBox = CreateFrame("Frame", nil, frame)
    blueBox:SetSize(180, 320)
    blueBox:SetPoint("LEFT", goldBox, "RIGHT", 10, 0)
    blueBox:SetBackdrop(CONTENT_BACKDROP)
    blueBox:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    blueBox:SetBackdropBorderColor(0, 0.7, 1, 1)

    local blueTitle = blueBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    blueTitle:SetPoint("TOP", 0, -10)
    blueTitle:SetText("SYNERGY CHECK")

    -- 3. Gray Box (Consumables)
    local grayBox = CreateFrame("Frame", nil, frame)
    grayBox:SetSize(180, 320)
    grayBox:SetPoint("LEFT", blueBox, "RIGHT", 10, 0)
    grayBox:SetBackdrop(CONTENT_BACKDROP)
    grayBox:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    grayBox:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    local grayTitle = grayBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    grayTitle:SetPoint("TOP", 0, -10)
    grayTitle:SetText("CONSUMABLES")

    -- --- BUTTONS ---
    local btnScan = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnScan:SetSize(100, 25)
    btnScan:SetPoint("BOTTOMLEFT", 20, 45)
    btnScan:SetText("Scan Raid")
    btnScan:SetScript("OnClick", function() 
        print("|cffffd100SausageComp:|r Scanning raid members...")
        -- Logic for Scanning will go here
    end)

    local btnReport = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnReport:SetSize(110, 25)
    btnReport:SetPoint("LEFT", btnScan, "RIGHT", 5, 0)
    btnReport:SetText("Report to Raid")
    btnReport:SetScript("OnClick", function() 
        -- Logic for Raid Report
    end)

    local btnWhisper = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnWhisper:SetSize(120, 25)
    btnWhisper:SetPoint("LEFT", btnReport, "RIGHT", 5, 0)
    btnWhisper:SetText("Whisper Slackers")

    -- --- FOOTER ---
    local verText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    verText:SetPoint("BOTTOMLEFT", 20, 15)
    verText:SetText("v " .. SAUSAGE_VERSION)

    local credits = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    credits:SetPoint("BOTTOM", 0, 15)
    credits:SetText("by Sausage Party")

    local btnUpdate = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnUpdate:SetSize(110, 25)
    btnUpdate:SetPoint("BOTTOMRIGHT", -20, 15)
    btnUpdate:SetText("Check Updates")
end

-------------------------------------------------------------------------------
-- MINIMAP BUTTON
-------------------------------------------------------------------------------
local function CreateMinimapIcon()
    local SausageMinimap = CreateFrame("Button", "SausageCompMinimap", Minimap)
    SausageMinimap:SetSize(31, 31)
    SausageMinimap:SetFrameLevel(8)
    SausageMinimap:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    SausageMinimap:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    local icon = SausageMinimap:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Inv_Misc_Food_54")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    
    local overlay = SausageMinimap:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetSize(53, 53)
    overlay:SetPoint("TOPLEFT", 0, 0)

    SausageMinimap:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    SausageMinimap:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if frame:IsShown() then frame:Hide() else frame:Show() end
        end
    end)
    
    -- Basic drag logic for WotLK
    SausageMinimap:SetMovable(true)
    SausageMinimap:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then self:StartMoving() end
    end)
    SausageMinimap:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
end

-------------------------------------------------------------------------------
-- CORE LOGIC (Aura, Synergy & Reporting)
-------------------------------------------------------------------------------
local function GetRaidBuffs(unit)
    local hasFlask, hasFood = false, false
    for i = 1, 40 do
        local name = UnitAura(unit, i)
        if not name then break end
        -- Simple check logic (expandable table)
        if name:find("Flask") or name:find("Elixir") then hasFlask = true end
        if name:find("Well Fed") then hasFood = true end
    end
    return hasFlask, hasFood
end

local function WhisperSlacker(name, reason)
    local msg = "[SausageComp]: You are missing " .. reason .. ". Please buff up!"
    SendChatMessage(msg, "WHISPER", nil, name)
end

local function ReportToRaid()
    if not IsInRaid() then return end
    if #raidData.missingFlasks > 0 then
        SendChatMessage("[SausageComp]: Missing Flasks: " .. table.concat(raidData.missingFlasks, ", "), "RAID")
    end
    if #raidData.missingFood > 0 then
        SendChatMessage("[SausageComp]: Missing Well Fed: " .. table.concat(raidData.missingFood, ", "), "RAID")
    end
end

-- Aura Synergy Logic (Feature 4)
local function CheckAuraConflicts()
    local activeAuras = {}
    -- Simplified check for Devotion Aura as example
    for i = 1, GetNumRaidMembers() do
        local unit = "raid"..i
        local name = GetUnitName(unit)
        -- Logic to detect multiple paladins with same aura
    end
end

-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        CreateSausageUI()
        CreateMinimapIcon()
        print("|cffffd100SAUSAGECOMP|r loaded. Type /sc to toggle.")
    end
end)

SLASH_SAUSAGECOMP1 = "/sc"
SlashCmdList["SAUSAGECOMP"] = function() if frame:IsShown() then frame:Hide() else frame:Show() end end