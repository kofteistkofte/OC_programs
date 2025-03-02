local component = require("component")


---@class FluidReactor
---@field address string
---@field controller reactor_redstone_port
---@field max_heat integer
local FluidReactor = {}

FluidReactor.__index = FluidReactor

---@param address string
---@return FluidReactor
function FluidReactor.new(address)
    local self = setmetatable({}, FluidReactor)
    local controller = component.proxy(address, "reactor_redstone_port")
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
