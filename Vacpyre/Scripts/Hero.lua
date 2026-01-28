Script.Require("Checkpoint")

Hero = {}

function Hero:Create()

    -- Props
    self.maxHealth = 100

    -- State
    self.hud = nil
    self.health = self.maxHealth
    self.alive = true
    self.inGameMenu = nil
end

function Hero:GatherProperties()

    return
    {

    }
end

function Hero:Start()

    -- Assign a global hero reference on the root node
    self:GetRoot().hero = self
    self.hud = self:GetRoot():FindChild("Hud", true)

    self.health = self.maxHealth

    local checkpointIdx = GameState.checkpoint
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

    self.controller.enableControl = false

    self.hud:SetBlackOpacity(1.0)
    TimerManager.SetTimer(function() Engine.GarbageCollect(); self.hud:FadeFromBlack(0.5) end, 0.25)
    TimerManager.SetTimer(function() self.controller.enableControl = true end, 0.25 + 0.5)
end

function Hero:Tick(deltaTime)

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

function Hero:Heal(health)

    health = healh or self.maxHealth
    self.health = health

end

function Hero:Kill()

    if (self.alive) then
        Log.Error("KILL")
        self.alive = false
        self.controller.enableControl = false

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

    if (Input.IsGamepadDown(Gamepad.Select) or Input.IsGamepadDown(Gamepad.Z)) then
        if (Input.IsGamepadPressed(Gamepad.Up)) then
            teleCp = GameState.checkpoint + 1
        elseif (Input.IsGamepadPressed(Gamepad.Down)) then
            teleCp = GameState.checkpoint - 1
        end
    end

    if (teleCp >= 1) then
        local cpNode = self:GetRoot():FindChild("Checkpoint" .. teleCp)

        if (cpNode) then
            self:SetWorldPosition(cpNode:GetSpawnPosition())
            self:SetWorldRotation(cpNode:GetSpawnRotation())
            Log.Debug("spawn rot = " .. tostring(cpNode:GetSpawnRotation()))

            GameState.checkpoint = teleCp
        end
    end

    if (Input.IsGamepadDown(Gamepad.Select) or Input.IsGamepadDown(Gamepad.Z)) then
        if (Input.IsGamepadPressed(Gamepad.Right)) then
            self.statsEnabled = not self.statsEnabled
            Renderer.EnableStatsOverlay(self.statsEnabled)
        end
    end
end