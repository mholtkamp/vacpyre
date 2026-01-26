Hud = {}

function Hud:Create()

    self.hero = nil
    self.vacuum = nil
    self.crosshair = nil
    self.chargeBar = nil
    self.chargeFg = nil
    self.jelly = nil

    self.jellyFlashDuration = 0.2
    self.jellyFlashTime = 0.0
    self.jellyOpacity = 0.5

    self.fadeToBlackTime = 0.0
    self.fadeToBlackDuration = 0.0
    self.fadeFromBlackTime = 0.0
    self.fadeFromBlackDuration = 0.0

end

function Hud:Start()

    self.hero = self:GetRoot():FindChild("Hero", true)
    self.vacuum = self.hero:FindChild("Vacuum", true)

    self.crosshair = self:FindChild("Crosshair", true)

    self.chargeBar = self:FindChild("ChargeBar", true)
    self.chargeFg = self:FindChild("ChargeFg", true)

    self.blackQuad1 = self:FindChild("BlackQuad", true)

    self.jelly = self:FindChild("Jelly", true)

    local platform = Engine.GetPlatform()
    if (platform == "3DS") then
        self:SetScale(0.5, 0.5)

        local root2 = Node.Construct("Widget")
        root2:SetAnchorMode(AnchorMode.FullStretch)
        root2:SetRatios(0,0,1,1)
        self.chargeBar:Attach(root2)
        self.chargeBar:SetAnchorMode(AnchorMode.Mid)

        self.blackQuad2 = self.blackQuad1:Clone(false)
        self.blackQuad2:Attach(root2)

        Engine.GetWorld(2):SetRootNode(root2)
    elseif (platform == "GameCube" or platform == "Wii") then
        self:SetScale(0.5, 0.5)
    end

    self.chargeBar:SetOpacityFloat(0.0)

    self:SetBlackOpacity(1.0)
    TimerManager.SetTimer(function() self:FadeFromBlack(0.5) end, 1.0)

end

function Hud:Tick(deltaTime)

    -- Update Crosshair
    local traceTarget = self.vacuum.traceTarget or self.vacuum.suckedObject
    local crosshairColor = traceTarget and Vec(1,0,0,1) or Vec(1,1,1,1)

    for i = 1, self.crosshair:GetNumChildren() do
        self.crosshair:GetChild(i):SetColor(crosshairColor)
    end

    -- Update Charge Bar
    local chargeAlpha = Math.Clamp(self.vacuum.charge, 0, 1)
    local targetOpacity = 0.0
    if (chargeAlpha > 0.0) then
        targetOpacity = 1.0
    end
    local opacity = self.chargeBar:GetOpacityFloat()
    opacity = Math.Approach(opacity, targetOpacity, 4.0, deltaTime)
    self.chargeBar:SetOpacityFloat(opacity)

    self.chargeFg:SetWidthRatio(chargeAlpha)

    -- Update jelly flash if damaged
    if (self.jellyFlashTime > 0.0) then
        self.jellyFlashTime = self.jellyFlashTime - deltaTime

        local opacity = 0.0
        local fadeRatio = 0.8
        if (self.jellyFlashTime > fadeRatio * self.jellyFlashDuration) then
            opacity = Math.MapClamped(self.jellyFlashTime, self.jellyFlashDuration, self.jellyFlashDuration * fadeRatio, 0.0, 1.0)
        else
            opacity = Math.MapClamped(self.jellyFlashTime, self.jellyFlashDuration * fadeRatio, 0, 1.0, 0.0)
        end
        opacity = opacity * self.jellyOpacity
        self.jelly:SetOpacityFloat(opacity)
    end

    -- Update fade to/from black
    local blackOpacity = 0.0
    if (self.fadeFromBlackTime > 0.0) then
        self.fadeFromBlackTime = self.fadeFromBlackTime - deltaTime
        blackOpacity = Math.Clamp(self.fadeFromBlackTime / self.fadeFromBlackDuration, 0, 1)

        Log.Debug("FADE FROM BLACK: " .. blackOpacity)

        self:SetBlackOpacity(blackOpacity)
    end

    if (self.fadeToBlackTime > 0.0) then
        self.fadeToBlackTime = self.fadeToBlackTime - deltaTime
        blackOpacity = Math.Clamp(1.0 - self.fadeToBlackTime / self.fadeFromBlackDuration, 0, 1)
        self:SetBlackOpacity(blackOpacity)
    end

end

function Hud:OnDamage()

    self.jellyFlashTime = self.jellyFlashDuration
    self.jelly:SetVisible(true)
    self.jelly:SetOpacityFloat(0.0)

end

function Hud:FadeToBlack(dur)

    self.fadeToBlackTime = dur
    self.fadeToBlackDuration = dur

end

function Hud:FadeFromBlack(dur)

    self.fadeFromBlackTime = dur
    self.fadeFromBlackDuration = dur

end

function Hud:SetBlackOpacity(opacity)

    self.blackQuad1:SetVisible(opacity > 0)
    self.blackQuad1:SetOpacityFloat(opacity)
    if (self.blackQuad2) then
        self.blackQuad2:SetVisible(opacity > 0)
        self.blackQuad2:SetOpacityFloat(opacity)
    end

end