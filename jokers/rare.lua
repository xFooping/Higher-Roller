-- Rare Jokers (Rarity 3)

-- Origami Joker
SMODS.Joker {
    key              = "origami",
    order            = 7,
    atlas            = "hr_jokers",
    pos              = { x = 6, y = 0 },
    rarity           = 3,
    cost             = 8,
    blueprint_compat = true,
    discovered       = true,

    config = { extra = { used_this_round = false } },

    loc_txt = {
        name = "Origami Joker",
        text = {
            "If exactly {C:attention}2 cards{} are played,",
            "destroy the {C:red}right card{} and",
            "add {C:blue}1.5x{} its chips to",
            "the {C:attention}left card{}",
            "{C:inactive}(Once per round)"
        }
    },

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            card.ability.extra.used_this_round = false
        end

        if context.before and not card.ability.extra.used_this_round then
            if G.play and #G.play.cards == 2 then
                local left  = G.play.cards[1]
                local right = G.play.cards[2]

                if left and right then
                    card.ability.extra.used_this_round = true

                    local bonus = math.floor((right.base.nominal or 0) * 1.5)
                    left.ability.bonus = (left.ability.bonus or 0) + bonus

                    SMODS.destroy_cards({ right })
                    card:juice_up(0.3, 0.4)

                    return {
                        message = "+" .. bonus .. " Chips",
                        colour  = G.C.BLUE
                    }
                end
            end
        end
    end
}

-- Natural Nine
SMODS.Joker {
    key              = "naturalnine",
    order            = 10,
    atlas            = "hr_jokers",
    pos              = { x = 9, y = 0 },
    rarity           = 3,
    cost             = 8,
    blueprint_compat = true,
    discovered       = true,

    config = { extra = { xmult = 6 } },

    loc_txt = {
        name = "Natural Nine",
        text = {
            "If scored cards sum to {C:attention}9{}",
            "by Baccarat rules,",
            "gain {X:red,C:white}X#1#{} Mult"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if baccarat_sum(G.play.cards) == 9 then
                return {
                    x_mult  = card.ability.extra.xmult,
                    message = "Natural Nine!",
                    colour  = G.C.GOLD
                }
            end
        end
    end
}

-- The Pit Boss
SMODS.Joker {
    key              = "thepitboss",
    order            = 13,
    atlas            = "hr_jokers",
    pos              = { x = 2, y = 1 },
    rarity           = 3,
    cost             = 8,
    blueprint_compat = true,
    discovered       = true,

    loc_txt = {
        name = "The Pit Boss",
        text = {
            "{X:red,C:white}X#1#{} Mult per",
            "{C:attention}Joker{} owned"
        }
    },

    loc_vars = function(self, info_queue, card)
        local count = G.jokers and math.max(1, #G.jokers.cards) or 1
        return { vars = { count } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local count = G.jokers and math.max(1, #G.jokers.cards) or 1
            return {
                x_mult  = count,
                message = "X" .. count,
                colour  = G.C.RED
            }
        end
    end
}
