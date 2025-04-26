local currentZone = nil -- Variable to track the current zone the player is in
local lastStatusPrint = 0 -- Variable to track the last time the status of the zone your in was printed
local statusIntervalMs = 5000 -- Variable to set the time/interval between status prints (in milliseconds)

--- Spawns a polygonal zone with ox_lib and sets up enter/exit handlers.
--- @param id string      Unique key matching Config.Zones[id].
--- @param zoneData table Zone definition (points, thickness, debug, population schedules).
local SpawnPolyZone = function(id, zoneData)
    if Config.DebugPrints then
        print(("Spawning poly zone '%s' (%d pts, thickness=%.1f)")
            :format(id, #zoneData.points, zoneData.thickness or 4.0))
    end

    lib.zones.poly({
        name      = id,
        points    = zoneData.points,
        thickness = zoneData.thickness or 4.0,
        debug     = zoneData.debug  or false,
        onEnter   = function()
            currentZone = id
            if Config.DebugPrints then
                print(("Entered zone '%s'"):format(id))
            end
        end,
        onExit    = function()
            if currentZone == id then
                if Config.DebugPrints then
                    print(("Exited zone '%s'"):format(id))
                end
                currentZone = nil
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
    SetParkedVehicleDensityMultiplierThisFrame   (base.parked)
    SetVehicleDensityMultiplierThisFrame         (base.vehicles)
    SetRandomVehicleDensityMultiplierThisFrame   (base.randomVehicles)
    SetPedDensityMultiplierThisFrame             (base.peds)
    SetScenarioPedDensityMultiplierThisFrame     (base.scenario, base.scenario)
end

--- Prints current status: active zone and multipliers.
--- Throttled to statusIntervalMs.
--- @param zone string|nil Current zone ID, or nil.
--- @param base table      Base population table.
local PrintStatus = function(zone, base)
    if not Config.DebugPrints then return end
    local name = zone or "DEFAULT"
    print(("STATUS | Zone: %s | Peds: %.2f | Veh: %.2f | RandVeh: %.2f | Parked: %.2f | Scenario: %.2f"):format(name, base.peds, base.vehicles, base.randomVehicles, base.parked, base.scenario))
end

--- Handles dynamic global-state overrides for zone populations.
--- Patches the client’s Config.Zones so all subsequent scheduling uses your new values.
--- @param _bagName string Ignored.
--- @param key     string "zone_<id>".
--- @param value   table  Array of new { from, to, population = {…} } schedules.
local OnGlobalStateChange = function(_bagName, key, value)
    local id = key:match("^zone_(.+)$")
    if id and Config.Zones[id] and type(value) == "table" then
        Config.Zones[id].population = value

        if Config.DebugPrints then
            print(("Schedules overridden for '%s':"):format(id))
            for idx, sched in ipairs(value) do
                local p = sched.population
                print(("[%d] %02d:00–%02d:00 → peds=%.2f, veh=%.2f, randVeh=%.2f, parked=%.2f, scenario=%.2f"):format(idx, sched.from, sched.to, p.peds, p.vehicles, p.randomVehicles, p.parked, p.scenario))
            end
        end
    end
end

AddStateBagChangeHandler("", nil, OnGlobalStateChange)

for id, data in pairs(Config.Zones) do
    SpawnPolyZone(id, data)
end

CreateThread(function()
    while true do
        local base
        if currentZone then
            base = GetScheduledPopulation(Config.Zones[currentZone].population)
                   or Config.DefaultPopulation
        else
            base = Config.DefaultPopulation
        end

        ApplyDensityMultipliers(base)

        local now = GetGameTimer()
        if now - lastStatusPrint >= statusIntervalMs then
            PrintStatus(currentZone, base)
            lastStatusPrint = now
        end

        Wait(0)
    end
end)
