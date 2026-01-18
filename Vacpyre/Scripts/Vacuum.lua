Vacuum = {}

function Vacuum:Create()

    self.suckPivot = nil
    self.launchSpeed = 30.0

    self.sucking = false
    self.suckedObject = nil
    self.traceTarget = nil

end

function Vacuum:GatherProperties()

    return
    {
        { name = "suckPivot", type = DatumType.Node },
        { name = "suckParticle", type = DatumType.Node },
        { name = "blowParticle", type = DatumType.Node },

    }

end

function Vacuum:Start()

end

function Vacuum:Tick(deltaTime)
    
    local camera = self.world:GetActiveCamera()
    local suckTarget = nil

    self.traceTarget = nil
    if (camera) then
        -- Trace directly forward from camera and check first thing hit
        local rayStart = camera:GetWorldPosition()
        local rayEnd = rayStart + camera:GetForwardVector() * 100.0
        local colMask = ~(VacpyreCollision.Player)

        local res = self.world:RayTest(rayStart, rayEnd, colMask)

        if (res.hitNode and res.hitNode:HasTag("Red")) then
            self.traceTarget = res.hitNode
        end
    end

    if (self.sucking and not self.suckedObject) then
        suckTarget = self.traceTarget
    end

    -- Disallow sucking targets too soon after blowing
    if (suckTarget and suckTarget.lastBlowTime) then
        local timeSinceBlow = Engine.GetElapsedTime() - suckTarget.lastBlowTime
        if (timeSinceBlow < 0.3) then
            suckTarget = nil
        end
    end

    if (suckTarget and self:MustDropObject(suckTarget)) then
        suckTarget = nil
    end

    if (suckTarget) then

        suckTarget.lastSuckTime = Engine.GetElapsedTime()

        local toCamera = camera:GetWorldPosition() - suckTarget:GetWorldPosition()
        local suckDir = toCamera:Normalize()
        local distance = toCamera:Length()
        local forceMag = Math.MapClamped(distance, 0, 100.0, 100.0, 10.0)
        local force = forceMag * suckDir
        suckTarget:AddForce(force)

        if (distance < 5.0) then
            self:SuckObject(suckTarget)
        end
    end

    self.suckParticle:EnableEmission(self.sucking and not self.suckedObject)

    -- Check if our sucked object is penetrating the environment.
    -- If so, release it
    if (self.suckedObject) then
        if (self:MustDropObject(self.suckedObject)) then
            self:ReleaseSuckedObject(0.0)
        end
    end
end

function Vacuum:MustDropObject(obj)

    local camera = self.world:GetActiveCamera()

    local rayStart = camera:GetWorldPosition()
    local rayEnd = self.suckPivot:GetWorldPosition() + self.suckPivot:GetForwardVector() * obj:GetBounds().radius -- obj:GetWorldPosition()
    rayEnd = rayEnd + (rayEnd - rayStart):Normalize() * 1.0
    local colMask = ~(VacpyreCollision.Player | VacpyreCollision.Projectile)
    local ignoreObjects = { obj }
    local res = self.world:RayTest(rayStart, rayEnd, colMask, ignoreObjects)

    local color = res.hitNode and Vec(1,0,0,1) or Vec(0,1,0,1)

    return (res.hitNode ~= nil)
end

function Vacuum:EnableSuck(suck)

    self.sucking = suck

    if (not suck and self.suckedObject) then
        self:ReleaseSuckedObject(self.launchSpeed)
        self.blowParticle:EnableEmission(true)
    end

end

function Vacuum:SuckObject(obj)

    obj:EnablePhysics(false)
    obj:SetCollisionMask(VacpyreCollision.Projectile)
    obj:Attach(self.suckPivot)
    local bounds = obj:GetBounds()
    obj:SetPosition(Vec(0,0,-bounds.radius))
    obj:SetRotation(Vec())
    self.suckedObject = obj

end

function Vacuum:ReleaseSuckedObject(launchSpeed)

        -- Shoot object
        self.suckedObject:EnablePhysics(true)
        self.suckedObject:SetCollisionMask(0xff)
        self.suckedObject:Attach(self:GetRoot(), true)

        -- Trace from camera, to current object pos.
        -- If trace fails, spawn it from camera instead.
        -- This is an attempt to stop objects going through walls
        local camera = self.world:GetActiveCamera()
        local rayStart = camera:GetWorldPosition()
        local rayEnd = self.suckedObject:GetWorldPosition()
        local res = self.world:RayTest(rayStart, rayEnd, VacpyreCollision.Environment)
        if (res.hitNode) then
            self.suckedObject:SetWorldPosition(camera:GetWorldPosition())
        end

        self.suckedObject:SetLinearVelocity(self.suckPivot:GetForwardVector() * launchSpeed)
        self.suckedObject.lastBlowTime = Engine.GetElapsedTime()

        self.suckedObject = nil

end

function Vacuum:BeginOverlap(this, other)

    if (self.sucking and 
        not self.suckedObject and
        other:HasTag("Red") and
        other.lastSuckTime and
        (Engine.GetElapsedTime() - other.lastSuckTime < 0.5)) then

        self:SuckObject(other)
    end
end