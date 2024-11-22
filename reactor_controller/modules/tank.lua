local component = require("component")


---@class Tank
---@field address string
---@field side integer
---@field lower_threashold number
---@field upper_threashold number
---@field controller 'component.proxy'
---@field capacity number
local Tank = {}

Tank.__index = Tank

---@param address string
---@param side integer
---@param lower_threashold number
---@param upper_threashold number
---@return Tank
function Tank.new(address, side, lower_threashold, upper_threashold)
    local self = setmetatable({}, Tank)
    local controller = component.proxy(address)
    if controller.type ~= "tank_controller" then
        error("The component \""..address.."\" is not a Tank Controller")
    end
    self.address = address
    self.side = side
    self.controller = controller
    self.lower_threashold = lower_threashold
    self.upper_threashold = upper_threashold
    self.capacity = self.controller.getTankCapacity(self.side)
    self.is_healty = true
    return self
end

---@return boolean
function Tank:check_health()
    local current_level = self.controller.getTankLevel(self.side)
    local percent = current_level / self.capacity * 100

    if percent <= self.lower_threashold then
        self.is_healty = false
    elseif percent >= self.upper_threashold then
        self.is_healty = true
    end

    return self.is_healty
end


return Tank
