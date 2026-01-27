Script.Require("GameState")

Checkpoint = {}

function Checkpoint:Create()

    self.checkpointIndex = 1

end

function Checkpoint:GatherProperties()

    return
    {
        { name = "checkpointIndex", type = DatumType.Integer },
    }

end

function Checkpoint:BeginOverlap(this, other)

    if (other:HasTag("Hero")) then

        local level = self:GetRoot()
        level:DisableAllZones()
        level:EnableZone(self.checkpointIndex - 1, true)
        level:EnableZone(self.checkpointIndex, true)
        level:EnableZone(self.checkpointIndex + 1, true)

        if (GameState.checkpoint < self.checkpointIndex) then
            Log.Debug("New Checkpoint: " .. self.checkpointIndex)
            GameState.checkpoint = self.checkpointIndex
        end

    end

end

function Checkpoint:GetSpawnPosition()

    return self:GetWorldPosition()

end

function Checkpoint:GetSpawnRotation()

    -- Woops, I made all the boxes facing sideways 
    local spawnRot = self:GetWorldRotation()
    spawnRot.y = spawnRot.y - 90.0
    return spawnRot

end