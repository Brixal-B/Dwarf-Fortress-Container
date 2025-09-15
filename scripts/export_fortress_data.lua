-- export_fortress_data.lua
-- Enhanced DFHack script for exporting fortress data to JSON
-- Usage: script /opt/dwarf-fortress/scripts/export_fortress_data.lua

local json = require('json')

-- Ensure output directory exists
function ensure_output_dir()
    local output_dir = '/opt/dwarf-fortress/output'
    dfhack.filesystem.mkdir_recursive(output_dir)
    return output_dir
end

-- Get current fortress information
function get_fortress_info()
    local site = df.global.world.world_data.active_site[0]
    local site_name = "Unknown"
    
    if site then
        site_name = dfhack.TranslateName(site.name) or "Unnamed Fortress"
    end
    
    return {
        name = site_name,
        year = df.global.cur_year,
        season = df.global.cur_season,
        tick = df.global.cur_year_tick
    }
end

-- Count different types of units
function get_population_stats()
    local stats = {
        total = 0,
        dwarves = 0,
        animals = 0,
        visitors = 0,
        dead = 0,
        military = 0
    }
    
    for _, unit in ipairs(df.global.world.units.active) do
        if unit then
            stats.total = stats.total + 1
            
            -- Check if unit is alive
            if unit.flags1.dead then
                stats.dead = stats.dead + 1
            else
                -- Count by race
                if unit.race == df.global.ui.race_id then
                    stats.dwarves = stats.dwarves + 1
                    
                    -- Check if in military
                    if unit.military.squad_id ~= -1 then
                        stats.military = stats.military + 1
                    end
                else
                    -- Check if visitor/resident
                    if unit.flags1.merchant or unit.flags1.diplomat then
                        stats.visitors = stats.visitors + 1
                    else
                        stats.animals = stats.animals + 1
                    end
                end
            end
        end
    end
    
    return stats
end

-- Get fortress wealth information
function get_wealth_stats()
    local wealth = df.global.ui.tasks.wealth
    
    return {
        total = wealth.total or 0,
        weapons = wealth.weapons or 0,
        armor = wealth.armor or 0,
        furniture = wealth.furniture or 0,
        other = wealth.other or 0,
        architecture = wealth.architecture or 0,
        displayed = wealth.displayed or 0
    }
end

-- Get fortress status and alerts
function get_fortress_status()
    local status = {
        paused = df.global.pause_state,
        fps = df.global.gps.display_frames,
        alerts = {},
        mood = "Unknown"
    }
    
    -- Check for various fortress conditions
    local alerts = {}
    
    -- Check for siege
    if df.global.ui.siege_engine.operating then
        table.insert(alerts, "Siege in progress")
    end
    
    -- Check for unhappy dwarves (simplified)
    local unhappy_count = 0
    for _, unit in ipairs(df.global.world.units.active) do
        if unit and unit.race == df.global.ui.race_id and not unit.flags1.dead then
            -- This is a simplified happiness check
            if unit.status.happiness < 25 then
                unhappy_count = unhappy_count + 1
            end
        end
    end
    
    if unhappy_count > 0 then
        table.insert(alerts, unhappy_count .. " unhappy dwarves")
    end
    
    status.alerts = alerts
    
    -- Determine overall fortress mood
    if #alerts == 0 then
        status.mood = "Content"
    elseif #alerts < 3 then
        status.mood = "Troubled"
    else
        status.mood = "Crisis"
    end
    
    return status
end

-- Get basic fortress resources
function get_resource_summary()
    local resources = {
        food_count = 0,
        drink_count = 0,
        wood_count = 0,
        stone_count = 0
    }
    
    -- Count items in stockpiles (simplified)
    for _, item in ipairs(df.global.world.items.other.FOOD) do
        if item and not item.flags.dump and not item.flags.forbid then
            resources.food_count = resources.food_count + item.stack_size
        end
    end
    
    for _, item in ipairs(df.global.world.items.other.DRINK) do
        if item and not item.flags.dump and not item.flags.forbid then
            resources.drink_count = resources.drink_count + item.stack_size
        end
    end
    
    -- Count wood and stone (simplified)
    for _, item in ipairs(df.global.world.items.other.WOOD) do
        if item and not item.flags.dump and not item.flags.forbid then
            resources.wood_count = resources.wood_count + item.stack_size
        end
    end
    
    for _, item in ipairs(df.global.world.items.other.BOULDER) do
        if item and not item.flags.dump and not item.flags.forbid then
            resources.stone_count = resources.stone_count + item.stack_size
        end
    end
    
    return resources
end

-- Main export function
function export_fortress_data()
    print("Exporting fortress data...")
    
    local output_dir = ensure_output_dir()
    local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    
    -- Gather all data
    local fortress_data = {
        timestamp = timestamp,
        export_version = "1.0",
        fortress_info = get_fortress_info(),
        population = get_population_stats(),
        wealth = get_wealth_stats(),
        status = get_fortress_status(),
        resources = get_resource_summary(),
        game_info = {
            version = dfhack.getDFVersion(),
            dfhack_version = dfhack.getVersion()
        }
    }
    
    -- Write main data file
    local main_file = output_dir .. '/fortress_data.json'
    local file = io.open(main_file, 'w')
    if file then
        file:write(json.encode(fortress_data))
        file:close()
        print("Fortress data exported to: " .. main_file)
    else
        print("Error: Could not write to " .. main_file)
        return false
    end
    
    -- Also write a timestamped backup
    local backup_file = output_dir .. '/fortress_data_' .. os.date("%Y%m%d_%H%M%S") .. '.json'
    local backup = io.open(backup_file, 'w')
    if backup then
        backup:write(json.encode(fortress_data))
        backup:close()
        print("Backup saved to: " .. backup_file)
    end
    
    -- Write summary file for quick access
    local summary = {
        last_update = timestamp,
        fortress_name = fortress_data.fortress_info.name,
        population_total = fortress_data.population.total,
        wealth_total = fortress_data.wealth.total,
        status = fortress_data.status.mood
    }
    
    local summary_file = output_dir .. '/fortress_summary.json'
    local summary_handle = io.open(summary_file, 'w')
    if summary_handle then
        summary_handle:write(json.encode(summary))
        summary_handle:close()
    end
    
    print("Export completed successfully!")
    return true
end

-- Run the export
export_fortress_data()
