local images = require('images')
local texts = require('texts')

local partyinvite = {}

partyinvite.visible = false
partyinvite.sender = ''
partyinvite.show_time = 0
partyinvite.preview = false
partyinvite.sender = ''

local background
local title_text
local invite_text
local yes_text
local no_text

partyinvite.x = 800
partyinvite.y = 420

function partyinvite.initialize()

    background =
        images.new()

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

    title_text =
        texts.new('')

    title_text:size(14)

    title_text:bold(true)

    title_text:bg_visible(false)

    title_text:hide()

    invite_text =
        texts.new('')

    invite_text:size(11)

    invite_text:bg_visible(false)

    invite_text:hide()

    yes_text =
        texts.new('')

    yes_text:size(12)

    yes_text:bold(true)

    yes_text:color(
    255,
    170,
    220
)

    yes_text:bg_visible(false)

    yes_text:hide()

    no_text =
        texts.new('')

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

function partyinvite.update()

    if partyinvite.visible and
       os.time() - partyinvite.show_time > 60
    then

        partyinvite.visible = false

        return

    end

if not partyinvite.visible and
   not partyinvite.preview
then

    background:hide()
    title_text:hide()
    invite_text:hide()
    yes_text:hide()
    no_text:hide()

    return

end

    background:pos(
        partyinvite.x,
        partyinvite.y
    )

    background:show()

    title_text:text(
        'Party Invitation'
    )

    title_text:pos(
        partyinvite.x + 115,
        partyinvite.y + 4
    )

    title_text:show()

    invite_text:text(
        partyinvite.sender ..
    ' invites you to a party. Accept?'
)

    invite_text:pos(
        partyinvite.x + 20,
        partyinvite.y + 42
    )

    invite_text:show()

    yes_text:text(
        '[ YES ]'
    )

    yes_text:pos(
        partyinvite.x + 90,
        partyinvite.y + 80
    )

    yes_text:show()

    no_text:text(
        '[ NO ]'
    )

    no_text:pos(
        partyinvite.x + 240,
        partyinvite.y + 80
    )

    no_text:show()

end

function partyinvite.destroy()

    background:destroy()

    title_text:destroy()

    invite_text:destroy()

    yes_text:destroy()

    no_text:destroy()

end

function partyinvite.click(x, y)

    if not partyinvite.visible and
       not partyinvite.preview
    then
        return false
    end

   -- YES

if x >= partyinvite.x + 90 and
   x <= partyinvite.x + 160 and
   y >= partyinvite.y + 80 and
   y <= partyinvite.y + 105
then

    windower.send_command(
        'input /join'
    )

    partyinvite.visible = false
    partyinvite.sender = ''

    return true

end

    -- NO

if x >= partyinvite.x + 240 and
   x <= partyinvite.x + 300 and
   y >= partyinvite.y + 80 and
   y <= partyinvite.y + 105
then

    windower.send_command(
        'input /decline'
    )

    partyinvite.visible = false
    partyinvite.sender = ''

    return true

end

return false

end

return partyinvite