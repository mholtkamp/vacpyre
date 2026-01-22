RedObject = {}

function RedObject:Create()

    self.physActivated = false

end

function RedObject:Start()

    self:SetCollisionGroup(VacpyreCollision.Red)

    -- Wait until we get sucked, or something with physics collides with us
    self:EnablePhysics(false)

end

function RedObject:OnSuck()

    if (not self.physActivated) then
        self:ActivatePhys()
    end

end

function RedObject:OnCollision(this, other)

    if (not self.activated and other:IsPhysicsEnabled()) then
        self:ActivatePhys()
    end

end

function RedObject:ActivatePhys()

    if (not self.physActivated) then
        self:EnablePhysics(true)
        self.physActivated = true
    end

end
