local packets =
    require('packets')

local spells =
    require('data/spells')

local abilities =
    require('data/abilities')

local skills =
    require('data/skills')

local targetdebuffs = {}

local effective_targets = {}

local shadow_counts = {}

local resist_states = {}

-- =========================================================
-- APPLY MESSAGES
-- =========================================================

local magic_apply_messages = T{
    2,230,236,237,252,264,266,
    268,269,270,271,272,
    277,278,280,402,403,404,
}

local skill_apply_messages = T{
    2,77,78,80,82,110,123,
    185,
    236,237,268,269,270,271,272,
}

local additional_effect_messages = T{
    160,
    161,
    162,
    163,
    164,
}

-- =========================================================
-- RESIST MESSAGES
-- =========================================================

local resist_message_multipliers = {

    [85]  = 0.5,
    [284] = 0.25,
    [653] = 0.125,

}

-- =========================================================
-- SONG EFFECTS
-- =========================================================

local song_effects = T{
    195,
    196,
    197,
    198,
    199,
    200,
    214,
    215,
    216,
    217,
}

-- =========================================================
-- REACTIVE CLEANUP EFFECTS
-- =========================================================

local action_break_effects = T{
    2,
    19,
    10,
    28,
    7,
}

-- =========================================================
-- SHADOW EFFECTS
-- =========================================================

local shadow_effects = T{
    66,
    444,
    445,
    446,
}

-- =========================================================
-- ADDITIONAL EFFECT DURATIONS
-- =========================================================

local additional_effect_durations = {

    [2]   = 60,
    [4]   = 120,
    [5]   = 120,
    [6]   = 60,
    [7]   = 30,
    [10]  = 15,
    [13]  = 180,
    [19]  = 90,
    [28]  = 60,
    [31]  = 120,
    [134] = 60,
    [135] = 60,

}

-- =========================================================
-- PRIORITIES
-- =========================================================

local effect_priorities = {

    [23]  = 1,
    [24]  = 2,
    [25]  = 3,

    [230] = 1,
    [231] = 2,
    [232] = 3,

    [58]  = 1,
    [80]  = 2,

    [56]  = 1,
    [79]  = 2,

    [254] = 1,
    [276] = 2,

}

-- =========================================================
-- EXCLUSIVE FAMILIES
-- =========================================================

local exclusive_families = {

    T{ 134, 135 },
    T{ 4, 566 },
    T{ 13, 565 },
    T{ 5, 156 },
    T{ 3, 541 },
    T{ 10, 402 },
    T{ 2, 19 },
    T{ 146, 147 },
    T{ 148, 149 },
    T{ 167, 404 },
    T{ 168, 403 },
    T{ 140, 141 },
    T{ 156, 157 },
    T{ 33, 580, 604, 615 },
    T{ 43, 369 },
    T{ 42, 504 },

}

-- =========================================================
-- HELPERS
-- =========================================================

local function get_priority(
    source_id
)

    return effect_priorities[
        source_id
    ] or 0

end

local function get_resist_multiplier(
    target_id
)

    return resist_states[
        target_id
    ] or 1.0

end

local function clear_resist_state(
    target_id
)

    resist_states[
        target_id
    ] = nil

end

local function remove_exclusive_effects(
    target_id,
    effect_id,
    owner_id
)

    local effects =
        effective_targets[
            target_id
        ]

    if not effects then
        return
    end

    for _, family in ipairs(
        exclusive_families
    ) do

        if family:contains(
            effect_id
        ) then

            for other_effect, effect in
                pairs(effects)
            do

                if family:contains(
                    other_effect
                ) then

                    if effect.OwnerId ==
                       owner_id
                    then

                        effects[
                            other_effect
                        ] = nil

                    end

                end

            end

        end

    end

end

local function reactive_cleanup(
    actor_id
)

    local effects =
        effective_targets[
            actor_id
        ]

    if not effects then
        return
    end

    for effect_id, _ in
        pairs(effects)
    do

        if action_break_effects:
            contains(effect_id)
        then

            effects[
                effect_id
            ] = nil

        end

    end

end

local function process_shadow_hit(
    target_id
)

    local effects =
        effective_targets[
            target_id
        ]

    if not effects then
        return
    end

    for _, shadow_effect in
        ipairs(shadow_effects)
    do

        if effects[
            shadow_effect
        ] then

            if not shadow_counts[
                target_id
            ] then

                shadow_counts[
                    target_id
                ] = 3

            end

            shadow_counts[
                target_id
            ] =
                shadow_counts[
                    target_id
                ] - 1

            if shadow_counts[
                target_id
            ] <= 0 then

                effects[
                    shadow_effect
                ] = nil

                shadow_counts[
                    target_id
                ] = nil

            end

            return

        end

    end

end

local function enforce_song_limit(
    target_id
)

    local effects =
        effective_targets[
            target_id
        ]

    if not effects then
        return
    end

    local songs = {}

    for effect_id, effect in
        pairs(effects)
    do

        if song_effects:
            contains(effect_id)
        then

            table.insert(
                songs,
                {
                    id = effect_id,
                    time =
                        effect.EndTime
                }
            )

        end

    end

    if #songs <= 2 then
        return
    end

    table.sort(

        songs,

        function(a, b)

            return a.time <
                   b.time

        end

    )

    while #songs > 2 do

        local remove =
            table.remove(
                songs,
                1
            )

        effects[
            remove.id
        ] = nil

    end

end

-- =========================================================
-- ADD EFFECT
-- =========================================================

local function add_effect(
    target_id,
    owner_id,
    source_id,
    effect_id,
    duration,
    from_player
)

    -- =====================================================
    -- INVALID EFFECTS
    -- =====================================================

    if not effect_id or
       effect_id == 0 or
       not duration or
       duration <= 0
    then
        return
    end

    -- impossible durations
    if duration > 7200 then
        return
    end

    -- =====================================================
    -- TARGET VALIDATION
    -- =====================================================

    local mob =
        windower.ffxi.get_mob_by_id(
            target_id
        )

    if not mob then
        return
    end

    -- dead target
    if mob.hpp == 0 then
        return
    end

    -- =====================================================
    -- EFFECT TABLE
    -- =====================================================

    if not effective_targets[
        target_id
    ] then

        effective_targets[
            target_id
        ] = {}

    end

    local effects =
        effective_targets[
            target_id
        ]

    local existing =
        effects[
            effect_id
        ]

    local new_priority =
        get_priority(
            source_id
        )

    local multiplier =
        get_resist_multiplier(
            target_id
        )

    duration =
        duration * multiplier

    clear_resist_state(
        target_id
    )

    -- =====================================================
    -- EXISTING EFFECT
    -- =====================================================

    if existing then

        local old_priority =
            get_priority(
                existing.SourceId
            )

        -- weaker overwrite
        if old_priority >
           new_priority then
            return
        end

        -- same owner refresh
        if existing.OwnerId ==
           owner_id then

            local now =
                os.clock()

            -- anti packet rollback
            if existing.LastRefresh and
               now - existing.LastRefresh <
               0.15
            then
                return
            end

            local new_end =
                now + duration

            local remaining =
                existing.EndTime - now

            -- smooth refresh behavior
            if remaining <= 3 then

                -- near expiration:
                -- full refresh immediately

                existing.EndTime =
                    new_end

            else

                -- gradual extension
                existing.EndTime =
                    math.max(

                        existing.EndTime - 1.0,
                        new_end

                    )

            end

            existing.SourceId =
                source_id

            existing.FromPlayer =
                from_player

            existing.LastRefresh =
                now

            return

        end

        -- stronger overwrite
        if new_priority >=
           old_priority then

            effects[
                effect_id
            ] = nil

        else
            return
        end

    end

    -- =====================================================
    -- EXCLUSIVE CLEANUP
    -- =====================================================

    remove_exclusive_effects(

        target_id,
        effect_id,
        owner_id

    )

    -- =====================================================
    -- APPLY
    -- =====================================================

    local now =
        os.clock()

    effects[
        effect_id
    ] = {

        EndTime =
            now + duration,

        SourceId =
            source_id,

        OwnerId =
            owner_id,

        FromPlayer =
            from_player,

        AppliedAt =
            now,

        LastRefresh =
            now,

    }

    -- =====================================================
    -- SHADOWS
    -- =====================================================

    if shadow_effects:
       contains(effect_id)
    then

        shadow_counts[
            target_id
        ] = 3

    end

    -- =====================================================
    -- SONGS
    -- =====================================================

    enforce_song_limit(
        target_id
    )

end

-- =========================================================
-- ADD DATA EFFECTS
-- =========================================================

local function add_data_effects(
    data_table,
    owner_id,
    source_id,
    target_id,
    from_player
)

    local data =
        data_table[
            source_id
        ]

    if not data then
        return
    end

    if type(data[1]) ==
       'number'
    then

        add_effect(

            target_id,
            owner_id,
            source_id,
            data[1],
            data[2],
            from_player

        )

        return

    end

    if type(data[1]) ==
       'table'
    then

        for i = 1, #data do

            local entry =
                data[i]

            if type(entry) ==
               'table'
            then

                add_effect(

                    target_id,
                    owner_id,
                    source_id,
                    entry[1],
                    entry[2],
                    from_player

                )

            end

        end

    end

end

-- =========================================================
-- ADDITIONAL EFFECTS
-- =========================================================

local function add_additional_effect(
    target_id,
    owner_id,
    effect_id
)

    local duration =
        additional_effect_durations[
            effect_id
        ] or 60

    add_effect(

        target_id,
        owner_id,
        0,
        effect_id,
        duration,
        false

    )

end

-- =========================================================
-- ACTION EVENT
-- =========================================================

windower.register_event(
    'action',
    function(act)

        local player =
            windower.ffxi.get_player()

        if not player then
            return
        end

        reactive_cleanup(
            act.actor_id
        )

        local from_player =
            act.actor_id ==
            player.id

        local data_table =
            nil

        local apply_messages =
            nil

        if act.category == 4 then

            data_table =
                spells

            apply_messages =
                magic_apply_messages

        elseif act.category == 6 then

            data_table =
                abilities

            apply_messages =
                skill_apply_messages

        elseif act.category == 3 or
               act.category == 7 or
               act.category == 11 or
               act.category == 13 then

            data_table =
                skills

            apply_messages =
                skill_apply_messages

        end

        local source_id =
            act.param

        for _, target in pairs(
            act.targets
        ) do

            for i = 1,
                #target.actions
            do

                local action =
                    target.actions[i]

                local message =
                    action.message

                -- RESIST TRACKING
                if resist_message_multipliers[
                    message
                ] then

                    resist_states[
                        target.id
                    ] =
                        resist_message_multipliers[
                            message
                        ]

                end

                -- DIRECT EFFECTS
                if data_table and
                   apply_messages and
                   apply_messages:
                   contains(message)
                then

                    add_data_effects(

                        data_table,
                        act.actor_id,
                        source_id,
                        target.id,
                        from_player

                    )

                end

                -- ADDITIONAL EFFECTS
                if action.has_add_effect then

                    local add_message =
                        action.add_effect_message

                    local add_effect =
                        action.add_effect_param

                    if additional_effect_messages:
                        contains(add_message)
                    then

                        add_additional_effect(

                            target.id,
                            act.actor_id,
                            add_effect

                        )

                    end

                end

                -- SHADOW HIT
                if message == 31 then

                    process_shadow_hit(
                        target.id
                    )

                end

                -- STONESKIN BREAK
                if message == 30 then

                    if effective_targets[
                        target.id
                    ] then

                        effective_targets[
                            target.id
                        ][37] = nil

                    end

                end

            end

        end

    end
)

-- =========================================================
-- ACTION MESSAGE
-- =========================================================

windower.register_event(
    'incoming chunk',
    function(id, data)

        if id ~= 0x29 then
            return
        end

        local target_id =
            data:unpack(
                'I',
                0x09
            )

        local effect_id =
            data:unpack(
                'I',
                0x0D
            )

        local message =
            data:unpack(
                'H',
                0x19
            ) % 32768

        -- REMOVE EFFECT
        if S{
            204,
            206
        }[message] then

            if effective_targets[
                target_id
            ] then

                local existing =
                    effective_targets[
                        target_id
                    ][
                        effect_id
                    ]

                if existing then

                    local now =
                        os.clock()

                    -- ignore stale removes
                    if not existing.LastRefresh or
                       now - existing.LastRefresh >
                       0.2
                    then

                        effective_targets[
                            target_id
                        ][
                            effect_id
                        ] = nil

                    end

                end

            end

        end

        -- TARGET GONE
        if S{
            6,
            20,
            113,
            406,
            605,
            646
        }[message] then

            effective_targets[
                target_id
            ] = nil

            shadow_counts[
                target_id
            ] = nil

            resist_states[
                target_id
            ] = nil

        end

    end
)

-- =========================================================
-- CLEANUP
-- =========================================================

function targetdebuffs.update()

    local now =
        os.clock()

    for target_id, effects in
        pairs(effective_targets)
    do

        for effect_id, effect in
            pairs(effects)
        do

            if effect.EndTime then

                local remaining =
                    effect.EndTime - now

                -- =========================================
                -- ANTI-FLICKER BUFFER
                -- =========================================

                if remaining <= -0.35 then

                    effects[
                        effect_id
                    ] = nil

                end

            end

        end

        -- =============================================
        -- EMPTY TARGET CLEANUP
        -- =============================================

        local empty = true

        for _ in pairs(effects) do
            empty = false
            break
        end

        if empty then

            effective_targets[
                target_id
            ] = nil

            shadow_counts[
                target_id
            ] = nil

            resist_states[
                target_id
            ] = nil

        end

    end

end

-- =========================================================
-- GET TARGET EFFECTS
-- =========================================================

function targetdebuffs
.get_target_debuffs()

    local target =
        windower.ffxi.get_mob_by_target(
            't'
        )

    if not target then
        return {}
    end

    local effects =
        effective_targets[
            target.id
        ] or {}

    local sorted = {}

    local now =
        os.clock()

    for effect_id, effect in
        pairs(effects)
    do

        local remaining =
            0

        if effect.EndTime then

            remaining =
                math.max(

                    0,

                    effect.EndTime -
                    now

                )

        end

        table.insert(

            sorted,

            {

                EffectId =
                    effect_id,

                Remaining =
                    math.max(
                        0,
                        remaining
                    ),

                SourceId =
                    effect.SourceId,

                OwnerId =
                    effect.OwnerId,

                FromPlayer =
                    effect.FromPlayer,

                EndTime =
                    effect.EndTime,

                AppliedAt =
                    effect.AppliedAt,

            }

        )

    end

    table.sort(

        sorted,

        function(a, b)

            if a.FromPlayer and
               not b.FromPlayer then
                return true
            end

            if b.FromPlayer and
               not a.FromPlayer then
                return false
            end

            local pa =
                get_priority(
                    a.SourceId
                )

            local pb =
                get_priority(
                    b.SourceId
                )

            if pa ~= pb then
                return pa > pb
            end

            return a.Remaining <
                   b.Remaining

        end

    )

    local final = {}

    for _, entry in ipairs(
        sorted
    ) do

        final[
            entry.EffectId
        ] = {

            EndTime =
                entry.EndTime,

            SourceId =
                entry.SourceId,

            OwnerId =
                entry.OwnerId,

            FromPlayer =
                entry.FromPlayer,

            AppliedAt =
                entry.AppliedAt,

            LastRefresh =
                entry.LastRefresh,

        }

    end

    return final

end

return targetdebuffs