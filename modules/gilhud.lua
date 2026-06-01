local settings =
    require('data/settings')

local function get_scale()
    return settings.gilhud.scale / 50
end

local texts =
    require('texts')

local images =
    require('images')

local gilhud = {}

gilhud.visible = true
gilhud.preview = false

gilhud.x = 1700
gilhud.y = 920

local gil_icon
local gil_text
local tooltip_text

local current_gil = 0
local previous_gil = 0
local gil_initialized = false

local session_balance = 0
local earned_gil = 0

local session_start = os.time()

local mouse_x = 0
local mouse_y = 0

-- =========================================================
-- FORMAT
-- =========================================================

local function comma_value(amount)

    local formatted =
        tostring(math.floor(amount))

    while true do

        formatted, k =
            string.gsub(
                formatted,
                '^(-?%d+)(%d%d%d)',
                '%1,%2'
            )

        if k == 0 then
            break
        end

    end

    return formatted

end

-- =========================================================
-- GIL/HOUR
-- =========================================================

local function get_gil_per_hour()

    local elapsed =
        os.time() -
        session_start

    if elapsed <= 0 then
        return 0
    end

    return
        (earned_gil / elapsed) * 3600

end

-- =========================================================
-- UPDATE GIL
-- =========================================================

local function update_gil()

    current_gil =
    windower.ffxi.get_items(
        'gil'
    ) or 0

if not gil_initialized then

    if current_gil <= 0 then
        return
    end

    previous_gil =
        current_gil

    gil_initialized =
        true

    return

end

local delta =
    current_gil -
    previous_gil

    session_balance =
        session_balance +
        delta

    if delta > 0 then

        earned_gil =
            earned_gil +
            delta

    end

    previous_gil =
        current_gil

end

-- =========================================================
-- HOVER
-- =========================================================

local function is_hovering()

    local scale = get_scale()
     
    local width =

        (
            string.len(
    comma_value(current_gil)
) * (8 * scale)
        ) + (40 * scale)

    return

        mouse_x >= gilhud.x and
        mouse_x <= gilhud.x + width and

        mouse_y >= gilhud.y - (4 * scale) and
        mouse_y <= gilhud.y + (24 * scale)

end

-- =========================================================
-- INITIALIZE
-- =========================================================

function gilhud.initialize()
    local scale = get_scale()

    current_gil =
        windower.ffxi.get_items(
            'gil'
        ) or 0

    previous_gil =
        current_gil

    -- ICON

    gil_icon =
        images.new()

    gil_icon:path(
        windower.addon_path ..
        'assets/icons/gil.png'
    )

    gil_icon:size(
        20 * scale,
        20 * scale
   )

    gil_icon:hide()

    -- MAIN TEXT

    gil_text =
        texts.new('')

    gil_text:size(
    math.floor(10 * scale)
)

    gil_text:font(
        'Arial'
    )

    gil_text:bold(true)

    gil_text:stroke_width(2)

    gil_text:stroke_color(
        0,
        0,
        0
    )

    gil_text:bg_alpha(0)

    gil_text:hide()

    -- TOOLTIP

    tooltip_text =
        texts.new('')

    tooltip_text:size(
    math.floor(9 * scale)
)

    tooltip_text:font(
        'Arial'
    )

    tooltip_text:bold(true)

    tooltip_text:stroke_width(2)

    tooltip_text:stroke_color(
        0,
        0,
        0
    )

    tooltip_text:bg_alpha(0)

    tooltip_text:hide()

    -- MOUSE TRACKING

    windower.register_event(

        'mouse',

        function(type, x, y)

            mouse_x = x
            mouse_y = y

        end

    )

end

-- =========================================================
-- HIDE
-- =========================================================

local function hide()

    gil_icon:hide()
    gil_text:hide()
    tooltip_text:hide()

end

-- =========================================================
-- UPDATE
-- =========================================================

function gilhud.update()
local scale = get_scale()    

    gil_text:size(
    math.floor(10 * scale)
)

tooltip_text:size(
    math.floor(9 * scale)
)

    gil_icon:size(
    20 * scale,
    20 * scale
)

    if not gilhud.visible then
   
        hide()

        return

    end


    -- =====================================================
    -- PREVIEW
    -- =====================================================

    if gilhud.preview then

        local preview_text =
            '644,854'

        gil_text:text(
            '\\cs(255,255,255)' ..
            preview_text ..
            '\\cr'
        )

        gil_text:pos(
            gilhud.x,
            gilhud.y - (2 * scale)
        )

        gil_text:show()

        gil_icon:pos(
            gilhud.x + (70 * scale),
            gilhud.y
        )

        gil_icon:show()

        return

    end

    -- =====================================================
    -- UPDATE VALUES
    -- =====================================================

    update_gil()

    local gil_hour =
        get_gil_per_hour()

    -- =====================================================
    -- SESSION BALANCE
    -- =====================================================

    local balance_text = ''

    if session_balance >= 0 then

        balance_text =
            string.format(
                '\\cs(80,255,80)↑ %s\\cr',
                comma_value(
                    session_balance
                )
            )

    else

        balance_text =
            string.format(
                '\\cs(255,80,80)↓ %s\\cr',
                comma_value(
                    math.abs(
                        session_balance
                    )
                )
            )

    end

    -- =====================================================
    -- MAIN TEXT
    -- =====================================================

    local gil_string =
        comma_value(
            current_gil
        )

    local text =
        string.format(
            '\\cs(255,255,255)%s\\cr',
            gil_string
        )

    -- =====================================================
    -- TOOLTIP
    -- =====================================================

    local tooltip =
        string.format(

            '\\cs(255,255,255)Gil per hour:\\cr\n' ..
            '\\cs(80,255,80)%s/h\\cr\n\n' ..
            '\\cs(255,255,255)Session:\\cr\n%s',

            comma_value(
                math.floor(
                    gil_hour
                )
            ),

            balance_text

        )

    -- =====================================================
    -- DRAW
    -- =====================================================

    gil_text:text(text)

    gil_text:pos(
        gilhud.x,
        gilhud.y - (2 * scale)
    )

    gil_text:show()

    local icon_x =
        gilhud.x +
        (
            string.len(
    gil_string
) * (8 * scale)
        ) +
        (8 * scale)

    gil_icon:pos(
        icon_x,
        gilhud.y
    )

    gil_icon:show()

    -- =====================================================
    -- TOOLTIP HOVER
    -- =====================================================

    if is_hovering() then

        tooltip_text:text(
            tooltip
        )

        tooltip_text:pos(
            gilhud.x,
            gilhud.y - (95 * scale)
        )

        tooltip_text:show()

    else

        tooltip_text:hide()

    end

end

-- =========================================================
-- DESTROY
-- =========================================================

function gilhud.destroy()

    gil_icon:destroy()
    gil_text:destroy()
    tooltip_text:destroy()

end

return gilhud