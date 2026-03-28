-- Atlas registrations
SMODS.Atlas({ key = "modicon",      path = "icon.png",         px = 34,  py = 34  })
SMODS.Atlas({ key = "jokers",       path = "hr_jokers.png",    px = 71,  py = 95  })
SMODS.Atlas({ key = "decks",        path = "hr_decks.png",     px = 71,  py = 95  })
SMODS.Atlas({ key = "consumables",  path = "hr_consumables.png", px = 71, py = 95 })
SMODS.Atlas({
    key = "timebomb",
    path = "timebomb.png",
    px = 142,
    py = 190,
    frames = 23,
    atlas_table = "ANIMATION_ATLAS"
})

-- Load Joker utility logic first
assert(load(SMODS.load_file("jokers/utils.lua")))()

-- Load Jokers by rarity
assert(load(SMODS.load_file("jokers/common.lua")))()
assert(load(SMODS.load_file("jokers/uncommon.lua")))()
assert(load(SMODS.load_file("jokers/rare.lua")))()
assert(load(SMODS.load_file("jokers/legendary.lua")))()

-- Load Decks
assert(load(SMODS.load_file("decks/abnormality.lua")))()

-- Load other types
assert(load(SMODS.load_file("consumables/spectrals.lua")))()
