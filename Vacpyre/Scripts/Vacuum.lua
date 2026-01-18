Vacuum = {}

function Vacuum:Create()

    self.suckPivot = nil

    self.sucking = false
    self.suckedObject = nil

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

    if (self.sucking and not self.suckedObject) then

        if (camera) then
            -- Trace directly forward from camera and check first thing hit
            local rayStart = camera:GetWorldPosition()
            local rayEnd = rayStart + camera:GetForwardVector() * 100.0
            local colMask = ~(VacpyreCollision.Player)

            local res = self.world:RayTest(rayStart, rayEnd, colMask)

            if (res.hitNode and res.hitNode:HasTag("Red")) then
                suckTarget = res.hitNode
            end
        end
    end

    if (suckTarget) then

        suckTarget.lastSuckTime = Engine.GetElapsedTime()

        local toCamera = camera:GetWorldPosition() - suckTarget:GetWorldPosition()
        local suckDir = toCamera:Normalize()
        local distance = toCamera:Length()
        Log.Debug("Dist = " .. tostring(distance))
        local forceMag = Math.MapClamped(distance, 0, 100.0, 100.0, 10.0)
        local force = forceMag * suckDir
        suckTarget:AddForce(force)

        if (distance < 5.0) then
            self:SuckObject(suckTarget)
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

end

function Vacuum:SuckObject(obj)

    obj:EnablePhysics(false)
    obj:Attach(self.suckPivot)
    local bounds = obj:GetBounds()
    LogTable(bounds)
    obj:SetPosition(Vec(0,0,-bounds.radius))
    obj:SetRotation(Vec())
    self.suckedObject = obj

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