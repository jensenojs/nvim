-- https://github.com/lukas-reineke/indent-blankline.nvim
-- 缩进指引线插件, 新模块名为 "ibl"
return {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    init = function()
        vim.opt.termguicolors = true
        vim.api.nvim_set_hl(0, "IndentBlanklineIndent", {
            fg = "#565552",
            nocombine = true
        })
    end,
    opts = {
        exclude = {
            filetypes = {"dashboard"}
        }
    }
}
