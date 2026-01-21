RockWall = {}

function RockWall:Create()

    self.fadeRocks = false
    self.fadeDuration = 2.0

    self.matInst = nil
    self.physEnabled = false
    self.fadeTime = 0.0

end

function RockWall:Tick(deltaTime)

    if (self.fadeRocks and self.physEnabled) then

        self.fadeTime = self.fadeTime + deltaTime
        local opacity = Math.MapClamped(self.fadeTime, 0, self.fadeDuration, 1.0, 0.0)
        self.matInst:SetOpacity(opacity)

        if (self.fadeTime > self.fadeDuration) then
            self:Doom()
        end
    end

end

function RockWall:Start()

    -- Disable physics by default
    for i = 1, self:GetNumChildren() do
        self:GetChild(i):EnablePhysics(false)
    end

    local platform = Engine.GetPlatform()
    if (platform == "3DS" or
        platform == "GameCube" or
        platform == "Wii") then

        -- On consoles, don't let rocks collide with each other
        -- because it's very expensive apparently (convex collsion?)
        self.fadeRocks = true
        self.matInst = self:GetChild(1):InstantiateMaterial()

        for i = 2, self:GetNumChildren() do
            self:GetChild(i):SetMaterialOverride(self.matInst)
        end
    end

end

function RockWall:OnCollision(this, other)

    if (not self.physEnabled and
        other:HasTag("Red") and
        other:GetLinearVelocity():Length() > 10.0) then

        if (self.fadeRocks) then
            for i = 1, self:GetNumChildren() do

                local rock = self:GetChild(i)
                local collider = Node.Construct("Box3D")
                collider:EnableCollision(true)
                collider:EnablePhysics(true)
                collider:SetCollisionGroup(VacpyreCollision.Default)
                collider:SetCollisionGroup(VacpyreCollision.Default | VacpyreCollision.Environment)
                collider:Attach(self, false, i)
                collider:SetWorldPosition(rock:GetWorldPosition())
                local extents = rock:GetBounds().radius
                collider:SetExtents(Vec(extents,extents,extents))
                rock:Attach(collider, true)
                rock:EnableCollision(false)
                rock:EnablePhysics(false)

                self.matInst:SetBlendMode(BlendMode.Translucent)
            end
        end

        for i = 1, self:GetNumChildren() do
            self:GetChild(i):EnablePhysics(true)
        end

        self.physEnabled = true
    end

end