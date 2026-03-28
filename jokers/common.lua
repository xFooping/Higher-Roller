-- Common Jokers (Rarity 1)

-- Poker Chip
SMODS.Joker {
    key              = "pokerchip",
    order            = 1,
    atlas            = "hr_jokers",
    pos              = { x = 0, y = 0 },
    rarity           = 1,
    cost             = 4,
    blueprint_compat = true,
    discovered       = true,

    config = { extra = { dollars = 2 } },

    loc_txt = {
        name = "Poker Chip",
        text = {
            "Earn {C:gold}$#1#{} at end of round",
            "per empty {C:attention}Joker{} slot",
            "{C:inactive}why would you think",
            "{C:inactive}this would be a chip joker?"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            local empty_slots = G.jokers.config.card_limit - #G.jokers.cards
            if empty_slots > 0 then
                return {
                    dollars = card.ability.extra.dollars * empty_slots,
                    message = "+$" .. (card.ability.extra.dollars * empty_slots),
                    colour  = G.C.GOLD
                }
            end
        end
    end
}

-- Newdies Joker
SMODS.Joker {
    key              = "newdies",
    order            = 2,
    atlas            = "hr_jokers",
    pos              = { x = 2, y = 0 },
    rarity           = 1,
    blueprint_compat = false,
    cost             = 2,
    discovered       = true,

    config = { extra = { dollars = -3 } },

    loc_txt = {
        name = "Newdies",
        text = {
            "{C:red,s:1.1}This dude stinks like shit",
            "{C:gold,s:1.1}$#1#{} at end of round"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            return { dollars = card.ability.extra.dollars }
        end
    end
}

-- Bookworm Joker
SMODS.Joker {
    key              = "bookworm",
    order            = 3,
    atlas            = "hr_jokers",
    pos              = { x = 1, y = 0 },
    rarity           = 1,
    cost             = 4,
    blueprint_compat = true,
    discovered       = true,

    loc_txt = {
        name = "Bookworm",
        text = {
            "{C:chips}+1 Chip{} per {C:attention}character{}",
            "in each other {C:attention}Joker's{} description",
            "{C:inactive}(spaces not counted)",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)"
        }
    },

    loc_vars = function(self, info_queue, card)
        local total = 0
        if G.jokers then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then
                    total = total + count_joker_chars(j)
                end
            end
        end
        return { vars = { total } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local total = 0
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then
                    total = total + count_joker_chars(j)
                end
            end
            if total > 0 then
                return {
                    chip_mod   = total,
                    message = "+" .. total .. " Chips",
                    colour  = G.C.CHIPS
                }
            end
        end
    end
}
