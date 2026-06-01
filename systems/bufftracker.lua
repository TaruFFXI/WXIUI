local actiontracker =
    require('systems/actiontracker')

local spellparser =
    require('systems/spellparser')

local res =
    require('resources')

local bufftracker = {}

local active_buffs = {}

local previous_buffs = {}

-- LOAD RUNTIME FILE
local function load_runtime()

    local path =
        windower.addon_path ..
        'data/runtime_buffs.lua'

    local chunk =
        loadfile(path)

    if not chunk then
        return {}
    end

    local success, data =
        pcall(chunk)

    if success and
       type(data) == 'table' then

        return data

    end

    return {}

end

-- SAVE RUNTIME
local function save_runtime()

    local path =
        windower.addon_path ..
        'data/runtime_buffs.lua'

    local file =
        io.open(path, 'w+')

    if not file then
        return
    end

    file:write('return {\n')

    for buff_id, buff in pairs(active_buffs) do

        file:write(string.format(
            '    [%d] = {\n',
            buff_id
        ))

        file:write(string.format(
            '        gained_at = %d,\n',
            buff.gained_at
        ))

        file:write(string.format(
            '        expires_at = %d,\n',
            buff.expires_at
        ))

        file:write(string.format(
            '        duration = %d,\n',
            buff.duration
        ))

        file:write(string.format(
            '        source_action = "%s",\n',
            buff.source_action or ''
        ))

        file:write('    },\n')

    end

    file:write('}')

    file:close()

end

-- RESTORE RUNTIME
local function restore_runtime()

    local runtime_buffs =
        load_runtime()

    for buff_id, buff in pairs(runtime_buffs) do

        if buff.expires_at > os.time() then

            active_buffs[buff_id] = buff

        end

    end

end

-- CREATE OR REFRESH TIMER
local function track_buff(
    buff_id,
    duration,
    source_action
)

    if not duration then
        return
    end

    active_buffs[buff_id] = {

        gained_at = os.time(),

        expires_at =
            os.time() + duration,

        duration =
            duration,

        source_action =
            source_action,

    }

    save_runtime()

end

-- UPDATE
function bufftracker.update()

    local player =
        windower.ffxi.get_player()

    if not player then
        return
    end

    local current_buffs = {}

    for _, buff_id in pairs(player.buffs) do

        if buff_id and buff_id > 0 then

            current_buffs[buff_id] = true

            local pending =
                actiontracker.get_pending(
                    player.id
                )

            if pending and
               pending.action_info then

                local parsed =
                    spellparser.parse(
                        pending.action_info
                    )

                if parsed and parsed.buffs then

                    for _, buff in pairs(parsed.buffs) do

                        if buff.id == buff_id then

                            track_buff(
                                buff_id,
                                buff.duration,
                                pending.action_name
                            )

                            actiontracker.clear_pending(
                                player.id
                            )

                        end

                    end

                end

            end

        end

    end

    -- LOST BUFFS
    for buff_id, _ in pairs(previous_buffs) do

        if not current_buffs[buff_id] then

            active_buffs[buff_id] = nil

            save_runtime()

        end

    end

    previous_buffs = current_buffs

end

-- GET BUFF
function bufftracker.get_buff(buff_id)

    return active_buffs[buff_id]

end

-- GET REMAINING
function bufftracker.get_remaining(buff_id)

    local buff =
        active_buffs[buff_id]

    if not buff then
        return nil
    end

    return math.max(
        buff.expires_at - os.time(),
        0
    )

end

-- GET ALL
function bufftracker.get_all()

    return active_buffs

end

-- INITIALIZE
restore_runtime()

return bufftracker