local module = ShaguTweaks:register({
    title = "Mouseover Bottom Left",
    description = "Hide the Bottom Left ActionBar and show on mouseover. The pet/shapeshift/aura/stance bars will not be clickable. The action bar must be enabled in 'Interface Options' > 'Advanced Options'. Please reload the UI after enabling or disabling the action bar.",
    expansions = { ["vanilla"] = true, ["tbc"] = nil },
    category = "Action Bar",
    enabled = nil,
})

module.enable = function(self)
    local _G = _G or getfenv(0)

    local timer = CreateFrame("Frame", nil, UIParent)
    local mouseOverBar
    local mouseOverButton
    local _, class = UnitClass("player")

    local function hidebars()        
        if class == "HUNTER" or "WARLOCK" then
            PetActionBarFrame:Hide()
        elseif class == "DRUID" or "ROGUE" or "WARRIOR" or "PALADIN" then
            ShapeshiftBarFrame:Hide()
        end
    end

    local function showbars()
        if class == "HUNTER" or "WARLOCK" then
            PetActionBarFrame:Show()
        elseif class == "DRUID" or "ROGUE" or "WARRIOR" or "PALADIN" then
            ShapeshiftBarFrame:Show()
        end
    end
        
    local function hide(bar)
        bar:Hide()
        showbars()
    end
    
    local function show(bar)
        bar:Show()    
        hidebars()
    end
    
    local function mouseover(bar)
        local function setTimer()
            timer.time = GetTime() + 2
            timer:SetScript("OnUpdate", function()
                if GetTime() >= timer.time then
                    hide(bar)
                    timer:SetScript("OnUpdate", nil)
                end
            end)
        end
    
        local tooltipVisible = GameTooltip:IsVisible()
        if (not tooltipVisible) and (mouseOverButton or mouseOverBar) then
            timer:SetScript("OnUpdate", nil)
            show(bar)
        elseif (not tooltipVisible) and (not mouseOverBar) and (not mouseOverButton) then
            setTimer()
        end
    end
    
    local function barEnter(frame, bar)
        frame:SetScript("OnEnter", function()
            mouseOverBar = true
            mouseover(bar)
        end)
    end
    
    local function barLeave(frame, bar)
        frame:SetScript("OnLeave", function()
            mouseOverBar = false     
            mouseover(bar)
        end)
    end
    
    local function buttonEnter(frame, bar)
        frame:SetScript("OnEnter", function()
            mouseOverButton = true
            frame:EnableMouse(false)
            mouseover(bar)        
        end)
    end
    
    local function buttonLeave(frame, bar)
        frame:SetScript("OnLeave", function()
            mouseOverButton = false
            frame:EnableMouse(true)
            mouseover(bar)
        end)
    end
    
    local function mouseoverButton(button, bar)
        local frame = CreateFrame("Frame", nil, UIParent)    
        frame:SetAllPoints(button)
        frame:EnableMouse(true)
        frame:SetFrameStrata("DIALOG")    
        buttonEnter(frame, bar)
        buttonLeave(frame, bar)
    end
    
    local function mouseoverBar(bar)
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetAllPoints(bar)
        frame:EnableMouse(true)
        barEnter(frame, bar) 
        barLeave(frame, bar)
    end
    
    local function setup(bar)
        if not bar:IsVisible() then return end        
        for i = 1, 12 do
            for _, button in pairs(
                    {
                    _G[bar:GetName()..'Button'..i],
                }
            ) do
                mouseoverButton(button, bar)
            end
        end
        mouseoverBar(bar)
        hide(bar)
    end    

    local function hideart()
        -- general function to hide textures and frames
        local function hide(frame, texture)
            if not frame then return end

            if texture and texture == 1 and frame.SetTexture then
            frame:SetTexture("")
            elseif texture and texture == 2 and frame.SetNormalTexture then
            frame:SetNormalTexture("")
            else
            frame:ClearAllPoints()
            frame.Show = function() return end
            frame:Hide()
            end
        end

        -- textures that shall be set empty
        local textures = {
            SlidingActionBarTexture0, SlidingActionBarTexture1,
            -- PetActionBarFrame
            SlidingActionBarTexture0, SlidingActionBarTexture1,
            -- ShapeshiftBarFrame
            ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
          }

        -- button textures that shall be set empty
        local normtextures = {
            ShapeshiftButton1, ShapeshiftButton2,
            ShapeshiftButton3, ShapeshiftButton4,
            ShapeshiftButton5, ShapeshiftButton6,
        }

        -- clear textures
        for id, frame in pairs(textures) do hide(frame, 1) end
        for id, frame in pairs(normtextures) do hide(frame, 2) end
    end

    local function lockbars()        
        local function lock(bar)
            bar.ClearAllPoints = function() end
            bar.SetPoint = function() end
        end

        PetActionBarFrame:ClearAllPoints()
        ShapeshiftBarFrame:ClearAllPoints()

        -- PetActionBarFrame
        local anchor = MultiBarBottomLeft
        PetActionBarFrame:SetPoint("CENTER", anchor, "CENTER", ActionButton1:GetWidth(), 2)

        -- ShapeshiftBarFrame
        local offset = 0
        local anchor = ActionButton1
        offset = anchor == ActionButton1 and ( MainMenuExpBar:IsVisible() or ReputationWatchBar:IsVisible() ) and 6 or 0
        offset = anchor == ActionButton1 and offset + 6 or offset
        ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 8, 1 + offset)

        lock(PetActionBarFrame)
        lock(ShapeshiftBarFrame)   
    end
    
    local events = CreateFrame("Frame", nil, UIParent)
    events:RegisterEvent("PLAYER_ENTERING_WORLD")

    events:SetScript("OnEvent", function()        
        if event == "PLAYER_ENTERING_WORLD" then
            lockbars()
            hideart()
            setup(MultiBarBottomLeft)
        end       
    end)
end