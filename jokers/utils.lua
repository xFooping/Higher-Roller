-- Shared helpers for High Roller Jokers

function blackjack_sum(cards)
    local total, aces = 0, 0
    for _, c in ipairs(cards) do
        local id = c:get_id()
        if id == 14 then
            aces  = aces + 1
            total = total + 11
        elseif id >= 11 and id <= 13 then
            total = total + 10
        elseif id >= 2 and id <= 10 then
            total = total + id
        end
    end
    while total > 21 and aces > 0 do
        total = total - 10
        aces  = aces  - 1
    end
    return total
end

function baccarat_sum(cards)
    local total = 0
    for _, c in ipairs(cards) do
        local id = c:get_id()
        if id == 14 then
            total = total + 1
        elseif id < 10 then
            total = total + id
        end
        -- 10, J, Q, K = 0, no action needed
    end
    return total % 10
end

function count_joker_chars(joker_card)
    local key = joker_card.config.center.key
    local desc = G.localization.descriptions.Joker[key]
    if not desc or not desc.text then return 0 end

    local count = 0
    for _, line in ipairs(desc.text) do
        local stripped = line:gsub("{[^}]*}", "")  -- strip {C:gold} style tags
        stripped = stripped:gsub("#%d+#", "X")      -- replace #1# #2# etc with single char
        for _ in stripped:gmatch("%S") do           -- count non-space characters
            count = count + 1
        end
    end
    return count
end
