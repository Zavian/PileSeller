local PileSeller = _G.PileSeller

local psSellingBoxFrame = CreateFrame("FRAME", "PileSeller_SellingBoxFrame", UIParent, "ThinBorderTemplate")



PileSeller:MakeMovable(psSellingBoxFrame)
psSellingBoxFrame:Hide()
psSellingBoxFrame:SetSize(350, 215)
psSellingBoxFrame:SetPoint("CENTER", UIParent)
psSellingBoxFrame.bg = psSellingBoxFrame:CreateTexture()
psSellingBoxFrame.bg:SetAllPoints(psSellingBoxFrame)
psSellingBoxFrame:EnableMouseWheel(true)
psSellingBoxFrame.bg:SetTexture([[Interface\Buttons\WHITE8X8]])
psSellingBoxFrame.bg:SetVertexColor(.1,.1,.1,.8)
psSellingBoxFrame.lblSelling = psSellingBoxFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
psSellingBoxFrame.lblSelling:SetPoint("TOP", psSellingBoxFrame, 0, -10, "BOTTOM")
psSellingBoxFrame.lblSelling:SetText("Do you want to sell these items?")
psSellingBoxFrame:SetFrameStrata("DIALOG")

psSellingBoxFrame.closeButton = CreateFrame("Button", "PileSeller_SellingBoxFrame_CloseButton", psSellingBoxFrame, "UIPanelCloseButton")
psSellingBoxFrame.closeButton:SetSize(26, 26)
psSellingBoxFrame.closeButton:SetPoint("TOPRIGHT")
psSellingBoxFrame.closeButton:SetScript("OnClick", function() psSellingBoxFrame:Hide() end)


psSellingBoxFrame.itemsScroll = PileSeller:CreateScroll(psSellingBoxFrame, "PileSeller_SellingBoxFrame_Scroll", 260, 120)
psSellingBoxFrame.itemsScroll:SetPoint("CENTER", psSellingBoxFrame, "CENTER", 0, 15)


psSellingBoxFrame:SetScript("OnShow", function() 
    PileSeller:PopulateList(psSellingBoxFrame.itemsScroll.content, psItems)
    
end)

if not psSellingBoxFrame.itemsScroll:GetScrollChild() then
    psSellingBoxFrame.itemsScroll:SetScrollChild(psSellingBoxFrame.itemsScroll.content)
end

psSellingBoxFrame.lblTutorial = psSellingBoxFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
psSellingBoxFrame.lblTutorial:SetPoint("BOTTOM", psSellingBoxFrame.itemsScroll, 0, -15, "BOTTOM")
psSellingBoxFrame.lblTutorial:SetText("|cFFFFFFFFright click on an item to remove it|r")

psSellingBoxFrame.btnAccept = CreateFrame("Button", nil, psSellingBoxFrame, "GameMenuButtonTemplate")
psSellingBoxFrame.btnAccept:SetPoint("BOTTOM", psSellingBoxFrame, "BOTTOM", -45, 5)
psSellingBoxFrame.btnAccept:SetSize(85, 26)
psSellingBoxFrame.btnAccept:SetText("Accept")
psSellingBoxFrame.btnAccept:SetScript("OnClick", function() PileSeller.selling = true; psSellingBoxFrame:Hide() end)

psSellingBoxFrame.btnDecline = CreateFrame("Button", nil, psSellingBoxFrame, "GameMenuButtonTemplate")
psSellingBoxFrame.btnDecline:SetPoint("BOTTOM", psSellingBoxFrame, "BOTTOM", 45, 5)
psSellingBoxFrame.btnDecline:SetSize(85, 26)
psSellingBoxFrame.btnDecline:SetText("Decline")
psSellingBoxFrame.btnDecline:SetScript("OnClick", function() psSellingBoxFrame:Hide(); psItems = {} end)

PileSeller.sellingBox = psSellingBoxFrame


