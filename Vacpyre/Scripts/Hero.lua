Hero = {}

function Hero:Create()


end

function Hero:Start()

    -- Assign a global hero reference on the root node
    self:GetRoot().hero = self

end