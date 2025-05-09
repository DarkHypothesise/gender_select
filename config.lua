Config = {}

-- UI Configuration
Config.UI = {
    title = "Character Gender",
    subtitle = "Select your character's gender to continue",
    maleLabel = "Male",
    femaleLabel = "Female",
    closeButtonLabel = "Close",
    backgroundColor = "rgba(15, 23, 42, 0.8)",
    accentColor = "#6366f1",
    secondaryColor = "#ec4899",
    font = "'Poppins', sans-serif"
}

-- Clothing Configuration
Config.Clothing = {
    male = {
        components = {
            [0] = {drawable = 0, texture = 0}, -- Face
            [1] = {drawable = 0, texture = 0}, -- Mask
            [2] = {drawable = 1, texture = 4}, -- Hair
            [3] = {drawable = 0, texture = 0}, -- Torso/Arms
            [4] = {drawable = 7, texture = 0}, -- Pants
            [5] = {drawable = 0, texture = 0}, -- Bags
            [6] = {drawable = 6, texture = 0}, -- Shoes
            [7] = {drawable = 0, texture = 0}, -- Accessories
            [8] = {drawable = 15, texture = 0}, -- Undershirt
            [9] = {drawable = 0, texture = 0}, -- Body Armor
            [10] = {drawable = 0, texture = 0}, -- Decals
            [11] = {drawable = 0, texture = 1}  -- Top
        },
        props = {
            [0] = {drawable = -1, texture = 0}, -- Hat
            [1] = {drawable = -1, texture = 0}, -- Glasses
            [2] = {drawable = -1, texture = 0}, -- Ear accessories
            [3] = {drawable = -1, texture = 0}, -- Watch
            [6] = {drawable = -1, texture = 0}, -- Bracelet
            [7] = {drawable = -1, texture = 0}  -- Additional
        }
    },
    female = {
        components = {
            [0] = {drawable = 0, texture = 0}, -- Face
            [1] = {drawable = 0, texture = 0}, -- Mask
            [2] = {drawable = 0, texture = 0}, -- Hair
            [3] = {drawable = 0, texture = 0}, -- Torso/Arms
            [4] = {drawable = 0, texture = 0}, -- Pants
            [5] = {drawable = 0, texture = 0}, -- Bags
            [6] = {drawable = 0, texture = 0}, -- Shoes
            [7] = {drawable = 0, texture = 0}, -- Accessories
            [8] = {drawable = 0, texture = 0}, -- Undershirt
            [9] = {drawable = 0, texture = 0}, -- Body Armor
            [10] = {drawable = 0, texture = 0}, -- Decals
            [11] = {drawable = 0, texture = 0}  -- Top
        },
        props = {
            [0] = {drawable = -1, texture = 0}, -- Hat
            [1] = {drawable = -1, texture = 0}, -- Glasses
            [2] = {drawable = -1, texture = 0}, -- Ear accessories
            [3] = {drawable = -1, texture = 0}, -- Watch
            [6] = {drawable = -1, texture = 0}, -- Bracelet
            [7] = {drawable = -1, texture = 0}  -- Additional
        }
    }
}
