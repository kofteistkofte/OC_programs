local component = require("component")


---@class Tank
---@field controller 'component.proxy'
---@field capacity number
local Tank = {}

Tank.__index = Tank

---@param address table
---@param lower_threashold number
---@param upper_threashold number
---@return Tank
function Tank:new(address, lower_threashold, upper_threashold)
    setmetatable(self, Tank)
    local controller = component.proxy(address[1])
    if controller.type ~= "tank_controller" then
        error("The component \""..address.."\" is not a Tank Controller")
    end
    self.address = address
    self.side = address[2]
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
