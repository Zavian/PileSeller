local PileSeller = _G.PileSeller
function PileSeller:MakeMovable(frame)
	frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
 end

local psSellingFrame = CreateFrame("FRAME", "PileSeller_SellingFrame", UIParent, "ThinBorderTemplate")
PileSeller:MakeMovable(psSellingFrame)
psSellingFrame:Hide()
psSellingFrame:SetSize(400, 100)
psSellingFrame:SetPoint("TOP", UIParent)
psSellingFrame.bg = psSellingFrame:CreateTexture()
psSellingFrame.bg:SetAllPoints(psSellingFrame)
psSellingFrame.bg:SetTexture(.1,.1,.1,.8)
psSellingFrame.lblSelling = psSellingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
psSellingFrame.lblSelling:SetPoint("TOP", psSellingFrame, 0, -10, "BOTTOM")
psSellingFrame.lblSelling:SetText("SCANNING ITEMS")
psSellingFrame:SetFrameStrata("DIALOG")

psSellingFrame.statusBar = CreateFrame("StatusBar", nil, psSellingFrame)
psSellingFrame.statusBar:SetStatusBarTexture(0,84/255,178/255, .9)
psSellingFrame.statusBar:SetMinMaxValues(0, NUM_BAG_SLOTS+1)
psSellingFrame.statusBar:SetValue(0)
psSellingFrame.statusBar:SetWidth(250)
psSellingFrame.statusBar:SetHeight(15)
psSellingFrame.statusBar:SetPoint("CENTER",psSellingFrame,"CENTER")
psSellingFrame.statusBar:SetFrameStrata("TOOLTIP")

--psSellingFrame.statusBar.texture = psSellingFrame.statusBar:CreateTexture()
--psSellingFrame.statusBar.texture:SetAllPoints(psSellingFrame.statusBar)
--psSellingFrame.statusBar.texture:SetTexture("Interface\\Common\\ShadowOverlay-Top")

psSellingFrame.statusBar.border = CreateFrame("FRAME", nil, psSellingFrame.statusBar)
psSellingFrame.statusBar.border:SetSize(250, 16)
psSellingFrame.statusBar.border:SetPoint("LEFT", psSellingFrame.statusBar)
psSellingFrame.statusBar.border:SetBackdrop({
	bgFile = [[Interface\Buttons\WHITE8X8]], 
	edgeFile = [[Interface\Buttons\WHITE8X8]], 
	edgeSize = 3, 
	insets = {
	    left = 1,
	    right = 1,
	    top = 1,
	    bottom = 1
  }
})
psSellingFrame.statusBar.border:SetBackdropColor(.76,.76,.76, .3)
psSellingFrame.statusBar.border:SetBackdropBorderColor(0, 0, 0)

psSellingFrame.statusBar.border.lbl = psSellingFrame.statusBar.border:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
psSellingFrame.statusBar.border.lbl:SetPoint("CENTER", psSellingFrame.statusBar.border, 0, -1)
psSellingFrame.statusBar.border.lbl:SetText("0 / 5")
psSellingFrame.statusBar.border.lbl:SetVertexColor(1,1,1)
psSellingFrame.statusBar:SetScript("OnValueChanged", function(self, value)
		psSellingFrame.statusBar.border.lbl:SetText(value .. " / " .. NUM_BAG_SLOTS + 1)
	end
)
psSellingFrame.sellingLbl = psSellingFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
psSellingFrame.sellingLbl:SetPoint("BOTTOM", psSellingFrame, 0, 25)
psSellingFrame.sellingLbl:SetText("")

psSellingFrame.profitLbl = psSellingFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
psSellingFrame.profitLbl:SetPoint("BOTTOM", psSellingFrame.sellingLbl, 0, -15)
psSellingFrame.profitLbl:SetText("Profit " .. PileSeller:getProfitPerCoin(0))

psSellingFrame.closeBtn = CreateFrame("Button", nil, psSellingFrame,"UIPanelCloseButton")
psSellingFrame.closeBtn:SetSize(26, 26)
psSellingFrame.closeBtn:SetPoint("TOPRIGHT", psSellingFrame, 0, 0)
psSellingFrame.closeBtn:SetScript("OnClick", function()
		psSellingFrame.statusBar.border:SetBackdropBorderColor(0,0,0)
		psSellingFrame.profitLbl:SetText("Profit: " .. PileSeller:getProfitPerCoin(0))
		psSellingFrame.sellingLbl:SetText("")
		psSellingFrame.statusBar:SetValue(0)
		psSellingFrame:Hide()
	end
)

PileSeller.sFrame = psSellingFrame

--function PileSeller:Abracadabra(value)
--	PileSeller.sFrame.statusBar:SetValue(value)
--end



