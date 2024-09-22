local component = require("component")


---@class Redstone
---@field controller 'component.proxy'
local Redstone = {}

Redstone.__index = Redstone

---@param address string
---@param side integer
function Redstone:new(address, side)
    setmetatable(self, Redstone)
    local controller = component.proxy(address)
    if controller.type ~= "redstone" then
        error("The component \""..address.."\" is not a Redstone controller")
    end
    self.address = address
    self.side = side
    self.controller = controller
    return self
end

---@param colour integer
---@return boolean
function Redstone:check_signal(colour)
    local output = self.controller.getBundledInput(self.side, colour)
    if output == 0 then
        return false
    else
        return true
    end
end


return Redstone
