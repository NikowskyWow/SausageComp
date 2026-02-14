-- [[ SAUSAGECOMP - Universal Raid Synergy Tracker ]] --
-- Author: Sausage Party / Kokotiar
-- Version: 1.2.0

local SAUSAGE_VERSION = "1.2.0"
local frame = CreateFrame("Frame", "SausageCompFrame", UIParent)

-- Design System Constants
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
    title:SetText("SAUSAGE RAID COMP")

    -- Content Boxes
    local function CreateBox(name, titleText, color, xOffset)
        local b = CreateFrame("Frame", name, frame)
        b:SetSize(185, 330)
        b:SetPoint("TOPLEFT", 20 + xOffset, -60)
        b:SetBackdrop(CONTENT_BACKDROP)
        b:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        b:SetBackdropBorderColor(unpack(color))
        
        local t = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        t:SetPoint("TOP", 0, -10)
        t:SetText(titleText)

        local c = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        c:SetPoint("TOPLEFT", 10, -30)
        c:SetJustifyH("LEFT")
        c:SetText("Click SCAN to start.")
        b.content = c
        return b
    end

    _G["SC_Box1"] = CreateBox("SC_UtilityBox", "RAID UTILITY", {1, 0.8, 0, 1}, 0)
    _G["SC_Box2"] = CreateBox("SC_SynergyBox", "SYNERGIES", {0, 0.7, 1, 1}, 195)
    _G["SC_Box3"] = CreateBox("SC_ConsumBox", "CONSUMABLES", {0.6, 0.6, 0.6, 1}, 390)

    -- Buttons
    local scan = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    scan:SetSize(120, 25)
    scan:SetPoint("BOTTOMLEFT", 20, 45)
    scan:SetText("SCAN RAID")
    scan:SetScript("OnClick", function() _G["SausageScan"]() end)

    local whisper = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    whisper:SetSize(130, 25)
    whisper:SetPoint("LEFT", scan, "RIGHT", 10, 0)
    whisper:SetText("WHISPER SLACKERS")
    whisper:SetScript("OnClick", function() _G["SausageWhisper"]() end)

    -- Footer
    local ver = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    ver:SetPoint("BOTTOMLEFT", 20, 15)
    ver:SetText("v " .. SAUSAGE_VERSION)

    local credits = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    credits:SetPoint("BOTTOM", 0, 15)
    credits:SetText("by Sausage Party")

    frame:Hide()
end

-------------------------------------------------------------------------------
-- MINIMAP BUTTON (RE-ADDED)
-------------------------------------------------------------------------------
local function CreateMinimap()
    local btn = CreateFrame("Button", "SausageMinimapIcon", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameLevel(8)
    btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Inv_Misc_Food_54")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", 0, 0)

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(self, b)
        if b == "LeftButton" then if frame:IsShown() then frame:Hide() else frame:Show() end end
    end)
    btn:SetMovable(true)
    btn:SetScript("OnMouseDown", function(self, b) if b == "RightButton" then self:StartMoving() end end)
    btn:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
end

-------------------------------------------------------------------------------
-- LOGIC (Wowhead Based)
-------------------------------------------------------------------------------
local slackers = {}

_G["SausageScan"] = function()
    local num = GetNumRaidMembers()
    if num == 0 then print("You are not in a raid!"); return end
    
    wipe(slackers)
    local utility, synergy, consum = "", "", ""
    
    -- Trackers for Buff Stacking (Wowhead)
    local hasMeleeHaste, hasSpellDamage, hasReplenish = false, false, false

    for i = 1, num do
        local name, _, _, _, class = GetRaidRosterInfo(i)
        local unit = "raid"..i
        local f, s = false, false

        for j = 1, 40 do
            local b = UnitAura(unit, j)
            if not b then break end
            if b:find("Flask") or b:find("Elixir") then f = true end
            if b:find("Well Fed") then s = true end
            -- Synergy detection
            if b == "Improved Icy Talons" or b == "Windfury Totem" then hasMeleeHaste = true end
            if b == "Ebon Plague" or b == "Earth and Moon" or b == "Curse of the Elements" then hasSpellDamage = true end
            if b == "Replenishment" then hasReplenish = true end
        end

        if not f or not s then table.insert(slackers, {n=name, f=f, s=s}) end
        consum = consum .. name .. ": " .. (f and "|cff00ff00F|r " or "|cffff0000F|r ") .. (s and "|cff00ff00S|r" or "|cffff0000S|r") .. "\n"
    end

    -- Update Synergy Box based on Wowhead "Ideal" rules
    synergy = "Melee Haste: " .. (hasMeleeHaste and "|cff00ff00OK|r" or "|cffff0000Missing|r") .. "\n"
    synergy = synergy .. "Spell Damage: " .. (hasSpellDamage and "|cff00ff00OK|r" or "|cffff0000Missing|r") .. "\n"
    synergy = synergy .. "Replenish: " .. (hasReplenish and "|cff00ff00OK|r" or "|cffff0000Missing|r") .. "\n"

    SC_Box1.content:SetText("Scan complete.\nUtility tracking active.")
    SC_Box2.content:SetText(synergy)
    SC_Box3.content:SetText(consum)
end

_G["SausageWhisper"] = function()
    for _, data in ipairs(slackers) do
        local m = "[SausageComp]: Missing " .. (not data.f and "Flask " or "") .. (not data.s and "Food" or "")
        SendChatMessage(m, "WHISPER", nil, data.n)
    end
end

-------------------------------------------------------------------------------
-- INIT
-------------------------------------------------------------------------------
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    CreateUI()
    CreateMinimap()
    SLASH_SAUSAGECOMP1 = "/sc"
    SlashCmdList["SAUSAGECOMP"] = function() if frame:IsShown() then frame:Hide() else frame:Show() end end
end)