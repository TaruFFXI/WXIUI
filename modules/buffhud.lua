local images = require('images')
local texts = require('texts')
local settings =
    require('data/settings')
local res = require('resources')

local bufftracker =
    require('systems/bufftracker')

local buffhud = {}
local current_buff_ids = {}

buffhud.visible = true

local buff_icons = {}

-- PREVIEW MODE
buffhud.preview = false

-- PUBLIC ANCHORS
buffhud.x = 800
buffhud.y = 980
local function get_scale()

    return
        settings.buffhud.scale / 50

end

-- MOUSE
buffhud.mouse_x = 0
buffhud.mouse_y = 0

local ICON_SIZE = 20
local ICON_SPACING = 24

-- TOOLTIP
local tooltip = texts.new('')

tooltip:size(10)
tooltip:font('Arial')
tooltip:color(255, 255, 255)
tooltip:stroke_color(0, 0, 0)
tooltip:stroke_width(2)
tooltip:bg_alpha(180)
tooltip:hide()

function buffhud.initialize()

    for i = 1, 16 do

        local icon = images.new()

        icon:hide()

        buff_icons[i] = icon

    end

end

function buffhud.update()

    if not buffhud.visible then

        tooltip:hide()

        for i = 1, 16 do

            buff_icons[i]:hide()

        end

        return

    end

    local scale =
    get_scale()

local icon_size =
    ICON_SIZE * scale

local icon_spacing =
    ICON_SPACING * scale

    local player =
        windower.ffxi.get_player()

    -- PREVIEW MODE
    if buffhud.preview then

        tooltip:hide()

        for i = 1, 16 do

            local icon = buff_icons[i]

            local x =
                buffhud.x +
                ((i - 1) * icon_spacing)

            local y = buffhud.y

            icon:path(
                windower.addon_path ..
                'assets/textures/buff.png'
            )

            icon:size(
    icon_size,
    icon_size
)

            icon:pos(x, y)

            icon:show()

        end

    for i = 1, 16 do
    current_buff_ids[i] = nil
end     

        return

    end

    if not player then
        return
    end

    local buffs = player.buffs

    local hovering = false

    for i = 1, 16 do

        local icon = buff_icons[i]

        local buff_id = buffs[i]

        if buff_id then

            local x =
                buffhud.x +
                ((i - 1) * icon_spacing)

            local y = buffhud.y

            local icon_path =
                windower.addon_path ..
                'assets/icons/' ..
                tostring(buff_id) ..
                '.png'

            if current_buff_ids[i] ~= buff_id then

    current_buff_ids[i] = buff_id

    icon:path(icon_path)

end

            icon:size(
                icon_size,
                icon_size
            )

            icon:pos(x, y)

            icon:show()

            -- TOOLTIP
            if buffhud.mouse_x >= x and
               buffhud.mouse_x <= x + icon_size and
               buffhud.mouse_y >= y and
               buffhud.mouse_y <= y + icon_size then

                local buff =
                    res.buffs[buff_id]

                local buff_name =
                    buff and buff.en
                    or 'Unknown Buff'

                local tooltip_text =
                    buff_name

                local remaining =
                    tonumber(
                        bufftracker.get_remaining(
                            buff_id
                        )
                    )

                if remaining ~= nil and
                   remaining > 0 then

                    remaining = math.max(
                        math.floor(remaining),
                        0
                    )

                    local hours =
                        math.floor(
                            remaining / 3600
                        )

                    local minutes =
                        math.floor(
                            (remaining % 3600) / 60
                        )

                    local seconds =
                        math.floor(
                            remaining % 60
                        )

                    local time_text = ''

                    if hours > 0 then

                        time_text = string.format(
                            '%d:%02d:%02d',
                            hours,
                            minutes,
                            seconds
                        )

                    else

                        time_text = string.format(
                            '%02d:%02d',
                            minutes,
                            seconds
                        )

                    end

                    tooltip_text =
                        tooltip_text ..
                        '\n' ..
                        time_text

                end

                tooltip:text(
                    tooltip_text
                )

                tooltip:pos(
                    buffhud.mouse_x + 16,
                    buffhud.mouse_y + 16
                )

                tooltip:show()

                hovering = true

            end

        else

            current_buff_ids[i] = nil

            icon:hide()

        end

    end

    if not hovering then
        tooltip:hide()
    end

end

function buffhud.destroy()

    tooltip:destroy()

    for i = 1, 16 do

        buff_icons[i]:destroy()

    end

end

return buffhud