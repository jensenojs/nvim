-- https://github.com/Bekaboo/dropbar.nvim
-- IDE 风格的 winbar 面包屑导航
return {
    "Bekaboo/dropbar.nvim",
    event = "UIEnter",
    dependencies = {{
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
    }},
    main = "dropbar",
    opts = {}
}
