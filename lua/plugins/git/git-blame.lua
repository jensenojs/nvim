-- https://github.com/f-person/git-blame.nvim
-- 通过虚拟文本在当前行显示 Git Blame 信息
return {
	"f-person/git-blame.nvim",
	event = "VeryLazy",
	-- plugin supports opts table directly
	opts = {
		enabled = true,
		message_template = " <summary> • <date> • <author> • <<sha>>",
		date_format = "%Y-%m-%d",
		virtual_text_column = 1,
	},
}
