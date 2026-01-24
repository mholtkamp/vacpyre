Script.Require("EnemyUtils")

Turret = {}

function Turret:Create()

    -- Props
    self.shootDelay = 0.5

    -- State
    self.shootTimer = 0.0

end

function Turret:GatherProperties()

    return
    {
        { name = "shootDelay", type = DatumType.Float },
        { name = "projectile", type = DatumType.Asset },
        { name = "firePivot", type = DatumType.Node},
        { name = "headMesh", type = DatumType.Node},
    }

end

function Turret:Tick(deltaTime)

    -- Shoot if we have LOS
    if (self.controller.lineOfSight) then
        
        self.shootTimer = self.shootTimer - deltaTime
        if (self.shootTimer <= 0.0) then
            EnemyUtils.FireProjectile(self, self.controller.hero, self.projectile, true)
            self.shootTimer = self.shootDelay
        end
    end

    -- Rotate head mesh to look at hero
    if (self.controller.lineOfSight) then
        self.headMesh:LookAt(self.controller.hero:GetWorldPosition())
    else
        self.headMesh:SetRotation(Vec())
    end
end

function Turret:OnCollision(this, other)

    if (self.controller) then
        self.controller:OnCollision(this, other)
    end

end