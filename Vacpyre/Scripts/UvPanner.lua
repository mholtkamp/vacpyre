UvPanner = {}

function UvPanner:Create()

    self.speed1 = Vec(0.1, 0,1)
    self.speed2 = Vec(0.1, 0.1)

end

function UvPanner:GatherProperties()

    return
    {
        { name = "speed1", type = DatumType.Vector2D },
        { name = "speed2", type = DatumType.Vector2D },
    }

end

function UvPanner:Start()

    self.matInst = self:InstantiateMaterial()

end

function UvPanner:Tick(deltaTime)

    local uvOff1 = self.matInst:GetUvOffset(1)
    uvOff1 = uvOff1 + self.speed1 * deltaTime
    self.matInst:SetUvOffset(uvOff1, 1)

    local uvOff2 = self.matInst:GetUvOffset(2)
    uvOff2 = uvOff2 + self.speed2 * deltaTime
    self.matInst:SetUvOffset(uvOff2, 2)

end
