-- Fooping Joker
SMODS.Joker {
    key              = "Fooping",
    atlas            = "hr_jokers",
    pos              = { x = 0, y = 0 },
    rarity           = 1,
    blueprint_compat = false,
    cost             = 2,
    discovered       = true,

    config = { extra = { dollars = 3 } },

    loc_txt = {
        name = "Fooping",
        text = {
            "Earn {C:gold}$#1#{} at end of round",
            "Better than Newdies"
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

-- Newdies Joker
SMODS.Joker {
    key              = "newdies",
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

-- The Wizard Joker
SMODS.Joker {
    key              = "thewizard",
    atlas            = "hr_jokers",
    pos              = { x = 1, y = 0 },
    rarity           = 3,
    blueprint_compat = true,
    cost             = 6,
    discovered       = true,

    config = { extra = { xmult = 3 } },

    loc_txt = {
        name = "The Wizard",
        text = {
            "Each scored {C:attention}Ace{}",
            "gives {X:red,C:white}X#1#{} Mult"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 14 then
                return { x_mult = card.ability.extra.xmult }
            end
        end
    end
}

-- Rusty Blade Joker
-- FIX: atlas was "jokers", changed to "hr_jokers"
SMODS.Joker {
    key              = "rustyblade",
    atlas            = "hr_jokers",
    pos              = { x = 3, y = 0 },
    rarity           = 2,
    cost             = 6,
    blueprint_compat = true,
    discovered       = true,

    config = { extra = { mult = 0, gain = 2 } },

    loc_txt = {
        name = "Rusty Blade",
        text = {
            "Discarding a {C:attention}Face Card{}",
            "permanently gains {C:red}+#2#{} Mult",
            "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.gain } }
    end,

    calculate = function(self, card, context)
        if context.discard and context.other_card then
            if context.other_card:is_face() then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.gain
                return {
                    message = "Sharpened!",
                    colour  = G.C.RED
                }
            end
        end

        if context.joker_main then
            return { mult = card.ability.extra.mult }
        end
    end
}

-- Lucky Clover Joker
SMODS.Joker {
    key              = "luckyclover",
    atlas            = "hr_jokers",
    pos              = { x = 4, y = 0 },
    rarity           = 2,
    cost             = 6,
    blueprint_compat = true,
    discovered       = true,

    config = { extra = { odds = 4, dollars = 2 } },

    loc_txt = {
        name = "Lucky Clover",
        text = {
            "Each scored {C:clubs}Club{} has a",
            "{C:green}1 in #1#{} chance to give {C:gold}+$#2#{}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.odds, card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit("Clubs") then
                if pseudorandom("luckyclover") < G.GAME.probabilities.normal / card.ability.extra.odds then
                    return {
                        dollars = card.ability.extra.dollars,
                        message = "+$" .. card.ability.extra.dollars,
                        colour  = G.C.GOLD
                    }
                end
            end
        end
    end
}

-- Time Bomb Joker
SMODS.Joker {
    key              = "timebomb",
    atlas            = "timebomb",
    pos              = { x = 0, y = 0 },
    rarity           = 2,
    cost             = 7,
    blueprint_compat = true,
    discovered       = true,

    config = { extra = { hands = 0, trigger = 3, dollars = 6 } },

    loc_txt = {
        name = "Time Bomb",
        text = {
            "Every {C:attention}#2#{} hands played,",
            "destroy a random card in deck",
            "and gain {C:gold}+$#3#{}",
            "{C:inactive}(#1#/#2#)"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.hands,
            card.ability.extra.trigger,
            card.ability.extra.dollars
        }}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.hands = card.ability.extra.hands + 1

            if card.ability.extra.hands >= card.ability.extra.trigger then
                card.ability.extra.hands = 0

                if G.deck and #G.deck.cards > 0 then
                    local destroyed = pseudorandom_element(G.deck.cards, pseudoseed('timebomb'))
                    destroyed:start_dissolve()
                end

                return {
                    dollars = card.ability.extra.dollars,
                    message = "BOOM!",
                    colour  = G.C.RED
                }
            end
        end
    end
}

-- Origami Joker
-- FIX: perma_bonus is not a real Balatro field. Changed to card.ability.bonus
--      which is what the game actually reads during chip scoring.
SMODS.Joker {
    key              = "origami",
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

-- Roulette Joker
-- FIX: atlas was "jokers", changed to "hr_jokers"
SMODS.Joker {
    key              = "roulette",
    atlas            = "hr_jokers",
    pos              = { x = 7, y = 0 },
    rarity           = 2,
    cost             = 6,
    blueprint_compat = false,
    discovered       = true,

    loc_txt = {
        name = "Roulette Joker",
        text = {
            "At {C:attention}end of round{},",
            "{C:green}#1# in 8{} chance to {C:gold}double{} money,",
            "otherwise lose {C:red}$5{}"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal or 1 } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            if pseudorandom("roulette") < G.GAME.probabilities.normal / 8 then
                ease_dollars(G.GAME.dollars)
                return {
                    message = "JACKPOT!",
                    colour  = G.C.GOLD
                }
            else
                ease_dollars(-5)
                return {
                    message = "-$5",
                    colour  = G.C.RED
                }
            end
        end
    end
}