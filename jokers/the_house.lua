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

--Magnetism
SMODS.Joker {
    key              = "magnetism",
    atlas            = "hr_jokers",
    pos              = { x = 4, y = 1 },
    rarity           = 3,
    cost             = 10,
    blueprint_compat = false,
    discovered       = true,

    loc_txt = {
        name = "Magnetism",
        text = {
            "Playing a {C:attention}single card{}",
            "pulls all cards of the same",
            "{C:attention}rank{} into play",
            "{C:inactive}(Up to 5 total)"
        }
    },

    calculate = function(self, card, context)
        if context.before and #G.play.cards == 1 then
            local played = G.play.cards[1]
            local rank   = played:get_id()
            local to_pull = {}
            local slots  = 4 -- already have 1, need up to 4 more

            -- Hand first
            for _, c in ipairs(G.hand.cards) do
                if #to_pull >= slots then break end
                if c:get_id() == rank then
                    table.insert(to_pull, c)
                end
            end

            -- Deck second
            if #to_pull < slots then
                for _, c in ipairs(G.deck.cards) do
                    if #to_pull >= slots then break end
                    if c:get_id() == rank then
                        table.insert(to_pull, c)
                    end
                end
            end

            if #to_pull > 0 then
                for _, c in ipairs(to_pull) do
                    local source = c.area
                    if source then source:remove_card(c) end
                    c.facing = 'face'
                    c.flipped = nil
                    G.play:emplace(c)
                    c:juice_up(0.2, 0.3)
                end
                return {
                    message = "Attracted!",
                    colour  = G.C.BLUE
                }
            end
        end
    end
}

-- Karma
SMODS.Joker {
    key              = "karma",
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

-- Ouroboros
SMODS.Joker {
    key              = "ouroboros",
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

-- Specimen
-- WORK IN PROGRESS: Works perfectly on paper, but the splash text shows exact value copied instead of "half value"
SMODS.Joker {
    key              = "specimen",
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
                    -- Support both standard numbers and Big numbers (Talisman)
                    local is_num = type(val) == "number"
                    local is_big = type(val) == "table" and (val.is_big or val.type == "Big")
                    
                    if is_num or is_big then
                        result[field] = val / 2
                        -- Track the primary field for the message update
                        if not modified_field or field:find("mult") or field:find("chip") then
                            modified_field = field
                            modified_val = result[field]
                        end
                    end
                end
            end

            -- Repetitions are handled separately
            if type(result.repetitions) == "number" then
                result.repetitions = math.max(1, math.floor(result.repetitions / 2))
            end

            -- SMART MESSAGE REPLACEMENT
            -- We find any numbers in the original message and halve them
            -- This preserves "Mult", "Chips", "Gold", etc.
            if result.message then
                result.message = result.message:gsub("(%d+%.?%d*)", function(n)
                    local num = tonumber(n)
                    if not num then return n end
                    
                    local halved = num / 2
                    -- Format: No .0 for integers, 1 decimal for others
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