Gate = {}

function Gate:Create()

    self.opening = false

end

function Gate:GatherProperties()

    return
    {
        { name = "doorLeft", type = DatumType.Node },
        { name = "doorRight", type = DatumType.Node },
    }
end

function Gate:Start()


end

function Gate:Tick(deltaTime)

    if (self.opening) then

        local rotY = self.doorLeft:GetRotation().y
        rotY = Math.ApproachAngle(rotY, 90.0, 40.0, deltaTime)

        self.doorLeft:SetRotation(Vec(0, rotY, 0))
        self.doorRight:SetRotation(Vec(0, -rotY, 0))

        if (rotY >= 90.0) then
            self.doorLeft:EnableCollision(true)
            self.doorRight:EnableCollision(true)
            self.opening = false
            self.opened = true
        end
    end
end

function Gate:Open()

    if (not self.opened and not self.opening) then
        self.doorLeft:EnableCollision(false)
        self.doorRight:EnableCollision(false)
        self.opening = true
    end
end
