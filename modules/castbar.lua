local texts =
    require('texts')

local prims =
    require('prims')

local res =
    require('resources')

local settings =
    require('data/settings')    

local castbar = {}

castbar.visible = true
castbar.preview = false

castbar.x = 810
castbar.y = 820

local cast_bg
local cast_fill
local cast_text

local cast_active = false

local cast_start = 0
local cast_duration = 0
local cast_name = ''
local function get_scale()

    return
        settings.castbar.scale / 50

end
-- =========================================================
-- SETTINGS
-- =========================================================

local BASE_WIDTH = 395
local BAR_HEIGHT = 8

-- =========================================================
-- COLORS
-- =========================================================

local BG_COLOR = {
    255,
    15,
    25,
    45
}

local FILL_COLOR = {
    255,
    70,
    170,
    255
}

-- =========================================================
-- CREATE RECT
-- =========================================================

local function create_rect(
    width,
    height,
    color
)

    return prims.new({

        w = width,
        h = height,

        color = color,

        visible = true

    })

end

-- =========================================================
-- START CAST
-- =========================================================

local function start_cast(
    spell_name,
    cast_time
)

    cast_active = true

    cast_start =
        os.clock()

    cast_duration =
        math.max(
            cast_time,
            0.1
        )

    cast_name =
        spell_name or
        'Casting...'

    cast_fill:width(2)

    cast_bg:show()
    cast_fill:show()
    cast_text:show()

end

-- =========================================================
-- STOP CAST
-- =========================================================

local function stop_cast()

    cast_active = false

    if castbar.preview then
        return
    end

    cast_bg:hide()
    cast_fill:hide()
    cast_text:hide()

end

-- =========================================================
-- ACTION EVENT
-- =========================================================

windower.register_event(

    'action',

    function(act)

        local player =
            windower.ffxi
            .get_player()

        if not player then
            return
        end

        -- PLAYER ONLY

        if act.actor_id ~= player.id then
            return
        end

        -- =================================================
        -- SPELL START
        -- =================================================

        if act.category == 8 or
           act.category == 9
        then

            if not act.targets or
               not act.targets[1] or
               not act.targets[1].actions or
               not act.targets[1].actions[1]
            then
                return
            end

            local action =
                act.targets[1]
                .actions[1]

            local spell_id =
                action.param

            local spell =
                res.spells[
                    spell_id
                ]

            if not spell then
                return
            end

            local cast_time =
                spell.cast_time or
                1

            start_cast(

                spell.en,

                cast_time

            )

        end

    end

)

-- =========================================================
-- INITIALIZE
-- =========================================================

function castbar.initialize()

    cast_bg =
        create_rect(

            BASE_WIDTH,
            BAR_HEIGHT,

            BG_COLOR

        )

    cast_fill =
        create_rect(

            BASE_WIDTH,
            BAR_HEIGHT,

            FILL_COLOR

        )

    cast_bg:hide()
    cast_fill:hide()

    cast_text =
        texts.new('')

    cast_text:size(10)

    cast_text:font(
        'Arial'
    )

    cast_text:bold(true)

    cast_text:color(
        255,
        255,
        255
    )

    cast_text:stroke_color(
        0,
        0,
        0
    )

    cast_text:stroke_width(2)

    cast_text:bg_alpha(0)

    cast_text:hide()

end

-- =========================================================
-- UPDATE
-- =========================================================

function castbar.update()

    if not castbar.visible then

        stop_cast()

        return

    end

    local scale =
    get_scale()

local bar_width =
    BASE_WIDTH * scale

local bar_height =
    BAR_HEIGHT * scale

local font_size =
    math.max(
        8,
        math.floor(
            10 * scale
        )
    )    

    -- =====================================================
    -- PREVIEW
    -- =====================================================

    if castbar.preview then

        cast_bg:show()
        cast_fill:show()
        cast_text:show()

        cast_bg:width(
    bar_width
)

cast_bg:height(
    bar_height
)

cast_fill:height(
    bar_height
)

        cast_bg:pos(
            castbar.x,
            castbar.y
        )

        cast_fill:pos(
            castbar.x,
            castbar.y
        )

        cast_fill:width(
            bar_width * 0.72
        )

        cast_text:size(
    font_size
)

        cast_text:text(
            'Fire IV'
        )

        cast_text:pos(
            castbar.x +
            (
                BASE_WIDTH / 2
            ) - 24,

            castbar.y -
math.max(
    14,
    18 * scale
)
        )

        return

    end

    if not cast_active then
        return
    end

    local elapsed =
        os.clock() -
        cast_start

    local percent =
        math.min(

            elapsed /
            cast_duration,

            1.0

        )

    cast_bg:show()
    cast_fill:show()
    cast_text:show()

    cast_bg:width(
    bar_width
)

cast_bg:height(
    bar_height
)

cast_fill:height(
    bar_height
)

    cast_bg:pos(
        castbar.x,
        castbar.y
    )

    cast_fill:pos(
        castbar.x,
        castbar.y
    )

    cast_fill:width(
        bar_width * percent
    )

    cast_text:size(
    font_size
)

    cast_text:text(
        cast_name
    )

    cast_text:pos(
        castbar.x +
        (
            bar_width / 2
        ) -
        (
            string.len(
                cast_name
            ) * 3
        ),

        castbar.y -
        math.max(
            14,
            18 * scale
        )
    )

    if percent >= 1.0 then
        stop_cast()
    end

end

-- =========================================================
-- PUBLIC API
-- =========================================================

function castbar.start_cast(
    name,
    duration
)

    start_cast(
        name or 'Casting...',
        duration or 3
    )

end

function castbar.hide()

    stop_cast()

end

-- =========================================================
-- DESTROY
-- =========================================================

function castbar.destroy()

    if cast_bg then
        cast_bg:destroy()
    end

    if cast_fill then
        cast_fill:destroy()
    end

    if cast_text then
        cast_text:destroy()
    end

end

return castbar