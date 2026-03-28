-- Uncommon Jokers (Rarity 2)

-- Rusty Blade Joker
SMODS.Joker {
    key              = "rustyblade",
    order            = 4,
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
    order            = 5,
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
    order            = 6,
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

-- Roulette Joker
SMODS.Joker {
    key              = "roulette",
    order            = 8,
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

-- The Dealer
SMODS.Joker {
    key              = "thedealer",
    order            = 9,
    atlas            = "hr_jokers",
    pos              = { x = 8, y = 0 },
    rarity           = 2,
    cost             = 7,
    blueprint_compat = true,
    discovered       = true,

    config = { extra = { xmult = 4 } },

    loc_txt = {
        name = "The Dealer",
        text = {
            "If scored cards sum to exactly",
            "{C:attention}21{} by Blackjack rules,",
            "gain {X:red,C:white}X#1#{} Mult"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            if blackjack_sum(G.play.cards) == 21 then
                return {
                    x_mult  = card.ability.extra.xmult,
                    message = "Blackjack!",
                    colour  = G.C.GOLD
                }
            end
        end
    end
}

-- The Natural
SMODS.Joker {
    key              = "thenatural",
    order            = 11,
    atlas            = "hr_jokers",
    pos              = { x = 0, y = 1 },
    rarity           = 2,
    cost             = 6,
    blueprint_compat = false,
    discovered       = true,

    config = { extra = { chips = 0, clean = true } },

    loc_txt = {
        name = "The Natural",
        text = {
            "If {C:attention}no discards{} are used,",
            "permanently gain {C:chips}+50 Chips{}",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.discard and context.other_card then
            card.ability.extra.clean = false
        end

        if context.end_of_round and context.main_eval then
            local was_clean = card.ability.extra.clean
            card.ability.extra.clean = true  -- reset for next round regardless

            if was_clean then
                card.ability.extra.chips = card.ability.extra.chips + 50
                return {
                    message = "+50 Chips",
                    colour  = G.C.CHIPS
                }
            end
        end

        if context.joker_main and card.ability.extra.chips > 0 then
            return { chips = card.ability.extra.chips }
        end
    end
}

-- One Armed Bandit
SMODS.Joker {
    key              = "onearmedbandit",
    order            = 12,
    atlas            = "hr_jokers",
    pos              = { x = 1, y = 1 },
    rarity           = 2,
    cost             = 6,
    blueprint_compat = false,
    discovered       = true,

    config = { extra = { mult = 0 } },

    loc_txt = {
        name = "One Armed Bandit",
        text = {
            "At end of round, pull the lever:",
            "{C:green}1 in 2{}: {C:gold}+$8{}",
            "{C:green}1 in 4{}: {C:red}+4 Mult{} permanently",
            "{C:green}1 in 8{}: {C:attention}Enhancement{} on random card",
            "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)"
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            local roll = pseudorandom("hr_bandit")

            if roll < 0.5 then
                return {
                    dollars = 8,
                    message = "[ $ $ $ ]",
                    colour  = G.C.GOLD
                }

            elseif roll < 0.75 then
                card.ability.extra.mult = card.ability.extra.mult + 4
                return {
                    message = "[ M M M ]",
                    colour  = G.C.RED
                }

            elseif roll < 0.875 then
                local enhancements = {
                    'm_bonus', 'm_mult', 'm_glass',
                    'm_steel', 'm_stone', 'm_gold',
                    'm_lucky', 'm_wild'
                }
                if #G.playing_cards > 0 then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local target = pseudorandom_element(G.playing_cards, pseudoseed('hr_bandit_card'))
                            local chosen = pseudorandom_element(enhancements,   pseudoseed('hr_bandit_enhance'))
                            if target and G.P_CENTERS[chosen] then
                                target:set_ability(G.P_CENTERS[chosen], nil, true)
                                target:juice_up(0.3, 0.4)
                            end
                            return true
                        end
                    }))
                end
                return {
                    message = "JACKPOT!",
                    colour  = G.C.GOLD
                }

            else
                return {
                    message = "Try Again...",
                    colour  = G.C.UI.TEXT_INACTIVE
                }
            end
        end

        if context.joker_main and card.ability.extra.mult > 0 then
            return { mult = card.ability.extra.mult }
        end
    end
}

-- Karma
SMODS.Joker {
    key              = "karma",
    order            = 16,
    atlas            = "hr_jokers",
    pos              = { x = 5, y = 1 },
    rarity           = 2,
    cost             = 4,
    blueprint_compat = false,
    discovered       = true,

    config = { extra = { percent = 50, last_discards_left = 99 } },

    loc_txt = {
        name = "Karma",
        text = {
            "{C:green}+1%{} per hand played,",
            "{C:red}-1%{} per discard",
            "Every {C:attention}5%{} from {C:attention}50%{}",
            "earn or lose {C:gold}$1{} at end of round",
            "{C:inactive}(Currently #1#% | #2#)"
        }
    },

    loc_vars = function(self, info_queue, card)
        local pct     = card.ability.extra.percent
        local raw     = math.floor((pct - 50) / 5)
        local dollars = math.max(-10, math.min(10, raw))
        local display = dollars == 0 and "$0"
            or (dollars > 0 and ("+$" .. dollars) or ("-$" .. math.abs(dollars)))
        return { vars = { pct, display } }
    end,

    calculate = function(self, card, context)

        if context.discard then
            local dleft = G.GAME.current_round.discards_left or 0
            if dleft < card.ability.extra.last_discards_left then
                card.ability.extra.last_discards_left = dleft
                card.ability.extra.percent = math.max(0, card.ability.extra.percent - 1)
                return {
                    message = "-1%",
                    colour  = G.C.RED
                }
            end
        end

        if context.joker_main then
            card.ability.extra.percent = math.min(100, card.ability.extra.percent + 1)
            return {
                message = "+1%",
                colour  = G.C.GREEN
            }
        end

        if context.end_of_round and context.main_eval then
            card.ability.extra.last_discards_left = 99

            local pct     = card.ability.extra.percent
            local raw     = math.floor((pct - 50) / 5)
            local dollars = math.max(-10, math.min(10, raw))

            if dollars ~= 0 then
                return {
                    dollars = dollars,
                    message = dollars > 0 and ("+$" .. dollars) or ("-$" .. math.abs(dollars)),
                    colour  = dollars > 0 and G.C.GOLD or G.C.RED
                }
            end
        end

    end
}

-- Specimen
SMODS.Joker {
    key              = "specimen",
    order            = 18,
    atlas            = "hr_jokers",
    pos              = { x = 7, y = 1 },
    rarity           = 2,
    cost             = 6,
    blueprint_compat = false,
    discovered       = true,

    loc_txt = {
        name = "Specimen",
        text = {
            "Copies the effect of the",
            "{C:attention}Joker to the left{}",
            "at {C:red}half{} value",
            "{C:inactive}(#1#)"
        }
    },

    loc_vars = function(self, info_queue, card)
        if not G.jokers then return { vars = { "No Joker" } } end
        local my_pos = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                my_pos = i
                break
            end
        end
        local label = "No Joker"
        if my_pos and my_pos > 1 then
            local other = G.jokers.cards[my_pos - 1]
            if other then
                label = other.config.center.blueprint_compat
                    and (other.ability.name or "Unknown")
                    or  "Incompatible"
            end
        end
        return { vars = { label } }
    end,

    calculate = function(self, card, context)
        local my_pos = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                my_pos = i
                break
            end
        end

        if not my_pos or my_pos <= 1 then return end
        local other = G.jokers.cards[my_pos - 1]
        if not other or not other.config.center.blueprint_compat then return end

        local result = SMODS.blueprint_effect(card, other, context)

        if result and type(result) == "table" then
            local halve_fields = {
                "mult_mod", "chip_mod",
                "Xmult_mod", "Xchip_mod",
                "Emult_mod", "Echip_mod",
                "mult", "chips",
                "x_mult", "x_chips",
                "dollars", "p_dollars"
            }
            local modified_field = nil
            local modified_val = nil

            for _, field in ipairs(halve_fields) do
                if result[field] then
                    local val = result[field]
                    local is_num = type(val) == "number"
                    local is_big = type(val) == "table" and (val.is_big or val.type == "Big")
                    
                    if is_num or is_big then
                        result[field] = val / 2
                        if not modified_field or field:find("mult") or field:find("chip") then
                            modified_field = field
                            modified_val = result[field]
                        end
                    end
                end
            end

            if type(result.repetitions) == "number" then
                result.repetitions = math.max(1, math.floor(result.repetitions / 2))
            end

            if result.message then
                result.message = result.message:gsub("(%d+%.?%d*)", function(n)
                    local num = tonumber(n)
                    if not num then return n end
                    local halved = num / 2
                    if halved % 1 == 0 then
                        return tostring(math.floor(halved))
                    else
                        return string.format("%.1f", halved)
                    end
                end)
            end

            return result
        end

        return result
    end
}
