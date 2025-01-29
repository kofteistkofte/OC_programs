local component = require("component")


---@class HeatExchanger
---@field address string
---@field controller gt_machine
local HeatExchanger = {}

HeatExchanger.__index = HeatExchanger

---@param address string
---@return HeatExchanger
function HeatExchanger.new(address)
    local self = setmetatable({}, HeatExchanger)
    local controller = component.proxy(address, "gt_machine")
    if controller.type ~= "gt_machine" then
        error("The component \""..address.."\" is not a GregTech Machine")
    elseif controller.getName() ~= "multimachine.heatexchanger" then
        error("The component \""..address.."\" is not a Heat Exchanger")
    end
    self.address = address
    self.controller = controller
    return self
end

function HeatExchanger:start()
    self.controller.setWorkAllowed(true)
end

function HeatExchanger:shutdown()
    print('Shutting down the Heat Exchanger '..self.address)
    self.controller.setWorkAllowed(false)
end


return HeatExchanger
