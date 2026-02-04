InGameMenu = {}

function InGameMenu:Create()

    self.timeOpen = 0.0

end

function InGameMenu:GatherProperties()

    return
    {
        { name = "resume", type = DatumType.Node},
        { name = "mainMenu", type = DatumType.Node},
        { name = "quit", type = DatumType.Node},
        { name = "hintText", type = DatumType.Node},
    }
end

function InGameMenu:Start()

    if (self.started) then
        return
    end

    self.resume:ConnectSignal("Activated", self, InGameMenu.Close)
    self.mainMenu:ConnectSignal("Activated", self, InGameMenu.GotoMainMenu)
    self.quit:ConnectSignal("Activated", self, InGameMenu.QuitGame)

    self.options = self:FindChild("Options", true)


    local useGamepad = Input.IsGamepadConnected(1)

    local hintStr = ""

    if (useGamepad) then
        hintStr = hintStr .. "`f33`Move:`fff` Right Stick\n"
        hintStr = hintStr .. "`f33`Look:`fff` Left Stick\n"
        hintStr = hintStr .. "`f33`Suck Object:`fff` Hold R\n"
        hintStr = hintStr .. "`f33`Shoot Object:`fff` Release R\n"
        hintStr = hintStr .. "`f33`Aim:`fff` Hold L\n"
        hintStr = hintStr .. "`f33`Jump:`fff` A\n"
        hintStr = hintStr .. "`f33`Drop Object:`fff` B\n"
        hintStr = hintStr .. "`f33`Reload Last Checkpoint:`fff` Y\n"
    else
        hintStr = hintStr .. "`f33`Move:`fff` W/A/S/D\n"
        hintStr = hintStr .. "`f33`Look:`fff` Move Mouse\n"
        hintStr = hintStr .. "`f33`Suck Object:`fff` Hold Left Click\n"
        hintStr = hintStr .. "`f33`Shoot Object:`fff` Release Left Click\n"
        hintStr = hintStr .. "`f33`Aim:`fff` Hold Right Click\n"
        hintStr = hintStr .. "`f33`Jump:`fff` Space\n"
        hintStr = hintStr .. "`f33`Drop Object:`fff` E\n"
        hintStr = hintStr .. "`f33`Reload Last Checkpoint:`fff` R\n"
    end

    self.hintText:SetText(hintStr)

    self.started = true

end

function InGameMenu:Tick(detlaTime)

    self.timeOpen = self.timeOpen + detlaTime

end

function InGameMenu:IsOpen()

    return (self:GetParent() ~= nil)

end

function InGameMenu:Open(controller)

    if (not self.started) then
        self:Start()
    end

    self.resume:SetActive(true)

    Button.SetSelected(self.resume)

    self.controller = controller
    self.controller.enableControl = false
    self:Attach(self.controller:GetRoot())

    Input.LockCursor(false)
    Input.TrapCursor(false)
    Input.ShowCursor(true)

    if (Engine.GetPlatform() == "3DS") then
        local world2 = Engine.GetWorld(2)
        if (world2:GetRootNode() == nil) then
        else
            local root2 = world2:GetRootNode()
        end
        world2:GetRootNode():AddChild(self.options)
        self.options:SetAnchorMode(AnchorMode.FullStretch)
        self.options:SetRatios(0.1, 0.1, 0.8, 0.8)
    end

    self.timeOpen = 0.0

end

function InGameMenu:Close()

    if (self.timeOpen < 0.1) then
        return
    end

    self.controller.enableControl = true
    self:Detach()

    if (Engine.GetPlatform() == "3DS") then
        self.options:Detach()
    end

    Input.LockCursor(true)
    Input.TrapCursor(true)
    Input.ShowCursor(false)

end

function InGameMenu:GotoMainMenu()

    if (self.timeOpen < 0.1) then
        return
    end

    if (Engine.GetPlatform() == "3DS") then
        Engine.GetWorld(2):Clear()
    end

    self.world:LoadScene("SC_MainMenu")

end

function InGameMenu:QuitGame()

    if (self.timeOpen < 0.1) then
        return
    end

    Engine.Quit()

end
