--
-- https://github.com/jesseduffield/lazygit
-- 符合vim直觉的git CUI
local bind = require("utils.bind")
local map_cr = bind.map_cr

local keymaps = {
	["n|<leader>G"] = map_cr("LazyGit"):with_noremap():with_silent():with_desc("打开LazyGit"),
}

bind.nvim_load_mapping(keymaps)

return {
	"kdheepak/lazygit.nvim",
	cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
}
