ProximitySphere = {}

function ProximitySphere:BeginOverlap(this, other)

    if (other:HasTag("Enemy")) then
        local controller = other.controller or other:FindChild("Controller", true)
        if (controller) then
            controller.heroNearby = true
        end
    end

end

function ProximitySphere:EndOverlap(this, other)

    if (other:HasTag("Enemy")) then
        local controller = other.controller or other:FindChild("Controller", true)
        if (controller) then
            controller.heroNearby = false
        end
    end

end