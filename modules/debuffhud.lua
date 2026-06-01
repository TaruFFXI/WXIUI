local images =
    require('images')

local texts =
    require('texts')

local res =
    require('resources')

local config =
    require('config')

local targetdebuffs =
    require('systems/targetdebuffs')

local global_settings =
    require('data/settings')    

-- =========================================================
-- SETTINGS
-- =========================================================

local defaults = {

    debuffhud = {

        visible = true,

        x = 1350,
        y = 930,

        icon_size = 20,

        spacing_x = 24,
        spacing_y = 34,

        max_debuffs = 32,

        icons_per_row = 8,

        low_timer_threshold = 10,
        blink_threshold = 15,

        timer_font_size = 9,

        show_timers = true,
        show_tooltip = true,

        fade_speed = 18,

    }

}

local settings =
    config.load(
        defaults
    )

local function get_scale()

    return
        global_settings.debuffhud.scale / 50

end    
-- =========================================================
-- MODULE
-- =========================================================

local debuffhud = {}

debuffhud.visible =
    settings.debuffhud.visible

debuffhud.preview =
    false

debuffhud.x =
    settings.debuffhud.x

debuffhud.y =
    settings.debuffhud.y

debuffhud.mouse_x =
    0

debuffhud.mouse_y =
    0

-- =========================================================
-- LAYOUT
-- =========================================================

local function ICON_SIZE()
    return settings.debuffhud.icon_size
end

local function ICON_SPACING_X()
    return settings.debuffhud.spacing_x
end

local function ICON_SPACING_Y()
    return settings.debuffhud.spacing_y
end

local function MAX_DEBUFFS()
    return settings.debuffhud.max_debuffs
end

local function ICONS_PER_ROW()
    return settings.debuffhud.icons_per_row
end

-- =========================================================
-- PATHS
-- =========================================================

local ICON_PATH =
    windower.addon_path ..
    'assets/icons/'

local FALLBACK_ICON =
    ICON_PATH ..
    'fallback.png'

-- =========================================================
-- STORAGE
-- =========================================================

local debuff_icons = {}
local debuff_timers = {}

local render_slots = {}
local used_slots = {}

local icon_states = {}

-- =========================================================
-- TOOLTIP
-- =========================================================

local tooltip =
    texts.new('')

tooltip:size(10)

tooltip:font(
    'Arial'
)

tooltip:color(
    255,
    255,
    255
)

tooltip:stroke_color(
    0,
    0,
    0
)

tooltip:stroke_width(2)

tooltip:bg_alpha(180)

tooltip:hide()

-- =========================================================
-- SLOT POSITION
-- =========================================================

local function get_slot_position(
    slot
)

    local row =
        math.floor(
            (
                slot - 1
            ) /
            ICONS_PER_ROW()
        )

    local col =
        (
            slot - 1
        ) %
        ICONS_PER_ROW()

    local x =
    debuffhud.x +
    (
        col *
        (ICON_SPACING_X() * get_scale())
    )

local y =
    debuffhud.y +
    (
        row *
        (ICON_SPACING_Y() * get_scale())
    )

    return x, y

end

-- =========================================================
-- ICON RESOLUTION
-- =========================================================

local function get_icon_path(
    buff_id
)

    local icon_path =
        ICON_PATH ..
        tostring(buff_id) ..
        '.png'

    if windower.file_exists(
        icon_path
    ) then

        return icon_path

    end

    return FALLBACK_ICON

end

-- =========================================================
-- FADE
-- =========================================================

local function update_fade(
    state
)

    local speed =
        settings.debuffhud
        .fade_speed

    if state.CurrentAlpha <
       state.TargetAlpha
    then

        state.CurrentAlpha =
            math.min(

                state.CurrentAlpha +
                speed,

                state.TargetAlpha

            )

    elseif state.CurrentAlpha >
           state.TargetAlpha
    then

        state.CurrentAlpha =
            math.max(

                state.CurrentAlpha -
                speed,

                state.TargetAlpha

            )

    end

end

-- =========================================================
-- INITIALIZE
-- =========================================================

function debuffhud.initialize()

    for i = 1,
        MAX_DEBUFFS()
    do

        local icon =
            images.new()

        icon:hide()

        debuff_icons[i] =
            icon

        local timer =
            texts.new('')

        timer:size(
            settings.debuffhud
            .timer_font_size
        )

        timer:font(
            'Arial'
        )

        timer:color(
            255,
            255,
            255
        )

        timer:stroke_color(
            0,
            0,
            0
        )

        timer:stroke_width(2)

        timer:bg_alpha(0)

        timer:hide()

        debuff_timers[i] =
            timer

        icon_states[i] = {

            CurrentAlpha = 0,
            TargetAlpha = 0,

            LastIconPath = nil,

            LastPosX = nil,
            LastPosY = nil,

            LastTimerPosX = nil,
            LastTimerPosY = nil,

            LastTimerText = nil,

            LastAlpha = -1,

        }

    end

end

-- =========================================================
-- UPDATE
-- =========================================================

function debuffhud.update()

    debuffhud.visible =
        settings.debuffhud.visible

    if not debuffhud.visible then

        tooltip:hide()

        return

    end

    local scale =
    get_scale()

local timer_size =
    math.max(
        8,
        math.floor(
            settings.debuffhud.timer_font_size *
            scale
        )
    )

local icon_size =
    ICON_SIZE() * scale

    local debuffs =
        targetdebuffs
        .get_target_debuffs()

-- =====================================================
-- PREVIEW
-- =====================================================

if debuffhud.preview then

    local now =
        os.clock()

    debuffs = {

        [2] = {
            EndTime = now + 120
        },

        [5] = {
            EndTime = now + 45
        },

        [19] = {
            EndTime = now + 9
        },

        [28] = {
            EndTime = now + 360
        },

        [134] = {
            EndTime = now + 15
        },

        [167] = {
            EndTime = now + 999
        }

    }

end

    local now =
        os.clock()

    local hovering =
        false

    used_slots = {}

    -- =====================================================
    -- ASSIGN STABLE SLOTS
    -- =====================================================

    for buff_id, effect in
        pairs(debuffs)
    do

        if not render_slots[
            buff_id
        ] then

            for slot = 1,
                MAX_DEBUFFS()
            do

                local occupied =
                    false

                for _, used_slot in
                    pairs(render_slots)
                do

                    if used_slot ==
                       slot
                    then

                        occupied =
                            true

                        break

                    end

                end

                if not occupied then

                    render_slots[
                        buff_id
                    ] = slot

                    break

                end

            end

        end

        local index =
            render_slots[
                buff_id
            ]

        used_slots[
            index
        ] = true

        local state =
            icon_states[index]

        if effect.EndTime then

            local remaining =
                effect.EndTime -
                now

            if remaining > 0 then

                local icon =
                    debuff_icons[index]

                local timer =
                    debuff_timers[index]

                timer:size(
    timer_size
)    

                local x, y =
                    get_slot_position(
                        index
                    )

                local icon_path =
                    get_icon_path(
                        buff_id
                    )

                -- =========================================
                -- OPTIMIZED ICON PATH
                -- =========================================

                if state.LastIconPath ~=
                   icon_path
                then

                    icon:path(
                        icon_path
                    )

                    state.LastIconPath =
                        icon_path

                end

                icon:size(
    icon_size,
    icon_size
)

                if state.LastPosX ~= x or
                   state.LastPosY ~= y
                then

                    icon:pos(x, y)

                    state.LastPosX = x
                    state.LastPosY = y

                end

                -- =========================================
                -- TARGET ALPHA
                -- =========================================

                local target_alpha =
                    255

                if remaining <=
                   settings.debuffhud
                   .blink_threshold
                then

                    target_alpha =
                        math.floor(
                            (
                                math.sin(
                                    now * 8
                                ) + 1
                            ) * 127
                        ) + 50

                end

                state.TargetAlpha =
                    target_alpha

                update_fade(
                    state
                )

                if state.LastAlpha ~=
                   state.CurrentAlpha
                then

                    icon:alpha(
                        state.CurrentAlpha
                    )

                    state.LastAlpha =
                        state.CurrentAlpha

                end

                icon:show()

                -- =========================================
                -- TIMER
                -- =========================================

                if settings
                   .debuffhud
                   .show_timers
                then

                    local seconds =
                        math.max(

                            math.floor(
                                remaining
                            ),

                            0

                        )

                    local display =
                        ''

                    if seconds >= 3600 then

                        display =
                            tostring(
                                math.floor(
                                    seconds / 3600
                                )
                            ) .. 'h'

                    elseif seconds >= 60 then

                        display =
                            tostring(
                                math.floor(
                                    seconds / 60
                                )
                            ) .. 'm'

                    else

                        display =
                            tostring(
                                seconds
                            )

                    end

                    -- =====================================
                    -- OPTIMIZED TEXT
                    -- =====================================

                    if state.LastTimerText ~=
                       display
                    then

                        timer:text(
                            display
                        )

                        state.LastTimerText =
                            display

                    end

                    local timer_x =
                        x + 4

                    if string.len(
                        display
                    ) >= 2 then

                        timer_x =
                            x + 1

                    end

                    if string.len(
                        display
                    ) >= 3 then

                        timer_x =
                            x - 2

                    end

                    local timer_y =
    y +
    icon_size +
    1

                    -- =====================================
                    -- OPTIMIZED TIMER POSITION
                    -- =====================================

                    if state.LastTimerPosX ~= timer_x or
                       state.LastTimerPosY ~= timer_y
                    then

                        timer:pos(
                            timer_x,
                            timer_y
                        )

                        state.LastTimerPosX =
                            timer_x

                        state.LastTimerPosY =
                            timer_y

                    end

                    if seconds <=
                       settings
                       .debuffhud
                       .low_timer_threshold
                    then

                        timer:color(
                            255,
                            80,
                            80
                        )

                    else

                        timer:color(
                            255,
                            255,
                            255
                        )

                    end

                    timer:show()

                else

                    timer:hide()

                end

                -- =========================================
                -- TOOLTIP
                -- =========================================

                if settings
                   .debuffhud
                   .show_tooltip
                then

                    if debuffhud.mouse_x >= x and
                       debuffhud.mouse_x <= x + icon_size and
                       debuffhud.mouse_y >= y and
                       debuffhud.mouse_y <= y + icon_size then

                        local buff =
                            res.buffs[
                                buff_id
                            ]

                        local buff_name =
                            buff and
                            buff.en
                            or
                            'Unknown Debuff'

                        tooltip:text(
                            buff_name
                        )

                        tooltip:pos(
                            debuffhud.mouse_x + 16,
                            debuffhud.mouse_y + 16
                        )

                        tooltip:show()

                        hovering = true

                    end

                end

            end

        end

    end

    -- =====================================================
    -- CLEANUP / FADE OUT
    -- =====================================================

    local active_slots = {}

    for buff_id, slot in
        pairs(render_slots)
    do

        if debuffs[
            buff_id
        ] then

            active_slots[
                slot
            ] = true

        else

            render_slots[
                buff_id
            ] = nil

        end

    end

    for i = 1,
        MAX_DEBUFFS()
    do

        local state =
            icon_states[i]

        if not active_slots[i] then

            state.TargetAlpha =
                0

            update_fade(
                state
            )

            if state.LastAlpha ~=
               state.CurrentAlpha
            then

                debuff_icons[i]:
                    alpha(
                        state.CurrentAlpha
                    )

                state.LastAlpha =
                    state.CurrentAlpha

            end

            if state.CurrentAlpha <= 0 then

                debuff_icons[i]:
                    hide()

                debuff_timers[i]:
                    hide()

            else

                debuff_icons[i]:
                    show()

            end

        end

    end

    -- =====================================================
    -- TOOLTIP CLEANUP
    -- =====================================================

    if not hovering then

        tooltip:hide()

    end

end

-- =========================================================
-- DESTROY
-- =========================================================

function debuffhud.destroy()

    tooltip:destroy()

    for i = 1,
        MAX_DEBUFFS()
    do

        debuff_icons[i]:
            destroy()

        debuff_timers[i]:
            destroy()

    end

end

-- =========================================================
-- SETTINGS ACCESS
-- =========================================================

function debuffhud.get_settings()

    return settings

end

function debuffhud.save_settings()

    settings.debuffhud.x =
        debuffhud.x

    settings.debuffhud.y =
        debuffhud.y

    config.save(settings)

end

return debuffhud