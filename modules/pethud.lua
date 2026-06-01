local texts =
    require('texts')

local images =
    require('images')

local packets =
    require('packets')

local settings =
    require('data/settings')

local function get_scale()
    return settings.pethud.scale / 50
end    

local pethud = {}

pethud.visible = true
pethud.preview = false

pethud.x = 640
pethud.y = 820

local background
local hp_bar
local hp_bg
local tp_bar
local tp_bg

local name_text
local hp_text
local tp_text

local pet_tp = 0
local pet = nil

-- =========================================================
-- COLORS
-- =========================================================

local COLORS = {

    background = {
        42, 48, 60
    },

    hp = {
        230, 140, 190
    },

    hp_bg = {
        15, 25, 45
    },

    tp = {
        170, 220, 255
    },

    tp_bg = {
        15, 25, 45
    }
    

}

-- =========================================================
-- HELPERS
-- =========================================================

local function clamp(value, min, max)

    if value < min then
        return min
    end

    if value > max then
        return max
    end

    return value

end

-- =========================================================
-- HIDE
-- =========================================================

local function hide()

    background:hide()

    hp_bg:hide()
    hp_bar:hide()

    tp_bg:hide()
    tp_bar:hide()

    name_text:hide()
    hp_text:hide()
    tp_text:hide()


end

-- =========================================================
-- INITIALIZE
-- =========================================================

function pethud.initialize()

    local scale = get_scale()

    -- BACKGROUND

    background =
        images.new()

    background:color(
        unpack(
            COLORS.background
        )
    )

    background:alpha(210)

    background:size(
    230 * scale,
    50 * scale
)

    background:hide()

    -- HP BG

    hp_bg =
        images.new()

    hp_bg:color(
        unpack(
            COLORS.hp_bg
        )
    )

    hp_bg:alpha(220)

    hp_bg:size(
        160 * scale,
        10 * scale
    )

    hp_bg:hide()

    -- HP BAR

    hp_bar =
        images.new()

    hp_bar:color(
        unpack(
            COLORS.hp
        )
    )

    hp_bar:alpha(255)

    hp_bar:size(
        160 * scale,    
        10 * scale
    )

    hp_bar:hide()

    -- TP BG

    tp_bg =
        images.new()

    tp_bg:color(
        unpack(
            COLORS.tp_bg
        )
    )

    tp_bg:alpha(220)

    tp_bg:size(
        160 * scale,
        10 * scale
    )

    tp_bg:hide()

    -- TP BAR

    tp_bar =
        images.new()

    tp_bar:color(
        unpack(
            COLORS.tp
        )
    )

    tp_bar:alpha(255)

    tp_bar:size(
        160 * scale,
        10 * scale
    )

    tp_bar:hide()

    -- NAME

    name_text =
        texts.new('')
    name_text:bg_visible(false)

    name_text:size(
    math.floor(10 * scale)
)

    -- HP TEXT

    hp_text =
        texts.new('')

    hp_text:size(
    math.floor(9 * scale)
)

    hp_text:font(
        'Arial'
    )

    hp_text:bold(true)

    hp_text:stroke_width(2)

    hp_text:bg_alpha(0)

    hp_text:hide()

    -- TP TEXT

    tp_text =
        texts.new('')

    tp_text:size(
    math.floor(9 * scale)
)

    tp_text:font(
        'Arial'
    )

    tp_text:bold(true)

    tp_text:stroke_width(2)

    tp_text:bg_alpha(0)

    tp_text:hide()

end

-- =========================================================
-- UPDATE
-- =========================================================

function pethud.update()

    local scale = get_scale()

local bg_width = 230 * scale
local bg_height = 50 * scale

local bar_width = 160 * scale
local hp_bar_height = 10 * scale
local tp_bar_height = 8 * scale

    background:size(
    bg_width,
    bg_height
)

hp_bg:size(
    bar_width,
    hp_bar_height
)

tp_bg:size(
    bar_width,
    tp_bar_height
)

name_text:size(
    math.floor(10 * scale)
)

hp_text:size(
    math.floor(9 * scale)
)

tp_text:size(
    math.floor(9 * scale)
)

    if not pethud.visible then

        hide()

        return

    end

    -- =====================================================
    -- PREVIEW
    -- =====================================================

    if pethud.preview then

        background:pos(
            pethud.x,
            pethud.y
        )

        background:show()

        hp_bg:pos(
            pethud.x + (10 * scale),
            pethud.y + (20 * scale)
        )

        hp_bg:show()

        hp_bar:pos(
            pethud.x + (10 * scale),
            pethud.y + (20 * scale)
        )

        hp_bar:size(
            160 * scale,
            10 * scale
        )

        hp_bar:show()

        tp_bg:pos(
            pethud.x + (10 * scale),
            pethud.y + (34 * scale)
        )

        tp_bg:show()

        tp_bar:pos(
            pethud.x + (10 * scale),
            pethud.y + (34 * scale)
        )

        tp_bar:size(
    bar_width,
    tp_bar_height
)

        tp_bar:show()

        name_text:text(
            'Carbuncle'
        )

        name_text:pos(
    pethud.x + (10 * scale),
    pethud.y + (2 * scale)
)

        name_text:show()

        hp_text:text(
            '100%'
        )

        hp_text:pos(
    pethud.x + (175 * scale),
    pethud.y + (16 * scale)
)

        hp_text:show()

        tp_text:text(
            '1240 TP'
        )

        tp_text:pos(
    pethud.x + (175 * scale),
    pethud.y + (31 * scale)
)

        tp_text:show()

        return

    end

    -- =====================================================
    -- PET
    -- =====================================================

    pet =
        windower.ffxi.get_mob_by_target(
            'pet'
        )

    if not pet then

        hide()

        return

    end

    local hp_percent =
        clamp(
            pet.hpp or 0,
            0,
            100
        )

    local tp =
        pet_tp

    local hp_width =
    math.floor(
        bar_width *
        (hp_percent / 100)
    )

    local tp_width =
    math.floor(
        bar_width *
        (tp / 3000)
    )

    -- =====================================================
    -- DRAW
    -- =====================================================

    background:pos(
        pethud.x,
        pethud.y
    )

    background:show()

    -- HP

    hp_bg:pos(
    pethud.x + (10 * scale),
    pethud.y + (20 * scale)
)

    hp_bg:show()

    hp_bar:pos(
    pethud.x + (10 * scale),
    pethud.y + (20 * scale)
)

    hp_bar:size(
    hp_width,
    hp_bar_height
)

    hp_bar:show()

    -- TP

    tp_bg:show()

    tp_bg:pos(
    pethud.x + (10 * scale),
    pethud.y + (34 * scale)
)
    tp_bar:pos(
    pethud.x + (10 * scale),
    pethud.y + (34 * scale)
)

    tp_bar:size(
    tp_width,
    tp_bar_height
)

    tp_bar:show()

    -- TEXT

    name_text:text(
        pet.name
    )

    name_text:pos(
    pethud.x + (10 * scale),
    pethud.y + (2 * scale)
)

    name_text:show()

    hp_text:text(
        string.format(
            '%d%%',
            hp_percent
        )
    )

    hp_text:pos(
    pethud.x + (175 * scale),
    pethud.y + (16 * scale)
)

    hp_text:show()

    tp_text:text(
        string.format(
            '%d TP',
            tp
        )
    )

    tp_text:pos(
    pethud.x + (175 * scale),
    pethud.y + (31 * scale)
)

    tp_text:show()

end

-- =========================================================
-- DESTROY
-- =========================================================

function pethud.destroy()

    background:destroy()

    hp_bg:destroy()
    hp_bar:destroy()

    tp_bg:destroy()
    tp_bar:destroy()

    name_text:destroy()
    hp_text:destroy()
    tp_text:destroy()

end

-- =========================================================
-- PET TP
-- =========================================================

windower.register_event(
    'incoming chunk',

    function(id, data)

        if id ~= 0x67 and
           id ~= 0x68
        then
            return
        end

        local packet =
            packets.parse(
                'incoming',
                data
            )

        if not packet then
            return
        end

        local pet =
            windower.ffxi.get_mob_by_target(
                'pet'
            )

        if not pet then
            pet_tp = 0
            return
        end

        local packet_pet_index =
            packet['Pet Index']

        if packet_pet_index and
           packet_pet_index ==
           pet.index
        then

            pet_tp =
                packet['Pet TP'] or 0

        end

    end
)

return pethud
