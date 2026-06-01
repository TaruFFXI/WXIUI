local images = require('images')
local texts = require('texts')
local packets = require('packets')
require('pack')

local tradeinvite = {}

tradeinvite.visible = false
tradeinvite.trader = ''
tradeinvite.show_time = 0
tradeinvite.preview = false

local background
local title_text
local invite_text
local yes_text
local no_text

tradeinvite.x = 800
tradeinvite.y = 420

function tradeinvite.initialize()

    background = images.new()

    background:color(
        15,
        25,
        45
    )

    background:alpha(220)

    background:size(
        370,
        120
    )

    background:hide()

    title_text = texts.new('')

    title_text:size(14)
    title_text:bold(true)
    title_text:bg_visible(false)
    title_text:hide()

    invite_text = texts.new('')

    invite_text:size(11)
    invite_text:bg_visible(false)
    invite_text:hide()

    yes_text = texts.new('')

    yes_text:size(12)
    yes_text:bold(true)

    yes_text:color(
        255,
        170,
        220
    )

    yes_text:bg_visible(false)
    yes_text:hide()

    no_text = texts.new('')

    no_text:size(12)
    no_text:bold(true)

    no_text:color(
        170,
        220,
        255
    )

    no_text:bg_visible(false)
    no_text:hide()

end

function tradeinvite.update()

    if tradeinvite.visible and
       os.time() - tradeinvite.show_time > 60
    then

        tradeinvite.visible = false

        return

    end

    if not tradeinvite.visible and
       not tradeinvite.preview
    then

        background:hide()
        title_text:hide()
        invite_text:hide()
        yes_text:hide()
        no_text:hide()

        return

    end

    background:pos(
        tradeinvite.x,
        tradeinvite.y
    )

    background:show()

    title_text:text(
        'Trade Request'
    )

    title_text:pos(
        tradeinvite.x + 125,
        tradeinvite.y + 4
    )

    title_text:show()

    invite_text:text(
        tradeinvite.trader ..
        ' wants to trade with you. Accept?'
    )

    invite_text:pos(
        tradeinvite.x + 20,
        tradeinvite.y + 42
    )

    invite_text:show()

    yes_text:text(
        '[ YES ]'
    )

    yes_text:pos(
        tradeinvite.x + 90,
        tradeinvite.y + 80
    )

    yes_text:show()

    no_text:text(
        '[ NO ]'
    )

    no_text:pos(
        tradeinvite.x + 240,
        tradeinvite.y + 80
    )

    no_text:show()

end

function tradeinvite.destroy()

    background:destroy()
    title_text:destroy()
    invite_text:destroy()
    yes_text:destroy()
    no_text:destroy()

end

function tradeinvite.click(x, y)

    if not tradeinvite.visible and
       not tradeinvite.preview
    then
        return false
    end

    -- YES

    if x >= tradeinvite.x + 90 and
       x <= tradeinvite.x + 160 and
       y >= tradeinvite.y + 80 and
       y <= tradeinvite.y + 105
    then

        windower.packets.inject_outgoing(
            0x33,
            'I3':pack(
                0x633,
                0,
                0
            )
         )

        tradeinvite.visible = false
        tradeinvite.trader = ''

        return true

    end

    -- NO

    if x >= tradeinvite.x + 240 and
       x <= tradeinvite.x + 300 and
       y >= tradeinvite.y + 80 and
       y <= tradeinvite.y + 105
    then

        tradeinvite.visible = false
        tradeinvite.trader = ''

        return true

    end

    return false

end

return tradeinvite