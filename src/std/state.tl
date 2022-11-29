local inventory = require("inventory")

local record state
    record Location
        id: string
        position: integer
        plate: inventory.Plate
    end
    record Module
        id: string
        locations: {Location}
    end
    record State
        modules: {Module}
        plates: function(): {inventory.Plate}
    end
end

return state
