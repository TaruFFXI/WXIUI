local texts =
    require('texts')

local prims =
    require('prims')

local config =
    require('config')

local res =
    require('resources')

local experience =
    require('systems/experience')

local global_settings =
    require('data/settings')    

local experiencehud = {}

-- =========================================================
-- SETTINGS
-- =========================================================

local defaults = {

    experiencehud = {

        visible = true,

        x = 1260,
        y = 1010,

        width = 395,
        height = 6,

        smoothing = 0.12,

        show_text = true,

    }

}

local settings =
    config.load(
        defaults
    )

local function get_scale()

    return
        global_settings.experiencehud.scale / 50

end
-- =========================================================
-- STATE
-- =========================================================

experiencehud.visible =
    settings.experiencehud.visible

experiencehud.preview =
    false

experiencehud.x =
    settings.experiencehud.x

experiencehud.y =
    settings.experiencehud.y

local displayed_ratio = 0
local last_display_text = ''

-- =========================================================
-- COLORS
-- =========================================================

local EXP_FILL = {
    255,
    220,
    190,
    60
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

local OUTLINE_SIZE = 1

-- =========================================================
-- ELEMENTS
-- =========================================================

local outline_top
local outline_bottom
local outline_left
local outline_right

local exp_bg
local exp_fill

local exp_text

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
-- CREATE OUTLINE
-- =========================================================

local function create_outline()

    outline_top =
        create_rect(
            settings.experiencehud.width +
            (OUTLINE_SIZE * 2),
            OUTLINE_SIZE,
            OUTLINE
        )

    outline_bottom =
        create_rect(
            settings.experiencehud.width +
            (OUTLINE_SIZE * 2),
            OUTLINE_SIZE,
            OUTLINE
        )

    outline_left =
        create_rect(
            OUTLINE_SIZE,
            settings.experiencehud.height,
            OUTLINE
        )

    outline_right =
        create_rect(
            OUTLINE_SIZE,
            settings.experiencehud.height,
            OUTLINE
        )

end

-- =========================================================
-- INITIALIZE
-- =========================================================

function experiencehud.initialize()

    experience.initialize()

    create_outline()

    exp_bg =
        create_rect(

            settings.experiencehud.width,
            settings.experiencehud.height,
            BG_COLOR

        )

    exp_fill =
        create_rect(

            settings.experiencehud.width,
            settings.experiencehud.height,
            EXP_FILL

        )

    exp_text =
        texts.new('')

    exp_text:size(10)

    exp_text:font('Arial')

    exp_text:bold(true)

    exp_text:color(
        255,
        255,
        255
    )

    exp_text:stroke_color(
        0,
        0,
        0
    )

    exp_text:stroke_width(2)

    exp_text:bg_alpha(0)

    exp_text:hide()

end

-- =========================================================
-- HIDE
-- =========================================================

local function hide()

    outline_top:visible(false)
    outline_bottom:visible(false)
    outline_left:visible(false)
    outline_right:visible(false)

    exp_bg:visible(false)
    exp_fill:visible(false)

    exp_text:hide()

end

-- =========================================================
-- UPDATE
-- =========================================================

function experiencehud.update()

    if not experiencehud.visible then

        hide()

        return

    end

    local scale =
    get_scale()

local bar_width =
    settings.experiencehud.width *
    scale

local bar_height =
    settings.experiencehud.height *
    scale

local outline_size =
    math.max(
        1,
        math.floor(
            OUTLINE_SIZE * scale
        )
    )

local font_size =
    math.max(
        8,
        math.floor(
            10 * scale
        )
    )

    local player =
        windower.ffxi.get_player()

    local current = 0
    local maximum = 1

    -- =====================================================
    -- EXP / CP MODE
    -- =====================================================

    if player and
       player.main_job_level >= 99
    then

        local cp_current =
            select(
                1,
                experience.get_capacity()
            )

        current =
            cp_current or 0

        maximum =
            30000

    else

        current,
        maximum =
            experience.get_exp()

        if maximum <= 0 then
            maximum = 1
        end

    end

    local ratio =
        math.max(
            0,
            math.min(
                current / maximum,
                1
            )
        )

    displayed_ratio =
        displayed_ratio +

        (
            (
                ratio -
                displayed_ratio
            ) *

            settings.experiencehud.smoothing
        )

    if player and
       settings.experiencehud.show_text
    then

        local main_job =
            res.jobs[
                player.main_job_id
            ]

        local sub_job =
            res.jobs[
                player.sub_job_id
            ]

        local main_short =
            main_job and
            main_job.ens or
            'UNK'

        local sub_short =
            sub_job and
            sub_job.ens or
            'UNK'

        local percent =
            math.floor(
                ratio * 100
            )

        local limit_current,
              limit_max,
              merit_current,
              merit_max =
              experience.get_limit()

        local cp_current,
              cp_max,
              jp_current =
              experience.get_capacity()

        local display_text =

            string.format(

                '%s/%s Lv %d/%d   MP %d/%d   JP %d   CP %d/%d   XP %d%%',

                main_short,
                sub_short,

                player.main_job_level,
                player.sub_job_level,

                merit_current,
                merit_max,

                jp_current,

                cp_current,
                cp_max,

                percent

            )

        if last_display_text ~=
           display_text
        then

            exp_text:text(
                display_text
            )

            last_display_text =
                display_text

        end

        exp_text:size(
            font_size
        )

        exp_text:pos(
            experiencehud.x,
            experiencehud.y -
            math.max(
                14,
                22 * scale
        )
    )

        exp_text:show()

    end

    local x =
        experiencehud.x

    local y =
        experiencehud.y

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
-- OUTLINE
-- =====================================================

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

    -- =====================================================
    -- BAR
    -- =====================================================

    exp_bg:width(
    bar_width
)

exp_bg:height(
    bar_height
)

exp_fill:height(
    bar_height
)

    exp_bg:pos(
        x,
        y
    )

    exp_fill:pos(
        x,
        y
    )

    exp_fill:width(

    bar_width *
    displayed_ratio

)

    -- =====================================================
    -- SHOW
    -- =====================================================

    outline_top:visible(true)
    outline_bottom:visible(true)
    outline_left:visible(true)
    outline_right:visible(true)

    exp_bg:visible(true)
    exp_fill:visible(true)

end

-- =========================================================
-- DESTROY
-- =========================================================

function experiencehud.destroy()

    outline_top:destroy()
    outline_bottom:destroy()
    outline_left:destroy()
    outline_right:destroy()

    exp_bg:destroy()
    exp_fill:destroy()

    exp_text:destroy()

end

return experiencehud