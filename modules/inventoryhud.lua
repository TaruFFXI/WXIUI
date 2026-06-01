local texts =
    require('texts')

local prims =
    require('prims')

local settings = require('data/settings')  
local function get_scale()
    return settings.inventoryhud.scale / 50
end  

local inventoryhud = {}

inventoryhud.visible = true
inventoryhud.preview = false

inventoryhud.x = 1500
inventoryhud.y = 180

local inventory_text
local tooltip_text

local bar_bg
local bar_fill

local mouse_x = 0
local mouse_y = 0

local bag_names = {
    'inventory',
    'safe',
    'storage',
    'locker',
    'satchel',
    'sack',
    'case',
    'wardrobe',
    'wardrobe2',
    'wardrobe3',
    'wardrobe4',
    'wardrobe5',
    'wardrobe6',
    'wardrobe7',
    'wardrobe8'
}

local display_names = {
    inventory = 'Inventory',
    safe = 'Safe',
    storage = 'Storage',
    locker = 'Locker',
    satchel = 'Satchel',
    sack = 'Sack',
    case = 'Case',
    wardrobe = 'Wardrobe',
    wardrobe2 = 'Wardrobe2',
    wardrobe3 = 'Wardrobe3',
    wardrobe4 = 'Wardrobe4',
    wardrobe5 = 'Wardrobe5',
    wardrobe6 = 'Wardrobe6',
    wardrobe7 = 'Wardrobe7',
    wardrobe8 = 'Wardrobe8'
}

-- =========================================================
-- BAR SETTINGS
-- =========================================================

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
-- HOVER
-- =========================================================

local function is_hovering()

    local scale = get_scale()

    return

        mouse_x >= inventoryhud.x and
        mouse_x <= inventoryhud.x + (100 * scale) and

        mouse_y >= inventoryhud.y and
        mouse_y <= inventoryhud.y + (24 * scale)

end

-- =========================================================
-- INITIALIZE
-- =========================================================

function inventoryhud.initialize()

    local scale = get_scale()

local bar_width = 90 * scale
local bar_height = math.max(2, 4 * scale)

    inventory_text =
        texts.new('')

    inventory_text:size(math.floor(10 * scale))

    inventory_text:font(
        'Arial'
    )

    inventory_text:bold(true)

    inventory_text:stroke_width(2)

    inventory_text:stroke_color(
        0,
        0,
        0
    )

    inventory_text:bg_alpha(0)

    inventory_text:hide()

    -- TOOLTIP

    tooltip_text =
        texts.new('')

    tooltip_text:size(math.floor(9 * scale))

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

    -- BAR

    bar_bg =
        create_rect(

    bar_width,
    bar_height,

            {
                255,
                15,
                25,
                45
            }

        )

    bar_fill =
        create_rect(

    bar_width,
    bar_height,

            {
                255,
                70,
                170,
                255
            }

        )

    -- MOUSE

    windower.register_event(

        'mouse',

        function(type, x, y)

            mouse_x = x
            mouse_y = y

        end

    )

end

-- =========================================================
-- UPDATE
-- =========================================================

function inventoryhud.update()

    local scale = get_scale()

inventory_text:size(
    math.floor(10 * scale)
)

tooltip_text:size(
    math.floor(9 * scale)
)

local bar_width = 90 * scale
local bar_height = math.max(2, 4 * scale)    

    if not inventoryhud.visible then

        inventory_text:hide()
        tooltip_text:hide()

        bar_bg:visible(false)
        bar_fill:visible(false)

        return

    end

    local current
    local max

    local bags =
        windower.ffxi.get_bag_info()

    if not bags then
        return
    end

    -- =====================================================
    -- PREVIEW
    -- =====================================================

    if inventoryhud.preview then

        current = 73
        max = 80

    else

        if not bags.inventory then
            return
        end

        current =
            bags.inventory.count

        max =
            bags.inventory.max

    end

    local ratio =
        current / max

    local remaining =
        max - current

    -- =====================================================
    -- COLORS
    -- =====================================================

    local color =
        '\\cs(70,170,255)'

    local bar_color = {
        255,
        70,
        170,
        255
    }

    if remaining <= 5 then

        color =
            '\\cs(255,80,80)'

        bar_color = {
            255,
            255,
            80,
            80
        }

    elseif remaining <= 10 then

        color =
            '\\cs(255,220,0)'

        bar_color = {
            255,
            255,
            220,
            0
        }

    end

    -- =====================================================
    -- MAIN TEXT
    -- =====================================================

    local text =
        color ..
        current ..
        '/' ..
        max ..
        '\\cr'

    inventory_text:text(text)

    inventory_text:pos(
        inventoryhud.x,
        inventoryhud.y
    )

    inventory_text:show()

    -- =====================================================
    -- BAR
    -- =====================================================
    bar_bg:size(
    bar_width,
    bar_height
)

bar_fill:size(
    bar_width,
    bar_height
)

    bar_bg:pos(
        inventoryhud.x,
        inventoryhud.y + (18 * scale)
    )

    bar_bg:visible(true)

    bar_fill:color(bar_color)

    bar_fill:pos(
        inventoryhud.x,
        inventoryhud.y + (18 * scale)
    )

    bar_fill:width(
        bar_width * ratio
    )

    bar_fill:visible(true)

    -- =====================================================
    -- TOOLTIP
    -- =====================================================

    if is_hovering() then

        local tooltip =
            ''

        for _, bag in ipairs(
            bag_names
        ) do

            if bags[bag] then

                tooltip =
                    tooltip ..

                    string.format(

                        '\\cs(255,255,255)%s\\cr  %d/%d\n',

                        display_names[bag],

                        bags[bag].count,

                        bags[bag].max

                    )

            end

        end

        tooltip_text:text(
            tooltip
        )

        local lines =
    #bag_names

local tooltip_y =
    inventoryhud.y -
    (
        lines * (14 * scale)
    ) - (20 * scale)

tooltip_text:pos(
    inventoryhud.x,
    tooltip_y
)

        tooltip_text:show()

    else

        tooltip_text:hide()

    end

end

-- =========================================================
-- DESTROY
-- =========================================================

function inventoryhud.destroy()

    inventory_text:destroy()
    tooltip_text:destroy()

    bar_bg:destroy()
    bar_fill:destroy()

end

return inventoryhud