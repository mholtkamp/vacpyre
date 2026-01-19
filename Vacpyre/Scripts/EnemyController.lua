EnemyController = {}

function EnemyController:Create()

    -- Properties
    self.moveSpeed = 5.0
    self.collider = nil
    self.hurtOnTouch = false
    self.approachDistance = 0.0

    -- State
    self.moveDir = Vec()
    self.moveTimer = 0.0
    self.heroNearby = false
    self.hero = nil
end

function EnemyController:GatherProperties()

    return
    {
        { name = "collider", type = DatumType.Node },
        { name = "mesh", type = DatumType.Node },
        { name = "moveSpeed", type = DatumType.Float },
        { name = "flying", type = DatumType.Bool },
        { name = "hurtOnTouch", type = DatumType.Bool },
        { name = "approachDistance", type = DatumType.Float},
        { name = "deathParticle", type = DatumType.Asset},
    }
end

function EnemyController:Start()

    self.enemy = self:GetParent()
    self.enemy.controller = self
    self.hero = self:GetRoot().hero
end

function EnemyController:Tick(deltaTime)

    local meshFwd = self.mesh:GetForwardVector()
    local facingDot = Vector.Dot(self.moveDir, meshFwd)
    local moveSpeed = Math.MapClamped(facingDot, 0, 1.0, self.moveSpeed * 0.1, self.moveSpeed)

    if (self.lineOfSight) then
        local toHero = (self.hero:GetWorldPosition() - self.collider:GetWorldPosition())
        toHero.y = 0.0
        local dist = toHero:Length()
        self.moveDir = toHero / dist

        if (dist < self.approachDistance) then
            moveSpeed = 0.0
        end
    else

        self.moveTimer = math.max(self.moveTimer - deltaTime, 0.0)

        if (self.moveTimer == 0.0) then
            self.moveTimer = Math.RandRange(1.0, 3.0)
            self.moveDir = Vector.Rotate(Vec(0,0,-1), Math.RandRange(0, 360.0), Vec(0, 1, 0))
        end

    end

    local sweepRes = self.collider:SweepToWorldPosition(self.collider:GetWorldPosition() + self.moveDir * moveSpeed * deltaTime)

    if (sweepRes.hitNode and not self.lineOfSight) then
        -- Hit something, so turn around
        self.moveDir = Vector.Rotate(self.moveDir, Math.RandRange(130, 230), Vec(0, 1, 0))
        self.moveTimer = Math.RandRange(1.0, 3.0)
    end

    -- Rotate mesh toward move dir
    local meshRot = self.mesh:GetWorldRotation()
    local targRot = Math.VectorToRotation(self.moveDir)
    meshRot.y = Math.ApproachAngle(meshRot.y, targRot.y, 400.0, deltaTime)
    self.mesh:SetWorldRotation(meshRot)

    -- If hero is nearby, and we are facing toward hero, then do a ray test
    -- to see if we should attack / pursue. The heroNearby flag will be set by
    -- by the ProximitySphere on the hero tree.
    if (self.heroNearby) then

        local toHero = (self.hero:GetWorldPosition() - self.mesh:GetWorldPosition()):Normalize()
        local dot = Vector.Dot(self.mesh:GetForwardVector(), toHero)
        
        if (dot > 0.2) then
            -- We are facing the hero, see if we have line-of-sight
            local rayStart = self.collider:GetWorldPosition()
            local rayEnd = self.hero:GetWorldPosition()
            local colMask = (VacpyreCollision.Environment | VacpyreCollision.Hero)
            local rayRes = self.world:RayTest(rayStart, rayEnd, colMask)

            self.lineOfSight = (rayRes.hitNode == self.hero)
            --Renderer.AddDebugLine(rayStart, rayEnd, self.lineOfSight  and Vec(0,1,0,1) or Vec(1,0,0,1), 5.0)
        end
    end
end

function EnemyController:OnCollision(this, other)

    if (this == self.enemy and
        other:HasTag("Red") and
        other:GetLinearVelocity():Length() > 5.0) then

        self.world:SpawnParticle(self.deathParticle, self.enemy:GetWorldPosition())
        self.enemy:Doom()
    end
end