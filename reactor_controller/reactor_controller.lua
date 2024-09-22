local serial = require("serialization")
local fs = require("filesystem")
local term = require("term")
local event = require("event")
local component = require("component")
local colors = require("colors")
local controllers = require("reactor_controller.controllers")


local redstone_side = 0


---@param value number
---@param max number
local function create_bar(value, max)
    local bars
    local lines
    if value <= max then
        bars = math.floor(value/max*10)
        lines = 10 - bars
    else
        bars = 10
        lines = 0
    end
    local bar_draw = string.rep("#", bars)
    local line_draw = string.rep("-", lines)
    return bar_draw..line_draw
end

---@param path? string
---@return table
local function load_config(path)
    if not path then
        path = "/etc/reactor_controller.cfg"
    end
    if not fs.exists(path) then
        print('config file does not exists')
    end
    local file, msg = io.open(path, "r")
    if not file then
        error("Error whule trying to read the config file at "..path..": "..msg)
    end
    local raw_configs = file:read("*a")
    file:close()
    local configs = serial.unserialize(raw_configs) or {-1}
    return configs
end


---@class Manager
---@field fluid_reactors [FluidReactorController]
---@field redstone table
local Manager = {}

Manager.__index = Manager

---@param config table
---@return Manager
function Manager:new(config)
    setmetatable(self, Manager)
    self.fluid_reactors = {}
    if config.redstone then
        redstone_side = config.redstone.side
    end
    if config.fluid_reactors then
        for index, cfg in pairs(config.fluid_reactors) do

            for _, field in pairs({"name", "reactor", "heatexchanger", "coolanttank", "watertank"}) do
                if not cfg[field] then
                    error("Missing field of \""..field.."\" in the fluid reactor number "..index)
                end
            end

            local fluid_reactor = controllers.FluidReactorController:new(
                cfg.name,
                cfg.reactor,
                cfg.heatexchanger,
                cfg.coolanttank,
                cfg.watertank
            )
            table.insert(self.fluid_reactors, fluid_reactor)
        end
    end
    return self
end

function Manager:check()
    for _, reactor in pairs(self.fluid_reactors) do
        reactor:check_system_health()
    end
end

function Manager:stop_all()
    print('Shutting down all the reactors')
    for _, reactor in pairs(self.fluid_reactors) do
        if reactor.active then
            print('Shutting down reactor '..reactor.name)
            reactor:set_status(false)
        end
    end
end

function Manager:print_reactors()
    term.clear()
    for _, reactor in pairs(self.fluid_reactors) do
        local status = reactor:get_status()
        print("-----------------")
        print("Fluid Reactor:   "..reactor.name)
        print("Is Active:       "..status.is_active)
        local heat_bar = create_bar(status.reactor.heat, status.reactor.max_heat)
        print("Reactor Heat:    "..heat_bar)
        print("                 "..status.reactor.heat.."/"..status.reactor.max_heat)
        local coolant_bar = create_bar(status.coolant.level, status.coolant.capacity)
        print("Coolant Tank:    "..coolant_bar)
        print("                 "..status.coolant.level.."/"..status.coolant.capacity)
        local water_bar = create_bar(status.water.level, status.water.capacity)
        print("Water Tank:      "..water_bar)
        print("                 "..status.water.level.."/"..status.water.capacity)
        print("Heat Exchanger:  "..tostring(status.heat_exchanger.active))
        print("                 "..status.heat_exchanger.progress)
    end
end


local manager = Manager:new(load_config())


while true do
    local id, _, _ = event.pull(1, "interrupted")
    if id == "interrupted" then
        print("Closing the program.")
        manager:stop_all()
        break
    end

    if component.redstone.getBundledInput(redstone_side, colors.red) then
        manager:stop_all()
    else
        manager:check()
    end

    manager:print_reactors()
end
