local texts =
    require('texts')

local prims =
    require('prims')

local settings =
    require('data/settings')

local tothud = {}

tothud.visible = true
tothud.preview = false

-- =========================================================
-- POSITION
-- =========================================================

tothud.x = 1450
tothud.y = 970
local function get_scale()

    return
        settings.tothud.scale / 50

end

-- =========================================================
-- DIMENSIONS
-- =========================================================

local BAR_WIDTH = 120
local BAR_HEIGHT = 14

local OUTLINE_SIZE = 2

-- =========================================================
-- SMOOTHING
-- =========================================================

local displayed_hp = 1.0

-- =========================================================
-- COLORS
-- =========================================================

local HP_FILL = {
    255,
    48,
    182,
    216
}

local BG_COLOR = {
    255,
    15,
    25,
    45
}

local OUTLINE = {
    255,
    0,
    0,
    0
}

-- =========================================================
-- TARGET CACHE
-- =========================================================

local mob_targets = {}

-- =========================================================
-- ACTION TRACKING
-- =========================================================

windower.register_event(
    'action',

    function(act)

        if not act or
           not act.actor_id or
           not act.targets
        then
            return
        end

        for _, target in ipairs(
            act.targets
        ) do

            if target.id then

                mob_targets[
                    act.actor_id
                ] = target.id

            end

        end

    end
)

-- =========================================================
-- ELEMENTS
-- =========================================================

local outline_top
local outline_bottom
local outline_left
local outline_right

local hp_bg
local hp_fill

local name_text

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
-- INITIALIZE
-- =========================================================

function tothud.initialize()

    outline_top =
        create_rect(
            BAR_WIDTH + 4,
            OUTLINE_SIZE,
            OUTLINE
        )

    outline_bottom =
        create_rect(
            BAR_WIDTH + 4,
            OUTLINE_SIZE,
            OUTLINE
        )

    outline_left =
        create_rect(
            OUTLINE_SIZE,
            BAR_HEIGHT,
            OUTLINE
        )

    outline_right =
        create_rect(
            OUTLINE_SIZE,
            BAR_HEIGHT,
            OUTLINE
        )

    hp_bg =
        create_rect(
            BAR_WIDTH,
            BAR_HEIGHT,
            BG_COLOR
        )

    hp_fill =
        create_rect(
            BAR_WIDTH,
            BAR_HEIGHT,
            HP_FILL
        )

    -- =====================================================
    -- NAME
    -- =====================================================

    name_text =
        texts.new('')

    name_text:size(9)

    name_text:font(
        'Arial'
    )

    name_text:bold(true)

    name_text:bg_alpha(0)

    name_text:stroke_alpha(255)

    name_text:stroke_width(2)

    name_text:hide()

end

-- =========================================================
-- HIDE
-- =========================================================

local function hide()

    outline_top:visible(false)
    outline_bottom:visible(false)
    outline_left:visible(false)
    outline_right:visible(false)

    hp_bg:visible(false)
    hp_fill:visible(false)

    name_text:hide()

end

-- =========================================================
-- UPDATE
-- =========================================================

function tothud.update()

    if not tothud.visible then

        hide()

        return

    end

    local st = nil

    -- =====================================================
    -- PREVIEW
    -- =====================================================

    if tothud.preview then

        st = {

            name = 'TargetToTarget',
            hpp = 64

        }

    else

        -- =================================================
        -- TARGET
        -- =================================================

        local target =
            windower.ffxi
            .get_mob_by_target('t')

        if not target then

            hide()

            return

        end

        -- =================================================
        -- TRACKED TARGET
        -- =================================================

        local tracked_target_id =
            mob_targets[target.id]

        if not tracked_target_id then

            hide()

            return

        end

        st =
            windower.ffxi
            .get_mob_by_id(
                tracked_target_id
            )

        if not st then

            hide()

            return

        end

    end

    -- =====================================================
    -- HP
    -- =====================================================

    local hp_percent =
        (
            st.hpp or
            100
        ) / 100

    displayed_hp =
        displayed_hp +
        (
            (
                hp_percent -
                displayed_hp
            ) * 0.15
        )

    local x =
        tothud.x

    local y =
        tothud.y

    local scale =
    get_scale()

local bar_width =
    BAR_WIDTH * scale

local bar_height =
    BAR_HEIGHT * scale

local outline_size =
    OUTLINE_SIZE * scale    

    -- =====================================================
    -- OUTLINE
    -- =====================================================

    outline_top:visible(true)
    outline_bottom:visible(true)
    outline_left:visible(true)
    outline_right:visible(true)

    outline_top:pos(
    x - outline_size,
    y - outline_size
)

outline_bottom:pos(
    x - outline_size,
    y + bar_height
)

outline_left:pos(
    x - outline_size,
    y
)

outline_right:pos(
    x + bar_width,
    y
)

outline_top:width(
    bar_width +
    (outline_size * 2)
)

outline_bottom:width(
    bar_width +
    (outline_size * 2)
)

outline_top:height(
    outline_size
)

outline_bottom:height(
    outline_size
)

outline_left:width(
    outline_size
)

outline_right:width(
    outline_size
)

outline_left:height(
    bar_height
)

outline_right:height(
    bar_height
)

    -- =====================================================
    -- BAR
    -- =====================================================

    hp_bg:visible(true)
    hp_fill:visible(true)

    hp_bg:pos(
        x,
        y
    )

    hp_fill:pos(
        x,
        y
    )

    hp_bg:width(
    bar_width
)

hp_bg:height(
    bar_height
)

hp_fill:height(
    bar_height
)

    hp_fill:width(
    math.max(
        2,
        bar_width *
        displayed_hp
    )
)

    -- =====================================================
    -- NAME
    -- =====================================================
name_text:size(
    math.floor(9 * scale)
)

    name_text:text(
        st.name
    )

    name_text:pos(
    x + (2 * scale),
    y - (14 * scale)
)

    name_text:show()

end

-- =========================================================
-- DESTROY
-- =========================================================

function tothud.destroy()

    outline_top:destroy()
    outline_bottom:destroy()
    outline_left:destroy()
    outline_right:destroy()

    hp_bg:destroy()
    hp_fill:destroy()

    name_text:destroy()

end

return tothud