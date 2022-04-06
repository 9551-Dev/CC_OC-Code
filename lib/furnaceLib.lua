-- furnace lib by manaphoenix

local module = {}

local furnaces = {}
local fuelChest = {}
local outputChest = {}
local inputChest = {}

-- internal functions
local function countFuel()
    local fuel = 0
    for i,v in pairs(fuelChest.list()) do
        fuel = fuel + v.count
    end
    return fuel
end

local function countInput()
    local input = 0
    for i,v in pairs(inputChest.list()) do
        input = input + v.count
    end
    return input
end

local function getFilledSlot(inventory)
    for i,v in pairs(inventory.list()) do
        if v.count > 0 then
            return i, v.count
        end
    end
    return nil
end

local function getName(peripheral)
    return peripheral.getName(peripheral)
end

-- module functions
function module.addFurnace(furnace)
    table.insert(furnaces, furnace)
end

function module.removeFurnace(furnace)
    for i,v in pairs(furnaces) do
        if v == furnace then
            table.remove(furnaces, i)
            return
        end
    end
end

function module.getFurnaces()
    return furnaces
end

function module.getFurnaceCount()
    return #furnaces
end

function module.setFuelChest(chest)
    fuelChest = chest
end

function module.setOutputChest(chest)
    outputChest = chest
end

function module.setInputChest(chest)
    inputChest = chest
end

function module.restackChest(inventory)
    for i,v in pairs(inventory.list()) do
        inventory.pushItems(getName(inventory), i)
    end
end

function module.refuelFurnaces()
    local fuel = countFuel()
    local maxSplit = fuel / #furnaces
    local attemptFilled = 0
    for i,v in pairs(furnaces) do
        repeat
            local slot, count = getFilledSlot(fuelChest)
            local movedItems = v.pullItems(getName(fuelChest), slot, maxSplit, 2)
            if movedItems == 0 then
                break;
            end
            attemptFilled = attemptFilled + count
        until attemptFilled >= maxSplit
    end
end

function module.emptyFurnaces()
    for i,v in pairs(furnaces) do
        v.pushItems(getName(outputChest), 3)
    end
end

function module.fillFurnaces()
    -- check to make there is room in output chest.
    if #outputChest.list() ~= 0 then
        return false, "Empty the output chest!"
    end

    local items = countInput()
    local maxSplit = items / #furnaces
    for i,v in pairs(furnaces) do
        local attemptFilled = 0
        repeat
            local slot,count = getFilledSlot(inputChest)
            local movedItems = v.pullItems(getName(inputChest), slot, maxSplit, 1)
            if movedItems == 0 then
                break;
            end
            attemptFilled = attemptFilled + count
        until attemptFilled >= maxSplit
    end
    return true
end

return module