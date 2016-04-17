local PileSeller = _G.PileSeller

local tutorialIndex = 0
local tutorials = {}

--function ClickAll(open, ui)
--    if open then
--        if ui.btnSaved:GetText() == "+" then ui.btnSaved:Click() end
--        if ui.btnToSell:GetText() == "+" then ui.btnToSell:Click() end
--    else
--        if ui.btnSaved:GetText() == "-" then ui.btnSaved:Click() end
--        if ui.btnToSell:GetText() == "-" then ui.btnToSell:Click() end 
--    end
--end

function PileSeller:ToggleTutorial(ui)
    if not ui.TutorialFrame then 
        CreateTeacher(ui)
        tutorials = {
            [0] = {
                title = "|cFF" .. PileSeller.color .. "Pile|rSeller",
                text = "In this short tutorial I will teach you the basics of the UI.",
            },
            [1] = {
                title = "Saved items",
                text = "This is where you can store the items that you want to keep.\nFor example you can add mounts or transmog items.",
                glow = ui.savedScroll.lblTitle,
            },
            [2] = {
                title = "Saved items",
                text = "Here you will be able to see a list of the saved items.\nRemember that you can click on them to gather more informations.",
                glow = ui.savedScroll.content,
                
            },
            [3] = {
                title = "Saved items",
                text = "Here you can add items.\nYou can link them from chat, from the dungeon journal or even by typing the item's ID",
                glow = ui.btnAddSavedItem,
            },
            [4] = {
                title = "Items to sell",
                text = "This is where you will find a list of all the items you will sell.",
                glow = ui.toSellScroll.lblTitle,
            },
            [5] = {
                title = "Items to sell",
                text = "Like the saved items list here you will be able to click any item.",
                glow = ui.toSellScroll.content,
            },
            [6] = {
                title = "Specific item",
                text = "By clicking an item in one of the lists something like this will appear.",
                glow = ui.itemInfos,
                showItemInfos = true,
            },
            [7] = {
                title = "Specific item",
                text = "By clicking this button (which will appear just for the saved items) you can set an alert whenever it will drop.",
                glow = ui.itemInfos.item.toggleAlert,
                showItemInfos = true,
            },
            [8] = {
                title = "Specific item",
                text = "By clicking this button you will be able to preview the item (if possible). Remember that you can do that also by control-clicking from the list.",
                glow = ui.itemInfos.item.tryIt,
                showItemInfos = true,
            },
            [9] = {
                title = "Specific item",
                text = "By clicking this button you will remove the clicked item from its list (both the saved items and the items to sell).",
                glow = ui.itemInfos.item.removeFromList,
                showItemInfos = true,
            },
            [10] = {
                title = "Ignoring",
                text = "Here you can ignore certain zones such as an instance or a region.",
                glow = ui.ignoredScroll.lblTitle
            },
            [11] = {
                title = "Ignoring",
                text = "By typing the name of the zone you will be able to either add or remove an element from the list.",
                glow = ui.btnAddIgnoreZone
            },
            [12] = {
                title = "Ignoring",
                text = "For example if you are ignoring Firelands all you'll have to do is to write Firelands into the text box and you will remove it.",
                glow = ui.btnAddIgnoreZone
            },
            [13] = {
                title = "Start tracking!",
                text = "By clicking here you can start manually a tracking session.\nThis will also start when you will enter alone in any instanced content.",
                glow = ui.toggleTracking,
            },
            [14] = {
                title = "Settings",
                text = "Remember that you will always be able to access the settings by clicking this button!",
                glow = ui.switch,
            },
            [15] = {
                title = "Selling",
                text = "Whenever you will open a merchant I will sell all the items tracked during the session.",
            },
            [16] = {
                title = "Selling",
                text = "The sell process takes a little while. Please be patient and wait 'til the border of the selling bar becomes white (like is now).",
                white = true,
            },
            [17] = {
                title = "|cFF" .. PileSeller.color .. "Pile|rSeller",
                text = "Sometimes the game will glitch and it won't sell some items.\nDon't worry tho, it won't be too much.",
            },
            [18] = {
                title = "|cFF" .. PileSeller.color .. "Pile|rSeller",
                text = "Lastly you you can type in the chat /pileseller or /ps for some easy commands.\nAnd now what are you waiting for? Go farm something!",
            },
            [19] = {
                title = "Contact",
                text = "Feel free to contact me via the curse page or wowinterface, and please report any bugs in either of comment sections"
            }
        }
        WriteLesson(tutorials[tutorialIndex], ui)            
    elseif ui.TutorialFrame:IsVisible() then
        ui.TutorialFrame:Hide()
    else ui.TutorialFrame:Show() end
end

function WriteLesson(tut, ui)
    if not ui.TutorialFrame:IsVisible() then ui.TutorialFrame:Show() end
    ui.TutorialFrame:SetPoint("BOTTOM", ui, 0, -ui.TutorialFrame:GetHeight() - 5)
    ui.TutorialFrame.title:SetText(tut.title)
    ui.TutorialFrame.text:SetText(tut.text)
    
    ui.TutorialFrame.next:SetEnabled(tutorialIndex ~= #tutorials)
    ui.TutorialFrame.prev:SetEnabled(tutorialIndex ~= 0)
    
    if tut.glow then
        if not ui.TutorialFrame.glow then ui.TutorialFrame.glow = CreateFrame("FRAME", nil, tut.TutorialFrame); ui.TutorialFrame.glow:SetParent(ui.TutorialFrame) end
        ui.TutorialFrame.glow:SetSize(36, 36)
        ui.TutorialFrame.glow:SetPoint("RIGHT", tut.glow, 50, 0)
        ui.TutorialFrame.glow.tex = ui.TutorialFrame.glow:CreateTexture()
		ui.TutorialFrame.glow.tex:SetTexture("Interface\\ICONS\\misc_arrowleft")
		ui.TutorialFrame.glow.tex:SetVertexColor(1,1,1,1)
		ui.TutorialFrame.glow.tex:SetAllPoints()
        ui.TutorialFrame.glow:Show()
        if tut.showItemInfos then
            PileSeller:SetItemInfo(PileSeller.UIConfig.itemInfos.item, select(2, GetItemInfo(19019)))
            ui.itemInfos.item.toggleAlert:Show()
        else ui.itemInfos:Hide() end
    else 
        if ui.TutorialFrame.glow then 
            ui.TutorialFrame.glow:Hide() 
        end
        
        if tut.title == "Selling" then
            PileSeller.sFrame:Show()
            if tut.white then
                PileSeller.sFrame.statusBar.border:SetBackdropBorderColor(1,1,1)
                PileSeller.sFrame.statusBar:SetValue(NUM_BAG_SLOTS + 1)
            else 
                PileSeller.sFrame.statusBar.border:SetBackdropBorderColor(0,0,0)
                PileSeller.sFrame.statusBar:SetValue(0)
            end
        else PileSeller.sFrame:Hide() end
    end
end

function CreateTeacher(ui)    
    ui.TutorialFrame = CreateFrame("Frame", nil, ui, "GlowBoxTemplate")
    ui.TutorialFrame:SetSize(200, 150)
    ui.TutorialFrame:SetFrameStrata("DIALOG")
    ui.TutorialFrame:SetParent(ui)
    --ui.TutorialFrame:SetScript("OnShow", function() ClickAll(true, ui) end)
    --ui.TutorialFrame:SetScript("OnHide", function() ClickAll(false, ui) end)
    
    ui.TutorialFrame.close = CreateFrame("Button", "PileSeller_TutorialFrame_CloseButton", ui, "UIPanelCloseButton")
	ui.TutorialFrame.close:SetPoint("TOPRIGHT", ui.TutorialFrame)
	ui.TutorialFrame.close:SetSize(26, 26)
    ui.TutorialFrame.close:SetParent(ui.TutorialFrame)
    
    ui.TutorialFrame.next = CreateFrame("Button", "PileSeller_TutorialFrame_Next", ui.TutorialFrame)
    ui.TutorialFrame.next:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    ui.TutorialFrame.next:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    ui.TutorialFrame.next:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
    ui.TutorialFrame.next:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    ui.TutorialFrame.next:SetSize(26, 26)
    ui.TutorialFrame.next:SetPoint("BOTTOMRIGHT", ui.TutorialFrame, 0, 0)
    ui.TutorialFrame.next:SetScript("OnClick", function() 
            tutorialIndex = tutorialIndex + 1;
            WriteLesson(tutorials[tutorialIndex], ui)  
        end
    )
    
    ui.TutorialFrame.prev = CreateFrame("Button", "PileSeller_TutorialFrame_Prev", ui.TutorialFrame)
    ui.TutorialFrame.prev:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    ui.TutorialFrame.prev:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    ui.TutorialFrame.prev:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    ui.TutorialFrame.prev:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    ui.TutorialFrame.prev:SetSize(26, 26)
    ui.TutorialFrame.prev:SetPoint("LEFT", ui.TutorialFrame.next, -24 , 0)
    ui.TutorialFrame.prev:SetEnabled(false)
    ui.TutorialFrame.prev:SetScript("OnClick", function() 
            tutorialIndex = tutorialIndex - 1;
            WriteLesson(tutorials[tutorialIndex], ui)  
        end
    )
    
    ui.TutorialFrame.title = ui.TutorialFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ui.TutorialFrame.title:SetPoint("TOPLEFT", ui.TutorialFrame, 10, -10)
    ui.TutorialFrame.title:SetJustifyH("LEFT")
    
    ui.TutorialFrame.text = ui.TutorialFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ui.TutorialFrame.text:SetPoint("TOPLEFT", ui.TutorialFrame, 10, -30)
    ui.TutorialFrame.text:SetSize(150, 75)
    ui.TutorialFrame.text:SetJustifyH("LEFT")
    ui.TutorialFrame.text:SetJustifyV("TOP")
    ui.TutorialFrame:Hide()
end