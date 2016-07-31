--[[
  /ps start
  /ps stop
  /ps ignorezone {Name}          		//Ignore a zone
  /ps alert {link}						//Pupup on drop
  ]]

-- Developing purposes------------------------
for i = 1, NUM_CHAT_WINDOWS do
	_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
end
----------------------------------------------
local PileSeller = _G.PileSeller
local psFrame, psEvents = CreateFrame("FRAME", "PileSeller_Frame"), {}
local canTrack = true
local waitingForItem = {false, "000000"}
PileSeller.selling = false
function psEvents:ADDON_LOADED(...)
	addoname = select(1,...)
	if addoname == "PileSeller" then
		if psSettings["debug"] then
			PileSeller:Print("|cFFFF0000THE DEBUG MODE IS ACTIVATED. IF YOU DON'T WISH SO, PLEASE TYPE /ps debug ON YOUR CHAT OR ELSE YOU WILL PROBABLY ENCOUNTER A LOT OF SPAM")
		end
		if psSettings["hideMinimapButton"] then
			print("|cFF" .. PileSeller.color .. "Pile|rSeller loaded. Type /pileseller o /ps to get into it!" )
			PileSeller_MinimapButton:Hide()
		else PileSeller_MinimapButton:Show() end
		if psItems then
			for i=1, #psItems do
				GetItemInfo(psItems[i])
			end
		end

		if psItemsSaved then
			for i=1, #psItemsSaved do
				GetItemInfo(psItemsSaved[i])
			end
		end
		PileSeller:PileSeller_MinimapButton_Reposition()
		tinsert(UISpecialFrames, "PileSeller_ConfigFrame") 
		tinsert(UISpecialFrames, "PileSeller_SellingBoxFrame")
		tinsert(UISpecialFrames, "PileSeller_SellingFrame")
		PileSeller:LoadArtifacts()
	end
end


function psEvents:CHAT_MSG_LOOT(...)
	--print(canTrack)
	local player = UnitName("player")
	local sender = select(5, ...)
	if #psIgnoredZones > 0 then 
		local zoneName = GetZoneText()
		if PileSeller:IsIgnored(zoneName) then return end
	end
	if canTrack and psSettings["trackSetting"] and (player == sender) then
		local item = select(1,...) -- This is the link of the item (with some crap text)
		item = PileSeller:getID(item)
		if item then
			if PileSeller:isSaved(item) and psItemsAlert[item] then
				local data = { name = select(1, GetItemInfo(item)), texture = select(10, GetItemInfo(item))}
				PileSeller:CreateAlert(data)
				--message("|cFF" .. PileSeller.color .. "Found |r " .. select(2, GetItemInfo(item)) .. "|cFF" .. PileSeller.color .. ". yay!|r")
			elseif select(11, GetItemInfo(item)) > 0 then
				if not PileSeller:KeepItem(item) then
					if PileSeller.UIConfig then
						if PileSeller.UIConfig:IsShown() then
							if  PileSeller.UIConfig.toSellScroll ~= nil then
								PileSeller:addItem(item, psItems, PileSeller.UIConfig.toSellScroll.content)
								PileSeller:UpdateUIInfo()
							end
						else tinsert(psItems, item) end
					else tinsert(psItems, item) end
				end
			end
		end
	end
end

function PileSeller:IsOwned(id)
	return C_TransmogCollection.PlayerHasTransmog(id)
end

function PileSeller:IsBoE(id)
	local f = CreateFrame('GameTooltip', 'PileSellerScanningTooltip', UIParent, 'GameTooltipTemplate')
	f:SetOwner(UIParent, 'ANCHOR_NONE') 
	f:SetItemByID(id)
	for i = 1, f:NumLines() do
		local t = _G["PileSellerScanningTooltipTextLeft" .. i]:GetText()
		if t == ITEM_BIND_ON_EQUIP then 
			--return true
			local returner = true
			if psSettings["keepTrasmogs"] then
				if psSettings["keepTrasmogsNotOwned"] then
					returner = not PileSeller:IsOwned(id)
				end
				returner = returner and PileSeller:CanTransmog(id)
			elseif psSettings["keepTrasmogsNotOwned"] then
				returner = not PileSeller:IsOwned(id)
			end
			return returner
		end
	end
	return false
end

function PileSeller:IsToken(item)
	local reqlevel, class = select(5, GetItemInfo(item)), select(6, GetItemInfo(item))
	if class == MISCELLANEOUS then
	    if select(3, GetItemInfo(item)) == 4 then 
	        if PileSeller:IsWearable(item) then
	        	return PileSeller:IsTier(reqlevel, item)
	        end      
	    end
	end
end

function PileSeller:CanTransmog(item)
	--[[
		C_Transmog.GetItemInfo(ID)
		Return:
			[1] = canBeChanged
			[2] = noChangeReason
			[3] = canBeSource
			[4] = noSourceReason
	]]--
	local canBeSource = select(3, C_Transmog.GetItemInfo(item))
	if not canBeSource then return false end
	if select(9, GetItemInfo(item)) == "INVTYPE_CLOAK" then return true end
	local class, subclass, reqlevel = select(6, GetItemInfo(item)), select(7, GetItemInfo(item)), select(5, GetItemInfo(item))
	if class == ARMOR then
		local wearerTable = {  
			-- This is the table to identify the armor type such as plate, mail, leather and cloth              
			["DEATHKNIGHT"] = select(5, GetAuctionItemSubClasses(2)),
			["DRUID"] = select(3, GetAuctionItemSubClasses(2)),
			["HUNTER"] = select(4, GetAuctionItemSubClasses(2)),
			["MAGE"] = select(2, GetAuctionItemSubClasses(2)),
			["MONK"] = select(3, GetAuctionItemSubClasses(2)),
			["PALADIN"] = select(5, GetAuctionItemSubClasses(2)),
			["PRIEST"] = select(2, GetAuctionItemSubClasses(2)),
			["ROGUE"] = select(3, GetAuctionItemSubClasses(2)),
			["SHAMAN"] = select(4, GetAuctionItemSubClasses(2)),
			["WARLOCK"] = select(2, GetAuctionItemSubClasses(2)),
			["WARRIOR"] = select(5, GetAuctionItemSubClasses(2))           
		}
		local playerClass = select(2, UnitClass("player"))
		-- if it's not something from the table above then it's a shield
		if subclass == wearerTable[playerClass] then return true 
		else 
			if subclass == select(7, GetAuctionItemSubClasses(2)) then
				-- the shield wearers
				return playerClass == "WARRIOR" or playerClass == "SHAMAN" or playerClass == "PALADIN"
			end
			return false
		end
	elseif class == WEAPON then
		return PileSeller:IsWearable(item)       
	else return false end    
end

function PileSeller:IsWearable(item)
	local playerClass = select(2, UnitClass("player"))     
	local f = CreateFrame('GameTooltip', 'PileSellerScanningTooltip', UIParent, 'GameTooltipTemplate')
	f:SetOwner(UIParent, 'ANCHOR_NONE') 
	f:SetItemByID(item) 
	local r,g,b = 0,0,0
	for i = 1, f:NumLines() do
		if _G["PileSellerScanningTooltipTextRight" .. i]:GetText() then
			r,g,b = _G["PileSellerScanningTooltipTextRight" .. i]:GetTextColor()
			if math.floor(r*256) == 255 and math.floor(g*256) == 32 and math.floor(b*256) == 32 then return false end
		end
		
		if _G["PileSellerScanningTooltipTextLeft" .. i]:GetText() then
			r,g,b = _G["PileSellerScanningTooltipTextLeft" .. i]:GetTextColor()
			if math.floor(r*256) == 255 and math.floor(g*256) == 32 and math.floor(b*256) == 32 then return false end
		end
	end
	local itemType = select(9, GetItemInfo(item))
	local isRanged = itemType == "INVTYPE_RANGED" or itemType == "INVTYPE_RANGEDRIGHT"
	if isRanged and (playerClass == "WARRIOR" or playerClass == "ROGUE") then
		return false
	end
	f:Hide()
	return true    
	--r,g,b = PileSellerScanningTooltipTextRight4:GetTextColor()
	
	--return not math.floor(r*256) == 255 and math.floor(g*256) == 32 and math.floor(b*256) == 32
end

local timer = 0
local Update_Interval = 1.5
local profit = 0
local Bag_Index = 0
local Last_Slot_Index = 1
local Index_Offset = 0
local broke = false

local function onUpdate(self, elapsed)
	if psSettings["speedTweaker"] then
		Update_Interval = psSettings["speedTweakerValue"]	
	else Update_Interval = 1.5 end
	timer = timer + elapsed
	if PileSeller.selling then
		if not PileSeller.sFrame:IsVisible() then 
			PileSeller.sFrame:Show() 
			PileSeller.sFrame.statusBar.border:SetBackdropBorderColor(0, 0, 0)
		end

		if timer >= Update_Interval then
			l = GetContainerNumSlots(Bag_Index)
			Index_Offset = ( GetContainerNumSlots(Bag_Index) / 2 )
			for i = Last_Slot_Index, Last_Slot_Index + Index_Offset do
				if not canTrack then
					--print(i .. " " .. Bag_Index)
					local item = select(7, GetContainerItemInfo(Bag_Index, i))
					local count = select(2, GetContainerItemInfo(Bag_Index, i))
					if item and not string.find(item, "battlepet") then
						if PileSeller:IsToSell(item) and not PileSeller:KeepItem(PileSeller:getID(item)) then
							PileSeller.sFrame.sellingLbl:SetText("Sold item " .. item)
							ShowMerchantSellCursor(1)
							UseContainerItem(Bag_Index, i)
							--print(select(11, GetItemInfo(item)))
							local temp = select(11, GetItemInfo(item))
							local cost = tonumber(temp)
							local _p = cost * count
							profit = profit + _p
							local rtn = PileSeller:getProfitPerCoin(profit)
							PileSeller.sFrame.profitLbl:SetText("Profit: " .. rtn)
						end
					end
					Last_Slot_Index = i
				else broke = true end
			end
			if broke then
				------------------------------------------------------------------------------------------
				-- This occurs when the player closes the shop before the end of the cycle
				------------------------------------------------------------------------------------------
				PileSeller.selling = false
				Bag_Index = 0
				Last_Slot_Index = 1
				Index_Offset = 0
				profit = 0
				broke = false
			elseif Last_Slot_Index >= l then
				------------------------------------------------------------------------------------------
				-- This occurs whenever I reach the end of a bag
				------------------------------------------------------------------------------------------
				Bag_Index = Bag_Index + 1
				Last_Slot_Index = 1
				PileSeller.sFrame.statusBar:SetValue(Bag_Index)
				if Bag_Index > NUM_BAG_SLOTS then
					------------------------------------------------------------------------------------------
					-- This is the end of the cycle and occurs when I finisced going through the bags
					------------------------------------------------------------------------------------------

					------------------------------
					-- Resetting all the variables
					------------------------------
					PileSeller.selling = false
					Bag_Index = 0
					Last_Slot_Index = 1
					Index_Offset = 10
					psItems = {}
					profit = 0
					PileSeller.sFrame.statusBar.border:SetBackdropBorderColor(1,1,1)
					if psSettings["sellJunkSetting"] then
						PileSeller:SellJunk()
					end
					if PileSeller.UIConfig then
						if PileSeller.UIConfig.toSellScroll then
							PileSeller:PopulateList(PileSeller.UIConfig.toSellScroll.content, psItems)
						end
					end
					------------------------------
					------------------------------
					------------------------------
				end
			end
			timer = 0
		end
	end
end
psFrame:SetScript("OnUpdate", onUpdate)

function PileSeller:IsIgnored(zone)
	if not zone then return false end
	for i = 1, #psIgnoredZones do
		if psIgnoredZones[i]:upper() == zone:upper() then
			return i
		end
	end
	return false
end

function PileSeller:getProfitPerCoin(profit)
	if profit == 0 then
		return "0|cFFFFD700g|r 0|cFFC0C0C0s|r 0|cFFCD7E32c|r"
	end
	local rtn = ""
	local gold = math.floor(profit / 100 / 100)
	if gold >= 1 then rtn = rtn .. gold .. "|cFFFFD700g|r " end

	local silver = math.floor((profit / 100) % 100)
	if silver >= 1 then rtn = rtn .. silver .. "|cFFC0C0C0s|r " end

	local copper = math.floor(profit % 100)
	if copper >= 1 then rtn = rtn .. copper .. "|cFFCD7E32c|r" end

	
	return rtn
end


function PileSeller:IsToSell(item)
	item = PileSeller:getID(item)
	if item then
		for i=1, #psItems do
			if item == psItems[i] then return true end
		end
		return false
	end
end

function psEvents:MERCHANT_SHOW(...)
	canTrack = false
	if psSettings["repairSetting"] and CanMerchantRepair() then
		local cost, _c = GetRepairAllCost()
		if cost ~= 0 then
			local g = psSettings["repairGuildSetting"] and CanGuildBankRepair()	and cost <= GetGuildBankWithdrawMoney()	
			RepairAllItems(g)
			local s = "Gear repaired for " .. PileSeller:getProfitPerCoin(cost)
			if g then s = s .. " with guild funds" end
			PileSeller:Print(s .. ".")
		end
	end
	if #psItems > 0 then
		if not psSettings["confSetting"] then
		  PileSeller.selling = true
		else PileSeller.sellingBox:Show() end
	elseif psSettings["sellJunkSetting"] then
		PileSeller:SellJunk()
	end
end



function PileSeller:SellJunk()
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			local item = select(7, GetContainerItemInfo(i, j))
			if item then
				local quality = select(3, GetItemInfo(item))
				local vendorable = select(11, GetItemInfo(item)) > 0
				if quality == 0  and vendorable then
					ShowMerchantSellCursor(1)
					UseContainerItem(i, j)
				end
			end
		end
	end
end

function PileSeller:ToggleTracking(set, keepTier, keepCraftingReagent, keepBoes, keepTrasmogsNotOwned, keepTrasmogs)
	if set then 
		if not psSettings["trackSetting"] then
			psSettings["trackSetting"] = true; print("|cFF" .. PileSeller.color .. "Pile|rSeller: |cFF00FF00Tracking enabled.|r")
			PileSeller:GlowButton(true)
			if PileSeller.UIConfig then
				PileSeller.UIConfig.toggleTracking:SetText("Stop tracking")
				PileSeller.UIConfig.toggleTracking:SetBackdropBorderColor(1,1,1,1)
			end
		end
	else
		if psSettings["trackSetting"] then
			psSettings["trackSetting"] = false; PileSeller:Print("|cFFFF0000Tracking disabled.|r") 
			PileSeller:GlowButton(false)
			if PileSeller.UIConfig then
				PileSeller.UIConfig.toggleTracking:SetText("Start tracking")
				PileSeller.UIConfig.toggleTracking:SetBackdropBorderColor(1,1,1,0)
			end
		end
	end

	if keepTier ~= nil then
		psSettings["keepTier"] = keepTier
		psSettings["keepCraftingReagent"] = keepCraftingReagent
		psSettings["keepBoes"] = keepBoes
		psSettings["keepTrasmogsNotOwned"] = keepTrasmogsNotOwned
		psSettings["keepTrasmogs"] = keepTrasmogs
	end
end

function psEvents:ZONE_CHANGED_NEW_AREA(...)
	if PileSeller.UIConfig then
		if PileSeller.UIConfig.ignoredScroll.lblTitle then
			if PileSeller.UIConfig.ignoredScroll.lblTitle.lblDesc then
				PileSeller.UIConfig.ignoredScroll.lblTitle.lblDesc:SetText("You are currently in:|n|cFF" .. PileSeller.color .. GetZoneText() .. "|r")
			end
		end
	end
	local type = select(2, GetInstanceInfo())
	local t = string.match(type, CHAT_MSG_RAID:lower()) or string.match(type, CHAT_MSG_PARTY:lower())
	local garrison = string.find(GetInstanceInfo(), GARRISON_LOCATION_TOOLTIP)
	local g = IsInGroup()
	if t and not garrison then
		if not g then
			if not psSettings["trackSetting"] and not psSettings["autoActivate"] then
				PileSeller:CreateCunstomStaticPopup(PileSeller.wishToTrack)
			elseif psSettings["autoActivate"] and not psSettings["trackSetting"] then
				PileSeller:ToggleTracking(true)
			end
		else
			if psSettings["autoDeactivate"] and psSettings["trackSetting"] then
				PileSeller:ToggleTracking(false)
			elseif psSettings["trackSetting"] and psSettings["showAlertSetting"] then
				StaticPopupDialogs["PS_TOGGLE_TRACKING"] = {
				  text = "Item tracking is active, do you wish to disable it?",
				  button1 = "Yes",
				  button2 = "No",
				  OnAccept = function()
					PileSeller:ToggleTracking(false)
				  end,
				  timeout = 0,
				  whileDead = false,
				  hideOnEscape = true,
				  preferredIndex = 3,
				}
				StaticPopup_Show ("PS_TOGGLE_TRACKING")
			end
		end
	elseif not t then
		if psSettings["autoDeactivate"] and psSettings["trackSetting"] then
				PileSeller:ToggleTracking(false)
		elseif psSettings["trackSetting"] and psSettings["showAlertSetting"] then
			StaticPopupDialogs["PS_TOGGLE_TRACKING"] = {
				  text = "Item tracking is still active, do you wish to disable it?",
				  button1 = "Yes",
				  button2 = "No",
				  OnAccept = function()
					 PileSeller:ToggleTracking(false)
				  end,
				  timeout = 0,
				  whileDead = false,
				  hideOnEscape = true,
				  preferredIndex = 3,
				}
				StaticPopup_Show ("PS_TOGGLE_TRACKING")
		end
	elseif garrison and psSettings["disableInGarrison"] then
		PileSeller:ToggleTracking(false)
	end
end

function psEvents:RAID_INSTANCE_WELCOME(...)
	local g = IsInGroup()
	local type = select(2, GetInstanceInfo())
	local t = string.match(type, CHAT_MSG_RAID:lower()) or string.match(type, CHAT_MSG_PARTY:lower())
	if t then
		if not g then
			if not psSettings["trackSetting"] and not psSettings["showAlertSetting"] then
				PileSeller:CreateCunstomStaticPopup(PileSeller.wishToTrack)
			elseif not psSettings["trackSetting"] and psSettings["showAlertSetting"] then
				PileSeller:ToggleTracking(true)
			end
		elseif psSettings["trackSetting"] and psSettings["autoDeactivate"] then
			PileSeller:ToggleTracking(false)
		elseif psSettings["trackSetting"] and psSettings["showAlertSetting"] then
			StaticPopupDialogs["PS_TOGGLE_TRACKING"] = {
			  text = "Item tracking is active, do you wish to disable it?",
			  button1 = "Yes",
			  button2 = "No",
			  OnAccept = function()
				 PileSeller:ToggleTracking(false)
			  end,
			  timeout = 0,
			  whileDead = false,
			  hideOnEscape = true,
			  preferredIndex = 3,
			}
			StaticPopup_Show ("PS_TOGGLE_TRACKING")
		end
	end
end

function psEvents:GOSSIP_SHOW(...) canTrack = false; end
function psEvents:GOSSIP_CLOSED(...) canTrack = true; end
function psEvents:QUEST_DETAIL(...) canTrack = false; end
function psEvents:QUEST_ACCEPTED(...) canTrack = true; end
function psEvents:MERCHANT_CLOSED(...) 
	canTrack = true
	if psSettings["autoCloseSellingBox"] then
		if PileSeller.sFrame then
			if PileSeller.sFrame:IsVisible() then
				PileSeller.sFrame:Hide()
			end
		end
	end
end
function psEvents:MAIL_SHOW(...) canTrack = false end
function psEvents:MAIL_CLOSED(...) canTrack = true end

function psEvents:GET_ITEM_INFO_RECEIVED()
	if waitingForItem[1] then 
		waitingForItem[1] = false 
		PileSeller:addItem(waitingForItem[2], waitingForItem[3])
	end
end

--- Hooking the events ---
psFrame:SetScript("OnEvent", function(self, event, ...)
	psEvents[event](self, ...)
	end)
for k, v in pairs(psEvents) do
	psFrame:RegisterEvent(k)
end
--------------------------

function PileSeller:addItem(item, list, scroll)
	local i = select(2, GetItemInfo(item)) 
	if not i then
		waitingForItem[1] = true
		waitingForItem[2] = item
		waitingForItem[3] = list
	else 
		list[#list + 1] = PileSeller:getID(i)
		if scroll then
			PileSeller:PopulateList(scroll, list)
			PileSeller.UIConfig.txtAddSavedItem:SetText("")
		end
	end
end

function PileSeller:removeItem(link, list, scroll, literal)
	local id
	if not literal then id = PileSeller:getID(link) else id = link end

	local removeIndex = 0
	for i=0, #list do
		-- Removing all the instances of the item from the list
		-- This helps since i can't manage exactly what i sold and what i didn't 
		while tostring(list[i]) == tostring(id) do
			tremove(list, i)
			PileSeller:debugprint(i .. ":removed")
		end
	end


	-- After removing all the items from the list
	-- i'll respawn the lists
	if PileSeller.UIConfig then
		if PileSeller.UIConfig:IsShown() and scroll then
			PileSeller:PopulateList(scroll, list)
			PileSeller:CreateItemsSection(PileSeller.UIConfig)
		end
	elseif PileSeller.sellingBox:IsShown() and scroll then
		PileSeller:debugprint("the scroll and the selling box is detected, should populate")
		PileSeller.sellingBox:Hide()
		PileSeller.sellingBox:Show()
	end
end

--[[ Function to get the item's ID from a link ]]--
function PileSeller:getID(item)
	local item = string.match(item, "item[%-?%d:]+") -- This is something like "item:7073:0:0:0:0:0:0:0:80:0:0:0:0"
	if #item > string.len("item:0000") then
		item = string.sub(item, 6) -- Now I have 7073:0:0:0:0:0:0:0:80:0:0:0:0

		i = 1
		current = item:sub(0,0)
		id = ""
		--print(current)
		while current ~= ":" do
			id = id .. item:sub(i,i)
			i = i + 1
			current = item:sub(i,i)
		end
		return id
	else return nil end
end

function PileSeller:isSaved(item)
	for i=1, #psItemsSaved do
		if(item == psItemsSaved[i]) then
			psItemsSavedFound[item] = true
			return true
		end
	end
	return false
end

function PileSeller:IsCraftingReagent(id)
	local f = CreateFrame('GameTooltip', 'PileSellerScanningTooltip', UIParent, 'GameTooltipTemplate')
	f:SetOwner(UIParent, 'ANCHOR_NONE') 
	f:SetItemByID(id)
	for i = 1, f:NumLines() do
		local t = _G["PileSellerScanningTooltipTextLeft" .. i]:GetText()
		if t == PROFESSIONS_USED_IN_COOKING then return true end
	end
	return false
end

function PileSeller:KeepItem(id)
	local keepTier = psSettings["keepTier"] and PileSeller:IsToken(id)
	local keepBoE = psSettings["keepBoes"] and PileSeller:IsBoE(id)
	--local keepTrasmog = ( psSettings["keepTrasmogs"] and PileSeller:CanTransmog(id) ) and keepBoE
	--local keepArtifactPower = psSettings["keepArtifactPower"] and PileSeller:IsArtifact(id, true)
	local keepCraftingReagent = psSettings["keepCraftingReagents"] and PileSeller:IsCraftingReagent(id)
	local keepSaved = PileSeller:isSaved(id)

	return keepTier or keepBoE or keepCraftingReagent or keepSaved or keepArtifactPower
end


function PileSeller:UseArtifact(id)
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			local item = select(7, GetContainerItemInfo(i, j))
			if item then
				local artifact = PileSeller:IsArtifact(id, false)
				if artifact then
					local artifactId = PileSeller:getID(item)
					if tonumber(artifactId) == tonumber(id) then 
						--UseContainerItem(i, j)
						print("Psych, can't do")
					end
				end
			end
		end
	end
end

function PileSeller:IsArtifact(id, canPrompt)
	local f = CreateFrame('GameTooltip', 'PileSellerScanningTooltip', UIParent, 'GameTooltipTemplate')
	f:SetOwner(UIParent, 'ANCHOR_NONE') 
	f:SetItemByID(id)
	for i = 1, f:NumLines() do
		local s = _G["PileSellerScanningTooltipTextLeft" .. i]:GetText()
		if s:find(ARTIFACT_POWER)  then
			if psSettings["alertArtifactPower"] and canPrompt then
				StaticPopupDialogs["PS_TOGGLE_TRACKING"] = {
					text = "Found artifact power!|nDo you wish to use it?",
					button1 = "Yes",
					button2 = "No",
					OnAccept = function()
						PileSeller:UseArtifact(id)
					end,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
				StaticPopup_Show ("PS_TOGGLE_TRACKING")
			end
			return true
		end
	end
	return false
end

-- Hook the bags buttons
function linkFromContainer(button)
	if PileSeller.UIConfig then
		if IsShiftKeyDown() and PileSeller.UIConfig:IsShown() then
			if PileSeller.UIConfig.txtAddSavedItem:HasFocus() then
				PileSeller.UIConfig.txtAddSavedItem:SetText(GetContainerItemLink(button:GetParent():GetID(), button:GetID()))
			end
		end
	end
end
hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", linkFromContainer)

-- Hook the links from chat
function linkFromChatFrame(self, link, text, button)
	if PileSeller.UIConfig then
		if IsShiftKeyDown() and PileSeller.UIConfig:IsShown() then
			if PileSeller.UIConfig.txtAddSavedItem:HasFocus() then
				local item =  PileSeller:getID(link)
				item = select(2, GetItemInfo(item))
				PileSeller.UIConfig.txtAddSavedItem:SetText(item)
			end
		end
	end
end
hooksecurefunc("ChatFrame_OnHyperlinkShow", linkFromChatFrame)

-- Hook the encounter
function EncounterJournal_Show()
	local originalM = EncounterJournal_Loot_OnClick
	EncounterJournal_Loot_OnClick = function(self, elapsed)
		if PileSeller.UIConfig then
			if IsShiftKeyDown() and PileSeller.UIConfig:IsShown() then
				if PileSeller.UIConfig.txtAddSavedItem:HasFocus() then
					PileSeller.UIConfig.txtAddSavedItem:SetText(self.link)
				end
			end
		end
	end 
end
hooksecurefunc("EncounterJournal_LoadUI", EncounterJournal_Show)

SLASH_PILESELLER1 = "/pileseller"
SLASH_PILESELLER2 ="/ps"

function SlashCmdList.PILESELLER(msg, editbox)
	if msg == "" then
		print("PileSeller arguments")
		print("|cFF" .. PileSeller.color .. "config|r|||cFF" .. PileSeller.color .. "items|r - open config or session window")
		print("|cFF" .. PileSeller.color .. "start|r - start a new session")
		print("|cFF" .. PileSeller.color .. "stop|r - stop the current session")
		print("|cFF" .. PileSeller.color .. "additem|r - adds an item to the saved list")
		print("|cFF" .. PileSeller.color .. "removeitem|r - removes and item from the saved list")
		print("|cFF" .. PileSeller.color .. "removesell|r - removes an item from the selling list")
		print("|cFF" .. PileSeller.color .. "ignorezone|r - ignores a zone by name")
	else
		if msg == "config" or msg == "items" then
			PileSeller:ShowConfig(msg)
		elseif string.match(msg, "additem ") then
			local s = string.gsub(msg, "additem ", "")
			if s then
				if string.match(s, "item[%-?%d:]+") then
					PileSeller:addItem(s, psItemsSaved)
					PileSeller:Print(s .. " added to the saved list.")
					if PileSeller.UIConfig and PileSeller.UIConfig.savedScroll then
						PileSeller:PopulateList(PileSeller.UIConfig.savedScroll.content, psItemsSaved)
					end
				else PileSeller:Print("Error") end
			end
		elseif string.match(msg, "removeitem ") then
			local s = string.gsub(msg, "removeitem  ", "")
			if s then
				if string.match(s, "item[%-?%d:]+") then
					PileSeller:removeItem(s, psItemsSaved, nil)
					PileSeller:Print(s .. " removed from the saved list.")
					if PileSeller.UIConfig and PileSeller.UIConfig.savedScroll then
						PileSeller:PopulateList(PileSeller.UIConfig.savedScroll.content, psItemsSaved)
					end
				else PileSeller:Print("Error") end
			end
		elseif string.match(msg, "removesell ") then
			local s = string.gsub(msg, "removesell  ", "")
			if s then
				if string.match(s, "item[%-?%d:]+") then
					PileSeller:removeItem(s, psItems, nil)
					PileSeller:Print(s .. " removed from the selling list.")
					if PileSeller.UIConfig then
						if PileSeller.UIConfig.toSellScroll then
							PileSeller:PopulateList(PileSeller.UIConfig.toSellScroll.content, psItems)
						end
					end
				else PileSeller:Print("Error") end
			end
		elseif msg == "start" then
			PileSeller:ToggleTracking(true)
		elseif msg == "stop" or msg == "end" then
			PileSeller:ToggleTracking(false)
		elseif string.match(msg, "ignorezone ") then
			local s = string.gsub(msg, "ignorezone ", "")
			if not PileSeller:IsIgnored(s) then
				tinsert(psIgnoredZones, s)
				PileSeller:Print(s .. " added to the ignored zones list.")
			else 
				tremove(psIgnoredZones, PileSeller:IsIgnored(s)) 
				PileSeller:Print(s .. " removed to the ignored zones list.")
			end
			if PileSeller.UIConfig and PileSeller.UIConfig.ignoredScroll then
				PileSeller:PopulateList(PileSeller.UIConfig.ignoredScroll.content, psIgnoredZones, true)
			end
		elseif msg == "debug" then
			--- Are you someone who isn't the dev? I don't suggest you to activate this option
			psSettings["debug"] = not psSettings["debug"]
			local append = psSettings["debug"] and "|cFF00FF00true|r" or "|cFFFF0000false|r"
			PileSeller:Print("DEBUG: " .. append)


		end 
	end
end

function PileSeller:Print(text)
	print("|cFF" .. PileSeller.color .. "Pile|rSeller: " .. text)
end