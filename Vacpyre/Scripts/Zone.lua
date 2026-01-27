Zone = {}

function Zone:Create()

    self.zoneIdx = 0
    self:AddTag("Zone")

end

function Zone:GatherProperties()

    return
    {
        { name = "zoneIdx", type = DatumType.Integer },
    }

end
