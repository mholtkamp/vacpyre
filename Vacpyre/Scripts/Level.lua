Script.Require("GameState")

Level = {}

function Level:Create()

    self.zones = {}

end

function Level:Start()

    -- Find all zones and register them
    self:Traverse(
        function(node)
            if (node:HasTag("Zone")) then
                Log.Debug("Found zone: " .. node:GetName())
                self:RegisterZone(node, node.zoneIdx)
            end

            return true
        end
    )

    self:DisableAllZones()

    -- Enable only zones within 1 of checkpoint idx
    self:EnableZone(GameState.checkpoint - 1, true)
    self:EnableZone(GameState.checkpoint, true)
    self:EnableZone(GameState.checkpoint + 1, true)

end

function Level:EnableZone(zoneIdx, enable)

    local zone = self.zones[zoneIdx]
    if (zone) then
        if (enable) then
            zone:Attach(self)
        else
            zone:Detach()
        end
    end

end

function Level:DisableAllZones()

    -- Disable all zones by default
    for k,v in pairs(self.zones) do
        self:EnableZone(k, false)
    end

end

function Level:RegisterZone(zone, zoneIdx)

    self.zones[zoneIdx] = zone

end
