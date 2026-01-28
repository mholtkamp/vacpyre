InGameMenu = {}

function InGameMenu:Create()

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

    self.resume:ConnectSignal("Activated", self, InGameMenu.Close)
    self.mainMenu:ConnectSignal("Activated", self, InGameMenu.GotoMainMenu)
    self.quit:ConnectSignal("Activated", self, InGameMenu.QuitGame)

    local useGamepad = Input.IsGamepadConnected(1)

    local hintStr = ""

    if (useGamepad) then
        hintStr = hintStr .. "`f33`Move:`fff` Right Stick\n"
        hintStr = hintStr .. "`f33`Look:`fff` Left Stick\n"
        hintStr = hintStr .. "`f33`Suck Object:`fff` Hold L\n"
        hintStr = hintStr .. "`f33`Shoot Object:`fff` Release L\n"
        hintStr = hintStr .. "`f33`Jump:`fff` A\n"
        hintStr = hintStr .. "`f33`Drop Object:`fff` B\n"
        hintStr = hintStr .. "`f33`Reload Last Checkpoint:`fff` Y\n"
    else
        hintStr = hintStr .. "`f33`Move:`fff` W/A/S/D\n"
        hintStr = hintStr .. "`f33`Look:`fff` Move Mouse\n"
        hintStr = hintStr .. "`f33`Suck Object:`fff` Hold Left Click\n"
        hintStr = hintStr .. "`f33`Shoot Object:`fff` Release Left Click\n"
        hintStr = hintStr .. "`f33`Jump:`fff` Space\n"
        hintStr = hintStr .. "`f33`Drop Object:`fff` E\n"
        hintStr = hintStr .. "`f33`Reload Last Checkpoint:`fff` R\n"
    end

    self.hintText:SetText(hintStr)

end

function InGameMenu:Tick(detlaTime)

    self.timeOpen = self.timeOpen + detlaTime

end

function InGameMenu:IsOpen()

    return (self:GetParent() ~= nil)

end

function InGameMenu:Open(controller)

    self.resume:SetActive(true)

    Button.SetSelected(self.resume)

    self.controller = controller
    self.controller.enableControl = false
    self:Attach(self.controller:GetRoot())

    self.timeOpen = 0.0

end

function InGameMenu:Close()

    if (self.timeOpen < 0.1) then
        return
    end

    self.controller.enableControl = true
    self:Detach()

end

function InGameMenu:GotoMainMenu()

    if (self.timeOpen < 0.1) then
        return
    end

    self.world:LoadScene("SC_MainMenu")

end

function InGameMenu:QuitGame()

    if (self.timeOpen < 0.1) then
        return
    end

    Engine.Quit()

end
