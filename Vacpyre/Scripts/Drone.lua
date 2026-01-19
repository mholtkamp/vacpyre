Drone = {}

function Drone:Create()

    -- Props
    self.propRotSpeed = 1000.0
    self.shootDelay = 0.5

    -- State
    self.shootTimer = 0.0

end

function Drone:GatherProperties()

    return
    {
        { name = "shootDelay", type = DatumType.Float },
        { name = "projectile", type = DatumType.Asset },
        { name = "firePivot", type = DatumType.Node},
    }

end

function Drone:Start()

    self.propeller1 = self:FindChild("Prop1", true)
    self.propeller2 = self:FindChild("Prop2", true)
    self.propellers = { self.propeller1, self.propeller2 }

end

function Drone:Tick(deltaTime)

    -- Rotate propellers
    local propRot = self.propeller1:GetRotation()
    propRot.y = propRot.y + deltaTime * self.propRotSpeed
    for i=1,#self.propellers do
        self.propellers[i]:SetRotation(propRot)
    end

    -- Shoot if we have LOS
    if (self.controller.lineOfSight) then
        
        self.shootTimer = self.shootTimer - deltaTime
        if (self.shootTimer <= 0.0) then
            local proj = self.projectile:Instantiate()
            self.world:GetRootNode():AddChild(proj)
            local toHero = (self.controller.hero:GetWorldPosition() - self:GetWorldPosition()):Normalize()
            proj:SetWorldPosition(self.firePivot:GetWorldPosition())
            proj:Launch(toHero)

            self.shootTimer = self.shootDelay
        end
    end
end