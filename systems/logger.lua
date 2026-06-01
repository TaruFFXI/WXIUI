local logger = {}

logger.enabled = true

function logger.debug(message)

    if not logger.enabled then
        return
    end

    windower.add_to_chat(
        207,
        '[WXIUI] ' .. tostring(message)
    )

end

function logger.error(message)

    windower.add_to_chat(
        167,
        '[WXIUI ERROR] ' ..
        tostring(message)
    )

end

return logger