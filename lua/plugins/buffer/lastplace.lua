-- https://github.com/ethanholz/nvim-lastplace
-- 重新打开文件时记忆上次光标位置
return {
	"ethanholz/nvim-lastplace",
	event = { "BufReadPre" },
	main = "nvim-lastplace",
	opts = {
		lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
		lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
		lastplace_open_folds = true,
	},
}
