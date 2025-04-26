--- Syncs all zone population schedules into GlobalState so clients receive them.
--- Prints each zone’s schedules when Config.DebugPrints is true.
--- @param resName string Name of the resource that just started.
local SyncGlobalZonePopulations = function(resName)
    if resName ~= GetCurrentResourceName() then return end

    for key, zone in pairs(Config.Zones) do
        GlobalState["zone_" .. key] = zone.population

        if Config.DebugPrints then
            print(("Zone '%s' schedules:"):format(key))
            for _, sched in ipairs(zone.population) do
                local p = sched.population
                print(("  %02d:00–%02d:00 → peds=%.2f, vehicles=%.2f, randomVehicles=%.2f, parked=%.2f, scenario=%.2f")
                    :format(sched.from, sched.to, p.peds, p.vehicles, p.randomVehicles, p.parked, p.scenario))
            end
        end
    end

    if Config.DebugPrints then
        print("GlobalState initialized with zone populations.")
    end
end
AddEventHandler('onResourceStart', SyncGlobalZonePopulations)

--- Handles the `pop:set` console command to tweak a zone’s schedule table.
--- Usage: `pop:set <zoneKey> <scheduleIndex> <field> <value>`
--- @param source number Console/source ID (0 = server).
--- @param args   table  { zoneKey:string, scheduleIndex:string, field:string, value:string }
local HandlePopSetCommand = function(source, args)
    local zk    = args[1]
    local idx   = tonumber(args[2])
    local field = args[3]
    local val   = tonumber(args[4])

    local zone = Config.Zones[zk]
    if not zone then
        print("Invalid zone.")
        return
    end
    local sched = zone.population[idx]
    if not sched or sched.population[field] == nil then
        print("Invalid schedule index or field.")
        return
    end

    sched.population[field] = val
    GlobalState["zone_" .. zk] = zone.population

    if Config.DebugPrints then
        print(("Updated %s[%d].%s → %.2f"):format(zk, idx, field, val))
    end
end
RegisterCommand("pop:set", HandlePopSetCommand, true)