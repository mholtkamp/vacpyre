Vacuum = {}

function Vacuum:Create()

    self.suckPivot = nil

    self.sucking = false

end

function Vacuum:GatherProperties()

    return
    {
        { name = "suckPivot", type = DatumType.Node },
    }

end

function Vacuum:Tick(deltaTime)
    
    if (self.sucking) then
        Log.Debug("SUCK")

        local camera = self.world:GetActiveCamera()

        if (camera) then
            Log.Debug("CAMERA")
            -- Trace directly forward from camera and check first thing hit
            local rayStart = camera:GetWorldPosition()
            local rayEnd = rayStart + camera:GetForwardVector() * 100.0
            local colMask = ~(VacpyreCollision.Player)

            local res = self.world:RayTest(rayStart, rayEnd, colMask)

            Log.Debug("HIT: " .. (res.hitNode and res.hitNode:GetName() or tostring(res.hitNode)))

            if (res.hitNode and res.hitNode:HasTag("Red")) then
                Log.Debug("TARGET: " .. res.hitNode:GetName())
                self.suckTarget = res.hitNode
            else
                self.suckTarget = nil
            end
        end
    else
        self.suckTarget = nil
    end

    if (self.suckTarget) then

        local force = 100.0 * (self.suckPivot:GetWorldPosition() - self.suckTarget:GetWorldPosition()):Normalize()
        self.suckTarget:AddForce(force)
    end

end

function Vacuum:EnableSuck(suck)

    self.sucking = suck

end