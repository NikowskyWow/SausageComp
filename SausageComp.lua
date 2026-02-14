-- [[ SAUSAGECOMP - Raid Architect Addon ]] --
-- Based on Wowhead WotLK Raid Comp Guide
-- Author: Sausage Party / Kokotiar

local SAUSAGE_VERSION = "1.1.0"
local frame = CreateFrame("Frame", "SausageCompFrame", UIParent)

-- UI Settings (Sausage Design System)
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

-- Buff Mapping (Wowhead Ideal Comp)
local SYNERGY_CATEGORIES = {
    ["Armor Red."] = {6203, 8647},        -- Sunder Armor, Expose Armor
    ["Melee Haste"] = {55610, 8512},      -- Imp. Icy Talons, Windfury Totem
    ["Spell Damage"] = {51160, 48511},    -- Ebon Plague, Earth and Moon
    ["Replenish"] = {48160, 57669, 31876},-- Vampiric Touch, Replenishment talent names
    ["Crit Chance"] = {20337, 37036},     -- Heart of the Crusader, Totem of Wrath
}

-------------------------------------------------------------------------------
-- UI ELEMENTS
-------------------------------------------------------------------------------
local function CreateUI()
    frame:SetSize(620, 480)
    frame:SetPoint("CENTER")
    frame:SetBackdrop(BACKDROP)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    tinsert(UISpecialFrames, "SausageCompFrame")

    -- Header
    local header = frame:CreateTexture(nil, "OVERLAY")
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    header:SetSize(300, 64)
    header:SetPoint("TOP", 0, 12)
    
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", header, "TOP", 0, -14)
    title:SetText("SAUSAGE RAID COMP - IDEAL SETUP")

    -- Close Button
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -8, -8)

    -- --- CONTENT BOXES ---
    -- 1. UTILITY (Gold)
    local box1 = CreateFrame("Frame", "SausageUtilityBox", frame)
    box1:SetSize(185, 340)
    box1:SetPoint("TOPLEFT", 20, -60)
    box1:SetBackdrop(CONTENT_BACKDROP)
    box1:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    box1:SetBackdropBorderColor(1, 0.8, 0, 1)
    
    local t1 = box1:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    t1:SetPoint("TOP", 0, -10)
    t1:SetText("RAID UTILITY (CDs)")

    -- 2. SYNERGY (Blue)
    local box2 = CreateFrame("Frame", "SausageSynergyBox", frame)
    box2:SetSize(185, 340)
    box2:SetPoint("LEFT", box1, "RIGHT", 10, 0)
    box2:SetBackdrop(CONTENT_BACKDROP)
    box2:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    box2:SetBackdropBorderColor(0, 0.7, 1, 1)

    local t2 = box2:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    t2:SetPoint("TOP", 0, -10)
    t2:SetText("SYNERGY & CONFLICTS")

    -- 3. CONSUMABLES (Gray)
    local box3 = CreateFrame("Frame", "SausageConsumBox", frame)
    box3:SetSize(185, 340)
    box3:SetPoint("LEFT", box2, "RIGHT", 10, 0)
    box3:SetBackdrop(CONTENT_BACKDROP)
    box3:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    box3:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    local t3 = box3:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    t3:SetPoint("TOP", 0, -10)
    t3:SetText("BUFFS & CONSUMABLES")

    -- --- FOOTER ---
    local ver = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    ver:SetPoint("BOTTOMLEFT", 20, 15)
    ver:SetText("v " .. SAUSAGE_VERSION)

    local cred = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    cred:SetPoint("BOTTOM", 0, 15)
    cred:SetText("by Sausage Party / Kokotiar")

    local btnUpdate = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnUpdate:SetSize(110, 22)
    btnUpdate:SetPoint("BOTTOMRIGHT", -20, 12)
    btnUpdate:SetText("Check Updates")
    
    -- --- ACTION BUTTONS ---
    local btnScan = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnScan:SetSize(120, 25)
    btnScan:SetPoint("BOTTOMLEFT", 20, 45)
    btnScan:SetText("SCAN RAID")
    
    local btnReport = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnReport:SetSize(120, 25)
    btnReport:SetPoint("LEFT", btnScan, "RIGHT", 5, 0)
    btnReport:SetText("REPORT TO RAID")

    local btnWhisper = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnWhisper:SetSize(130, 25)
    btnWhisper:SetPoint("LEFT", btnReport, "RIGHT", 5, 0)
    btnWhisper:SetText("WHISPER SLACKERS")

    frame:Hide()
end

-------------------------------------------------------------------------------
-- CORE FUNCTIONS
-------------------------------------------------------------------------------

local function ScanSynergies()
    -- Táto funkcia prebehne cez členov raidu a porovná ich talenty/buffy
    -- s našou tabuľkou SYNERGY_CATEGORIES.
    -- Pre WotLK 3.3.5a využívame UnitAura a Inspect talenty.
    print("|cffffd100SausageComp:|r Analyzing raid synergies based on Wowhead specs...")
end

-- Minimap Icon & Slash Commands
local function Init()
    CreateUI()
    SLASH_SAUSAGECOMP1 = "/sc"
    SlashCmdList["SAUSAGECOMP"] = function() 
        if frame:IsShown() then frame:Hide() else frame:Show() end 
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then Init() end
end)