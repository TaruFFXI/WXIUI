local texts =
    require('texts')

local res =
    require('resources')

local region_zones =
    require('regionZones')

local settings =
    require('data/settings')

local function get_scale()
    return settings.zonehud.scale / 50
end    

local zonehud = {}

zonehud.visible = true
zonehud.preview = false

zonehud.y = 300

local zone_text
local region_text

local display_start = 0
local showing = false

local DISPLAY_TIME = 5
local FADE_TIME = 1

local current_zone = nil

-- =========================================================
-- REGION
-- =========================================================

local function get_region_name(zone_id)

    for region_id, zones in
        pairs(region_zones.map)
    do

        if zones:contains(zone_id) then

            local region =
                res.regions[
                    region_id
                ]

            if region then
                return region.en
            end

        end

    end

    return ''

end

-- =========================================================
-- HIDE
-- =========================================================

local function hide()

    zone_text:hide()
    region_text:hide()

end

-- =========================================================
-- SHOW
-- =========================================================

local function show_zone()

    local info =
        windower.ffxi.get_info()

    if not info then
        return
    end

    local zone =
        res.zones[
            info.zone
        ]

    if not zone then
        return
    end

    local region_name =
        get_region_name(
            info.zone
        )

    zone_text:text(
        zone.en
    )

    region_text:text(
        '- ' ..
        region_name ..
        ' -'
    )

    display_start =
        os.clock()

    showing = true

    zone_text:show()
    region_text:show()

end

-- =========================================================
-- INITIALIZE
-- =========================================================

function zonehud.initialize()

local scale = get_scale()
    -- =====================================================
    -- ZONE TEXT
    -- =====================================================

    zone_text =
        texts.new('')

    zone_text:size(
    math.floor(44 * scale)
)

    zone_text:font(
        'Grammara'
    )

    zone_text:bold(true)

    zone_text:stroke_width(3)

    zone_text:stroke_color(
        51,
        47,
        38
    )

    zone_text:bg_alpha(0)

    zone_text:color(
        255,
        255,
        193
    )

    zone_text:hide()

    -- =====================================================
    -- REGION TEXT
    -- =====================================================

    region_text =
        texts.new('')

    region_text:size(
    math.floor(28 * scale)
)

    region_text:font(
        'Grammara'
    )

    region_text:bold(true)

    region_text:stroke_width(3)

    region_text:stroke_color(
        51,
        47,
        38
    )

    region_text:bg_alpha(0)

    region_text:color(
        255,
        255,
        193
    )

    region_text:hide()

    local info =
        windower.ffxi.get_info()

    if info then
        current_zone =
            info.zone
    end

end

-- =========================================================
-- STOP PREVIEW
-- =========================================================

function zonehud.stop_preview()

    zonehud.preview = false

    showing = false

    hide()

end

-- =========================================================
-- UPDATE
-- =========================================================

function zonehud.update()

  local scale = get_scale()  

    zone_text:size(
    math.floor(44 * scale)
)

region_text:size(
    math.floor(28 * scale)
)

    if not zonehud.visible then

        hide()

        return

    end

    -- =====================================================
    -- PREVIEW
    -- =====================================================

    if zonehud.preview then

        zone_text:text(
            'Southern San d\'Oria'
        )

        region_text:text(
            '- Kingdom of San d\'Oria -'
        )

    else

        -- =================================================
        -- ZONE CHECK
        -- =================================================

        local info =
            windower.ffxi.get_info()

        if info and
           info.zone ~= current_zone
        then

            current_zone =
                info.zone

            show_zone()

        end

        if not showing then
            return
        end

    end

    -- =====================================================
    -- TIMING
    -- =====================================================

    local alpha = 255

    if not zonehud.preview then

        local elapsed =
            os.clock() -
            display_start

        -- FADE IN

        if elapsed < FADE_TIME then

            alpha =
                math.floor(
                    (
                        elapsed /
                        FADE_TIME
                    ) * 255
                )

        -- FADE OUT

        elseif elapsed >
            DISPLAY_TIME
        then

            local fade_elapsed =
                elapsed -
                DISPLAY_TIME

            alpha =
                math.floor(
                    255 -
                    (
                        fade_elapsed /
                        FADE_TIME
                    ) * 255
                )

        end

        if alpha < 0 then

            showing = false

            hide()

            return

        end

    end

    -- =====================================================
    -- CENTERING
    -- =====================================================

    local zone_width,
          zone_height =
        zone_text:extents()

    local region_width,
          region_height =
        region_text:extents()

    local center_x =
        windower
        .get_windower_settings()
        .ui_x_res / 2

    local center_y =
        zonehud.y

    -- =====================================================
    -- DRAW ZONE
    -- =====================================================

    zone_text:pos(
        center_x -
        (zone_width / 2),

        center_y
    )

    zone_text:alpha(alpha)

    zone_text:show()

    -- =====================================================
    -- DRAW REGION
    -- =====================================================

    region_text:pos(
        center_x -
        (region_width / 2),

        center_y + (62 * scale)
    )

    region_text:alpha(alpha)

    region_text:show()

end

-- =========================================================
-- DESTROY
-- =========================================================

function zonehud.destroy()

    zone_text:destroy()
    region_text:destroy()

end

return zonehud