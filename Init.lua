-- Initialization file


_G.PileSeller = { __addonversion = "2.2.0" }
local PileSeller = _G.PileSeller


PileSeller.color = "6cafcc"
PileSeller.wishToTrack = "Do you wish to track the items in this run?"

-- Debug tools
function PileSeller:tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

GetItemInfo(19019)


function PileSeller:PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    --table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("   ", indent)..tostring(v)..":")
                PileSeller:PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("   ", indent)..tostring(v)..": "..tostring(value))
                PileSeller:PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("   ", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("   ", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end
--------------



-- This will be used both into the creation of the checkboxes and on the init of the settings
PileSeller.settings = {
    [1] = {
        name = "autoActivate",
        default = false,
        text = "Auto activate tracking by entering a raid or instance alone.",
        sub = false,
    },
    [2] = {
        name = "autoDeactivate",
        default = false,
        text = "Auto deactivate tracking when exiting a raid or an instance.",
    },
    [3] = {
        name = "autoCloseSellingBox",
        default = false,
        text = "Auto close the item sold dialog when closing the vendor.",
        sub = false
    },
    [4] = {
        name = "confSetting",
        default = true,
        text = "Show confirmation before selling the loot.",
        sub = false
    },
    [5] = {
        name = "hideJunkSetting",
        default = true,
        text = "Don't show gray items in the selling list.",
        sub = false
    },
    [6] = {
        name = "sellJunkSetting",
        default = true,
        text = "Auto sell junk.",
        sub = false
    },
    [7] = {
        name = "repairSetting",
        default = false,
        text = "Auto repair gear.",
        sub = false,
        masterOf = "repairGuildSetting"
    },
    [8] = {
        name = "repairGuildSetting",
        default = false,
        text = "Use guild funds.",
        sub = true,
        slaveOf = "repairSetting"
    },
    [9] = {
        name = "showAlertSetting",
        default = true,
        text = "Always message me if tracking is on (|cFF00FF00Recommended|r).",
        sub = false,
    },
    [10] = {
        name = "disableInGarrison",
        default = true,
        text = "Always disable tracking when entering in garrison.",
        sub = false,
    },    
    [11] = {
        name = "hideMinimapButton",
        default = false,
        text = "Hide minimap button. (You can type /pileseller or /ps to access the addon)",
        sub = false,
        f = function(self)
            psSettings["hideMinimapButton"] = self:GetChecked()
            PileSeller:HideMinimapButton(self:GetChecked())
        end
    },
    [12] = {
        name = "speedTweaker",
        default = false,
        text = "Tweak the speed while selling the items.",
        sub = false,
        f = function(self)
            psSettings["speedTweaker"] = self:GetChecked()
            self:GetParent().speedTweakerSlider:SetEnabled(self:GetChecked())
            if self:GetChecked() then
                self:GetParent().speedTweakerSlider.value:SetTextColor(253/255, 209/255, 22/255,1)
            else
                self:GetParent().speedTweakerSlider.value:SetTextColor(153/255, 153/255, 153/255, 1)
            end
        end
    }
}
PileSeller.itemsToKeep = {
    [1] = {
        name = "keepTier",
        default = false,
        title = "Keep tiers",
        tooltip = "Keep all the tokens you are able to use.",
        icon = "Achievement_Dungeon_GloryoftheRaider"
    },
    [2] = {
        name = "keepBoes",
        default = false,
        title = "Keep BoE",
        tooltip = "Keep all the Bind on Equip items specified on the dropdown box above\n(checked = keep)\n|cFF00FF00Recipes are not in this category, use the recipe section|r.",
        icon =  "Ability_Priest_Evangelism"
    }, 
    [3] = {
        name = "keepCraftingReagents",
        default = false,
        title = "Keep crafting reagents",
        tooltip = "Keep all the crafting reagents.",
        icon = "INV_Enchanting_WOD_crystalbundle"
    },
    [4] = {
        name = "keepLockboxes",
        default = false,
        title = "Keep all lockboxes",
        tooltip = "Keep all the dropped lockboxes.",
        icon = "Garrison_BronzeChest"
    },
    [5] = {
        name = "keepRecipes",
        default = false,
        title = "Keep all the recipes",
        tooltip = "Keep all the recipes from various professions specified in the dropdown box above\n(checked = keep)",
        icon = "inv_scroll_05"
    },
    [6] = {
        name = "keepCompanions",
        default = false,
        title = "Keep all companions",
        tooltip = "Keep all the items that let me learn companions.",
        icon = "INV_MISC_PETMOONKINTA"        
    },
    [7] = {
        name = "keepItemLevel",
        default = false,
        title = "Keep items above item level",
        tooltip = "Keep all the items above the item level specified in the textbox.\n(value included. ex: 600 is all items with item level >= 600)",
        icon = "Achievement_General_Classact"
    },
    [8] = {
        name = "keepItemQuality",
        default = true,
        title = "Keep items of a certain quality",
        tooltip = "Keep all the items of the specified quality in the dropdown box above\n(checked = keep)",
        icon = "Achievement_Garrison_Alliance_PVE"
    },
    [9] = {
        name = "keepSpecials",
        default = true,
        title = "Keep all special items",
        tooltip = "Special items are consumables such as Illusion scrolls, artifact power items, order hall upgrades and a lot of other cool stuff.\n|cFF00FF00Recommended|r",
        icon = "INV_Misc_CelebrationCake_01"
    }
}






function ToggleCheckAndText(ui, check, set)
    ui[check]:SetEnabled(set)
    if set then ui[check].lbl:SetTextColor(253/255, 209/255, 22/255,1)
    else ui[check].lbl:SetTextColor(153/255, 153/255, 153/255, 1) end
end

if not psItems then psItems = {} end
if not psItemsSaved  then psItemsSaved = {} end
if not psItemsSavedFound then psItemsSavedFound = {} end
if not psSettings then 
	psSettings = {}
    for i = 1, PileSeller:tablelength(PileSeller.settings) do
        local s = PileSeller.settings[i].name
        local d = PileSeller.settings[i].default
        psSettings[s] = d
    end

    for i = 1, PileSeller:tablelength(PileSeller.itemsToKeep) do
        local s = PileSeller.itemsToKeep[i].name
        local d = PileSeller.itemsToKeep[i].default
        psSettings[s] = d
    end
    psSettings["minimapButtonPos"] = 175 
    psSettings["trackSetting"] = false
else
    for i=1, PileSeller:tablelength(PileSeller.settings) do
        local s = PileSeller.settings[i].name
        local d = PileSeller.settings[i].default
        if psSettings[s] == nil then psSettings[s] = d end
    end
    for i = 1, PileSeller:tablelength(PileSeller.itemsToKeep) do
        local s = PileSeller.itemsToKeep[i].name
        local d = PileSeller.itemsToKeep[i].default
        if psSettings[s] == nil then psSettings[s] = d end
    end
    if psSettings["minimapButtonPos"] == nil then psSettings["minimapButtonPos"] = 175 end
    if psSettings["trackSetting"] == nil then psSettings["trackSetting"] = false end
    if psSettings["debug"] == nil then psSettings["debug"] = false end
end
if not psItemsAlert then psItemsAlert = {} end
if not psIgnoredZones then psIgnoredZones = {} end
if psTutorialDone == nil then psTutorialDone = false end

-------------- This is because these variables are now deprecated (Version 2.2.0)
if psSettings["keepTrasmogsNotOwned"] ~= nil then psSettings["keepTrasmogsNotOwned"] = nil end
if psSettings["keepTrasmogs"] ~= nil then psSettings["keepTrasmogs"] = nil end

function PileSeller:Reset()
	psItems = nil
	psItemsSaved = nil
	psItemsSavedFound = nil
	psItemsAlert = nil
	psSettings = nil
	ReloadUI()
	print("|cFF" .. PileSeller.color "Pile|rSeller's variables reset.")
end

function PileSeller:debugprint(string)
    if psSettings["debug"] then print(string) end
end
