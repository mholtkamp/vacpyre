Script.Require("Checkpoint")

Hero = {}

function Hero:Create()

    -- Props
    self.maxHealth = 100

    -- State
    self.hud = nil
    self.health = self.maxHealth
    self.alive = true
end

function Hero:Start()

    -- Assign a global hero reference on the root node
    self:GetRoot().hero = self
    self.hud = self:GetRoot():FindChild("Hud", true)

    self.health = self.maxHealth

    local checkpointIdx = Checkpoint.curCheckpoint
    local checkpointName = "Checkpoint" .. checkpointIdx
    local checkpointNode = self:GetRoot():FindChild(checkpointName, false)

    if (checkpointNode) then
        local spawnPos = checkpointNode:GetSpawnPosition()
        local spawnRot = checkpointNode:GetSpawnRotation()
        self:SetWorldPosition(spawnPos)
        self:SetWorldRotation(spawnRot)
    else
        Log.Error("No checkpoint found!")
    end

end

function Hero:Tick(deltaTime)

    if (Input.IsKeyPressed(Key.R) or Input.IsGamepadPressed(Gamepad.Y)) then
        self:Kill()
    end

    self:UpdateDebug(deltaTime)

end

function Hero:Damage(damage)

    if (self.alive) then
        self.hud:OnDamage()

        self.health = Math.Clamp(self.health - damage, 0, self.maxHealth)

        if (self.health <= 0) then
            self:Kill()
        end
    end

end

function Hero:Kill()

    if (self.alive) then
        Log.Error("KILL")
        self.alive = false

        self.hud:FadeToBlack(0.5)
        TimerManager.SetTimer(function() Engine.GetWorld(1):LoadScene("SC_Cave") end, 1.0)
    end

end

function Hero:UpdateDebug(deltaTime)

    -- Teleport to checkpoints when hitting the number keys
    local teleCp = 0

    if (Input.IsKeyPressed(Key.N1)) then
        teleCp = 1
    elseif (Input.IsKeyPressed(Key.N2)) then
        teleCp = 2
    elseif (Input.IsKeyPressed(Key.N3)) then
        teleCp = 3
    elseif (Input.IsKeyPressed(Key.N4)) then
        teleCp = 4
    elseif (Input.IsKeyPressed(Key.N5)) then
        teleCp = 5
    elseif (Input.IsKeyPressed(Key.N6)) then
        teleCp = 6
    elseif (Input.IsKeyPressed(Key.N7)) then
        teleCp = 7
    elseif (Input.IsKeyPressed(Key.N8)) then
        teleCp = 8
    end

    if (teleCp >= 1) then
        local cpNode = self:GetRoot():FindChild("Checkpoint" .. teleCp)

        if (cpNode) then
            self:SetWorldPosition(cpNode:GetSpawnPosition())
            self:SetWorldRotation(cpNode:GetSpawnRotation())
            Log.Debug("spawn rot = " .. tostring(cpNode:GetSpawnRotation()))
        end
    end
end