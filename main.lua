-- Atlas registrations
SMODS.Atlas({ key = "modicon",      path = "icon.png",         px = 34,  py = 34  })
SMODS.Atlas({ key = "jokers",       path = "hr_jokers.png",    px = 71,  py = 95  })
SMODS.Atlas({ key = "consumables",  path = "hr_consumables.png", px = 71, py = 95 })
SMODS.Atlas({
    key = "timebomb",
    path = "timebomb.png",
    px = 142,
    py = 190,
    frames = 23,
    atlas_table = "ANIMATION_ATLAS"
})

-- Load joker files
assert(load(SMODS.load_file("jokers/existing.lua")))()
assert(load(SMODS.load_file("jokers/the_house.lua")))()
assert(load(SMODS.load_file("consumables/spectrals.lua")))()