local component = require("component")


---@class FluidReactor
---@field controller 'component.proxy'
---@field max_heat integer
local FluidReactor = {}

FluidReactor.__index = FluidReactor

---@param address string
---@return FluidReactor
function FluidReactor:new(address)
    setmetatable(self, FluidReactor)
    local controller = component.proxy(address)
    if controller.type ~= "reactor_redstone_port" then
        error("The component \""..address.."\" is not a Reactor Redstone Port")
    end
    self.address = address
    self.controller = controller
    self.active = false
    self.max_heat = self.controller.getMaxHeat()
    return self
end

function FluidReactor:start()
    print("Starting the Fluid Reactor "..self.address)
    self.controller.setActive(true)
    self.active = true
end

function FluidReactor:shutdown()
    print("Shutting down the Fluid Reactor "..self.address)
    self.controller.setActive(false)
    self.active = false
end

---@return boolean
function FluidReactor:check_health()
    local heat = self.controller.getHeat()
    if self.active and heat >= 1000 then
        return false
    elseif not self.active and heat > 0 then
        return false
    else
        return true
    end
end


return FluidReactor
