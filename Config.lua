local PileSeller = _G.PileSeller
local checkIcon = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:15:15|t"


local lastClicked 

function GetStaticPopup(text, returni)
	for i = 1, 10 do
		if _G["StaticPopup" .. i] then
			if _G["StaticPopup" .. i .. "Text"] then
				if _G["StaticPopup" .. i .. "Text"]:GetText() == text then
					if not returni then
						return _G["StaticPopup" .. i]
					else return i end
				end
			end
		end
	end
end

function PileSeller:CreateCunstomStaticPopup(text)
	StaticPopupDialogs["PS_TOGGLE_TRACKING"] = {
		text = text,
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			--PileSeller:PrintTable(self)
			local popup = GetStaticPopup(text)
			local index = GetStaticPopup(text, true)
			PileSeller:ToggleTracking(true, 
				popup.checkbox1:GetChecked(), 
				popup.checkbox2:GetChecked(), 
				popup.checkbox3:GetChecked(), 
				popup.checkbox4:GetChecked(),
				popup.checkbox5:GetChecked()
			)
			HideAllFromConfig(popup)
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	StaticPopup_Show ("PS_TOGGLE_TRACKING")
	local popup = GetStaticPopup(text)

	local checkboxes = {
		[1] = {
			text = "Don't sell any tiers I can use.",
			variable = "keepTier",
			sub = false
		},
		[2] = {
			text = "Don't sell any crafting reagent.",
			variable = "keepCraftingReagents",
			sub = false
		},
		[3] = {
			text = "Don't sell any BoE.",
			variable = "keepBoes",
			sub = false
		},
		[4] = {
			text = "Just keep the ones I don't already own.",
			variable = "keepTrasmogsNotOwned",
			sub = true
		},
		[5] = {
			text = "Keep only the ones I can transmog.",
			variable = "keepTrasmogs",
			sub = true
		},
	}

	local Y, X = 40, 55
	for i = 1, #checkboxes do
		popup["checkbox" .. i] = CreateFrame("CheckButton", "popupCheckbox" .. i, popup, "UICheckButtonTemplate") 
		popup["checkbox" .. i]:SetSize(25, 25)
		popup["checkbox" .. i]:SetChecked(psSettings[checkboxes[i].variable])
		popup["checkbox" .. i]:SetScript("OnClick", function() popup["checkbox" .. i]:SetChecked(not popup["checkbox" .. i]:GetChecked()) end)
		popup["checkbox" .. i].lbl = popup["checkbox" .. i]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		popup["checkbox" .. i].lbl:SetText(checkboxes[i].text)

		local sub = checkboxes[i].sub and X + 20 or X
		popup["checkbox" .. i]:SetPoint("CENTER", popup, "LEFT", sub, Y)
		popup["checkbox" .. i].lbl:SetPoint("LEFT", popup["checkbox" .. i], 25, 0, "RIGHT")
		Y = Y - 20
	end
	local height = 20 * #checkboxes + 80
	popup:SetHeight(height)
end

--- Function to write all the contents of a scroll frame
--- inputs:
--- 	list 	= scrollframe to fill
--- 	items 	= list of the items (eg. psItems)
--- 	literal = wether it's something to get id from or not (eg. ignored zone list)
--- outbut: none
function PileSeller:PopulateList(list, items, width, literal, drops)
	if not width then width = 258 end
	if items == psIgnoredZones then
		print("received: ")
		print("list = " .. list:GetName())
		print("items = psIgnoredZones")
		print("width = " .. width)
		print(literal)
		print(drops)
	end
	PileSeller:ClearAllButtons(list)
	PileSeller:debugprint(list:GetName() .. " populating")
	if not literal then
		for i = 1, #items do
			PileSeller:CreateScrollButton(list, items[i], i, width, 21, drops)
		end
	else
		for i = 1, #items do
			PileSeller:CreateScrollButton(list, -1, i, width, 21, items[i], drops)
		end
	end
end


--- Function to "delete" all the contents of a scroll frame
--- input:
--- 	parent 	= scrollframe to treat
--- outbut: none
function PileSeller:ClearAllButtons(parent)
	local name = parent:GetName() .. "Button"

	local i = 1
	local b = parent[name .. i]
	while b do
		parent[name .. i].t:SetText("")
		parent[name .. i]:SetBackdropColor(.27, .27, .27, 1)
		parent[name .. i]:SetSize(parent[name .. i]:GetWidth(),0)
		parent[name .. i]:SetHighlightTexture(nil)
		parent[name .. i]:SetScript("OnClick", nil)
		parent[name .. i]:SetScript("OnEnter", nil)
		parent[name .. i]:SetScript("OnLeave", nil)
		i = i + 1
		b = parent[name .. i]
	end
end

--- Function to create a button while filling a list
--- input:
	--- parent 		= scrollframe to fill
	--- id 			= item id (-1 = nil)
	--- progress 	= normally the method it's run in a for loop, used to create space from one button and another
	--- height 		= height of a button
	--- [zoneName]	= used for creating the ignored zones
--- outbut: none
function PileSeller:CreateScrollButton(parent, id, progress, width, height, zoneName, sources)
	local name = parent:GetName() .. "Button" .. progress
	local text = ""
	local found = ""
	if not parent[name] then
		parent[name] = CreateFrame("Button", parent:GetName() .. "Button" .. progress, parent)
		parent[name].t = parent[name]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	else parent[name]:Show() end
	if id ~= -1 then
		if parent:GetName() == "PileSeller_ConfigFrame_SavedScrollContent" then
			if psItemsSavedFound[id] then found = " " .. checkIcon end
		end
		local n, l, q, _t, _t, _t, _t, _t, _t, _t, _t  = GetItemInfo(id)
		text = n

		-- select text color
		qualities = {}
		qualities[0] = { r = 0.615, g = 0.615, b = 0.615}
		qualities[1] = { r = 1, g = 1, b = 1}
		qualities[2] = { r = .118, g = 1, b = 0}
		qualities[3] = { r = 0, g = .439, b = 1}
		qualities[4] = { r = .639, g = .207, b = .933}
		qualities[5] = { r = 1, g = .501, b = 0}
		qualities[6] = { r = .901, g = .800, b = .501}
		if q >= 6 then q = qualities[6]
		else q = qualities[q] end
		parent[name].t:SetTextColor(q.r, q.g, q.b)

		parent[name]:SetScript("OnEnter", function()
			GameTooltip:SetOwner(parent[name], "ANCHOR_BOTTOMRIGHT", 0, parent[name]:GetHeight())
			GameTooltip:SetHyperlink(l)
			GameTooltip:Show()
		end)
		parent[name]:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		PileSeller:debugprint(parent:GetName())
		if parent:GetName() ~= "PileSeller_SellingBoxFrame_ScrollContent" then
			parent[name]:SetScript("OnClick", function()
				lastClicked = parent
				PileSeller:SetItemInfo(PileSeller.UIConfig.itemInfos.item, id)
				if IsShiftKeyDown() then
					ChatEdit_InsertLink(l)
				elseif IsControlKeyDown() then
					DressUpItemLink(l)
				end				
			end)
		else
			parent[name]:RegisterForClicks("AnyDown")
			parent[name]:SetScript("OnClick", function(self, button)
				if IsShiftKeyDown() then
					ChatEdit_InsertLink(l)
				elseif IsControlKeyDown() then
					DressUpItemLink(l)
				end
				if button == "RightButton" then
					PileSeller:debugprint("banana")
					PileSeller:removeItem(l, psItems, parent)
					_G["PileSeller_SellingBoxFrame"]:Hide()
					_G["PileSeller_SellingBoxFrame"]:Show()
				end
			end)
		end
	elseif id == -1 then
		text = zoneName
		if parent:GetName() ~= "PileSeller_ConfigFrame_ItemInfos_MiniDialog_ScrollFrameContent" then			
			parent[name]:SetScript("OnClick", function()
				PileSeller.UIConfig.txtAddIgnoreZone:SetText(text)
			end)
		else
			if text == TRANSMOG_SOURCE_1 then
				parent[name]:SetScript("OnEnter", function()
					PileSeller:CreateTooltipInfo(parent[name], sources)
				end)
				parent[name]:SetScript("OnLeave", function() GameTooltip:Hide() end)
			end
		end
	end

	parent[name].t:SetText(text .. found)
	parent[name].t:SetPoint("LEFT", parent[name])
	parent[name].t:SetSize(width, height)
	parent[name]:SetSize(width, height)

	parent[name]:SetHighlightTexture("Interface\\AddOns\\PileSeller\\media\\highlight", "ADD")

	parent[name]:SetBackdrop({
		bgFile = [[Interface\Buttons\WHITE8X8]], 
	})
	if progress % 2 == 0 or progress == 0 then parent[name]:SetBackdropColor(.15, .15, .15,1)
	else parent[name]:SetBackdropColor(.27, .27, .27,1) end
	if progress == 1 then parent[name]:SetPoint("TOPLEFT", parent, 1, -1)
	else parent[name]:SetPoint("TOPLEFT", parent, 1, -height * (progress - 1) - 1) end

end


--- Function to get the profit estimated from the items
--- input: none
--- output: 
	---formatted string (0g 0s 0c)
function GetSell()
	local rtn = 0
	local item = ""
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			item = select(7, GetContainerItemInfo(i, j))
			if item then
				local count = select(2, GetContainerItemInfo(i, j))
				if PileSeller:IsToSell(item) then
					local cost = select(11, GetItemInfo(id))
					rtn = rtn + (cost * count)
				end
			end
		end
	end
	return PileSeller:getProfitPerCoin(rtn)
end

--- Function to create the window of the addon
--- input: 	none
--- output: none
function PileSeller:ShowConfig(args)
	PileSeller:debugprint("entered showconfig")
	local switchTo = ""
	if args == "config" then switchTo = "Items"
	elseif args == "items" then switchTo = "Config" end
	if not PileSeller.UIConfig then
		PileSeller.UIConfig = CreateFrame("Frame", "PileSeller_ConfigFrame", UIParent, "ThinBorderTemplate")
		PileSeller.UIConfig:SetFrameStrata("MEDIUM")
		PileSeller.UIConfig:SetSize(500, 400)
		PileSeller.UIConfig:SetPoint("RIGHT", UIParent, -100, 0)
		PlaySound("igCharacterInfoOpen")
		PileSeller:MakeMovable(PileSeller.UIConfig)

		PileSeller.UIConfig:SetScript("OnShow", function()
			PileSeller:UpdateUIInfo()
		end)

		-- Texture
		PileSeller.UIConfig.bg = PileSeller.UIConfig:CreateTexture()
		PileSeller.UIConfig.bg:SetAllPoints(PileSeller.UIConfig)
		PileSeller.UIConfig.bg:SetTexture([[Interface\Buttons\WHITE8X8]])
		PileSeller.UIConfig.bg:SetVertexColor(.1,.1,.1,.8)

		-- Title
		PileSeller.UIConfig.title = PileSeller.UIConfig:CreateFontString("PileSeller_ConfigFrame_Title", "OVERLAY", "GameFontHighlight")
		PileSeller.UIConfig.title:SetPoint("TOPLEFT", PileSeller.UIConfig, "TOPLEFT", 10, -10)
		PileSeller.UIConfig.title:SetText("|cFF" .. PileSeller.color .. "Pile|rSeller")

		-- Switch Mode
		PileSeller.UIConfig.switch = CreateFrame("Button", "PileSeller_ConfigFrame_SwitchButton", PileSeller.UIConfig, "GameMenuButtonTemplate")
		PileSeller.UIConfig.switch:SetPoint("TOPRIGHT", PileSeller.UIConfig, "TOPRIGHT", -30, -4)
		PileSeller.UIConfig.switch:SetSize(75, 26)
		PileSeller.UIConfig.switch:SetText(switchTo)
		PileSeller.UIConfig.switch:SetScript("OnClick", function()
			local t = PileSeller.UIConfig.switch:GetText()
			if t == "Items" then
				t = "Config"
				PileSeller:CreateItemsSection(PileSeller.UIConfig)
				 PileSeller.UIConfig.tutorial:Show()
			elseif t == "Config" then
				t = "Items"
				CreateConfigSection(PileSeller.UIConfig)
				 PileSeller.UIConfig.tutorial:Hide()
			end
			PileSeller.UIConfig.switch:SetText(t)
		end
		)
		
		-- Tutorial Button
		PileSeller.UIConfig.tutorial = CreateFrame("Button", "PileSeller_ConfigFrame_TutorialButton", PileSeller.UIConfig)
		PileSeller.UIConfig.tutorial:SetSize(50, 50)
		PileSeller.UIConfig.tutorial:SetPoint("BOTTOMRIGHT", PileSeller.UIConfig, "BOTTOMRIGHT", 15, -15)
		PileSeller.UIConfig.tutorial:SetNormalTexture("Interface\\COMMON\\help-i")
		PileSeller.UIConfig.tutorial:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
		PileSeller.UIConfig.tutorial:SetScript("OnClick", function()
				PileSeller:ToggleTutorial(PileSeller.UIConfig)
			end
		)
		
		
		-- Toggle Tracking Button
		PileSeller.UIConfig.toggleTracking = CreateFrame("Button", "PileSeller_ConfigFrame_ToggleTracking", PileSeller.UIConfig, "GameMenuButtonTemplate")
		PileSeller.UIConfig.toggleTracking:SetPoint("TOP", PileSeller.UIConfig, "TOP", 0, 0)
		PileSeller.UIConfig.toggleTracking:SetSize(125, 26)
		PileSeller.UIConfig.toggleTracking:SetText(psSettings["trackSetting"] and "Stop tracking" or "Start tracking")
		PileSeller.UIConfig.toggleTracking:SetScript("OnClick", function()
			local b = PileSeller.UIConfig.toggleTracking:GetText() == "Start tracking"
			PileSeller:ToggleTracking(b)
			PileSeller.UIConfig.toggleTracking:SetText(psSettings["trackSetting"] and "Stop tracking" or "Start tracking")
		end
		)
		PileSeller.UIConfig.toggleTracking:SetBackdrop({
			edgeFile = [[Interface\Buttons\WHITE8X8]], 
			edgeSize = 3, 
			insets = {
					left = 1,
					right = 1,
					top = 1,
					bottom = 1
	  		}
		})
		PileSeller.UIConfig.toggleTracking:SetBackdropBorderColor(1, 1, 1, psSettings["trackSetting"] and 1 or 0)

		PileSeller.UIConfig.close = CreateFrame("Button", "PileSeller_ConfigFrame_CloseButton", PileSeller.UIConfig, "UIPanelCloseButton")
		PileSeller.UIConfig.close:SetPoint("TOPRIGHT", PileSeller.UIConfig)
		PileSeller.UIConfig.close:SetSize(34, 34)
		PileSeller.UIConfig.close:SetScript("OnClick", HideConfig)
	else 
		PileSeller.UIConfig:Show() 
		PlaySound("igCharacterInfoOpen");
		PileSeller.UIConfig.switch:SetText(switchTo)
	end
	if args == "items" then
		PileSeller:debugprint("entered showconfig items")
		PileSeller:CreateItemsSection(PileSeller.UIConfig)
		PileSeller.UIConfig.tutorial:Show()
	elseif args == "config" then
		PileSeller:debugprint("entered showconfig config")		
		CreateConfigSection(PileSeller.UIConfig)
	end
end


--- Function to hide the config
--- input:	none
--- output:	sound
function HideConfig()
	PileSeller.UIConfig:Hide()
	--for i = 0, #UISpecialFrames do if UISpecialFrames[i] == "PileSeller_ConfigFrame" then print("kek"); tremove(UISpecialFrames, i) end end
	--tremove(UISpecialFrames, "PileSeller_ConfigFrame")
	PlaySound("igCharacterInfoClose")
end

--- Function to hide all the elements of the ui (used when switching from a mode to another)
--- input:
	--- ui = UIConfig
--- output: none
function HideAllFromConfig(ui)
	
	-- By doing this I can find any other item in the frame
	-- Now I just hide all the things that I don't need
	if ui:GetName():find("StaticPopup") then
		local children = { ui:GetChildren() }
		for i = 1, #children do
			local name = children[i]:GetName()
			if name:find("popupCheckbox") then
				children[i]:Hide()
			end
		end
	else
		local children = { ui:GetChildren() }
		for i=1, #children do
			local name = children[i]:GetName()
			local kid = 
				name == "PileSeller_ConfigFrame_CloseButton" or 
				name == "PileSeller_ConfigFrame_SwitchButton" or 
				name == "PileSeller_ConfigFrame_ToggleTracking" or 
				name == "PileSeller_ConfigFrame_TutorialButton" or
				(children[i]:GetName() == "PileSeller_ConfigFrame_ItemInfos" and not children[i]:IsVisible()) 
			if not kid then children[i]:Hide() end
		end
	end
end

--- Function to create the item info window
function CreateItemInfos(UIConfig)
	HideAllFromConfig(UIConfig)

	UIConfig.itemInfos = CreateFrame("Frame", "PileSeller_ConfigFrame_ItemInfos", UIConfig, "ThinBorderTemplate")
	UIConfig.itemInfos:SetSize(200, 300)
	UIConfig.itemInfos:SetPoint("LEFT", UIConfig, -UIConfig.itemInfos:GetWidth() + 10, 0)
	UIConfig.itemInfos.bg = UIConfig.itemInfos:CreateTexture()
	UIConfig.itemInfos.bg:SetAllPoints(UIConfig.itemInfos)
	UIConfig.itemInfos.bg:SetTexture([[Interface\Buttons\WHITE8X8]])
	UIConfig.itemInfos.bg:SetVertexColor(.27,.27,.27,1)

	UIConfig.itemInfos.item = CreateFrame("Frame", nil, UIConfig.itemInfos)
	UIConfig.itemInfos.item:SetSize(50, 50)
	UIConfig.itemInfos.item:SetPoint("TOP", UIConfig.itemInfos, 0, -10)
	UIConfig.itemInfos.item.tx = UIConfig.itemInfos.item:CreateTexture(nil, "BACKGROUND")
	UIConfig.itemInfos.item.tx:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
	UIConfig.itemInfos.item.tx:SetVertexColor(1,1,1,1)
	UIConfig.itemInfos.item.tx:SetAllPoints()

	local infos = {
		[1] = {obj = "FontString", name = "itemName", inherits = "GameFontNormal" },
		[2] = {obj = "FontString", name = "itemClass", inherits = "GameFontHighlight" },
		[3] = {obj = "FontString", name = "itemValue", inherits = "GameFontHighlight" },
		[4] = {obj = "Button", name = "itemSource" },
		[5] = {obj = "FontString", name = "itemID", inherits = "GameFontHighlight" },
	}



	for i = 1, #infos do
		if infos[i].obj == "FontString" then
			UIConfig.itemInfos.item[infos[i].name] = UIConfig.itemInfos.item:CreateFontString(nil, "OVERLAY", infos[i].inherits)
			UIConfig.itemInfos.item[infos[i].name]:SetPoint("BOTTOM", UIConfig.itemInfos.item, 0, -20 - (i*20))
			UIConfig.itemInfos.item[infos[i].name]:SetText("iteminfo." .. i)
			UIConfig.itemInfos.item[infos[i].name]:SetSize(175, 40)
		else
			UIConfig.itemInfos.item[infos[i].name] = CreateFrame("Button", nil, UIConfig.itemInfos.item, "GameMenuButtonTemplate")
			UIConfig.itemInfos.item[infos[i].name]:SetPoint("BOTTOM", UIConfig.itemInfos.item, 0, -20 - (i*18))
			UIConfig.itemInfos.item[infos[i].name]:SetText("iteminfo." .. i)
			UIConfig.itemInfos.item[infos[i].name]:SetSize(125, 21)
		end
	end

	UIConfig.itemInfos.item.removeFromList = CreateFrame("Button", nil, UIConfig.itemInfos.item, "GameMenuButtonTemplate")
	UIConfig.itemInfos.item.removeFromList:SetText("Remove from list")
	UIConfig.itemInfos.item.removeFromList:SetSize(125, 21)
	UIConfig.itemInfos.item.removeFromList:SetPoint("BOTTOM", UIConfig.itemInfos.item[infos[#infos].name], "BOTTOM", 0, -80)

	UIConfig.itemInfos.item.tryIt = CreateFrame("Button", nil, UIConfig.itemInfos.item, "GameMenuButtonTemplate")
	UIConfig.itemInfos.item.tryIt:SetText("Preview item")
	UIConfig.itemInfos.item.tryIt:SetSize(125, 21)
	UIConfig.itemInfos.item.tryIt:SetPoint("TOP", UIConfig.itemInfos.item.removeFromList, "TOP", 0, 20)

	UIConfig.itemInfos.item.toggleAlert = CreateFrame("Button", nil, UIConfig.itemInfos.item, "GameMenuButtonTemplate")
	UIConfig.itemInfos.item.toggleAlert:SetText("Set alert")
	UIConfig.itemInfos.item.toggleAlert:SetSize(125, 21)
	UIConfig.itemInfos.item.toggleAlert:SetPoint("TOP", UIConfig.itemInfos.item.tryIt, "TOP", 0, 20)


	UIConfig.itemInfos.btnClose = CreateFrame("Button", nil, UIConfig.itemInfos, "UIPanelCloseButton")
	UIConfig.itemInfos.btnClose:SetSize(26, 26)
	UIConfig.itemInfos.btnClose:SetPoint("TOPRIGHT")

	UIConfig.itemInfos:Hide()
	--SetItemInfo(PileSeller.UIConfig.itemInfos.item, "60844")
end

function CreateMiniDialog(parent)
	parent.miniDialog = CreateFrame("Frame", "PileSeller_ConfigFrame_ItemInfos_MiniDialog", parent, "ThinBorderTemplate")
	parent.miniDialog:SetSize(200, 125)
	parent.miniDialog:SetPoint("BOTTOM", parent, "BOTTOM")
	parent.miniDialog.bg = parent.miniDialog:CreateTexture()
	parent.miniDialog.bg:SetAllPoints(parent.miniDialog)
	parent.miniDialog.bg:SetTexture([[Interface\Buttons\WHITE8X8]])
	parent.miniDialog.bg:SetVertexColor(.27,.27,.27,1)
	parent.miniDialog:SetFrameStrata("HIGH")

	parent.miniDialog.closeButton = CreateFrame("Button", "PileSeller_ConfigFrame_ItemInfos_MiniDialog_CloseButton", parent.miniDialog, "UIPanelCloseButton")
	parent.miniDialog.closeButton:SetPoint("TOPRIGHT", parent.miniDialog)
	parent.miniDialog.closeButton:SetSize(26, 26)

	parent.miniDialog.title = parent.miniDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	parent.miniDialog.title:SetText("|cFF".. PileSeller.color .. "Item Source(s)|r")
	parent.miniDialog.title:SetSize(100, 21)
	parent.miniDialog.title:SetPoint("TOPLEFT", parent.miniDialog)

	--parent.miniDialog.scroller = CreateFrame("ScrollFrame", nil, parent.miniDialog, "UIPanelScrollFrameTemplate")
	--parent.miniDialog.scroller:SetSize(175, 100)
	--parent.miniDialog.scroller:SetPoint("LEFT", parent.miniDialog, "LEFT", 0, -10)
	--parent.miniDialog.scroller:SetBackdropColor(0,0,0)
	parent.miniDialog.scroller = PileSeller:CreateScroll(parent.miniDialog, "PileSeller_ConfigFrame_ItemInfos_MiniDialog_ScrollFrame", 175, 100, true)
	parent.miniDialog.scroller:SetPoint("LEFT", parent.miniDialog, "LEFT", 0, -10)
	parent.miniDialog.scroller:SetParent(parent.miniDialog)

	parent.miniDialog.scroller.text = parent.miniDialog.scroller:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	parent.miniDialog.scroller.text:SetJustifyH("LEFT")
	parent.miniDialog.scroller.text:SetJustifyV("TOP")
	parent.miniDialog.scroller.text:SetText("I have to test\nA very long string\n\nThat can be\nThis long")
	parent.miniDialog.scroller.text:SetPoint("TOPLEFT", parent.miniDialog, "TOPLEFT", 10, -20)
	parent.miniDialog.scroller.text:SetSize(170, 75)
	parent.miniDialog.scroller.text:Hide()


	-- REMOVED BECAUSE C_TransmogCollection.GetAppearanceSourceDrops RETURNS WRONG INFO
	--parent.miniDialog.showBossSource = CreateFrame("Button", nil, parent.miniDialog, "GameMenuButtonTemplate")
	--parent.miniDialog.showBossSource:SetText("Show instance sources")
	--parent.miniDialog.showBossSource:SetSize(200, 21)
	--parent.miniDialog.showBossSource:SetPoint("BOTTOMRIGHT", parent.miniDialog, nil, 0, -5)

	parent.miniDialog:Hide()
end

function SetMiniDialogInfo(parent, itemLink, thereAreBosses)
	PileSeller:ClearAllButtons(parent.miniDialog.scroller.content)
	local sources = PileSeller:GetItemSources(itemLink)
	if parent.miniDialog:IsShown() then return end 
	parent.miniDialog:Show()
	if not sources or not sources[1] then parent.miniDialog.scroller.text:SetText("This item is not trasmogrificable, hence I don't know the source (sorry)."); parent.miniDialog.scroller.text:Show();
	else
		parent.miniDialog.scroller.text:Hide()
		local text = {}
		local writtenText = {}
		if #sources[1] >= 1 then
			for i = 1, #sources[1] do
				--local name, nameColor, sourceText, sourceColor = WardrobeCollectionFrameModel_GetSourceTooltipInfo(sources[i])
				if not writtenText[sources[1][i].text] then
					tinsert(text, sources[1][i].text)
				end
				writtenText[sources[1][i].text] = true
			end
		end


		--if sources[2] then 
		--	parent.miniDialog.showBossSource:Show() 
		--	parent.miniDialog.showBossSource:SetScript("OnClick", function() 
		--		PileSeller:PrintTable(C_TransmogCollection.GetAppearanceSourceDrops(sources[3]))	
		--	end)
		--else parent.miniDialog.showBossSource:Hide() end
		PileSeller:PopulateList(parent.miniDialog.scroller.content, text, 172, true, sources)
	end
end

function PileSeller:SetItemInfo(parent, item)
	parent:GetParent():Show()
	if parent:GetParent().miniDialog then
		parent:GetParent().miniDialog:Hide()
	end
	local n, l, q, _, _, _, c, _, _, i, v = GetItemInfo(item)

	qualities = {}
	qualities[0] = "9d9d9d"
	qualities[1] = "FFFFFF"
	qualities[2] = "1eff00"
	qualities[3] = "0070ff"
	qualities[4] = "a335ee"
	qualities[5] = "ff8000"
	qualities[6] = "e6cc80"
	if q >= 6 then q = qualities[6]
	else q = qualities[q] end

	local tx = parent.tx
	tx:SetTexture(i)
	tx:SetVertexColor(1,1,1,1)
	tx:SetAllPoints()

	local id = PileSeller:getID(l)

	parent.itemName:SetText(n)
	parent.itemClass:SetText("|cFF".. PileSeller.color .. "Item type:|r |cFF" .. q .. c .. "|r")
	parent.itemID:SetText("|cFF".. PileSeller.color .. "Item ID:|r " .. id)

	parent.tryIt:SetScript("OnClick", function()
		DressUpItemLink(l)
	end
	)
	
	parent.removeFromList:SetScript("OnClick", function()
		local tableToGet = {}
		if lastClicked:GetName() == "PileSeller_ConfigFrame_SavedScrollContent" then tableToGet = psItemsSaved
		else tableToGet = psItems end

		PileSeller:removeItem(l, tableToGet, lastClicked)
		PileSeller:UpdateUIInfo()

	end
	)
	if lastClicked then 
		if lastClicked:GetName() then
			if lastClicked:GetName() == "PileSeller_ConfigFrame_ToSellScrollContent" then parent.toggleAlert:Hide()
			elseif lastClicked:GetName() == "PileSeller_ConfigFrame_SavedScrollContent" then
				parent.toggleAlert:Show()
				if psItemsAlert[id] then parent.toggleAlert:SetText("Remove Alert")
				else parent.toggleAlert:SetText("Set alert") end
				parent.toggleAlert:SetScript("OnClick", function()
					if parent.toggleAlert:GetText() == "Set alert" then
						psItemsAlert[id] = true
						parent.toggleAlert:SetText("Remove alert")
					else psItemsAlert[id] = false end
				end
				)
			end
		end
	end

	local t = "|cFF".. PileSeller.color .. "Item value: |r"
	if v > 0 then
		local gold = math.floor(v / 100 / 100)
		local silver = math.floor((v / 100) % 100)
		local copper = math.floor(v % 100)
		if gold > 1 then t = t .. gold .. "|cFFFFD700g|r " end
		if silver > 1 then t = t .. silver .. "|cFFC0C0C0s|r " end
		if copper > 1 then t = t .. copper .. "|cFFCD7E32c|r" end
	else t = t .. "No value" end
	parent.itemValue:SetText(t)


	
	if not WardrobeCollectionFrameModel_GetSourceTooltipInfo then
		parent.itemSource:SetText("Load Sources")
		parent.itemSource:SetScript("OnClick", function()
			CollectionsJournal_LoadUI()
			parent.itemSource:SetText("Show Sources")
			parent.itemSource:SetScript("OnClick", function()
				if not parent:GetParent().miniDialog then CreateMiniDialog(parent:GetParent()) end
				SetMiniDialogInfo(parent:GetParent(), select(2, GetItemInfo(item)))
			end)
			--buttonToClick = CreateFrame("Button", nil, parent, "UIDropDownMenuTemplate")
		end)
	else
		parent.itemSource:SetText("Show Sources")
		parent.itemSource:SetScript("OnClick", function()
			if not parent:GetParent().miniDialog then CreateMiniDialog(parent:GetParent()) end
			SetMiniDialogInfo(parent:GetParent(), select(2, GetItemInfo(item)))
		end)
	end
end

function PileSeller:CreateItemsSection(UIConfig)
	PileSeller:debugprint("entered createitemssection")
	CreateItemInfos(UIConfig)
	CreateSavedSection(UIConfig)
	CreateToSellSection(UIConfig)
	CreateIgnoreZone(UIConfig)
end

function PileSeller:CreateScroll(parent, name, width, height, noBorder)
	local f = CreateFrame("ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
	f:SetSize(width, height)
	f:SetClampedToScreen(true)
	f:EnableMouseWheel(true)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetTexture([[Interface\Buttons\WHITE8X8]])
	tex:SetVertexColor(.27,.27,.27,1)
	tex:SetAllPoints()
	if not noBorder then
		f:SetBackdrop({
			edgeFile = [[Interface\Buttons\WHITE8X8]], 
			edgeSize = 1, 
			insets = {
				left = 1,
				right = 1,
				top = 1,
				bottom = 1
		  }
		})
		f:SetBackdropBorderColor(0, 0, 0)
	end

	f.content = CreateFrame("Frame", name .. "Content")
	f.content:SetSize(width, height)
	f:SetScrollChild(f.content)

	f:SetScript("OnMouseWheel", function(self, delta) 
		local vertical = f:GetVerticalScroll()
		local max = f:GetVerticalScrollRange()
		local step = (max / 21 * 5) -- how much i should move. 21 = height of the button. 5 = speed
		_G[name .. "ScrollBar"]:SetMinMaxValues(0, max)
		local move = step * -delta
		if vertical + move > 0 and vertical + move < max then
			f:SetVerticalScroll(vertical + move)
		elseif vertical + move > max then
			f:SetVerticalScroll(max)
		elseif vertical + move < 0 then 
			f:SetVerticalScroll(0)
		end
		_G[name .. "ScrollBar"]:SetValue(f:GetVerticalScroll()) -- feelsbadman
	end)

	return f
end

function CreateSavedSection(UIConfig)	
	PileSeller:debugprint("entered createitemssection saved")
	--[[SAVED SECTION]]--
	if not UIConfig.savedScroll then
		UIConfig.savedScroll = PileSeller:CreateScroll(UIConfig, "PileSeller_ConfigFrame_SavedScroll", 260, 120)
		UIConfig.savedScroll:SetPoint("TOPLEFT", UIConfig, 20, -35)
		UIConfig.savedScroll:SetParent(UIConfig)
	else 
		PileSeller:debugprint("entered createitemssection saved else")
		UIConfig.savedScroll:Show()
		UIConfig.savedScroll:SetScrollChild(UIConfig.savedScroll.content)
		UIConfig.savedScroll:EnableMouseWheel(true) 
	end
	PileSeller:PopulateList(UIConfig.savedScroll.content, psItemsSaved, 258)

	if not UIConfig.savedScroll.lblTitle then
		UIConfig.savedScroll.lblTitle = UIConfig.savedScroll:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		UIConfig.savedScroll.lblTitle:SetText("Saved items list")
		UIConfig.savedScroll.lblTitle:SetPoint("TOPRIGHT", UIConfig.savedScroll, UIConfig.savedScroll.lblTitle:GetWidth() + 30, 0)		
	else UIConfig.savedScroll.lblTitle:Show() end

	if not UIConfig.savedScroll.lblTitle.lblDesc then
		UIConfig.savedScroll.lblTitle.lblDesc = UIConfig.savedScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		UIConfig.savedScroll.lblTitle.lblDesc:SetText("Items saved: " .. #psItemsSaved .. "|nItems found: " .. PileSeller:tablelength(psItemsSavedFound))
		UIConfig.savedScroll.lblTitle.lblDesc:SetPoint("LEFT", UIConfig.savedScroll.lblTitle, 0, -UIConfig.savedScroll.lblTitle:GetHeight() - 10)
		UIConfig.savedScroll.lblTitle.lblDesc:SetJustifyH("LEFT")
	else UIConfig.savedScroll.lblTitle.lblDesc:Show() end

	-- Creating the add item bar
	if not UIConfig.txtAddSavedItem then 
		UIConfig.txtAddSavedItem = CreateFrame("EditBox", nil, UIConfig.savedScroll)
		UIConfig.txtAddSavedItem:SetSize(260, 21)
		UIConfig.txtAddSavedItem:SetPoint("LEFT", UIConfig.savedScroll, "LEFT", 0, -70)
		UIConfig.txtAddSavedItem:SetAutoFocus(false)
		UIConfig.txtAddSavedItem:SetScript("OnEscapePressed", function()
			UIConfig.txtAddSavedItem:ClearFocus()
		end
		)
		
		-- Setting the EditBox properties
		UIConfig.txtAddSavedItem:SetFontObject("GameFontHighlight")	-- Its font
		UIConfig.txtAddSavedItem:SetTextInsets(5, 0, 0, 0)			-- Some insets for the text
		UIConfig.txtAddSavedItem:SetBackdrop({						-- The border and backdrop
		bgFile = [[Interface\Buttons\WHITE8X8]],
		tile = false,
		edgeFile = [[Interface\Buttons\WHITE8X8]], 
		edgeSize = 1, 
		insets = {
				left = 1,
				right = 1,
				top = 1,
				bottom = 1
		  }
		})
		UIConfig.txtAddSavedItem:SetBackdropColor(.27,.27,.27, 1)
		UIConfig.txtAddSavedItem:SetBackdropBorderColor(0, 0, 0)
		UIConfig.txtAddSavedItem:SetScript("OnEnterPressed", function()
			local t = UIConfig.txtAddSavedItem:GetText()
			if t then
				if string.match(t, "item[%-?%d:]+") then
					PileSeller:addItem(t, psItemsSaved, UIConfig.savedScroll.content)
				else
					local l = string.len(t)
					for i=1, l do
						s = t:sub(i,i)
						if s < '0' or s > '9' then 
							UIConfig.txtAddSavedItem:SetText("-- ERROR --")
							return
						end
					end
					PileSeller:addItem(t, psItemsSaved, UIConfig.savedScroll.content)
					UIConfig.txtAddSavedItem:SetText("")
					PileSeller:UpdateUIInfo()
				end
			end
		end
		)
	else UIConfig.txtAddSavedItem:Show() end


	-- Creating the add item button
	if not UIConfig.btnAddSavedItem then 
		UIConfig.btnAddSavedItem = CreateFrame("Button", nil, UIConfig.txtAddSavedItem, "GameMenuButtonTemplate")
		UIConfig.btnAddSavedItem:SetSize(26, 26)
		UIConfig.btnAddSavedItem:SetPoint("RIGHT", UIConfig.txtAddSavedItem, "RIGHT", 26, -1)
		UIConfig.btnAddSavedItem:SetText("+")
		UIConfig.btnAddSavedItem:SetScript("OnClick", function()
			local t = UIConfig.txtAddSavedItem:GetText()
			if t then
				if string.match(t, "item[%-?%d:]+") then
					PileSeller:addItem(t, psItemsSaved, UIConfig.savedScroll.content)
				else
					local l = string.len(t)
					for i=1, l do
						s = t:sub(i,i)
						if s < '0' or s > '9' then 
							UIConfig.txtAddSavedItem:SetText("-- ERROR --")
							return
						end
					end
					PileSeller:addItem(t, psItemsSaved, UIConfig.savedScroll.content)
					UIConfig.txtAddSavedItem:SetText("")
					PileSellser:UpdateUIInfo()
				end
			end
		end
		)
	else UIConfig.btnAddSavedItem:Show() end
	if not UIConfig.savedScroll:GetScrollChild() then
		UIConfig.savedScroll:SetScrollChild(UIConfig.savedScroll.content)
	end
end

function CreateToSellSection(UIConfig)
	if not UIConfig.toSellScroll then
		UIConfig.toSellScroll = PileSeller:CreateScroll(UIConfig, "PileSeller_ConfigFrame_ToSellScroll", 260, 100)
		UIConfig.toSellScroll:SetPoint("BOTTOM", UIConfig.savedScroll, 0, -UIConfig.savedScroll:GetHeight() - 10)
		UIConfig.toSellScroll:SetParent(UIConfig)
	else UIConfig.toSellScroll:Show(); UIConfig.toSellScroll:EnableMouseWheel(true) end
	PileSeller:PopulateList(UIConfig.toSellScroll.content, psItems, 258)

	if not UIConfig.toSellScroll.lblTitle then
		UIConfig.toSellScroll.lblTitle = UIConfig.toSellScroll:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		UIConfig.toSellScroll.lblTitle:SetText("To sell items list")
		UIConfig.toSellScroll.lblTitle:SetPoint("TOPRIGHT", UIConfig.toSellScroll, UIConfig.toSellScroll.lblTitle:GetWidth() + 30, 0)		
	else UIConfig.toSellScroll.lblTitle:Show() end

	if not UIConfig.toSellScroll.lblTitle.lblDesc then
		UIConfig.toSellScroll.lblTitle.lblDesc = UIConfig.savedScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		local p = GetSell()
		UIConfig.toSellScroll.lblTitle.lblDesc:SetText("Items to sell: " .. #psItems .. "|nProfit: " .. p)
		UIConfig.toSellScroll.lblTitle.lblDesc:SetPoint("LEFT", UIConfig.toSellScroll.lblTitle, 0, -UIConfig.toSellScroll.lblTitle:GetHeight() - 10)	
		UIConfig.toSellScroll.lblTitle.lblDesc:SetJustifyH("LEFT")
	else UIConfig.toSellScroll.lblTitle.lblDesc:Show() end

end

function CreateIgnoreZone(UIConfig)
	if not UIConfig.ignoredScroll then
		UIConfig.ignoredScroll = PileSeller:CreateScroll(UIConfig, "PileSeller_ConfigFrame_IgnoredScroll", 260, 55)
		UIConfig.ignoredScroll:SetPoint("BOTTOM", UIConfig.toSellScroll, 0, -65)
		UIConfig.ignoredScroll:SetParent(UIConfig)		
	else UIConfig.ignoredScroll:Show(); UIConfig.ignoredScroll:EnableMouseWheel(true) end
	PileSeller:PopulateList(UIConfig.ignoredScroll.content, psIgnoredZones, 258, true)

	-- Creating the add item bar
	if not UIConfig.txtAddIgnoreZone then 
		UIConfig.txtAddIgnoreZone = CreateFrame("EditBox", nil, UIConfig.ignoredScroll)
		UIConfig.txtAddIgnoreZone:SetSize(260, 21)
		UIConfig.txtAddIgnoreZone:SetPoint("BOTTOM", UIConfig.ignoredScroll, 0, -20)
		UIConfig.txtAddIgnoreZone:SetAutoFocus(false)
		UIConfig.txtAddIgnoreZone:SetScript("OnEscapePressed", function()
			UIConfig.txtAddIgnoreZone:ClearFocus()
		end
		)
		
		-- Setting the EditBox properties
		UIConfig.txtAddIgnoreZone:SetFontObject("GameFontHighlight")	-- Its font
		UIConfig.txtAddIgnoreZone:SetTextInsets(5, 0, 0, 0)			-- Some insets for the text
		UIConfig.txtAddIgnoreZone:SetBackdrop({						-- The border and backdrop
		bgFile = [[Interface\Buttons\WHITE8X8]],
		tile = false,
		edgeFile = [[Interface\Buttons\WHITE8X8]], 
		edgeSize = 1, 
		insets = {
				left = 1,
				right = 1,
				top = 1,
				bottom = 1
		  }
		})
		UIConfig.txtAddIgnoreZone:SetBackdropColor(.27,.27,.27, 1)
		UIConfig.txtAddIgnoreZone:SetBackdropBorderColor(0, 0, 0)

		UIConfig.txtAddIgnoreZone:SetScript("OnTextChanged", function()
				if PileSeller:IsIgnored(UIConfig.txtAddIgnoreZone:GetText()) then
					UIConfig.btnAddIgnoreZone:SetText("-")
				else UIConfig.btnAddIgnoreZone:SetText("+") end
			end
		)

		UIConfig.txtAddIgnoreZone:SetScript("OnEnterPressed", function()
			local s = UIConfig.btnAddIgnoreZone:GetText() == "+"
			local t = UIConfig.txtAddIgnoreZone:GetText()
			if s then				
				tinsert(psIgnoredZones, t)
				PileSeller:PopulateList(UIConfig.ignoredScroll.content, psIgnoredZones, 258, true)
			else
				local index = PileSeller:IsIgnored(t)
				tremove(psIgnoredZones, index)
				PileSeller:PopulateList(UIConfig.ignoredScroll.content, psIgnoredZones, 258, true)
			end
			UIConfig.txtAddIgnoreZone:SetText("")
		end
		)
	else UIConfig.txtAddIgnoreZone:Show() end

	if not UIConfig.ignoredScroll.lblHelp then
		UIConfig.ignoredScroll.lblHelp = UIConfig.ignoredScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		UIConfig.ignoredScroll.lblHelp:SetText("use the above box to add and remove zones")
		UIConfig.ignoredScroll.lblHelp:SetPoint("BOTTOM", UIConfig.txtAddIgnoreZone, 0, -UIConfig.txtAddIgnoreZone:GetHeight() + 2)		
	else UIConfig.ignoredScroll.lblHelp:Show() end

	if not UIConfig.ignoredScroll.lblTitle then
		UIConfig.ignoredScroll.lblTitle = UIConfig.ignoredScroll:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		UIConfig.ignoredScroll.lblTitle:SetText("Ignored zone list")
		UIConfig.ignoredScroll.lblTitle:SetPoint("TOPRIGHT", UIConfig.ignoredScroll, UIConfig.ignoredScroll.lblTitle:GetWidth() + 30, 0)		
	else UIConfig.ignoredScroll.lblTitle:Show() end

	if not UIConfig.ignoredScroll.lblTitle.lblDesc then
		UIConfig.ignoredScroll.lblTitle.lblDesc = UIConfig.ignoredScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetText("You are currently in:|n|cFF" .. PileSeller.color .. GetZoneText() .. "|r")
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetWidth(125)
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetJustifyH("LEFT")
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetPoint("LEFT", UIConfig.ignoredScroll.lblTitle, 0, -UIConfig.ignoredScroll.lblTitle:GetHeight() - 10)		
	else UIConfig.ignoredScroll.lblTitle.lblDesc:Show() end


	-- Creating the add item button
	if not UIConfig.btnAddIgnoreZone then 
		UIConfig.btnAddIgnoreZone = CreateFrame("Button", nil, UIConfig.txtAddIgnoreZone, "GameMenuButtonTemplate")
		UIConfig.btnAddIgnoreZone:SetSize(26, 26)
		UIConfig.btnAddIgnoreZone:SetPoint("RIGHT", UIConfig.txtAddIgnoreZone, "RIGHT", 26, -1)
		UIConfig.btnAddIgnoreZone:SetText("+")
		UIConfig.btnAddIgnoreZone:SetScript("OnClick", function()
			local s = UIConfig.btnAddIgnoreZone:GetText() == "+"
			local t = UIConfig.txtAddIgnoreZone:GetText()
			if s then				
				tinsert(psIgnoredZones, t)
				PileSeller:PopulateList(UIConfig.ignoredScroll.content, psIgnoredZones, 258, true)
			else
				local index = PileSeller:IsIgnored(t)
				tremove(psIgnoredZones, index)
				PileSeller:PopulateList(UIConfig.ignoredScroll.content, psIgnoredZones, 258, true)
			end
			UIConfig.txtAddIgnoreZone:SetText("")
		end
		)
	else UIConfig.btnAddIgnoreZone:Show() end

	if not UIConfig.ignoredScroll:GetScrollChild() then
		UIConfig.ignoredScroll:SetScrollChild(UIConfig.ignoredScroll.content)
	end
end

function CreateConfigSection(UIConfig)
	HideAllFromConfig(UIConfig)
	local y = -30
	for i = 1, #PileSeller.settings do
		PileSeller:CreateCheckButton(PileSeller.settings[i], UIConfig, y)
		y = y - 25
	end
end

function PileSeller:CreateCheckButton(check, parent, y)
	local name = check.name
	local sub = check.sub and 50 or 30
	local width = check.sub and 335 or 400
	local text = check.text
	parent[name] = CreateFrame("CheckButton", "chk" .. name, UIConfig, "UICheckButtonTemplate")
	parent[name]:SetChecked(psSettings[name])
	if not check.f then
		parent[name]:SetScript("OnClick", function()
			local b = parent[name]:GetChecked()
			psSettings[name] = parent[name]:GetChecked()
			if check.masterOf then ToggleCheckAndText(parent, check.masterOf, b) end
		end
		)
	else parent[name]:SetScript("OnClick", check.f) end
	parent[name]:SetPoint("TOPLEFT", parent, sub, y)
	local chkWidth = parent[name]:GetWidth()
	
	parent[name].lbl = parent[name]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	parent[name].lbl:SetPoint("LEFT", parent[name], chkWidth, 0, "RIGHT")
	parent[name].lbl:SetWordWrap(true)
	parent[name].lbl:SetWidth(width)
	parent[name].lbl:SetJustifyH("LEFT")
	parent[name].lbl:SetText(text)
	parent[name].lbl:SetTextColor(253/255, 209/255, 22/255,1)
	if check.slaveOf then ToggleCheckAndText(parent, name, psSettings[check.slaveOf]) end
	
	parent[name]:SetParent(parent)
end

function PileSeller:UpdateUIInfo()
	local p = GetSell()
	if PileSeller.UIConfig.toSellScroll and PileSeller.UIConfig.savedScroll then
		PileSeller.UIConfig.toSellScroll.lblTitle.lblDesc:SetText("Items to sell: " .. #psItems .. "|nProfit: " .. p)
		PileSeller.UIConfig.savedScroll.lblTitle.lblDesc:SetText("Items saved: " .. #psItemsSaved .. "|nItems found: " .. PileSeller:tablelength(psItemsSavedFound))
	end
end

function PileSeller:PileSeller_MinimapButton_Reposition()
	PileSeller_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(psSettings["minimapButtonPos"])),(80*sin(psSettings["minimapButtonPos"]))-52)
end

-- Only while the button is dragged this is called every frame
function PileSeller_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	psSettings["minimapButtonPos"] = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	PileSeller:PileSeller_MinimapButton_Reposition() -- move the button
end

function PileSeller_MinimapButton_OnClick()
	if PileSeller.UIConfig then 
		if PileSeller.UIConfig:IsShown() then 
			HideConfig() 
		else PileSeller:ShowConfig("items")end
	else PileSeller:ShowConfig("items") end
end

function PileSeller_MinimapButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
	local s = "|cFFFFFFFFPileSeller|r|n"
	if psSettings["trackSetting"] then
		s = s .. "|cFF00FF00Tracking|r|nGoing to sell " .. #psItems .. " item(s)"
	else 
		s = s .. "|cFFFF0000Not tracking|r" 
	end
	GameTooltip:SetText(s)
end

function PileSeller_MinimapButton_OnLeave(self)
	GameTooltip:Hide()
end



function collectionJournalToggled(closeNow)
	if PileSeller.UIConfig then
		--print("found UIConfig")
		if PileSeller.UIConfig.itemInfos then
			--print("found UIConfig.itemInfos")
			if PileSeller.UIConfig.itemInfos.item.itemSource then
				--print(PileSeller.UIConfig.itemInfos.item.itemSource:GetText())
				if PileSeller.UIConfig.itemInfos.item.itemSource:GetText() == "Load Sources" then
					--print("kekeke")
					PileSeller.UIConfig.itemInfos.item.itemSource:SetText("Show Sources")

					local id = PileSeller.UIConfig.itemInfos.item.itemID:GetText()
					id = string.gsub(id, "|cFF" .. PileSeller.color .. "Item ID:|r ", "")
					--print(id)
					id = tonumber(id)
					PileSeller.UIConfig.itemInfos.item.itemSource:SetScript("OnClick", function() 
						if not PileSeller.UIConfig.itemInfos.miniDialog then CreateMiniDialog(PileSeller.UIConfig.itemInfos) end
						SetMiniDialogInfo(PileSeller.UIConfig.itemInfos, select(2, GetItemInfo(id)))
					end)
				end
			end
		end
	end
end
hooksecurefunc("ToggleCollectionsJournal", collectionJournalToggled)
