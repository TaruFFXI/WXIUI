local spellparser = {}

-- NORMALIZE
function spellparser.parse(info)

    if not info then
        return nil
    end

    local result = {
        buffs = {}
    }

    -- FORMAT:
    -- { buff_id, duration }
    if type(info[1]) == 'number' then

        table.insert(
            result.buffs,
            {
                id = info[1],
                duration = info[2]
            }
        )

        return result

    end

    -- FORMAT:
    -- {
    --   { buff_id, duration },
    --   { buff_id, duration }
    -- }
    if type(info[1]) == 'table' then

        for _, entry in pairs(info) do

            if type(entry) == 'table' then

                table.insert(
                    result.buffs,
                    {
                        id = entry[1],
                        duration = entry[2]
                    }
                )

            end

        end

        return result

    end

    return nil

end

return spellparser