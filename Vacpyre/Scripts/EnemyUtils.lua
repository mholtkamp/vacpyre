
EnemyUtils = {}

EnemyUtils.FireProjectile = function(shooter, target, projScene, lead)

    local proj = projScene:Instantiate()
    shooter:GetRoot():AddChild(proj)
    local spawnPos = shooter.firePivot and shooter.firePivot:GetWorldPosition() or shooter:GetWorldPosition()
    local aimPos = target:GetWorldPosition()

    if (lead and 
        target.controller and 
        target.controller.GetVelocity) then

        local targetVel = target.controller:GetVelocity()
        local targetPos = aimPos

        local i = 0
        for i = 0, 3 do
            -- v = d/t
            -- t = d/v
            local time =  (aimPos - spawnPos):Length() / proj.speed
            local targetMovedPos = targetPos + targetVel * time
            aimPos = targetMovedPos

        end
    end

    local aimDirection = (aimPos - spawnPos):Normalize()
    proj:SetWorldPosition(spawnPos)
    proj:Launch(aimDirection)

end