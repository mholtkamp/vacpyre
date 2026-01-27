local world = Engine.GetWorld(1)
local root = world:GetRootNode()

root:Traverse(
    function (node)

        if (node:HasTag("Zone")) then

            local childToWorldPos = {}

            for i = 1, node:GetNumChildren() do
                local child = node:GetChild(i)
                local worldPos = child:GetWorldPosition()
                childToWorldPos[child] = worldPos
            end

            -- Set zone pos to origin
            node:SetWorldPosition(Vec(0,0,0))

            -- Restore world position
            for k, v in pairs(childToWorldPos) do
                k:SetWorldPosition(v)
            end
        end

        return true
    end
)
