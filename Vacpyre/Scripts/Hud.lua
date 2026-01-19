Hud = {}

function Hud:Create()

    self.hero = nil
    self.vacuum = nil
    self.crosshair = nil
    self.chargeBar = nil
    self.chargeFg = nil

end

function Hud:Start()

    self.hero = self:GetRoot():FindChild("Hero", true)
    self.vacuum = self.hero:FindChild("Vacuum", true)

    self.crosshair = self:FindChild("Crosshair", true)

    self.chargeBar = self:FindChild("ChargeBar", true)
    self.chargeFg = self:FindChild("ChargeFg", true)

    local platform = Engine.GetPlatform()
    if (platform == "3DS") then
        self:SetScale(0.5, 0.5)

        local root2 = Node.Construct("Widget")
        root2:SetAnchorMode(AnchorMode.FullStretch)
        root2:SetRatios(0,0,1,1)
        self.chargeBar:Attach(root2)
        self.chargeBar:SetAnchorMode(AnchorMode.Mid)

        Engine.GetWorld(2):SetRootNode(root2)
    elseif (platform == "GameCube" or platform == "Wii") then
        self:SetScale(0.5, 0.5)
    end

    self.chargeBar:SetOpacityFloat(0.0)

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



end