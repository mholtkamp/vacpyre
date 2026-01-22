Block = {}

function Block:Start()

    self:EnablePhysics(false)

    TimerManager.SetTimer(function() self:EnablePhysics(true) end, 0.1)
end