Config = {}

Config.DebugPrints = true -- Debug Prints to console (client & server).

Config.Zones = {
  -- Example for this entry:
  --   • 00:00–06:00 sleepy: very few peds/vehicles  
  --   • 06:00–18:00 busy: normal traffic & pedestrians  
  --   • 18:00–24:00 evening: moderate activity  
  downtown = {
    name      = "Downtown Los Santos",
    points    = {
      vector3(532.29, -1140.31, 25.00), -- preferably the Z coordinates should be the same for all points
      vector3(-291.11, -1154.06, 25.00),
      vector3(54.61,    283.98, 25.00),
      vector3(1239.57,  -42.82, 25.00),
    },
    thickness = 500.0,
    debug     = true,
    -- The `population` field is an array of:
    --   { from = <hour>, to = <hour>, population = { peds, vehicles, randomVehicles, parked, scenario } }
    -- Hours are in 24h format, [from, to).  Schedules must cover 0–24 to avoid fallbacks.
    population = {
      {
        from       =   0,
        to         =   6,
        population = { -- 0.0 nothing , 1.0 normal density also max amount
          peds           = 0.2,  -- 0.0 = no pedestrians, 1.0 = normal pedestrian density (max)
          vehicles       = 0.1,  -- 0.0 = no vehicles, 1.0 = normal vehicle traffic (max)
          randomVehicles = 0.1,  -- 0.0 = no “random” vehicles (e.g. pull-outs), 1.0 = normal random vehicle spawns (max)
          parked         = 0.1,  -- 0.0 = no parked cars, 1.0 = normal number of parked vehicles (max) 
          scenario       = 0.2,  -- 0.0 = no scenario peds (ambient animations), 1.0 = normal scenario peds (max)
        },
      },
      {
        from       =   6,
        to         =  18,
        population = {
          peds           = 1.0,
          vehicles       = 1.0,
          randomVehicles = 1.0,
          parked         = 0.8,
          scenario       = 1.0,
        },
      },
      {
        from       =  18,
        to         =  24,
        population = {
          peds           = 0.8,
          vehicles       = 0.6,
          randomVehicles = 0.6,
          parked         = 0.6,
          scenario       = 0.7,
        },
      },
    },
  },
  -- In this example we have one sub-table in the `population` array with a schedule from 0 to 24.
  -- This means that the population settings will be applied all day long.
  grovestreet = {
    name      = "Grove Street Home",
    points    = {
      vec3(-324.41, -1648.56, 20.00),
      vec3(-251.02, -1444.6, 20.00),
      vec3(461.67, -2057.22, 20.00),
      vec3(353.07, -2202.24, 20.00),
    },
    thickness = 500.0,
    debug     = true,
    population = {
      {
        from       =   0,
        to         =  24,
        population = {
          peds           = 0.5,
          vehicles       = 0.4,
          randomVehicles = 0.3,
          parked         = 0.2,
          scenario       = 0.5,
        },
      },
    },
  },
}

-- Fallback when no schedule matches (should rarely happen if 0–24 is covered)
Config.DefaultPopulation = {
  peds           = 0.7,
  vehicles       = 0.7,
  randomVehicles = 0.7,
  parked         = 0.6,
  scenario       = 0.7,
}