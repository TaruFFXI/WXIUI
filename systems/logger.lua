local logger = {}

logger.enabled = true

function logger.debug(message)

    if not logger.enabled then
        return
    end

    windower.add_to_chat(
        207,
        '[WXI] ' .. tostring(message)
    )

end

function logger.error(message)

    windower.add_to_chat(
        167,
        '[WXI ERROR] ' ..
        tostring(message)
    )

end

return logger