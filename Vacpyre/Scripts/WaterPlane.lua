WaterPlane = {}

function WaterPlane:Create()

    self.uvSpeed = Vec()
    self.hero = nil

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

    -- Hero is set on overlap
    if (self.hero) then
        -- Kill hero when the midpoint goes below water level
        if (self.hero:GetWorldPosition().y < self:GetWorldPosition().y) then
            self.hero:Kill()
        end
    end

end

function WaterPlane:BeginOverlap(this, other)

    if (other:HasTag("Hero")) then
        self.hero = other
    end

end

function WaterPlane:EndOverlap(this, other)

    if (other == self.hero) then
        self.hero = nil
    end

end


function WaterPlane:OnCollision(this, other)

end