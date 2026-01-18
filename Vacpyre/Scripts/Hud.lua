Hud = {}

function Hud:Create()

    self.hero = nil
    self.vacuum = nil
    self.crosshair = nil

end

function Hud:Start()

    self.hero = self:GetRoot():FindChild("Hero", true)
    self.vacuum = self.hero:FindChild("Vacuum", true)

    self.crosshair = self:FindChild("Crosshair", true)

    local platform = Engine.GetPlatform()
    if (platform == "3DS") then
        self:SetScale(0.5, 0.5)
    elseif (platform == "GameCube" or platform == "Wii") then
        self:SetScale(0.5, 0.5)
    end

end

function Hud:Tick(deltaTime)

    local traceTarget = self.vacuum.traceTarget

    local crosshairColor = traceTarget and Vec(1,0,0,1) or Vec(1,1,1,1)

    for i = 1, self.crosshair:GetNumChildren() do
        self.crosshair:GetChild(i):SetColor(crosshairColor)
    end



end