WaterPlane = {}

function WaterPlane:Create()

    self.uvSpeed = Vec()

end

function WaterPlane:GatherProperties()

    return
    {
        { name = "uvSpeed", type = DatumType.Vector2D },
    }
end

function WaterPlane:Start()

    self.matInst = self:InstantiateMaterial()

end

function WaterPlane:Tick(deltaTime)

    local uvOff = self.matInst:GetUvOffset()
    uvOff = uvOff + self.uvSpeed * deltaTime
    self.matInst:SetUvOffset(uvOff)

end

function WaterPlane:OverlapBegin(this, other)

    Log.Debug("OVERLAP!")

    if (other:HasTag("Hero")) then
        other:Kill()
        Log.Debug("Water kill")
    end

end

function WaterPlane:OnCollision(this, other)

    Log.Debug("ON COL!")

    if (other:HasTag("Hero")) then
        other:Kill()
        Log.Debug("Water kill")
    end
end