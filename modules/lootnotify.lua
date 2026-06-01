local texts =
    require('texts')

local prims =
    require('prims')

local settings =
    require('data/settings')

local function get_scale()
    return settings.lootnotify.scale / 50
end    

local lootnotify = {}

lootnotify.visible = true
lootnotify.preview = false

lootnotify.x = 40
lootnotify.y = 500

local BAR_WIDTH = 185
local BAR_HEIGHT = 18

local DURATION = 5

local MAX_NOTIFICATIONS = 5

local FILL_COLOR = {
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

local notifications = {}

local preview_spawned = false

local function create_rect(
    width,
    height,
    color
)

    return prims.new({

        w = width,
        h = height,

        color = color,

        visible = false

    })

end

-- TEXTO Y BARRAS

function lootnotify.add(text)

    local entry = {}

    local scale = get_scale()

    entry.start_time =
        os.clock()

    entry.text_string =
        text:gsub(
            '[%z\1-\31]',
            ''
        )

    entry.outline =
    create_rect(
        (BAR_WIDTH * scale) + 2,
        (BAR_HEIGHT * scale) + 2,
        OUTLINE
    )

    entry.bg =
    create_rect(
        BAR_WIDTH * scale,
        BAR_HEIGHT * scale,
        BG_COLOR
    )

    entry.fill =
    create_rect(
        BAR_WIDTH * scale,
        BAR_HEIGHT * scale,
        FILL_COLOR
    )

    entry.text =
        texts.new('')

    entry.text:size(
    math.floor(11 * scale)
)

    entry.text:font('Arial')

    entry.text:bold(true)

    entry.text:bg_alpha(0)

    entry.text:stroke_alpha(255)

    entry.text:stroke_width(2)

    entry.text:color(
        255,
        255,
        255
    )

    table.insert(
        notifications,
        1,
        entry
    )

    while
        #notifications >
        MAX_NOTIFICATIONS
    do

        local old =
            table.remove(
                notifications
            )

        old.outline:destroy()
        old.bg:destroy()
        old.fill:destroy()
        old.text:destroy()

    end

end

 -- DETECT

windower.register_event(
    'incoming text',

    function(
        original,
        modified,
        mode
    )

        local player =
            windower.ffxi.get_player()

        if not player then
            return
        end

        local name =
            player.name

        local pattern =
            name ..
            ' obtains '

        if not original:contains(
            pattern
        ) then
            return
        end

        local item =
            original:match(
                'obtains (.+)%.'
            )

        if item then

            lootnotify.add(
                item
            )

        end

            end
        )


function lootnotify.update()

         local scale = get_scale()

    if lootnotify.preview and
   not preview_spawned
then

    preview_spawned = true

    lootnotify.add(
        'LootNotify Preview'
    )

end

if not lootnotify.preview then

    preview_spawned = false

end

    for i = #notifications, 1, -1 do


        local entry =
            notifications[i]

        local elapsed =
            os.clock() -
            entry.start_time

        if elapsed >= DURATION then

            entry.outline:destroy()
            entry.bg:destroy()
            entry.fill:destroy()
            entry.text:destroy()

            table.remove(
                notifications,
                i
            )

        end

    end

    for i, entry in ipairs(
        notifications
    ) do

        local elapsed =
            os.clock() -
            entry.start_time

        local remaining =
            math.max(
                0,
                1 -
                (
                    elapsed /
                    DURATION
                )
            )

        local x =
            lootnotify.x

        local y =
            lootnotify.y +
            (
                (i - 1) * (24 * scale)
            )

        entry.outline:pos(
           x - 1,
           y - 1
        )

        entry.bg:pos(
            x,
            y
        )

        entry.fill:pos(
            x,
            y
        )

        entry.fill:width(
            math.max(
                2,
                (BAR_WIDTH * scale) *
                remaining
            )
        )

        
        entry.text:text(
            entry.text_string
        )

        entry.text:pos(
            x + (8 * scale),
            y - (1 * scale)
        )

        entry.outline:visible(
            true
        )

        entry.bg:visible(
            true
        )

        entry.fill:visible(
            true
        )

        entry.text:show()

    end

end

function lootnotify.destroy()

    for _, entry in ipairs(
        notifications
    ) do

        entry.outline:destroy()
        entry.bg:destroy()
        entry.fill:destroy()
        entry.text:destroy()

    end

end

return lootnotify