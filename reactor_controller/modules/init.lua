local modules = {}

modules.FluidReactor = require("reactor_controller.modules.fluid_reactor")
modules.HeatExchanger = require("reactor_controller.modules.heat_exchanger")
modules.Tank = require("reactor_controller.modules.tank")
modules.Redstone = require("reactor_controller.modules.redstone")

return modules
