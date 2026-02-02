Script.Require("GameState")

Level = {}

function Level:Create()

    self.zones = {}
    self.songAlpha = 0.0
    self.musicShiftCp = 4

    self.bgm1 = nil
    self.bgm2 = nil
end

function Level:GatherProperties()

    return
    {

    }

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

        local platform = Engine.GetPlatform()
    local isConsole = platform == "GameCube" or
                      platform == "Wii" or
                      platform == "3DS"


    if (isConsole) then
        self.bgm1 = LoadAsset("SW_Song2_LQ")
        self.bgm2 = LoadAsset("SW_Song1_LQ")
    else
        self.bgm1 = LoadAsset("SW_Song2_HQ")
        self.bgm2 = LoadAsset("SW_Song1_HQ")
    end

    -- Don't restart songs after dying
    if (not Audio.IsSoundPlaying(self.bgm1)) then
        local volume1 = (GameState.checkpoint >= self.musicShiftCp) and 0.0 or 1.0
        Audio.PlaySound2D(self.bgm1, volume1, 1, 1, true)
        Audio.PlaySound2D(self.bgm2, 1.0 - volume1, 1, 1, true)
    end

    self.songAlpha = GameState.checkpoint >= self.musicShiftCp and 1.0 or 0.0
    Log.Debug("SONG ALPHA = " .. tostring(self.songAlpha))
end

function Level:Stop()

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

function Level:Tick(deltaTime)

    -- Blend music over to song 2 once we hit level 4
    local targetAlpha = 0.0
    if (GameState.checkpoint >= 4) then
        targetAlpha = 1.0
    end

    self.songAlpha = Math.Approach(self.songAlpha, targetAlpha, 0.5, deltaTime)

    Audio.UpdateSound(self.bgm1, 1.0 - self.songAlpha, 1.0, 1)
    Audio.UpdateSound(self.bgm2, self.songAlpha, 1.0, 1)

end