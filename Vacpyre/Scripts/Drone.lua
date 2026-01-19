Drone = {}

function Drone:Create()

    self.propRotSpeed = 1000.0

end

function Drone:GatherProperties()


end

function Drone:Start()

    self.propeller1 = self:FindChild("Prop1", true)
    self.propeller2 = self:FindChild("Prop2", true)
    self.propellers = { self.propeller1, self.propeller2 }

end

function Drone:Tick(deltaTime)

    local propRot = self.propeller1:GetRotation()
    propRot.y = propRot.y + deltaTime * self.propRotSpeed
    for i=1,#self.propellers do
        self.propellers[i]:SetRotation(propRot)
    end

end