local PileSeller = _G.PileSeller

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("PileSeller", {
    type = "launcher",
    icon = [[Interface\Addons\PileSeller\media\logo]],
    text = "PileSeller",
    OnClick = function(clickedframe, button)
        PileSeller_MinimapButton_OnClick()
    end,
})

function dataobj:OnTooltipShow()
    GameTooltip:AddLine("|cFFFFFFFFPileSeller|r")
    if not psSettings["trackSetting"] then
        GameTooltip:AddLine("|cFFFF0000Not tracking|r")
    else
        GameTooltip:AddLine("|cFF00FF00Tracking|r")
        GameTooltip:AddLine("Going to sell " .. #psItems .. " item(s)")
    end
end

function dataobj:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
    GameTooltip:ClearLines()
    dataobj.OnTooltipShow(GameTooltip)
    GameTooltip:Show()
end

function dataobj:OnLeave()
    GameTooltip:Hide()
end
