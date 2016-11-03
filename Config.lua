local PileSeller = _G.PileSeller
local checkIcon = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:15:15|t"


local lastClicked 

function GetStaticPopup(name)
	for i = 1, #StaticPopup_DisplayedFrames do 
		if StaticPopup_DisplayedFrames[i]:GetName() == name then return i end
	end
	return nil
end


function PileSeller:CreateCunstomStaticPopup(text)
	if not _G["PS_TOGGLE_TRACKING"] then
		local popup = CreateFrame("Frame", "PS_TOGGLE_TRACKING", UIParent)
		popup:SetFrameStrata("DIALOG")
		popup:SetSize(320, 72)
		popup.text = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		popup.text:SetText(text)
		popup.text:SetPoint("TOP", popup, "TOP", 0, -15)
		local displayedFrames = StaticPopup_DisplayedFrames
		if not StaticPopup_DisplayedFrames[1] then
			popup:SetPoint("TOP", UIParent, "TOP", 0, -135)
		else 
			popup:SetPoint("TOP", StaticPopup_DisplayedFrames[1], "BOTTOM")
		end
		tinsert(StaticPopup_DisplayedFrames, popup)
		popup:Show()

		local backdrop = {
			bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],  
			edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
			tile = true,
			tileSize = 32,
			edgeSize = 32,
			insets = {
				left = 11,
				right = 12,
				top = 12,
				bottom = 11
			}
		}
		popup:SetBackdrop(backdrop)
		local Y, X = 45, 25
		local lines = 1
		for i = 1, PileSeller:tablelength(PileSeller.itemsToKeep) do
		PileSeller:CreateCheckIcon(PileSeller.itemsToKeep[i], popup, -Y, X, 35)
			X = X + 40
			if X >= 305 then
				Y = Y + 40
				X = 25 + ( 40 * 2)
				lines = lines + 1
			end
		end
		local height = 50 * lines + 80
		popup:SetHeight(height)

		popup.button1 = CreateFrame("Button", nil, popup, "StaticPopupButtonTemplate")
		popup.button1:SetPoint("BOTTOM", popup, "BOTTOM", -70, 15)

		popup.button2 = CreateFrame("Button", nil, popup, "StaticPopupButtonTemplate")
		popup.button2:SetPoint("BOTTOM", popup, "BOTTOM", 70, 15)

		popup.button1:SetText("Yes")
		popup.button2:SetText("No")

		popup.button1:SetScript("OnClick", function()
			PileSeller:ToggleTracking(true, popup)
			popup:Hide()
		end)
		popup.button2:SetScript("OnClick", function() popup:Hide() end)

		popup:SetScript("OnHide", function() 
			local index = GetStaticPopup("PS_TOGGLE_TRACKING")
			if index then
				tremove(StaticPopup_DisplayedFrames, index)
			end
		end)
	else _G["PS_TOGGLE_TRACKING"]:Show() end
end
--PileSeller:CreateCunstomStaticPopup(PileSeller.wishToTrack)

--- Function to write all the contents of a scroll frame
--- inputs:
--- 	list 	= scrollframe to fill
--- 	items 	= list of the items (eg. psItems)
--- 	literal = wether it's something to get id from or not (eg. ignored zone list)
--- outbut: none
function PileSeller:PopulateList(list, items, width, literal, drops)
	if not width then width = 258 end
	PileSeller:ClearAllButtons(list)
	PileSeller:debugprint(list:GetName() .. " populating")
	local item = 1
	if not literal then
		for i = 1, #items do
			local shouldHide = select(3, GetItemInfo(items[i])) == 0 and psSettings["hideJunkSetting"]
			if not shouldHide then
				PileSeller:CreateScrollButton(list, items[i], item, width, 21, drops)
				item = item + 1
			end
		end
	else
		for i = 1, #items do
			PileSeller:CreateScrollButton(list, -1, i, width, 21, items[i], drops)
		end
	end
	item = 1
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
		PileSeller.UIConfig.tutorial:SetSize(75, 75)
		PileSeller.UIConfig.tutorial:SetPoint("BOTTOMRIGHT", PileSeller.UIConfig, "BOTTOMRIGHT", 15, -15)
		PileSeller.UIConfig.tutorial:SetNormalTexture("Interface\\COMMON\\help-i")
		PileSeller.UIConfig.tutorial:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

		if not psTutorialDone then
			PileSeller:CreateRing(PileSeller.UIConfig.tutorial)
		end

		PileSeller.UIConfig.tutorial:SetScript("OnClick", function()
				PileSeller:ToggleTutorial(PileSeller.UIConfig)
				psTutorialDone = true
				if PileSeller.UIConfig.tutorial.glow then
					PileSeller.UIConfig.tutorial.glow:Hide()
				end
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
			PileSeller:debugprint(name)
			local kid = 
				name == "PileSeller_ConfigFrame_CloseButton" or 
				name == "PileSeller_ConfigFrame_SwitchButton" or 
				name == "PileSeller_ConfigFrame_ToggleTracking" or 
				name == "PileSeller_ConfigFrame_TutorialButton" or
				(children[i]:GetName() == "PileSeller_ConfigFrame_ItemInfos" and not children[i]:IsVisible()) 
			if not kid and not children[i].donthide then 
				children[i]:Hide() 
			end
		end
	end
end

--- Function to create the item info window
function CreateItemInfos(UIConfig)
	HideAllFromConfig(UIConfig)

	UIConfig.itemInfos = CreateFrame("Frame", "PileSeller_ConfigFrame_ItemInfos", UIConfig, "ThinBorderTemplate")
	UIConfig.itemInfos:SetSize(225, 300)
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
			UIConfig.itemInfos.item[infos[i].name]:SetSize(200, 40)
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

function PileSeller:CreateScroll(parent, name, width, height, noBorder, noBackground)
	local f = CreateFrame("ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
	f:SetSize(width, height)
	f:SetClampedToScreen(true)
	f:EnableMouseWheel(true)
	_G[name .. "ScrollBar"]:SetParent(parent)
	_G[name .. "ScrollBar"]:Show()
	f:SetClipsChildren(true) -- 7.1 thingie
	

	if not noBackground then
		local tex = f:CreateTexture(nil, "BACKGROUND")
		tex:SetTexture([[Interface\Buttons\WHITE8X8]])
		tex:SetVertexColor(.27,.27,.27,1)
		tex:SetAllPoints()
	end
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
		--local step = ((max / 21) * 5) -- how much i should move. 21 = height of the button. 5 = speed
		_G[name .. "ScrollBar"]:SetMinMaxValues(0, max)
		local move = 13 * -delta
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
		UIConfig.savedScroll.ScrollBar:Show();
	end
	PileSeller:PopulateList(UIConfig.savedScroll.content, psItemsSaved, 258)

	if not UIConfig.savedScroll.lblTitle then
		UIConfig.savedScroll.lblTitle = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		UIConfig.savedScroll.lblTitle:SetText("Saved items list")
		UIConfig.savedScroll.lblTitle:SetPoint("TOPRIGHT", UIConfig.savedScroll, UIConfig.savedScroll.lblTitle:GetWidth() + 30, 0)
		UIConfig.savedScroll.lblTitle:SetParent(UIConfig)		
	else UIConfig.savedScroll.lblTitle:Show() end

	if not UIConfig.savedScroll.lblTitle.lblDesc then
		UIConfig.savedScroll.lblTitle.lblDesc = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		UIConfig.savedScroll.lblTitle.lblDesc:SetText("Items saved: " .. #psItemsSaved .. "|nItems found: " .. PileSeller:tablelength(psItemsSavedFound))
		UIConfig.savedScroll.lblTitle.lblDesc:SetPoint("LEFT", UIConfig.savedScroll.lblTitle, 0, -UIConfig.savedScroll.lblTitle:GetHeight() - 10)
		UIConfig.savedScroll.lblTitle.lblDesc:SetJustifyH("LEFT")
		UIConfig.savedScroll.lblTitle.lblDesc:SetParent(UIConfig)
	else UIConfig.savedScroll.lblTitle.lblDesc:Show() end

	-- Creating the add item bar
	if not UIConfig.txtAddSavedItem then 
		UIConfig.txtAddSavedItem = CreateFrame("EditBox", nil, UIConfig)
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
			if t and #t > 0 then
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
			else if t and #t == 0 then
				UIConfig.txtAddSavedItem:SetText("You have to input an ID or a link")
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
	else UIConfig.toSellScroll:Show(); UIConfig.toSellScroll:EnableMouseWheel(true); UIConfig.toSellScroll.ScrollBar:Show(); end
	PileSeller:PopulateList(UIConfig.toSellScroll.content, psItems, 258)

	if not UIConfig.toSellScroll.lblTitle then
		UIConfig.toSellScroll.lblTitle = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		UIConfig.toSellScroll.lblTitle:SetText("To sell items list")
		UIConfig.toSellScroll.lblTitle:SetPoint("TOPRIGHT", UIConfig.toSellScroll, UIConfig.toSellScroll.lblTitle:GetWidth() + 30, 0)	
		UIConfig.toSellScroll.lblTitle:SetParent(UIConfig)	
	else UIConfig.toSellScroll.lblTitle:Show() end

	if not UIConfig.toSellScroll.lblTitle.lblDesc then
		UIConfig.toSellScroll.lblTitle.lblDesc = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		local p = GetSell()
		UIConfig.toSellScroll.lblTitle.lblDesc:SetText("Items to sell: " .. #psItems .. "|nProfit: " .. p)
		UIConfig.toSellScroll.lblTitle.lblDesc:SetPoint("LEFT", UIConfig.toSellScroll.lblTitle, 0, -UIConfig.toSellScroll.lblTitle:GetHeight() - 10)	
		UIConfig.toSellScroll.lblTitle.lblDesc:SetJustifyH("LEFT")
		UIConfig.toSellScroll.lblTitle.lblDesc:SetParent(UIConfig)
	else UIConfig.toSellScroll.lblTitle.lblDesc:Show() end

end

function CreateIgnoreZone(UIConfig)
	if not UIConfig.ignoredScroll then
		UIConfig.ignoredScroll = PileSeller:CreateScroll(UIConfig, "PileSeller_ConfigFrame_IgnoredScroll", 260, 55)
		UIConfig.ignoredScroll:SetPoint("BOTTOM", UIConfig.toSellScroll, 0, -65)
		UIConfig.ignoredScroll:SetParent(UIConfig)		
	else UIConfig.ignoredScroll:Show(); UIConfig.ignoredScroll:EnableMouseWheel(true); UIConfig.ignoredScroll.ScrollBar:Show(); end
	PileSeller:PopulateList(UIConfig.ignoredScroll.content, psIgnoredZones, 258, true)

	-- Creating the add item bar
	if not UIConfig.txtAddIgnoreZone then 
		UIConfig.txtAddIgnoreZone = CreateFrame("EditBox", nil, UIConfig)
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
		UIConfig.ignoredScroll.lblTitle = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		UIConfig.ignoredScroll.lblTitle:SetText("Ignored zone list")
		UIConfig.ignoredScroll.lblTitle:SetPoint("TOPRIGHT", UIConfig.ignoredScroll, UIConfig.ignoredScroll.lblTitle:GetWidth() + 30, 0)	
		UIConfig.ignoredScroll.lblTitle:SetParent(UIConfig)	
	else UIConfig.ignoredScroll.lblTitle:Show() end

	if not UIConfig.ignoredScroll.lblTitle.lblDesc then
		UIConfig.ignoredScroll.lblTitle.lblDesc = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetText("You are currently in:|n|cFF" .. PileSeller.color .. GetZoneText() .. "|r")
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetWidth(125)
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetJustifyH("LEFT")
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetPoint("LEFT", UIConfig.ignoredScroll.lblTitle, 0, -UIConfig.ignoredScroll.lblTitle:GetHeight() - 10)	
		UIConfig.ignoredScroll.lblTitle.lblDesc:SetParent(UIConfig)	
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
	UIConfig.savedScroll.lblTitle:Hide()
	UIConfig.savedScroll.lblTitle.lblDesc:Hide()
	UIConfig.toSellScroll.lblTitle:Hide()
	UIConfig.toSellScroll.lblTitle.lblDesc:Hide()
	UIConfig.ignoredScroll.lblTitle:Hide()
	UIConfig.ignoredScroll.lblTitle.lblDesc:Hide()


	----------- Creating the buttons
	UIConfig.tab1Button = CreateFrame("Button", "PileSeller_ConfigFrame_Tab1Button", UIConfig, "GameMenuButtonTemplate")
	UIConfig.tab1Button:SetText("General Options")
	UIConfig.tab1Button:SetSize(120, 25)
	UIConfig.tab1Button:SetPoint("TOPLEFT", UIConfig, "TOPLEFT", 30, -40)
	UIConfig.tab2Button = CreateFrame("Button", "PileSeller_ConfigFrame_Tab2Button", UIConfig, "GameMenuButtonTemplate")
	UIConfig.tab2Button:SetText("Items to Keep")
	UIConfig.tab2Button:SetSize(120, 25)
	UIConfig.tab2Button:SetPoint("RIGHT", UIConfig.tab1Button, "RIGHT", 120, 0)


	UIConfig.tab1Button:SetScript("OnClick", function(self)
		local other = UIConfig.tab2Button
		local otherpage = UIConfig.configContainer.configPage2
		local page = UIConfig.configContainer.configPage1 

		self.Text:SetTextColor(1,1,1)
		other.Text:SetTextColor(253/255, 209/255, 22/255)
		page:Show()
		otherpage:Hide()
	end)

	UIConfig.tab2Button:SetScript("OnClick", function(self)
		local other = UIConfig.tab1Button
		local otherpage = UIConfig.configContainer.configPage1
		local page = UIConfig.configContainer.configPage2

		self.Text:SetTextColor(1,1,1)
		other.Text:SetTextColor(253/255, 209/255, 22/255)
		page:Show()
		otherpage:Hide()

		if page["keepBoes"].dropdown then
			 page["keepBoes"].dropdown.frame:Hide()
		end

		if page["keepRecipes"].dropdown then
			page["keepRecipes"].dropdown.frame:Hide()
		end

		if page["keepItemQuality"].dropdown then
			page["keepItemQuality"].dropdown.frame:Hide()
		end
	end)
	---------------------------------

	----------- Creating the container
	UIConfig.configContainer = CreateFrame("Frame", "PileSeller_ConfigFrame_Pages", UIConfig)
	UIConfig.configContainer:SetSize(450, 325)
	UIConfig.configContainer:SetPoint("TOPLEFT", UIConfig.tab1Button, "TOPLEFT", 0, -25)
	---------------------------------

	----------- Creating the pages
	UIConfig.configContainer.configPage1 = CreateFrame("Frame", "PileSeller_ConfigFrame_Page1", UIConfig.configContainer, "InsetFrameTemplate3")
	UIConfig.configContainer.configPage1:SetSize(450, 325)
	UIConfig.configContainer.configPage1:SetPoint("TOPLEFT", UIConfig.tab1Button, "TOPLEFT", 0, -25)
	UIConfig.configContainer.configPage2 = CreateFrame("Frame", "PileSeller_ConfigFrame_Page2", UIConfig.configContainer, "InsetFrameTemplate3")
	UIConfig.configContainer.configPage2:SetSize(450, 325)
	UIConfig.configContainer.configPage2:SetPoint("TOPLEFT", UIConfig.tab1Button, "TOPLEFT", 0, -25)
	---------------------------------
	UIConfig.tab1Button.Text:SetTextColor(1,1,1)
	UIConfig.tab2Button.Text:SetTextColor(253/255, 209/255, 22/255)
	UIConfig.configContainer.configPage1:Show()
	UIConfig.configContainer.configPage2:Hide()

	UIConfig.configContainer.configPage1.configScroller = PileSeller:CreateScroll(UIConfig.configContainer.configPage1, "PileSeller_ConfigFrame_Page1_ConfigScroller", UIConfig.configContainer.configPage1:GetWidth() - 20, UIConfig.configContainer.configPage1:GetHeight() - 40, true, true)
	UIConfig.configContainer.configPage1.configScroller:SetPoint("CENTER", UIConfig.configContainer.configPage1, "CENTER", -35, 0)
	local parent = UIConfig.configContainer.configPage1.configScroller.content
	local y = 0
	for i = 1, #PileSeller.settings do
		PileSeller:CreateCheckButton(PileSeller.settings[i], parent, y)
		y = y - 35
		if PileSeller.settings[i].name == "speedTweaker" then
			if not psSettings["speedTweakerValue"] then
				psSettings["speedTweakerValue"] = 1.5
			end 
			parent.speedTweaker.questionButton = CreateFrame("Button", "PileSeller_ConfigFrame_ConfigScroller_SpeedTweaker_Tutorial", parent.speedTweaker)
			parent.speedTweaker.questionButton:SetNormalTexture([[Interface\BUTTONS\UI-MicroButton-Help-Up]])
			parent.speedTweaker.questionButton:SetPushedTexture([[Interface\BUTTONS\UI-MicroButton-Help-Up]])
			parent.speedTweaker.questionButton:SetHighlightTexture([[Interface\Buttons\UI-MicroButton-Hilight]], "ADD")
			parent.speedTweaker.questionButton:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
				GameTooltip:SetSize(200, 200)
				GameTooltip:AddLine("|cFFFFFFFFSpeed Tweaking|r")
				GameTooltip:AddLine("This option defines how fast the selling process is.")
				GameTooltip:AddLine("This is an advanced option and, being lower than the default value (1.5) can have unintended behavior (such as skipping items or entire bags) and is especially bound to your latency.", nil, nil, nil, true)
				GameTooltip:Show()
			end)

			parent.speedTweaker.questionButton:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			
			parent.speedTweaker.questionButton:SetPoint("RIGHT", parent.speedTweaker.lbl, -50, 10)
			parent.speedTweaker.questionButton:SetSize(30, 50)

			y = y - 25
			parent.speedTweakerSlider = CreateFrame("Slider", "PileSeller_ConfigFrame_ConfigScroller_SpeedTweakerSlider", parent, "OptionsSliderTemplate")
			parent.speedTweakerSlider:SetPoint("TOPLEFT", parent, 80, y + 15)
			parent.speedTweakerSlider:SetOrientation("HORIZONTAL")
			parent.speedTweakerSlider:SetMinMaxValues(.5, 2.0)
			parent.speedTweakerSlider:SetValue(psSettings["speedTweakerValue"])
			parent.speedTweakerSlider:SetValueStep(.5)
			parent.speedTweakerSlider:SetObeyStepOnDrag(true)
			parent.speedTweakerSlider:SetSize(100, 20)
			parent.speedTweakerSlider.value = parent.speedTweakerSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			parent.speedTweakerSlider.value:SetPoint("CENTER", parent.speedTweakerSlider, 0, -15)
			parent.speedTweakerSlider.value:SetText(psSettings["speedTweakerValue"])



            parent.speedTweakerSlider:SetEnabled(psSettings["speedTweaker"])
            if psSettings["speedTweaker"] then
                parent.speedTweakerSlider.value:SetTextColor(253/255, 209/255, 22/255,1)
            else
                parent.speedTweakerSlider.value:SetTextColor(153/255, 153/255, 153/255, 1)
            end

            parent.speedTweakerSlider.High:Hide()
            parent.speedTweakerSlider.Low:Hide()
			
			parent.speedTweakerSlider:SetScript("OnValueChanged", function(self, value)
				self.value:SetText(value)
				psSettings["speedTweakerValue"] = value
			end)
			y = y - 25
		end
	end

	--UIConfig.configContainer.configPage2.configScroller = PileSeller:CreateScroll(UIConfig.configContainer.configPage2, "PileSeller_ConfigFrame_Page2_ConfigScroller", UIConfig.configContainer.configPage2:GetWidth() - 20, UIConfig.configContainer.configPage2:GetHeight() - 40, true, true)
	parent = UIConfig.configContainer.configPage2--.configScroller.content
	y = -20
	local x = 25
	local spacing = 80
	for i = 1, #PileSeller.itemsToKeep do
		PileSeller:CreateCheckIcon(PileSeller.itemsToKeep[i], parent, y, x)
		if PileSeller.itemsToKeep[i].name == "keepBoes" then
			if psSettings["keepBoes"] ~= nil then
				if psSettings["keepBoes-cloth"] == nil then psSettings["keepBoes-cloth"] = true end
				if psSettings["keepBoes-leather"] == nil then psSettings["keepBoes-leather"] = true end
				if psSettings["keepBoes-mail"] == nil then psSettings["keepBoes-mail"] = true end
				if psSettings["keepBoes-plate"] == nil then psSettings["keepBoes-plate"] = true end
				if psSettings["keepBoes-cosmetics"] == nil then psSettings["keepBoes-cosmetics"] = true end
				if psSettings["keepBoes-shields"] == nil then psSettings["keepBoes-shields"] = true end
				if psSettings["keepBoes-offhands"] == nil then psSettings["keepBoes-offhands"] = true end
				if psSettings["keepBoes-weapons"] == nil then psSettings["keepBoes-weapons"] = true end
				if psSettings["keepBoes-necks"] == nil then psSettings["keepBoes-necks"] = true end
				if psSettings["keepBoes-rings"] == nil then psSettings["keepBoes-rings"] = true end
				if psSettings["keepBoes-trinkets"] == nil then psSettings["keepBoes-trinkets"] = true end
				if psSettings["keepBoes-owned"] == nil then psSettings["keepBoes-owned"] = false end
			end
			if not parent["keepBoes"].dropdown then
				BoEFilterDropdown_Initialize(parent["keepBoes"])
			end
			if not parent["keepBoes"].checkbox then
				BoEFilterCheckbox_Initialize(parent["keepBoes"])
			end
		elseif PileSeller.itemsToKeep[i].name == "keepRecipes" then
			local name = "keepRecipes"
			if psSettings[name] ~= nil then
				if psSettings[name.."-alchemy"] == nil then psSettings[name.."-alchemy"] = true end
				if psSettings[name.."-blacksmithing"] == nil then psSettings[name.."-blacksmithing"] = true end
				if psSettings[name.."-enchanting"] == nil then psSettings[name.."-enchanting"] = true end
				if psSettings[name.."-engineering"] == nil then psSettings[name.."-engineering"] = true end
				if psSettings[name.."-inscription"] == nil then psSettings[name.."-inscription"] = true end
				if psSettings[name.."-jewelcrafting"] == nil then psSettings[name.."-jewelcrafting"] = true end
				if psSettings[name.."-leatherworking"] == nil then psSettings[name.."-leatherworking"] = true end
				if psSettings[name.."-tailoring"] == nil then psSettings[name.."-tailoring"] = true end
				if psSettings[name.."-cooking"] == nil then psSettings[name.."-cooking"] = true end
				if psSettings[name.."-fishing"] == nil then psSettings[name.."-fishing"] = true end
				if psSettings[name.."-firstaid"] == nil then psSettings[name.."-firstaid"] = true end
			end
			if not parent[name].dropdown then
				RecipeFilterDropdown_Initialize(parent[name])
			end
		elseif PileSeller.itemsToKeep[i].name == "keepItemLevel" then
			if psSettings["keepItemLevel"] ~= nil then
				if psSettings["keepItemLevelValue"] == nil then psSettings["keepItemLevelValue"] = 1 end
			end
			if not parent["keepItemLevel"].slider then
				KeepItemLevelSlider_Inizialize(parent["keepItemLevel"])
			end
		elseif PileSeller.itemsToKeep[i].name == "keepItemQuality" then
			local name = "keepItemQuality"
			if psSettings[name] ~= nil then
				if psSettings[name.."-common"] == nil then psSettings[name.."-common"] = false end
				if psSettings[name.."-uncommon"] == nil then psSettings[name.."-uncommon"] = false end
				if psSettings[name.."-rare"] == nil then psSettings[name.."-rare"] = false end
				if psSettings[name.."-epic"] == nil then psSettings[name.."-epic"] = false end
				if psSettings[name.."-legendary"] == nil then psSettings[name.."-legendary"] = true end
			end
			if not parent[name].dropdown then
				KeepItemQualityDropdown_Initialize(parent[name])
			end
		end
		x = x + spacing
		if x >= spacing * 5 then
			x = 25
			y = y - spacing - 25
		end
		--y = y - 35
	end
end



function KeepItemLevelSlider_Inizialize(button)
	button.slider = CreateFrame("Slider", "PileSeller_ConfigFrame_KeepItemLevel_Slider", button, "OptionsSliderTemplate")
	button.slider:SetPoint("TOP", button, 0, 0)
	button.slider:SetOrientation("HORIZONTAL")
	button.slider:SetMinMaxValues(1, 999)
	button.slider:SetValue(psSettings["keepItemLevelValue"])
	button.slider:SetValueStep(1)
	button.slider:SetObeyStepOnDrag(true)
	button.slider:SetSize(button:GetWidth(), 20)
	button.slider.value = CreateFrame("EditBox", nil, button.slider)
	button.slider.value:SetSize(button:GetWidth(), 21)
	button.slider.value:SetPoint("TOP", button.slider, "TOP", 0, -21)
	button.slider.value:SetNumeric(true)
	button.slider.value:SetMaxLetters(3)
	button.slider.value:SetAutoFocus(false)
	button.slider.value:SetText(psSettings["keepItemLevelValue"])

	button.slider.value:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	button.slider.value:SetScript("OnTextChanged", function(self)
		local number = tonumber(self:GetText())
		if number == nil then
			number = 1
		end
		psSettings["keepItemLevelValue"] = number
		self:GetParent():SetValue(number)
	end)
	
	button.slider:SetScript("OnValueChanged", function(self, value)
		self.value:SetText(value)
		psSettings["keepItemLevelValue"] = value
	end)
	
	-- Setting the EditBox properties
	button.slider.value:SetFontObject("GameFontHighlight")	-- Its font
	button.slider.value:SetTextInsets(5, 0, 0, 0)			-- Some insets for the text
	button.slider.value:SetBackdrop({						-- The border and backdrop
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
	button.slider.value:SetBackdropColor(.27,.27,.27, 1)
	button.slider.value:SetBackdropBorderColor(0, 0, 0)

	button.slider.High:Hide()
    button.slider.Low:Hide()

    if button.tex:IsDesaturated() then
    	button.slider:Hide()
    	button.slider.value:Hide()
    end

end

function KeepItemQualityDropdown_Initialize(button)
	button.dropdown = CreateFrame("BUTTON", button:GetName() .. "DropDown", button, "GameMenuButtonTemplate")
	button.dropdown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

	button.dropdown.frame = CreateFrame("BUTTON", button.dropdown:GetName() .. "Frame", button, "UIDropDownMenuTemplate")
	button.dropdown.frame:SetPoint("RIGHT", button.dropdown)
	button.dropdown:SetSize(button:GetWidth(), 21)
	UIDropDownMenu_Initialize(button.dropdown.frame, function(button)
		local info = UIDropDownMenu_CreateInfo()
		info.maxWidth = button:GetWidth() - 20
		info.text = CHECK_ALL
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = true
		info.isTitle = false
		info.func = function()
			psSettings["keepItemQuality-common"] = true
			psSettings["keepItemQuality-uncommon"] = true
			psSettings["keepItemQuality-rare"] = true
			psSettings["keepItemQuality-epic"] = true
			psSettings["keepItemQuality-legendary"] = true
		end
		UIDropDownMenu_AddButton(info, 1)
		info.keepShownOnClick = true	
		info.text = "|cFFffffffCommon|r"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepItemQuality-common"] = not psSettings["keepItemQuality-common"] end
		info.checked = psSettings["keepItemQuality-common"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "|cFF1eff00Uncommon|r"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepItemQuality-uncommon"] = not psSettings["keepItemQuality-uncommon"] end
		info.checked = psSettings["keepItemQuality-uncommon"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "|cFF0070ddRare|r"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepItemQuality-rare"] = not psSettings["keepItemQuality-rare"] end
		info.checked = psSettings["keepItemQuality-rare"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "|cFFa335eeEpic|r"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepItemQuality-epic"] = not psSettings["keepItemQuality-epic"] end
		info.checked = psSettings["keepItemQuality-epic"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "|cFFff8000Legendary|r"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepItemQuality-legendary"] = not psSettings["keepItemQuality-legendary"] end
		info.checked = psSettings["keepItemQuality-legendary"]
		UIDropDownMenu_AddButton(info, 1)
	end, "MENU")
	button.dropdown:SetText("Qualities")

	button.dropdown:SetScript("OnClick", function(self)
		ToggleDropDownMenu(1, nil, self.frame, self, 0, 0)
	end)
	if button.tex:IsDesaturated() then
		button.dropdown:Hide()
	else button.dropdown:Show() end
end

function BoEFilterCheckbox_Initialize(button)
	button.checkbox = CreateFrame("CheckButton",button:GetName().."chk", button, "UICheckButtonTemplate")
	button.checkbox:SetSize(25, 25)
	button.checkbox:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, -25)
	button.checkbox:SetChecked(psSettings["keepBoes-owned"])
	button.checkbox.lbl = button.checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.checkbox.lbl:SetText("Not owned")
	button.checkbox.lbl:SetPoint("LEFT", button.checkbox, 25, 0, "RIGHT")
	button.checkbox.lbl:SetFont("Fonts\\FRIZQT__.TTF", 9)

	if psSettings["keepBoes-owned"] then button.checkbox:Show()
	else button.checkbox:Hide() end

	button.checkbox:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetSize(30, 30)
		GameTooltip:AddLine("Keep only items which you don't own the appearance", 253/255, 209/255, 22/255, true)			
		GameTooltip:Show()
	end)
	button.checkbox:SetScript("OnLeave", function(self)			
		GameTooltip:Hide()
	end)
end

function RecipeFilterDropdown_Initialize(button)
	button.dropdown = CreateFrame("BUTTON", button:GetName() .. "DropDown", button, "GameMenuButtonTemplate")
	button.dropdown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

	button.dropdown.frame = CreateFrame("BUTTON", button.dropdown:GetName() .. "Frame", button, "UIDropDownMenuTemplate")
	button.dropdown.frame:SetPoint("RIGHT", button.dropdown)
	button.dropdown:SetSize(button:GetWidth(), 21)
	UIDropDownMenu_Initialize(button.dropdown.frame, function(button)
		local info = UIDropDownMenu_CreateInfo()
		info.maxWidth = button:GetWidth() - 20
		info.text = CHECK_ALL
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = true
		info.isTitle = false
		info.func = function()
			psSettings["keepRecipes-alchemy"] = true
			psSettings["keepRecipes-blacksmithing"] = true
			psSettings["keepRecipes-enchanting"] = true
			psSettings["keepRecipes-engineering"] = true
			psSettings["keepRecipes-inscription"] = true
			psSettings["keepRecipes-jewelcrafting"] = true
			psSettings["keepRecipes-leatherworking"] = true
			psSettings["keepRecipes-tailoring"] = true
			psSettings["keepRecipes-cooking"] = true
		end
		UIDropDownMenu_AddButton(info, 1)
		info.keepShownOnClick = true	
		info.text = "Alchemy"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-alchemy"] = not psSettings["keepRecipes-alchemy"] end
		info.checked = psSettings["keepRecipes-alchemy"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Blacksmithing"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-blacksmithing"] = not psSettings["keepRecipes-blacksmithing"] end
		info.checked = psSettings["keepRecipes-blacksmithing"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Enchanting"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-enchanting"] = not psSettings["keepRecipes-enchanting"] end
		info.checked = psSettings["keepRecipes-enchanting"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Engineering"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-engineering"] = not psSettings["keepRecipes-engineering"] end
		info.checked = psSettings["keepRecipes-engineering"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Inscription"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-inscription"] = not psSettings["keepRecipes-inscription"] end
		info.checked = psSettings["keepRecipes-inscription"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Jewelcrafting"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-jewelcrafting"] = not psSettings["keepRecipes-jewelcrafting"] end
		info.checked = psSettings["keepRecipes-jewelcrafting"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Leatherworking"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-leatherworking"] = not psSettings["keepRecipes-leatherworking"] end
		info.checked = psSettings["keepRecipes-leatherworking"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Tailoring"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-tailoring"] = not psSettings["keepRecipes-tailoring"] end
		info.checked = psSettings["keepRecipes-tailoring"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Cooking"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-cooking"] = not psSettings["keepRecipes-cooking"] end
		info.checked = psSettings["keepRecipes-cooking"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Fishing"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-fishing"] = not psSettings["keepRecipes-fishing"] end
		info.checked = psSettings["keepRecipes-fishing"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "First Aid"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepRecipes-firstaid"] = not psSettings["keepRecipes-firstaid"] end
		info.checked = psSettings["keepRecipes-firstaid"]
		UIDropDownMenu_AddButton(info, 1)


	end, "MENU")
	--UIDropDownMenu_SetWidth(button.dropdown, 250)
	button.dropdown:SetText("Profs.")

	button.dropdown:SetScript("OnClick", function(self)
		ToggleDropDownMenu(1, nil, self.frame, self, 0, 0)
	end)
	if button.tex:IsDesaturated() then
		button.dropdown:Hide()
	else button.dropdown:Show() end
end

function BoEFilterDropdown_Initialize(button)
	button.dropdown = CreateFrame("BUTTON", button:GetName() .. "DropDown", button, "GameMenuButtonTemplate")
	button.dropdown:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

	button.dropdown.frame = CreateFrame("BUTTON", button.dropdown:GetName() .. "Frame", button, "UIDropDownMenuTemplate")
	button.dropdown.frame:SetPoint("RIGHT", button.dropdown)
	button.dropdown:SetSize(button:GetWidth(), 21)
	UIDropDownMenu_Initialize(button.dropdown.frame, function(button)
		local info = UIDropDownMenu_CreateInfo()
		info.maxWidth = button:GetWidth() - 20
		info.text = CHECK_ALL
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = true
		info.isTitle = false
		info.func = function()
			psSettings["keepBoes-cloth"] = true
			psSettings["keepBoes-leather"] = true
			psSettings["keepBoes-mail"] = true
			psSettings["keepBoes-plate"] = true
			psSettings["keepBoes-necks"] = true
			psSettings["keepBoes-rings"] = true
			psSettings["keepBoes-trinkets"] = true
		end
		UIDropDownMenu_AddButton(info, 1)
		info.keepShownOnClick = true	
		info.text = "Cloth"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-cloth"] = not psSettings["keepBoes-cloth"] end
		info.checked = psSettings["keepBoes-cloth"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Leather"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-leather"] = not psSettings["keepBoes-leather"] end
		info.checked = psSettings["keepBoes-leather"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Mail"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-mail"] = not psSettings["keepBoes-mail"] end
		info.checked = psSettings["keepBoes-mail"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Plate"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-plate"] = not psSettings["keepBoes-plate"] end
		info.checked = psSettings["keepBoes-plate"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Cosmetics"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-cosmetics"] = not psSettings["keepBoes-cosmetics"] end
		info.checked = psSettings["keepBoes-cosmetics"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Shields"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-shields"] = not psSettings["keepBoes-shields"] end
		info.checked = psSettings["keepBoes-shields"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Off Hands"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-offhands"] = not psSettings["keepBoes-offhands"] end
		info.checked = psSettings["keepBoes-offhands"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "~~~~~~~~~~~~"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = true
		info.func = nil
		info.checked = nil
		info.notClickable = true
		UIDropDownMenu_AddButton(info, 1)
		
		info = UIDropDownMenu_CreateInfo()
		info.maxWidth = button:GetWidth() - 20
		info.keepShownOnClick = true

		info.text = "Weapons"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-weapons"] = not psSettings["keepBoes-weapons"] end
		info.checked = psSettings["keepBoes-weapons"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Necks"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-necks"] = not psSettings["keepBoes-necks"] end
		info.checked = psSettings["keepBoes-necks"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Rings"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-rings"] = not psSettings["keepBoes-rings"] end
		info.checked = psSettings["keepBoes-rings"]
		UIDropDownMenu_AddButton(info, 1)

		info.text = "Trinkets"
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = false
		info.func = function() psSettings["keepBoes-trinkets"] = not psSettings["keepBoes-trinkets"] end
		info.checked = psSettings["keepBoes-trinkets"]
		UIDropDownMenu_AddButton(info, 1)


	end, "MENU")
	--UIDropDownMenu_SetWidth(button.dropdown, 250)
	button.dropdown:SetText("Types")

	button.dropdown:SetScript("OnClick", function(self)
		ToggleDropDownMenu(1, nil, self.frame, self, 0, 0)
	end)
	if button.tex:IsDesaturated() then
		button.dropdown:Hide()
	else button.dropdown:Show() end
end

function PileSeller:CreateCheckIcon(button, parent, y, x, size)
	local name = button.name
	local default = button.default
	local title = button.title
	local tooltip = button.tooltip
	local active = false
	if psSettings[name] ~= nil then
		active = psSettings[name]
	else active = default end
	local icon = "Interface\\ICONS\\" .. button.icon
	if not size then size = 75 end

	parent[name] = CreateFrame("Button", "btn" .. name, parent)
	parent[name]:SetSize(size, size)
	parent[name].tex = parent[name]:CreateTexture()
	parent[name].tex:SetTexture(icon)
	parent[name].tex:SetAllPoints()
	parent[name].tex:SetDesaturated(not active)
	parent[name]:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

	parent[name]:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	parent[name]:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:SetSize(30, 30)
		GameTooltip:AddLine("|cFFFFFFFF" .. title .. "|r")
		GameTooltip:AddLine(tooltip, 253/255, 209/255, 22/255, true)			
		GameTooltip:Show()
	end)
	parent[name]:SetScript("OnClick", function(self)
		local desaturated = self.tex:IsDesaturated()
		if desaturated then
			psSettings[name] = true
			self.tex:SetDesaturated(false)
			if parent:GetName() ~= "PS_TOGGLE_TRACKING" then
				if name == "keepBoes" or name == "keepRecipes" then
					parent[name].dropdown:Show()
					if parent[name].checkbox then
						parent[name].checkbox:Show()
					end
				elseif name == "keepItemLevel" then
					parent[name].slider:Show()
					parent[name].slider.value:Show()
				elseif name == "keepItemQuality" then
					parent[name].dropdown:Show()
				end
			end
		else
			psSettings[name] = false
			self.tex:SetDesaturated(true)
			if parent:GetName() ~= "PS_TOGGLE_TRACKING" then
				if name == "keepBoes" or name == "keepRecipes" then
					parent[name].dropdown:Hide()
					if parent[name].checkbox then
						parent[name].checkbox:Hide()
					end
				elseif name == "keepItemLevel" then
					parent[name].slider:Hide()
					parent[name].slider.value:Hide()
				elseif name == "keepItemQuality" then
					parent[name].dropdown:Hide()
				end
			end
		end
	end)
	parent[name]:SetScript("OnLeave", function() GameTooltip:Hide() end)

end

function PileSeller:CreateCheckButton(check, parent, y)
	local name = check.name
	local sub = check.sub and 50 or 30
	local width = check.sub and 325 or 350
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
	parent[name].lbl:SetFont("Fonts\\FRIZQT__.TTF", 14)
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
