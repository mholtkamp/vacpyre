Script.Require("GameState")

MainMenuWidget = {}

function MainMenuWidget:Create()

    self.time = 0.0
    self.scrollQuad = nil
    self.scrollSpeed = 0.1
    self.fadeDuration = 1.0
    self.song = nil
end

function MainMenuWidget:GatherProperties()

    return
    {
        { name = "scrollQuad", type = DatumType.Node },
        { name = "scrollSpeed", type = DatumType.Float },
        { name = "startText", type = DatumType.Node },
        { name = "blackQuad", type = DatumType.Node },
        { name = "levelName", type = DatumType.String },
    }

end

function MainMenuWidget:Start()

    self.scrollQuad:SetVertexColors(Vec(1,0,0,1), Vec(1,0,0,1), Vec(0,0,0,0), Vec(0,0,0,0))
    self.blackQuad:SetVisible(false)

    Input.LockCursor(false)
    Input.TrapCursor(false)
    Input.ShowCursor(true)

    local platform = Engine.GetPlatform()
    local isConsole = platform == "GameCube" or
                      platform == "Wii" or
                      platform == "3DS"

    if (isConsole) then
        self.song = LoadAsset("SW_Song2_LQ")
    else
        self.song = LoadAsset("SW_Song2_HQ")
    end

    Audio.StopAllSounds()
    Audio.PlaySound2D(self.song, 1, 1, 0, true)

end

function MainMenuWidget:Stop()

    Audio.StopAllSounds()

end

function MainMenuWidget:Tick(deltaTime)

    self.time = self.time + deltaTime

    -- Scroll quad
    local uvOff = self.scrollQuad:GetUvOffset()
    uvOff.y = uvOff.y + deltaTime * self.scrollSpeed
    self.scrollQuad:SetUvOffset(uvOff)

    -- Pulse press start text
    local startAlpha = math.abs(math.sin(self.time * 2.0))
    self.startText:SetOpacityFloat(startAlpha)

    -- Transition to game when user presses start
    if (not self.fading and
        (Input.IsKeyPressed(Key.Enter) or Input.IsKeyPressed(Key.Space) or Input.IsGamepadPressed(Gamepad.Start))) then

        self.fading = true
        self.fadeTime = self.fadeDuration
        self.blackQuad:SetVisible(true)
    end

    -- If we are fading, then begin showing the black quad
    if (self.fading) then
        self.fadeTime = self.fadeTime - deltaTime
        local blackOpacity = Math.Clamp(1.0 - (self.fadeTime / self.fadeDuration), 0, 1)
        self.blackQuad:SetOpacityFloat(blackOpacity)

        if (blackOpacity >= 1.0) then
            GameState.checkpoint = 1
            self.world:LoadScene( self.levelName)
        end
    end

    -- Fade in sound
    local vol =  Math.Clamp((self.time) * 0.25, 0, 1)
    Audio.UpdateSound(self.song, vol)

end