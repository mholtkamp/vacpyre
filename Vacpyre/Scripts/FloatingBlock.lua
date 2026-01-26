FloatingBlock = {}

function FloatingBlock:Create()

    self.dampTimer = 0.0
    self.defaultLinDamping = 0.5
    self.defaultAngDamping = 0.2

end

function FloatingBlock:Start()

    local parent = self:GetParent()

    parent:SetLinearFactor(Vec(1,0,1))
    parent:SetAngularFactor(Vec(0,1,0))
    parent:SetAngularDamping(self.defaultLinDamping)
    parent:SetLinearDamping(self.defaultAngDamping)

    parent:ConnectSignal("OnCollision", self, FloatingBlock.OnCollision)

end

function FloatingBlock:Tick(deltaTime)

    local parent = self:GetParent()

    if (self.dampTimer > 0) then
        self.dampTimer = math.max(self.dampTimer - deltaTime, 0.0)

        parent:SetLinearDamping(1.0)
        parent:SetAngularDamping(1.0)

        if (self.dampTimer <= 0.0) then
            parent:SetLinearDamping(self.defaultLinDamping)
            parent:SetAngularDamping(self.defaultAngDamping)
        end
    end

end


function FloatingBlock:OnCollision(this, other, impactPosition, impactNormal)

    if (other:HasTag("Hero")) then
        -- When player touches, increase damping temporarily so it doesnt slide out beneath easily
        self.dampTimer = 0.3
    end
end