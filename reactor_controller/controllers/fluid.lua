local modules = require("reactor_controller.modules")


---@class FluidReactorController
local FluidReactorController = {}

FluidReactorController.__index = FluidReactorController

---@param name string
---@param reactor string
---@param exchanger string
---@param coolant table
---@param water table
---@return FluidReactorController
function FluidReactorController:new(name, reactor, exchanger, coolant, water)
    setmetatable(self, FluidReactorController)
    self.name = name
    self.reactor = modules.FluidReactor:new(reactor)
    self.heat_exchanger = modules.HeatExchanger:new(exchanger)
    self.coolant_tank = modules.Tank:new(coolant[1], coolant[2], 1.0, 3.0)
    self.water_tank = modules.Tank:new(water[1], water[2], 10.0, 40.0)
    self.active = false
    return self
end

function FluidReactorController:check_tanks()
    if self.water_tank:check_health() and self.coolant_tank:check_health() then
        return true
    else
        return false
    end
end

---@param status boolean
function FluidReactorController:set_status(status)
    if status then
        self.heat_exchanger:start()
        self.reactor:start()
        self.active = true
    else
        self.reactor:shutdown()
        self.heat_exchanger:shutdown()
        self.active = false
    end
end

function FluidReactorController:check_system_health()
    local tank_health = self:check_tanks()
    local reactor_health = self.reactor:check_health()
    if not self.active and tank_health and reactor_health then
        print('Reactor '..self.name..' is ready to back online.')
        self:set_status(true)
    elseif self.active and not (tank_health and reactor_health) then
        print('Health  of Reactor '..self.name..' is not ok. Shutting down.')
        self:set_status(false)
    end
end

function FluidReactorController:get_status()
    local is_active = "Reactor is inactive"
    if self.active then
        is_active = "Reactor is ACTIVE"
    end
    local data = {
        is_active = is_active,
        reactor = {
            heat = self.reactor.controller.getHeat(),
            max_heat = self.reactor.max_heat
        },
        heat_exchanger = {
            active = self.heat_exchanger.controller.isWorkAllowed(),
            progress = self.heat_exchanger.controller.getWorkProgress()
        },
        coolant = {
            level = self.coolant_tank.controller.getTankLevel(self.coolant_tank.side),
            capacity = self.coolant_tank.capacity
        },
        water = {
            level = self.water_tank.controller.getTankLevel(self.water_tank.side),
            capacity = self.water_tank.capacity
        }
    }
    return data
end


return FluidReactorController
