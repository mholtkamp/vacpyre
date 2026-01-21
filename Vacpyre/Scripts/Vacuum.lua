Vacuum = {}

function Vacuum:Create()

    self.suckPivot = nil
    self.launchSpeed = 60.0

    self.sucking = false
    self.suckedObject = nil
    self.traceTarget = nil
    self.aiming = false
    self.charge = 0.0
    self.chargeSpeed = 0.5
end

function Vacuum:GatherProperties()

    return
    {
        { name = "suckPivot", type = DatumType.Node },
        { name = "suckParticle", type = DatumType.Node },
        { name = "blowParticle", type = DatumType.Node },
        { name = "chargeSpeed", type = DatumType.Float },
    }

end

function Vacuum:Start()


end

function Vacuum:Tick(deltaTime)
    
    --if (self.suckedObject and not self.suckedObject:IsValid()) then
    -- if (not Node.IsValid(self.suckedObject)) then
    --     self.suckedObject = nil
    -- end

    local camera = self.world:GetActiveCamera()
    local suckTarget = nil

    self.traceTarget = nil
    if (camera) then
        -- Trace directly forward from camera and check first thing hit
        local rayStart = camera:GetWorldPosition()
        local rayEnd = rayStart + camera:GetForwardVector() * 100.0
        local colMask = ~(VacpyreCollision.Player | VacpyreCollision.Barrier)

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

    -- If we are aiming, then make the material transparent
    if (self.suckedObject) then

        local targetOpacity = 1.0
        if (self.aiming) then
            targetOpacity = 0.35
        end

        local matInst = self.suckedObject.matInst
        local opacity = matInst:GetOpacity() 
        opacity = Math.Approach(opacity, targetOpacity, 3.0, deltaTime)
        matInst:SetOpacity(opacity)

        local blendMode = BlendMode.Opaque
        if (opacity < 1.0) then
            blendMode = BlendMode.Translucent
        end
        matInst:SetBlendMode(blendMode)
    end

    -- Increase blow charge if sucking object
    if (self.suckedObject) then
        self.charge = self.charge + self.chargeSpeed * deltaTime
        self.charge = Math.Clamp(self.charge, 0, 1)
    end
end

function Vacuum:MustDropObject(obj)

    local camera = self.world:GetActiveCamera()

    local rayStart = camera:GetWorldPosition()
    local rayEnd = self.suckPivot:GetWorldPosition() + self.suckPivot:GetForwardVector() * obj:GetBounds().radius -- obj:GetWorldPosition()
    rayEnd = rayEnd + (rayEnd - rayStart):Normalize() * 1.0
    local colMask = ~(VacpyreCollision.Player | VacpyreCollision.Projectile | VacpyreCollision.Barrier)
    local ignoreObjects = { obj }
    local res = self.world:RayTest(rayStart, rayEnd, colMask, ignoreObjects)

    local color = res.hitNode and Vec(1,0,0,1) or Vec(0,1,0,1)

    return (res.hitNode ~= nil)
end

function Vacuum:EnableSuck(suck)

    self.sucking = suck

    if (not suck and self.suckedObject) then
        local launchSpeed = self.launchSpeed * self.charge
        self:ReleaseSuckedObject(launchSpeed)
        self.blowParticle:EnableEmission(true)
    end

end

function Vacuum:SuckObject(obj)

    -- Cache it's original parent so we can attach it properly when shooting it back out
    obj.origParent = obj:GetParent()

    obj:EnablePhysics(false)
    obj:SetCollisionMask(VacpyreCollision.Projectile | VacpyreCollision.Barrier)
    obj:Attach(self.suckPivot)
    local bounds = obj:GetBounds()
    obj:SetPosition(Vec(0,0,-bounds.radius))
    obj:SetRotation(Vec())

    -- Instantiate it's own material so we can make it transparent when aiming
    if (not obj.matInst) then
        local mesh = obj:GetChildByType("StaticMesh3D")
        obj.matInst = mesh:InstantiateMaterial()
    end

    obj:ConnectSignal("OnDestroy", self, function() self.suckedObject = nil; self.charge = 0; end)

    self.charge = 0.0
    self.suckedObject = obj

end

function Vacuum:ReleaseSuckedObject(launchSpeed)

    if (self.suckedObject and self.suckedObject:IsValid()) then
        -- Shoot object
        self.suckedObject:EnablePhysics(true)
        self.suckedObject:SetCollisionMask(0xff)
        self.suckedObject:Attach(self.suckedObject.origParent, true)

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
        self.suckedObject.matInst:SetOpacity(1.0)
        self.suckedObject.matInst:SetBlendMode(BlendMode.Opaque)
        self.suckedObject:DisconnectSignal("OnDestroy", self)
    end

    self.charge = 0.0

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