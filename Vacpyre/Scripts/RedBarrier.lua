RedBarrier = {}

function RedBarrier:Create()

    self.poofParticle = nil
    self.scrollSpeed = 1.0
end

function RedBarrier:GatherProperties()

    return
    {
        { name = "scrollSpeed", type = DatumType.Float },
    }
end

function RedBarrier:Start()

    self.poofParticle = LoadAsset("P_RedPoof")
    self.poofSound = LoadAsset("SW_Poof")

    self.matInst = self:InstantiateMaterial()

end

function RedBarrier:Tick(deltaTime)

    local uvOff = self.matInst:GetUvOffset()
    uvOff.y = uvOff.y + deltaTime * self.scrollSpeed
    self.matInst:SetUvOffset(uvOff)

end

function RedBarrier:BeginOverlap(this, other)

    if (this == self and
        other:HasTag("Red")) then

        -- Spawn poof
        self.world:SpawnParticle(self.poofParticle, other:GetWorldPosition())

        -- Play sound
        Audio.PlaySound3D(self.poofSound, other:GetWorldPosition(), 10, 50)

        -- Kill the object
        other:Doom()
    end
end