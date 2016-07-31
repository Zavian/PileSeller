-- Initialization file


_G.PileSeller = { __addonversion = "2.1.1" }
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
        masterOf = "autoDeactivate"
    },
    [2] = {
        name = "autoDeactivate",
        default = false,
        text = "Auto deactivate tracking when exiting a raid or an instance.",
        sub = true,
        slaveOf = "autoActivate"
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
        name = "sellJunkSetting",
        default = true,
        text = "Auto sell junk.",
        sub = false
    },
    [6] = {
        name = "repairSetting",
        default = false,
        text = "Auto repair gear.",
        sub = false,
        masterOf = "repairGuildSetting"
    },
    [7] = {
        name = "repairGuildSetting",
        default = false,
        text = "Use guild funds.",
        sub = true,
        slaveOf = "repairSetting"
    },
    [8] = {
        name = "showAlertSetting",
        default = true,
        text = "Always message me if tracking is on (|cFF00FF00Recommended|r).",
        sub = false,
    },
    [9] = {
        name = "disableInGarrison",
        default = true,
        text = "Always disable tracking when entering in garrison.",
        sub = false,
    },    
    [10] = {
        name = "keepTier",
        default = false,
        text = "Don't sell any tier tokens I can use.",
        sub = false
    },
    [11] = {
        name = "keepBoes",
        default = false,
        text = "Don't sell any BoE (Bind on Equip).",
        sub = false,
        f = function()
            --PileSeller:PrintTable(PileSeller.UIConfig["keepBoes"].lbl)
            psSettings["keepBoes"] = PileSeller.UIConfig.configScroller.content["keepBoes"]:GetChecked()
            ToggleCheckAndText(PileSeller.UIConfig, "keepTrasmogs", PileSeller.UIConfig["keepBoes"]:GetChecked())
            ToggleCheckAndText(PileSeller.UIConfig, "keepTrasmogsNotOwned", PileSeller.UIConfig["keepBoes"]:GetChecked())
        end
        --masterOf = ["keepTrasmogs", "keepTrasmogsNotOwned"]
    },
    [12] = {
        name = "keepTrasmogsNotOwned",
        default = false,
        text = "Just keep the ones I don't already own.",
        sub = true,
        slaveOf = "keepBoes"
    },
    [13] = {
        name = "keepTrasmogs",
        default = false,
        text = "Keep only the ones I can transmog.",
        sub = true,
        slaveOf = "keepBoes"
    },    
    [14] = {
        name = "keepCraftingReagents",
        default = false,
        text = "Don't sell any Crafting Reagent.",
        sub = false
    },
    [15] = {
        name = "hideMinimapButton",
        default = false,
        text = "Hide minimap button. (You can type /pileseller or /ps to access the addon)",
        sub = false,
        f = function()
            local b = PileSeller.UIConfig.configScroller.content.hideMinimapButton:GetChecked()
            psSettings["hideMinimapButton"] = b
            PileSeller:HideMinimapButton(b)
        end
    },
    [16] = {
        name = "speedTweaker",
        default = false,
        text = "Tweak the speed while selling the items.",
        sub = false,
        f = function()
            local b = PileSeller.UIConfig.configScroller.content.speedTweaker:GetChecked()
            psSettings["speedTweaker"] = b
            --PileSeller.UIConfig.configScroller.content.speedTweaker.questionButton:SetEnabled(b)
            PileSeller.UIConfig.configScroller.content.speedTweakerSlider:SetEnabled(b)
            if b then
                PileSeller.UIConfig.configScroller.content.speedTweakerSlider.value:SetTextColor(253/255, 209/255, 22/255,1)
            else
                PileSeller.UIConfig.configScroller.content.speedTweakerSlider.value:SetTextColor(153/255, 153/255, 153/255, 1)
            end
        end
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
    psSettings["minimapButtonPos"] = 175 
    psSettings["trackSetting"] = false
else
    for i=1, PileSeller:tablelength(PileSeller.settings) do
        local s = PileSeller.settings[i].name
        local d = PileSeller.settings[i].default
        if psSettings[s] == nil then psSettings[s] = d end
    end
    if psSettings["minimapButtonPos"] == nil then psSettings["minimapButtonPos"] = 175 end
    if psSettings["trackSetting"] == nil then psSettings["trackSetting"] = false end
    if psSettings["debug"] == nil then psSettings["debug"] = false end
end
if not psItemsAlert then psItemsAlert = {} end
if not psIgnoredZones then psIgnoredZones = {} end
if psTutorialDone == nil then psTutorialDone = false end

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