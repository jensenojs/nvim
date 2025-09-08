-- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt
-- 使用快捷键配合textobjects快速地添加/修改/删除各种包括符, 如()、[]、{}、<>等
-- 默认配置是足够好的, 可以去瞅瞅我的README.md, 这里给个tldr的版本
-- 1. basic
--    add : ys, delete : ds, change : cs
--
--    Old text                    Command         New text
--    local str = H*ello          ysiw"           local str = "Hello"
-- 2. alias, 注意下面的例子中yss是ys的一种变体
--    () : b, [] : r, {} : B
--
--    Old text                    Command         New text ~
--    sample* text                yssb            (sample text)
-- 3. autojump
return {
	"kylechui/nvim-surround",
	config = true,
}
