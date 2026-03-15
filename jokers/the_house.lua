-- Shared helpers for The House set

local function blackjack_sum(cards)
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

local function baccarat_sum(cards)
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

-- ─────────────────────────────────────────
-- The Dealer  |  Blackjack  |  Uncommon
-- ─────────────────────────────────────────
SMODS.Joker {
    key              = "thedealer",
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

-- ─────────────────────────────────────────
-- Natural Nine  |  Baccarat  |  Rare
-- ─────────────────────────────────────────
SMODS.Joker {
    key              = "naturalnine",
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

-- ─────────────────────────────────────────
-- The Natural  |  Craps  |  Uncommon
-- ─────────────────────────────────────────
SMODS.Joker {
    key              = "thenatural",
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
            "permanently gain {C:chips}+10 Chips{}",
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
                card.ability.extra.chips = card.ability.extra.chips + 10
                return {
                    message = "+10 Chips",
                    colour  = G.C.CHIPS
                }
            end
        end

        if context.joker_main and card.ability.extra.chips > 0 then
            return { chips = card.ability.extra.chips }
        end
    end
}

-- ─────────────────────────────────────────
-- One Armed Bandit  |  Slots  |  Uncommon
-- ─────────────────────────────────────────
SMODS.Joker {
    key              = "onearmedbandit",
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

-- ─────────────────────────────────────────
-- The Pit Boss  |  Meta  |  Rare
-- ─────────────────────────────────────────
SMODS.Joker {
    key              = "thepitboss",
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

-- ─────────────────────────────────────────
-- The Pot  |  Created by All In  |  Never in pool
-- ─────────────────────────────────────────
SMODS.Joker {
    key              = "thepot",
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