local distance = {}

-- =========================================================
-- STATE
-- =========================================================

distance.target_distance = 0

distance.target_exists = false

distance.color = {
    r = 255,
    g = 255,
    b = 255
}

distance.mode =
    'default'

-- =========================================================
-- HELPERS
-- =========================================================

local function set_color(
    r,
    g,
    b
)

    distance.color.r = r
    distance.color.g = g
    distance.color.b = b

end

-- =========================================================
-- MAGIC CHECK
-- =========================================================

local function can_cast_magic(
    player
)

    if not player then
        return false
    end

    local magic_jobs = {

        WHM = true,
        BLM = true,
        RDM = true,
        SCH = true,
        GEO = true,
        BRD = true,
        SMN = true,
        BLU = true,

    }

    if magic_jobs[
        player.main_job
    ] then

        return true

    end

    if magic_jobs[
        player.sub_job
    ] then

        return true

    end

    return false

end

-- =========================================================
-- MODE DETECTION
-- =========================================================

local function detect_mode()

    local player =
        windower.ffxi
        .get_player()

    if not player then
        return 'default'
    end

    -- =====================================================
    -- NINJUTSU
    -- =====================================================

    if player.main_job ==
       'NIN'
    then

        return 'ninjutsu'

    end

    -- =====================================================
    -- RANGED WEAPON CHECK
    -- =====================================================

    local equipment =
        windower.ffxi
        .get_items()

    if equipment and
       equipment.equipment
    then

        local range_bag =
            equipment.equipment.range_bag

        local range_slot =
            equipment.equipment.range

        if range_bag and
           range_slot
        then

            local bag =
                equipment[range_bag]

            local item =
                bag and
                bag[range_slot]

            if item then

                local res =
                    require('resources')

                local item_data =
                    res.items[item.id]

                if item_data and
                   item_data.skill
                then

                    local skill =
                        item_data.skill

                    -- Bow
                    if skill == 25 then
                        return 'bow'
                    end

                    -- Marksmanship
                    if skill == 26 then
                        return 'gun'
                    end

                    -- Ignore Throwing
                    if skill == 27 then
                        return 'xbow'
                    end

                end

            end

        end

    end

    -- =====================================================
    -- MAGIC FALLBACK
    -- =====================================================

    if can_cast_magic(
        player
    ) then

        return 'magic'

    end

    -- =====================================================
    -- MELEE
    -- =====================================================

    return 'melee'

end

-- =========================================================
-- UPDATE
-- =========================================================

function distance.update()

    local target =
        windower.ffxi
        .get_mob_by_target('t')

    local player =
        windower.ffxi
        .get_mob_by_target('me')

    if not target or
       not player
    then

        distance.target_exists =
            false

        return

    end

    distance.target_exists =
        true

    local dist =
        target.distance:sqrt()

    distance.target_distance =
        dist

    distance.mode =
        detect_mode()

    local combined_size =
        player.model_size +
        target.model_size

    -- =====================================================
    -- MAGIC
    -- =====================================================

    if distance.mode ==
       'magic'
    then

        local max_distance =
            20 +
            combined_size

        if dist <=
           max_distance
        then

            set_color(
                0,
                255,
                0
            )

        else

            set_color(
                255,
                255,
                255
            )

        end

        return

    end

    -- =====================================================
    -- NINJUTSU
    -- =====================================================

    if distance.mode ==
       'ninjutsu'
    then

        local max_distance =
            16 +
            combined_size

        if dist <=
           max_distance
        then

            set_color(
                0,
                255,
                0
            )

        else

            set_color(
                255,
                255,
                255
            )

        end

        return

    end

    -- =====================================================
    -- BOW
    -- =====================================================

    if distance.mode ==
       'bow'
    then

        local true_min =
            6.0 +
            combined_size

        local true_max =
            9.5 +
            combined_size

        local square_min =
            4.6 +
            combined_size

        local square_max =
            14.5 +
            combined_size

        if dist >= true_min and
           dist <= true_max
        then

            set_color(
                0,
                0,
                255
            )

        elseif dist >= square_min and
               dist <= square_max
        then

            set_color(
                0,
                255,
                0
            )

        elseif dist <= 25 then

            set_color(
                255,
                255,
                0
            )

        else

            set_color(
                255,
                255,
                255
            )

        end

        return

    end

    -- =====================================================
    -- GUN / XBOW
    -- =====================================================

    if distance.mode ==
       'gun' or
       distance.mode ==
       'xbow'
    then

        local true_min =
            3.0 +
            combined_size

        local true_max =
            5.0 +
            combined_size

        local square_min =
            2.2 +
            combined_size

        local square_max =
            7.0 +
            combined_size

        if dist >= true_min and
           dist <= true_max
        then

            set_color(
                0,
                0,
                255
            )

        elseif dist >= square_min and
               dist <= square_max
        then

            set_color(
                0,
                255,
                0
            )

        elseif dist <= 25 then

            set_color(
                255,
                255,
                0
            )

        else

            set_color(
                255,
                255,
                255
            )

        end

        return

    end

    -- =====================================================
    -- MELEE
    -- =====================================================

    local melee_range =
        3 +
        combined_size

    if dist <=
       melee_range
    then

        set_color(
            0,
            255,
            0
        )

    else

        set_color(
            255,
            255,
            255
        )

    end

end

-- =========================================================
-- GETTERS
-- =========================================================

function distance.get_distance()

    return
        distance.target_distance

end

function distance.get_color()

    return
        distance.color.r,
        distance.color.g,
        distance.color.b

end

function distance.has_target()

    return
        distance.target_exists

end

return distance