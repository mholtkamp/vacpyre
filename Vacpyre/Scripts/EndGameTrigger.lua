Script.Require("GameState")

EndGameTrigger = {}

function EndGameTrigger:BeginOverlap(this, other)

    if (not other:HasTag("Hero")) then
        return
    end

    local hero = GameState.hero
    hero.controller.inGameMenu:Close()
    hero.controller.enableControl = false
    hero.hud:FadeToBlack(1.0)

    local showWidget = function()
        local endGameWidget = LoadAsset("SC_EndGameWidget")
        self:GetRoot():AddChild(endGameWidget:Instantiate())
    end

    local gotoMenu = function()
        Engine.GetWorld(1):LoadScene("SC_MainMenu")
    end

    TimerManager.SetTimer(showWidget, 1.5)
    TimerManager.SetTimer(gotoMenu, 7.0)

end
