-- Legendary/Special Jokers (Rarity 4)

-- Ouroboros
SMODS.Joker {
    key              = "ouroboros",
    order            = 17,
    atlas            = "hr_jokers",
    pos              = { x = 6, y = 1 },
    rarity           = 4,
    cost             = 20,
    blueprint_compat = false,
    discovered       = true,

    config = { extra = { xmult = 10, base = 10, decay = 0.5 } },

    loc_txt = {
        name = "Ouroboros",
        text = {
            "{X:red,C:white}X#1#{} Mult",
            "Loses {C:attention}X#2#{} each hand played",
            "When it hits {C:attention}X1{}, {C:green}rebirth{}:",
            "restart at {X:red,C:white}X#3#{} Mult,",
            "double {C:attention}starting value{} and {C:red}decay{}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = {
            string.format("%.1f", card.ability.extra.xmult),
            string.format("%.1f", card.ability.extra.decay),
            string.format("%.0f", card.ability.extra.base * 2)
        }}
    end,

    calculate = function(self, card, context)
        if context.joker_main and not context.blueprint then
            local current  = card.ability.extra.xmult
            local next_val = current - card.ability.extra.decay

            if next_val <= 1 then
                card.ability.extra.base  = card.ability.extra.base  * 2
                card.ability.extra.decay = card.ability.extra.decay * 2
                card.ability.extra.xmult = card.ability.extra.base
                card:juice_up(0.8, 0.8)
                return {
                    Xmult_mod = current,
                    message   = "REBORN!",
                    colour    = G.C.GOLD
                }
            end

            card.ability.extra.xmult = next_val
            return {
                Xmult_mod = current,
                message   = "X" .. string.format("%.1f", current),
                colour    = G.C.RED
            }
        end
    end
}

-- The Pot (Special Creation)
SMODS.Joker {
    key              = "thepot",
    order            = 14,
    atlas            = "hr_jokers",
    pos              = { x = 3, y = 1 },
    rarity           = 4,
    cost             = 0,
    blueprint_compat = true,
    discovered       = false,

    config = { extra = { xmult = 1 } },

    loc_txt = {
        name = "The Pot",
        text = {
            "{X:red,C:white}X#1#{} Mult",
            "{C:inactive}(Created by {C:spectral}All In{C:inactive})"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    in_pool = function(self, args)
        return false
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult  = card.ability.extra.xmult,
                message = "X" .. card.ability.extra.xmult,
                colour  = G.C.RED
            }
        end
    end
}
