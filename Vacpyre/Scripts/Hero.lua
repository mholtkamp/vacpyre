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
    end

end