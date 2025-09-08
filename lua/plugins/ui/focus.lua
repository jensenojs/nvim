-- https://github.com/nvim-focus/focus.nvim
-- 自动聚焦与自动调整分屏尺寸
return {
    "nvim-focus/focus.nvim",
    event = "VeryLazy",
    init = function()
        -- 忽略的 filetype 列表, 这些窗口不参与自动调整
        local ignore_filetypes = {"NvimTree"}
        local ignore_buftypes = {"nofile", "prompt", "popup"}
        local augroup = vim.api.nvim_create_augroup("FocusDisable", { clear = true })
        -- 根据 BufType 禁用自动调整
        vim.api.nvim_create_autocmd("WinEnter", {
            group = augroup,
            callback = function()
                if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
                    vim.w.focus_disable = true
                else
                    vim.w.focus_disable = false
                end
            end,
            desc = "根据 BufType 禁用 focus 自动调整"
        })
        -- 根据 FileType 禁用自动调整
        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            callback = function()
                if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
                    vim.w.focus_disable = true
                else
                    vim.w.focus_disable = false
                end
            end,
            desc = "根据 FileType 禁用 focus 自动调整"
        })
    end,
    main = "focus",
    opts = {
        excluded_filetypes = {"NvimTree"}
    }
}
