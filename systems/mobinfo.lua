local mobinfo = {}

local sqlite3 =
    require('sqlite3')

local res =
    require('resources')

local db = nil

-- =========================================================
-- OPEN DB
-- =========================================================

local function open_db()

    if db then
        return
    end

    local path =
        windower.addon_path ..
        'database.db'

    db =
        sqlite3.open(path)

    if not db then

        windower.add_to_chat(
            167,
            '[WXI] Failed to open database.db'
        )

    end

end

-- =========================================================
-- GET TARGET INFO
-- =========================================================

function mobinfo.get_target_info()

    open_db()

    if not db then
        return nil
    end

    local player =
        windower.ffxi
        .get_player()

    if not player then
        return nil
    end

    local target =
        windower.ffxi
        .get_mob_by_target('t')

    if not target or
       not target.name
    then
        return nil
    end

    local zone =
        res.zones[
            windower.ffxi
            .get_info()
            .zone
        ].name

    local query =
        'SELECT * FROM monster ' ..
        'WHERE name="' ..
        target.name ..
        '" AND zone="' ..
        zone ..
        '" LIMIT 1'

    local info = nil

    for
        id,
        name,
        family,
        job,
        zone_name,
        isaggressive,
        islinking,
        isnm,
        isfishing,
        levelmin,
        levelmax,
        sight,
        sound,
        magic,
        lowhp,
        healing,
        ts,
        th,
        scent
    in db:urows(query)
    do

        info = {}

        info.MinLevel =
            tonumber(levelmin)

        info.MaxLevel =
            tonumber(levelmax)

        info.Aggro =
            isaggressive == 1

        info.Link =
            islinking == 1
     
        info.NM =
            isnm == 1

        info.Sight =
            sight == 1

        info.Sound =
            sound == 1

        info.Magic =
            tonumber(magic) == 1

        info.Blood =
            lowhp == 1

        info.Healing =
            healing == 1

        info.TrueSight =
            ts == 1

        info.TrueHearing =
            th == 1

        info.Scent =
            scent == 1

        break

    end

    return info

end

-- =========================================================
-- LEVEL STRING
-- =========================================================

function mobinfo.get_level_string(info)

    if not info then
        return '?'
    end

    local min =
        info.MinLevel

    local max =
        info.MaxLevel

    if not min then
        return '?'
    end

    if min == max or
       not max
    then
        return tostring(min)
    end

    return
        tostring(min) ..
        '-' ..
        tostring(max)

end

-- =========================================================
-- AGGRO STRING
-- =========================================================

function mobinfo.get_aggro_string(info)

    if not info or
       not info.Aggro
    then
        return nil
    end

    local t = {}

    if info.TrueSight then
        table.insert(t, 'TrueSight')
    end

    if info.TrueHearing then
        table.insert(t, 'TrueHearing')
    end

    if info.Sight then
        table.insert(t, 'Sight')
    end

    if info.Sound then
        table.insert(t, 'Sound')
    end

    if info.Magic then
        table.insert(t, 'Magic')
    end

    if info.Blood then
        table.insert(t, 'Low HP')
    end

    if info.Healing then
        table.insert(t, 'Healing')
    end

    if info.Scent then
        table.insert(t, 'Scent')
    end

    if #t == 0 then
        return 'Aggro'
    end

    return table.concat(
        t,
        ' / '
    )

end

return mobinfo