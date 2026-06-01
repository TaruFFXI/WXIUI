local packets =
    require('packets')

require('coroutine')

local experience = {}

-- =========================================================
-- STATE
-- =========================================================

experience.mode = 1

experience.exp_current = 0
experience.exp_max = 1

experience.limit_current = 0
experience.limit_max = 10000

experience.merit_current = 0
experience.merit_max = 30

experience.capacity_current = 0
experience.capacity_max = 30000

experience.jobpoint_current = 0
experience.jobpoint_max = 500

local initialized =
    false

-- =========================================================
-- HELPERS
-- =========================================================

local function clamp(
    value,
    minimum,
    maximum
)

    return math.max(
        minimum,
        math.min(
            value,
            maximum
        )
    )

end

-- =========================================================
-- EXP INCREASE
-- =========================================================

local function increase_exp(
    value
)

    experience.exp_current =
        experience.exp_current +
        value

    if experience.exp_current >
       experience.exp_max
    then

        experience.exp_current =
            experience.exp_current -
            experience.exp_max

    end

end

local function increase_limit(
    value
)

    experience.limit_current =
        experience.limit_current +
        value

    if experience.limit_current >=
       experience.limit_max
    then

        local merit_gain =
            math.floor(

                experience.limit_current /
                experience.limit_max

            )

        experience.merit_current =
            clamp(

                experience.merit_current +
                merit_gain,

                0,
                experience.merit_max

            )

        experience.limit_current =
            experience.limit_current %
            experience.limit_max

    end

end

local function increase_capacity(
    value
)

    experience.capacity_current =
        experience.capacity_current +
        value

    if experience.capacity_current >=
       experience.capacity_max
    then

        local jp_gain =
            math.floor(

                experience.capacity_current /
                experience.capacity_max

            )

        experience.jobpoint_current =
            clamp(

                experience.jobpoint_current +
                jp_gain,

                0,
                experience.jobpoint_max

            )

        experience.capacity_current =
            experience.capacity_current %
            experience.capacity_max

    end

end

-- =========================================================
-- PACKETS
-- =========================================================

local function handle_incoming_chunk(
    id,
    data
)

    -- =====================================================
    -- EXP STATE
    -- =====================================================

    if id == 0x61 then

        experience.exp_current =
            data:unpack(
                'H',
                0x11
            )

        experience.exp_max =
            data:unpack(
                'H',
                0x13
            )

        if experience.exp_max <= 0 then
            experience.exp_max = 1
        end

    end

    -- =====================================================
    -- EXP GAIN
    -- =====================================================

    if id == 0x2D then

        local value =
            data:unpack(
                'I',
                0x11
            )

        local message =
            data:unpack(
                'H',
                0x19
            ) % 1024

        -- NORMAL EXP
        if message == 8 or
           message == 105
        then

            experience.mode = 1

            increase_exp(
                value
            )

        -- MERITS
        elseif message == 371 or
               message == 372
        then

            experience.mode = 2

            increase_limit(
                value
            )

            -- FORCE MERIT ESTIMATE
            if experience.limit_current >=
               experience.limit_max
            then

                experience.merit_current =
                    clamp(

                        experience.merit_current + 1,

                        0,
                        experience.merit_max

                    )

            end

        -- JOB POINTS
        elseif message == 718 or
               message == 735
        then

            experience.mode = 3

            increase_capacity(
                value
            )

            -- FORCE JP ESTIMATE
            if experience.capacity_current >=
               experience.capacity_max
            then

                experience.jobpoint_current =
                    clamp(

                        experience.jobpoint_current + 1,

                        0,
                        experience.jobpoint_max

                    )

            end

        end

    end

    -- =====================================================
    -- MERITS
    -- =====================================================

    if id == 0x63 and
       data:byte(5) == 2
    then

        experience.limit_current =
            data:unpack(
                'H',
                9
            )

        experience.merit_current =
            data:byte(11) % 128

        experience.merit_max =
            data:byte(13) % 128

    end

    -- =====================================================
    -- JOB POINTS
    -- =====================================================

    if id == 0x63 and
       data:byte(5) == 5
    then

        local player =
            windower.ffxi
            .get_player()

        if player then

            local offset =
                player.main_job_id *
                6 +
                13

            experience.capacity_current =
                data:unpack(
                    'H',
                    offset
                )

            experience.jobpoint_current =
                data:unpack(
                    'H',
                    offset + 2
                )

        end

    end

end

-- =========================================================
-- INITIALIZE
-- =========================================================

function experience.initialize()

    if initialized then
        return
    end

    initialized = true

    windower.register_event(
        'incoming chunk',
        handle_incoming_chunk
    )

end

-- =========================================================
-- GETTERS
-- =========================================================

function experience.get_exp()

    return
        experience.exp_current,
        experience.exp_max

end

function experience.get_limit()

    return
        experience.limit_current,
        experience.limit_max,
        experience.merit_current,
        experience.merit_max

end

function experience.get_capacity()

    return
        experience.capacity_current,
        experience.capacity_max,
        experience.jobpoint_current,
        experience.jobpoint_max

end

function experience.get_mode()

    return experience.mode

end

return experience