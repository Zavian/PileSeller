local PileSeller = _G.PileSeller

-- /run PileSeller:GetItemSources(select(2, GetItemInfo(140712)))
-- /dump WardrobeCollectionFrameModel_GetSourceTooltipInfo(C_TransmogCollection.GetAppearanceSources(26394)[1])

local InventorySlots = {
['INVTYPE_HEAD'] = 1,
['INVTYPE_NECK'] = 2,
['INVTYPE_SHOULDER'] = 3,
['INVTYPE_BODY'] = 4,
['INVTYPE_CHEST'] = 5,
['INVTYPE_ROBE'] = 5,
['INVTYPE_WAIST'] = 6,
['INVTYPE_LEGS'] = 7,
['INVTYPE_FEET'] = 8,
['INVTYPE_WRIST'] = 9,
['INVTYPE_HAND'] = 10,
['INVTYPE_CLOAK'] = 15,
['INVTYPE_WEAPON'] = 16,
['INVTYPE_SHIELD'] = 17,
['INVTYPE_2HWEAPON'] = 16,
['INVTYPE_WEAPONMAINHAND'] = 16,
['INVTYPE_RANGED'] = 16,
['INVTYPE_RANGEDRIGHT'] = 16,
['INVTYPE_WEAPONOFFHAND'] = 17,
['INVTYPE_HOLDABLE'] = 17,
	-- ['INVTYPE_TABARD'] = 19,
}

--[[
	sourceType = {
		1 = Boss

		6 = Profession
	}

]]--


local model = CreateFrame('DressUpModel')
function PileSeller:GetItemAppearance(itemLink)
	local itemID, _, _, slotName = GetItemInfoInstant(itemLink)
	if itemLink == itemID then
		itemLink = 'item:' .. itemID
	end
	local slot = InventorySlots[slotName]
	if not slot or not IsDressableItem(itemLink) then return end
	model:SetUnit('player')
	model:Undress()
	model:TryOn(itemLink, slot)
	local sourceID = model:GetSlotTransmogSources(slot)
	if sourceID then
		local categoryID, appearanceID, canEnchant, texture, isCollected, itemLink = C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
		return appearanceID, isCollected, sourceID
	end
end

function PileSeller:GetItemSources(itemLink, getAllSources)
	local dropSources = {{}}
	local thereAreBosses = false
	local sources = nil
	local sourceID = select(3, PileSeller:GetItemAppearance(itemLink))
	local appearanceID = select(1, PileSeller:GetItemAppearance(itemLink))
	local canBeSource = select(3, C_Transmog.GetItemInfo(PileSeller:getID(itemLink)))
	if not canBeSource then return end
	if appearanceID then
		sourceTexts = {}
		sources = WardrobeCollectionFrame_GetSortedAppearanceSources(appearanceID)
		--PileSeller:PrintTable(sources)
		if getAllSources then return sources end
		if #sources >= 1 then
			for i = 1, #sources do
				local name, nameColor, sourceText, sourceColor = WardrobeCollectionFrameModel_GetSourceTooltipInfo(sources[i])
				local drops = nil
				if sourceText == TRANSMOG_SOURCE_1 then 
					thereAreBosses = true 
					--local appearanceID = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[i].sourceID))
					--print(appearanceID)
					drops = C_TransmogCollection.GetAppearanceSourceDrops(sources[i].sourceID)
					--print(drops)
					--PileSeller:PrintTable(drops)
				end
				local tempTable = {text = "", drop = {}}
				if drops then
					tempTable = {text = sourceText, drop = drops}
				else
					tempTable = {text = sourceText, drop = nil}
				end
				tinsert(sourceTexts, tempTable)
			end
		else
			print("wut")
		end
	end
	--local hash, res = {}, {}
	--for _,v in ipairs(sourceTexts) do
	--	if (not hash[v]) then
	--		res[#res+1] = v
	--		hash[v] = true
	--	end
	--end
	--print(sourceID)
	--PileSeller:PrintTable(sourceTexts)
	return { [1] = sourceTexts, [2] = thereAreBosses, [3] = appearanceID, [4] = sources, [5] = sourceID}
end


function PileSeller:CreateTooltipInfo(owner, sources)
	GameTooltip:SetOwner(owner, "ANCHOR_BOTTOMRIGHT", 0, owner:GetHeight())
	GameTooltip:AddLine("Appearances dropped by:")

	local sourceTexts, thereAreBosses, appearanceID, sourceTable, sourceID = sources[1], sources[2], sources[3], sources[4], sources[5]
	--print(sourceTexts)
	--print(thereAreBosses)
	--print(appearanceID)
	--print(source)
	--print(sourceID)
	--print(sourceID)
	--local sources = PileSeller:GetItemSources(itemLink, true)
	-- now I have all the sources
	local writtenDrops = {}
	for i = 1, #sourceTexts do
		local drops = sourceTexts[i].drop
		--PileSeller:PrintTable(drops)
		if drops then
			for j = 1, #drops do
				local string = "|cFFFF957A" .. drops[j].encounter .. "|r in |cFF" .. PileSeller.color ..  drops[j].instance .. "|r"
				--if drops[j].difficulties then
				--	if #drops[j].difficulties == 1 then
				--		string = string .. " (" .. drops[j].difficulties[1] .. ")"
				--	end
				--end
				if not writtenDrops[string] then
					GameTooltip:AddLine("Dropped by " .. string)
				end
				writtenDrops[string] = true
			end
		end
	end
	--if sourceTable then
	--	print(#sourceTable)
	--	for i = 1, #sourceTable do
	--		local name, nameColor, sourceText, sourceColor = WardrobeCollectionFrameModel_GetSourceTooltipInfo(sourceTable[i])
	--		if sourceText == TRANSMOG_SOURCE_1 then
	--			
	--		end
	--	end
	--end
	--for i=1, #drops do
	--	if drops[i].text == TRANSMOG_SOURCE_1 then
	--		for j=1, #drops[i].drop do
	--			GameTooltip:AddLine("|cFF" .. PileSeller.color .. "Dropped by:|r " .. drops[i].drop[j].encounter .. " in " .. drops[i].drop[j].instance)
	--		end
	--	end
	--end
	GameTooltip:Show()
end


