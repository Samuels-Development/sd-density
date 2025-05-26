local currentZone = nil             -- Variable to track the current zone the player is in
local currentBase = nil             -- Current population table to apply
local lastHourCheck = GetClockHours()  -- Last hour we checked schedules
local debug = Config.DebugPrints
local zones = Config.Zones
local defaultPop = Config.DefaultPopulation

for _, rel in ipairs(Config.Relationships) do
    SetRelationshipBetweenGroups(rel.relationship,rel.group1,rel.group2)
end

--- Spawns a polygonal zone with ox_lib and sets up enter/exit handlers.
--- @param id string      Unique key matching Config.Zones[id].
--- @param zoneData table Zone definition (points, thickness, debug, population schedules).
local SpawnPolyZone = function(id, zoneData)
    if debug then
        print(("Spawning poly zone '%s' (%d pts, thickness=%.1f)"):format(id, #zoneData.points, zoneData.thickness or 4.0))
    end

    lib.zones.poly({
        name      = id,
        points    = zoneData.points,
        thickness = zoneData.thickness or 4.0,
        debug     = zoneData.debug  or false,
        onEnter   = function()
            currentZone = id
            RefreshBase()
            if debug then
                print(("Entered zone '%s'"):format(id))
            end
        end,
        onExit    = function()
            if currentZone == id then
                if debug then
                    print(("Exited zone '%s'"):format(id))
                end
                currentZone = nil
                RefreshBase()
            end
        end,
    })
end

--- Finds the matching schedule for the current hour.
--- @param schedules table[] Array of { from, to, population = {...} }.
--- @return table            The matched population table, or nil.
local GetScheduledPopulation = function(schedules)
    local hr = GetClockHours()
    for _, sched in ipairs(schedules) do
        if hr >= sched.from and hr < sched.to then
            return sched.population
        end
    end
    return nil
end

--- Applies density multipliers this frame.
--- @param base table Base population settings (peds, vehicles, etc.).
local ApplyDensityMultipliers = function(base)
    SetParkedVehicleDensityMultiplierThisFrame(base.parked)
    SetVehicleDensityMultiplierThisFrame(base.vehicles)
    SetRandomVehicleDensityMultiplierThisFrame(base.randomVehicles)
    SetPedDensityMultiplierThisFrame(base.peds)
    SetScenarioPedDensityMultiplierThisFrame(base.scenario, base.scenario)
end

--- Prints current status: active zone and multipliers.
--- Throttled to statusIntervalMs.
--- @param zone string|nil Current zone ID, or nil.
--- @param base table      Base population table.
local PrintStatus = function(zone, base)
    if not debug then return end
    local name = zone or "DEFAULT"
    print(("STATUS | Zone: %s | Peds: %.2f | Veh: %.2f | RandVeh: %.2f | Parked: %.2f | Scenario: %.2f"):format(name, base.peds, base.vehicles, base.randomVehicles, base.parked, base.scenario))
end

--- Refreshes `currentBase` based on zone & time.
RefreshBase = function()
    local schedules = currentZone and zones[currentZone].population
    currentBase = (schedules and GetScheduledPopulation(schedules)) or defaultPop
    lastHourCheck = GetClockHours()
end

RefreshBase() -- Run it to initially set density for the zone the player is in (if any)

--- Handles dynamic global-state overrides for zone populations.
--- Patches the client’s Config.Zones so all subsequent scheduling uses new values.
--- @param _bagName string Ignored.
--- @param key     string "zone_<id>".
--- @param value   table  Array of new { from, to, population = {…} } schedules.
local OnGlobalStateChange = function(_bagName, key, value)
    local id = key:match("^zone_(.+)$")
    if id and zones[id] and type(value) == "table" then
        zones[id].population = value

        if debug then
            print(("Schedules overridden for '%s':"):format(id))
            for idx, sched in ipairs(value) do
                local p = sched.population
                print(("[%d] %02d:00–%02d:00 → peds=%.2f, veh=%.2f, randVeh=%.2f, parked=%.2f, scenario=%.2f"):format(idx, sched.from, sched.to, p.peds, p.vehicles, p.randomVehicles, p.parked, p.scenario))
            end
        end

        if currentZone == id then
            RefreshBase()
        end
    end
end

-- Register statebag handler
AddStateBagChangeHandler("", nil, OnGlobalStateChange)

-- Spawn all zones
for id, data in pairs(zones) do
    SpawnPolyZone(id, data)
end

CreateThread(function()
    while true do
        ApplyDensityMultipliers(currentBase)
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        RefreshBase()

        Wait(30000)
    end
end)

if debug then
    CreateThread(function()
        while true do
            PrintStatus(currentZone, currentBase)

            Wait(1000)
        end
    end)
end
