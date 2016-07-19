local PileSeller = _G.PileSeller

local defaultData = {
	currentSpec = nil,
	width = 255,
	newTrait = ARTIFACT_TOAST_NEW_POWER_AVAILABLE,
	unlockTrait = ARTIFACT_TOAST_RETURN_TO_FORGE,
	weaponData = {
		name = "",
		itemID = nil
	}
}

local alertQueue = {}

local newTrait = "New saved item dropped!"
local unlockTrait = ""


local artifactFrame, anim = nil, nil

function OnFinished()
	--print("anim finished")
	-- Resetting the frame	
	anim:Finish()
	CreateDefaultData()
	artifactFrame.BottomLineLeft:SetWidth(defaultData.width)
	artifactFrame.BottomLineRight:SetWidth(defaultData.width)
	artifactFrame.BottomLineLeft:SetWidth(defaultData.width)
	artifactFrame.BottomLineRight:SetWidth(defaultData.width)
	artifactFrame.ToastBG:SetWidth(defaultData.width + 20)

	artifactFrame.BottomLineLeft:SetAlpha(0)
	artifactFrame.BottomLineRight:SetAlpha(0)
	artifactFrame.ArtifactName:SetAlpha(0)
	artifactFrame.NewTrait:SetAlpha(0)
	artifactFrame.UnlockTrait:SetAlpha(0)
	artifactFrame:SetAlpha(1)


	-- Resetting text
	artifactFrame.ArtifactName:SetText(defaultData.weaponData.name)
	artifactFrame.NewTrait:SetText(defaultData.newTrait)
	artifactFrame.UnlockTrait:SetText(defaultData.unlockTrait)

	-- Resetting texture
	local texture = select(10, GetItemInfo(defaultData.weaponData.itemID))
	artifactFrame.Icon:SetTexture(texture)

	tremove(alertQueue, 1)
	artifactFrame:Hide()
	ProcessQueue()
end

--function FetchNameBecauseIHateBlizz(class, spec)
--	local possibleEndingsBecauseFuckBlizz = {
--		starter = {
--			"1", ""
--		},
--		ender = {
--			"2", "_2", "_SECOND", ""
--		}
--	}
--	local name = ""
--	local localizedString = "ARTIFACT_" .. class .. "_" .. spec .. "_WEAPONNAME"
--	for i=1, #possibleEndingsBecauseFuckBlizz.starter do
--		if _G[localizedString .. possibleEndingsBecauseFuckBlizz.starter[i]] then
--			localizedString = localizedString .. possibleEndingsBecauseFuckBlizz.starter[i]
--		end
--	end
--
--	name = _G[localizedString]
--
--	for i=1, #possibleEndingsBecauseFuckBlizz.ender do
--		if _G[localizedString .. possibleEndingsBecauseFuckBlizz.ender[i]] then
--			localizedString = localizedString .. possibleEndingsBecauseFuckBlizz.ender[i]
--		end
--	end
--	name = name .. 
--	return localizedString
--end

function CreateDefaultData()
	local playerClass = select(2, UnitClass("player"))	
	local artifactInfo = PileSeller:LoadArtifacts()
	local itemID = artifactInfo.id
	local artifact_name = artifactInfo.name


	if defaultData.currentSpec then
		if artifactSpec ~= defaultData.currentSpec then
			defaultData.currentSpec = artifactSpec
		else return end
	else defaultData.currentSpec = artifactSpec end

	defaultData.weaponData.name = artifact_name
	defaultData.weaponData.itemID = itemID
end
-- Function to init the alert system
function CreateAlertSystem()
	artifactFrame = ArtifactLevelUpToast
	anim = ArtifactLevelUpToast.ArtifactLevelUpAnim

	if not defaultUnlockTrait then 
		defaultUnlockTrait = artifactFrame.UnlockTrait:GetText()
	end
	if not defaultNewTrait then
		defaultNewTrait = artifactFrame.NewTrait:GetText()
	end

	anim:SetScript("OnFinished", OnFinished)
	anim:SetScript("OnStop", OnFinished)

	artifactFrame:SetScript("OnMouseDown", function() anim:Stop() end)

	CreateDefaultData()


	--artifactFrame.ArtifactName:SetText("Oh shit waddup")
	--artifactFrame.Icon:SetTexture([[Interface\AddOns\PileSeller\media\dat-boy]])
	--artifactFrame.NewTrait:SetText("It's dat boy!")
	--artifactFrame.UnlockTrait:SetText("")
end

function PileSeller:CreateAlert(data)
	if not anim or not artifactFrame then CreateAlertSystem() end
	if not data then return end
	PileSeller:AddToAlertQueue(data)
end

function ProcessQueue()
	if artifactFrame:IsVisible() or ArtifactLevelUpToast:IsVisible() then return end
	local data = alertQueue[1]
	if not data then return end -- This means that the queue it's finished
	--PileSeller:PrintTable(alertQueue)
	anim:SetScript("OnPlay", function()
		if data ~= "default" then
			artifactFrame.ArtifactName:SetText(data.name)
			artifactFrame.Icon:SetTexture(data.texture)
			artifactFrame.NewTrait:SetText(data.newTrait)
			artifactFrame.UnlockTrait:SetText(data.unlockTrait)

			if artifactFrame.ArtifactName:GetWidth() > defaultData.width then
				local newWidth = artifactFrame.ArtifactName:GetWidth()
				artifactFrame.BottomLineLeft:SetWidth(newWidth)
				artifactFrame.BottomLineRight:SetWidth(newWidth)
				artifactFrame.CloudyLineLeft:SetWidth(newWidth)
				artifactFrame.CloudyLineRight:SetWidth(newWidth)
				artifactFrame.ToastBG:SetWidth(newWidth + 20)
			end
		end
	end)
	artifactFrame:Show()
	anim:Play()
	PlaySound("UI_70_Artifact_Forge_Toast_TraitAvailable")
	data = {name = defaultData.weaponData.name, texture = select(10, GetItemInfo(defaultData.weaponData.itemID)), newTrait = defaultData.newTrait, unlockTrait = defaultData.unlockTrait}
end

function PileSeller:AddToAlertQueue(data)
	tinsert(alertQueue, data)
	ProcessQueue()
end

function PileSeller:Test(nonono)
	local data = {name = nonono, texture = select(10, GetItemInfo(19019)), newTrait = "New item dropped!", unlockTrait = ""}
	PileSeller:CreateAlert(data)
	--124360
	--C_TransmogCollection.PlayerHasTransmog
	--print(C_TransmogCollection.GetAppearanceSourceDrops(1))

	--print(C_ArtifactUI.GetArtifactInfo)
end

function PileSeller:anima()
	PileSeller:AddToAlertQueue("default")
end
