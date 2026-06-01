local texts =
    require('texts')

local config =
    require('config')

local distance =
    require('systems/distance')

local distancehud = {}

-- =========================================================
-- SETTINGS
-- =========================================================

local defaults = {

    distancehud = {

        visible = true,

        x = 1180,
        y = 860,

    }

}

local settings =
    config.load(
        defaults
    )

local global_settings =
    require('data/settings')

local function get_scale()

    return
        global_settings.distancehud.scale / 50

end

-- =========================================================
-- STATE
-- =========================================================

distancehud.visible =
    settings.distancehud
    .visible

distancehud.preview =
    false

distancehud.x =
    settings.distancehud
    .x

distancehud.y =
    settings.distancehud
    .y

-- =========================================================
-- UI
-- =========================================================

local distance_text

-- =========================================================
-- INITIALIZE
-- =========================================================

function distancehud.initialize()

    distance_text =
        texts.new('')

    distance_text:size(10)

    distance_text:font(
        'Arial'
    )

    distance_text:stroke_width(2)

    distance_text:stroke_color(
        0,
        0,
        0
    )

    distance_text:bg_alpha(0)

    distance_text:hide()

end

-- =========================================================
-- UPDATE
-- =========================================================

function distancehud.update()

    if not distancehud.visible
    then

        distance_text:hide()

        return

    end

    local scale =
    get_scale()

local font_size =
    math.max(
        8,
        math.floor(
            10 * scale
        )
    )

distance_text:size(
    font_size
)

    -- =====================================================
    -- PREVIEW
    -- =====================================================

    if distancehud.preview then

        distance_text:text(
            '5.2'
        )

        distance_text:color(
            0,
            255,
            0
        )

        distance_text:pos(
            distancehud.x,
            distancehud.y
        )

        distance_text:show()

        return

    end

    -- =====================================================
    -- UPDATE SYSTEM
    -- =====================================================

    distance.update()

    -- =====================================================
    -- TARGET CHECK
    -- =====================================================

    if not distance
           .has_target()
    then

        distance_text:hide()

        return

    end

    -- =====================================================
    -- DATA
    -- =====================================================

    local target_distance =
        distance.get_distance()

    local r,
          g,
          b =
        distance.get_color()

    -- =====================================================
    -- COLOR
    -- =====================================================

    distance_text:color(
        r,
        g,
        b
    )

    -- =====================================================
    -- TEXT
    -- =====================================================

    local display_text =
        string.format(

            '%.1f',

            target_distance

        )

    distance_text:text(
        display_text
    )

    distance_text:pos(
        distancehud.x,
        distancehud.y
    )

    distance_text:show()

end

-- =========================================================
-- DESTROY
-- =========================================================

function distancehud.destroy()

    distance_text:destroy()

end

return distancehud