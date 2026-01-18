Vacuum = {}

function Vacuum:Create()

    self.suckPivot = nil

    self.sucking = false
    self.suckedObject = nil
    self.lastSuckTarget = nil
    self.lastSuckGraceTime = 0.0
    self.suckGracePeriod = 0.3
    self.suckGraceTime = 0.0

end

function Vacuum:GatherProperties()

    return
    {
        { name = "suckPivot", type = DatumType.Node },
    }

end

function Vacuum:Tick(deltaTime)
    
    local camera = self.world:GetActiveCamera()
    local suckTarget = nil

    self.lastSuckGraceTime = math.max(self.lastSuckGraceTime - deltaTime, 0.0)

    if (self.sucking and not self.suckedObject) then

        if (camera) then
            -- Trace directly forward from camera and check first thing hit
            local rayStart = camera:GetWorldPosition()
            local rayEnd = rayStart + camera:GetForwardVector() * 100.0
            local colMask = ~(VacpyreCollision.Player)

            local res = self.world:RayTest(rayStart, rayEnd, colMask)

            if (res.hitNode and res.hitNode:HasTag("Red")) then
                suckTarget = res.hitNode
                self.lastSuckTarget = suckTarget
                self.lastSuckGraceTime = self.suckGracePeriod
            end
        end

        -- If the crosshair goes slightly off the last target, still use it for a brief period
        if (not suckTarget and
            self.lastSuckTarget and
            self.lastSuckGraceTime > 0.0) then

            suckTarget = self.lastSuckTarget
        end
    end

    if (suckTarget) then

        local toCamera = camera:GetWorldPosition() - suckTarget:GetWorldPosition()
        local suckDir = toCamera:Normalize()
        local distance = toCamera:Length()
        Log.Debug("Dist = " .. tostring(distance))
        local forceMag = Math.MapClamped(distance, 0, 100.0, 100.0, 10.0)
        local force = forceMag * suckDir
        suckTarget:AddForce(force)

        if (distance < 5.0) then
            suckTarget:EnablePhysics(false)
            suckTarget:Attach(self.suckPivot)
            local bounds = suckTarget:GetBounds()
            LogTable(bounds)
            suckTarget:SetPosition(Vec(0,0,-bounds.radius))
            suckTarget:SetRotation(Vec())
            self.suckedObject = suckTarget
        end
    end

end

function Vacuum:EnableSuck(suck)

    self.sucking = suck

    if (not suck and self.suckedObject) then
        -- Shoot object
        self.suckedObject:EnablePhysics(true)
        self.suckedObject:Attach(self:GetRoot(), true)

        local launchSpeed = 30.0
        self.suckedObject:SetLinearVelocity(self.suckPivot:GetForwardVector() * launchSpeed)

        self.suckedObject = nil
    end

    if (not suck) then
        self.lastSuckTarget = nil
        self.lastSuckGraceTime = 0.0
    end

end