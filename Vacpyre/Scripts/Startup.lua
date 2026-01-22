
VacpyreCollision =
{
    Default = 0x01,
    Environment = 0x02,
    Player = 0x04, Hero = 0x04,
    Red = 0x08,
    Projectile = 0x10,
    Sucked = 0x20,
    Barrier = 0x40,
    Chainlink = 0x80
}

function LogTable(tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      Log.Debug(formatting)
      tprint(v, indent+1)
    else
      Log.Debug(formatting .. tostring(v))
    end
  end
end
