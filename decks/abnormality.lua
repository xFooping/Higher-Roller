-- Abnormality Deck implementation

SMODS.Back {
    name = "Abnormality Deck",
    key = "abnormality",
    pos = { x = 0, y = 0 },
    atlas = "hr_decks",
    config = { hr_abnormality = true },
    loc_txt = {
        name = "Abnormality Deck",
        text = {
            "Start with {C:attention}2{} Negative",
            "{C:spectral}Cryptid{} Spectral cards",
            "Gain another when {C:attention}starting{} a round",
            "{C:inactive}(Copies playing cards)"
        }
    },

    apply = function(self)
        G.GAME.modifiers.hr_abnormality = true
        
        -- Start with 2 negative Cryptid cards
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                for i = 1, 2 do
                    local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_cryptid', 'abnormality')
                    card:set_edition({negative = true}, true)
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                end
                return true
            end
        }))
    end
}

-- HOOKS (Placed outside the table so they actually run)

-- Hook into select_blind (start of round)
local select_blind_ref = G.FUNCS.select_blind
G.FUNCS.select_blind = function(e)
    select_blind_ref(e)
    
    -- Check if we are using the Abnormality Deck
    if G.GAME and G.GAME.modifiers and G.GAME.modifiers.hr_abnormality then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.8, -- Wait for transition to finish
            func = function()
                local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_cryptid', 'abnormality_start')
                if card then
                    card:set_edition({negative = true}, true)
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    
                    -- Visual confirmation
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Abnormality!", 
                        colour = G.C.SECONDARY_SET.Spectral
                    })
                end
                return true
            end
        }))
    end
end
