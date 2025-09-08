-- *gv* *v_gv* *reselect-Visual*
-- gv			Start Visual mode with the same area as the previous
-- 			area and the same mode.
-- 			In Visual mode the current and the previous Visual
-- 			area are exchanged.
-- 			After using "p" or "P" in Visual mode the text that
-- 			was put will be selected.

-- 								*gn* *v_gn*
-- gn			Search forward for the last used search pattern, like
-- 			with `n`, and start Visual mode to select the match.
-- 			If the cursor is on the match, visually selects it.
-- 			If an operator is pending, operates on the match.
-- 			E.g., "dgn" deletes the text of the next match.
-- 			If Visual mode is active, extends the selection
-- 			until the end of the next match.
-- 			'wrapscan' applies.
-- 			Note: Unlike `n` the search direction does not depend
-- 			on the previous search command.
-- https://medium.com/@wilddog64/tabout-nvim-looks-nice-but-you-cant-tab-away-from-whatever-quotes-and-open-a-new-line-7d8a7f7d48d8

-- https://github.com/mg979/vim-visual-multi
return {
	"mg979/vim-visual-multi",
	event = "VeryLazy",
}
