local PileSeller = _G.PileSeller
local psMinimapFrame = CreateFrame("FRAME", "PileSeller_MinimapFrame")

function PileSeller:GlowButton(set)
	if set then PileSeller_MinimapButtonGlow:SetVertexColor(1, 1, 1, 1) 
	else PileSeller_MinimapButtonGlow:SetVertexColor(1, 1, 1, 0) end
end

function PileSeller:HideMinimapButton(set)
    if set then PileSeller_MinimapButton:Hide()
    else PileSeller_MinimapButton:Show() end
end

local negative = false
local minimap_timer = 0
local minimap_glows = 0
local minimap_glow = true
local function onUpdateMinimapFrame(self, elapsed)
	minimap_timer = minimap_timer + elapsed
	if minimap_glow then
		if psSettings["trackSetting"] then
			if minimap_timer < 1 then
				if negative then
					PileSeller_MinimapButtonGlow:SetVertexColor(1, 1, 1, 1 - minimap_timer)
				else PileSeller_MinimapButtonGlow:SetVertexColor(1, 1, 1, minimap_timer) end
			else
				if not negative and minimap_timer > 2 then
					minimap_timer = 0
					if negative then negative = false else negative = true end
					minimap_glows = minimap_glows + 1
					if minimap_glows == 50 then
						PileSeller_MinimapButtonGlow:SetVertexColor(1, 1, 1, 1)
						minimap_glows = 0
						minimap_glow = false
						minimap_timer = 0
					end
				elseif negative and minimap_timer > 1 then
					minimap_timer = 0
					if negative then negative = false else negative = true end
				end 
			end
		end
	else 
		if minimap_timer > 120 then
			minimap_glow = true
			minimap_timer = 0
		end
	end
	
end
psMinimapFrame:SetScript("OnUpdate", onUpdateMinimapFrame)