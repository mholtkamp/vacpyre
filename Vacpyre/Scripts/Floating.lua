Floating = {}

function Floating:Create()


    self.bouyancy = 10.0
    self.angularDamping = 0.3
    self.linearDamping = 0.2

    self.defaultAngularDamping = 0.0
    self.defaultLinearDamping = 0.0
    self.waterLevel = 0.0
    self.water = nil
    self.dampTimer = 0.0
    self.maxBouyantDepth = 8.0

end

function Floating:GatherProperties()

    return
    {
        { name = "bouyancy", type = DatumType.Float },
        { name = "angularDamping", type = DatumType.Float },
        { name = "linearDamping", type = DatumType.Float },
        { name = "maxBouyantDepth", type = DatumType.Float },
    }

end


function Floating:Start()

    local parent = self:GetParent()
    self.defaultAngularDamping = parent:GetAngularDamping()
    self.defaultLinearDamping = parent:GetLinearDamping()

    parent:ConnectSignal("BeginOverlap", self, Floating.BeginOverlap)
    parent:ConnectSignal("EndOverlap", self, Floating.EndOverlap)
    parent:ConnectSignal("OnCollision", self, Floating.OnCollision)

end

function Floating:Tick(deltaTime)

    local parent = self:GetParent()

    if (self.water) then
        local deltaY = self.waterLevel - parent:GetWorldPosition().y
        local bouyantForce = Math.MapClamped(deltaY, 0.0, self.maxBouyantDepth, 0.0, self.bouyancy)

        if (bouyantForce > 0.1) then
            parent:AddForce(Vec(0, bouyantForce, 0))
        end

    end

end

function Floating:BeginOverlap(this, other)

    if (other:HasTag("Water")) then

        self.water = other
        self.waterLevel = other:GetWorldPosition().y 
        
        local parent = self:GetParent()
        parent:SetAngularDamping(self.angularDamping)
        parent:SetLinearDamping(self.linearDamping)

    end

end

function Floating:EndOverlap(this, other)

    if (other == self.water) then

        if (this:GetWorldPosition().y > other:GetWorldPosition().y) then
            self.water = nil

            local parent = self:GetParent()
            parent:SetAngularDamping(self.defaultAngularDamping)
            parent:SetLinearDamping(self.defaultLinearDamping)
        end

    end
end

function Floating:OnCollision(this, other)


end