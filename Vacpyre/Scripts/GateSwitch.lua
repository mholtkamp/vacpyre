GateSwitch = {}

function GateSwitch:Start()

    self.activated = false
    self.time = 0.0

end

function GateSwitch:GatherProperties()

    return
    {
        { name = "gate", type = DatumType.Node },
        { name = "light", type = DatumType.Node},
        { name = "activationSound", type = DatumType.Asset},
    }
end

function GateSwitch:Tick(deltaTime)

    self.time = self.time + deltaTime
    local lightIntensity = math.abs(math.sin(self.time * 2.0))
    self.light:SetIntensity(lightIntensity)

end

function GateSwitch:OnCollision(this, other)

    if (not self.activated and
        other:HasTag("Red")) then

        Log.Debug("SWITCH HIT!")

        self.gate:Open()
        self.light:SetVisible(false)
        self.activated = true

        if (self.activationSound) then
            Audio.PlaySound2D(self.activationSound)
        end
    end

end