SMODS.Consumable {
    set        = 'Spectral',
    key        = 'all_in',
    atlas      = 'hr_consumables',
    pos        = { x = 0, y = 0 },
    cost       = 4,
    discovered = true,

    loc_txt = {
        name = 'All In',
        text = {
            "Destroy all {C:attention}Jokers{}.",
            "Create {C:attention}The Pot{}, a Joker with",
            "{X:red,C:white}X Mult{} equal to their",
            "combined {C:gold}sell value{}"
        }
    },

    can_use = function(self, card)
        return #G.jokers.cards > 0
    end,

    use = function(self, card, area, copier)
        -- Lock in sell value BEFORE destruction
        local total_value = 0
        for _, j in ipairs(G.jokers.cards) do
            total_value = total_value + (j.sell_cost or math.floor((j.cost or 4) / 2))
        end
        total_value = math.max(1, total_value)

        -- Collect references before the list changes
        local to_destroy = {}
        for _, j in ipairs(G.jokers.cards) do
            table.insert(to_destroy, j)
        end

        -- Destroy all jokers
        SMODS.destroy_cards(to_destroy)

        -- Create The Pot after the dissolve animations finish
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay   = 0.8,
            func    = function()
                local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_hr_thepot')
                new_joker.ability.extra.xmult = total_value
                new_joker:add_to_deck()
                G.jokers:emplace(new_joker)
                new_joker:juice_up(0.5, 0.5)
                return true
            end
        }))
    end
}