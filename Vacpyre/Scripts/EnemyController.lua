EnemyController = {}

function EnemyController:Create()

    -- Properties
    self.moveSpeed = 5.0
    self.collider = nil

    -- State
    self.moveDir = Vec()
    self.moveTimer = 0.0
end

function EnemyController:GatherProperties()

    return
    {
        { name = "collider", type = DatumType.Node },
        { name = "mesh", type = DatumType.Node },
        { name = "moveSpeed", type = DatumType.Float },
        { name = "flying", type = DatumType.Bool },
    }
end

function EnemyController:Tick(deltaTime)

    self.moveTimer = math.max(self.moveTimer - deltaTime, 0.0)


    Log.Debug("moveTimer = " .. tostring(self.moveTimer))

    if (self.moveTimer == 0.0) then
        self.moveTimer = Math.RandRange(1.0, 3.0)
        self.moveDir = Vector.Rotate(Vec(0,0,-1), Math.RandRange(0, 360.0), Vec(0, 1, 0))
    end

    self.collider:SweepToWorldPosition(self.collider:GetWorldPosition() + self.moveDir * self.moveSpeed * deltaTime)

    self.mesh:LookAt(self.collider:GetWorldPosition() + self.moveDir)
end