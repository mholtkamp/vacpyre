Projectile = {}

function Projectile:Create()

    -- Props
    self.speed = 30.0
    self.damage = 10.0
    self.impactParticle = nil

    -- State
    self.velocity = Vec()
    self.impacted = false
end

function Projectile:GatherProperties()

    return
    {
        { name = "speed", type = DatumType.Float },
        { name = "damage", type = DatumType.Float },
        { name = "impactParticle", type = DatumType.Asset },
    }
end

function Projectile:Start()

end

function Projectile:Launch(dir)

    self.velocity = self.speed * dir

end

function Projectile:Tick(deltaTime)

    local pos = self:GetWorldPosition()
    pos = pos + self.velocity * deltaTime
    local sweepRes = self:SweepToWorldPosition(pos)

    if (sweepRes.hitNode) then
        self:OnCollision(self, sweepRes.hitNode, sweepRes.hitPosition, sweepRes.hitNormal)
    end

end

function Projectile:OnCollision(this, other, impactPos, impactNormal)

    if (other:HasTag("Hero")) then
        other:Damage(self.damage)
    end

    if (self.impactParticle) then
        local particle = self.world:SpawnParticle(self.impactParticle, self:GetWorldPosition())
        local normalRot = Math.VectorToRotation(impactNormal)
        particle:SetRotation(normalRot)
    end

    self:Doom()

end
