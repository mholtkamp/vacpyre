Hero = {}

function Hero:Create()

    -- Props
    self.maxHealth = 100

    -- State
    self.hud = nil
    self.health = self.maxHealth
end

function Hero:Start()

    -- Assign a global hero reference on the root node
    self:GetRoot().hero = self
    self.hud = self:GetRoot():FindChild("Hud", true)

    self.health = self.maxHealth

end

function Hero:Damage(damage)

    self.hud:OnDamage()

    self.health = Math.Clamp(self.health - damage, 0, self.maxHealth)

    if (self.health <= 0) then
        Log.Error("DEAD")
    end

end