-- https://github.com/b0o/incline.nvim
-- 浮动状态栏/可替代 winbar 的实现
return {
    "b0o/incline.nvim",
    dependencies = {'nvim-web-devicons'},
    event = "UIEnter",
    main = "incline",
    opts = {
        render = function(props)
            local devicons = require 'nvim-web-devicons'
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
            if filename == '' then
                filename = '[No Name]'
            end
            local ft_icon, ft_color = devicons.get_icon_color(filename)

            local function get_git_diff()
                local icons = {
                    removed = require("utils.icons").get("git").Remove,
                    changed = require("utils.icons").get("git").Mod_alt,
                    added = require("utils.icons").get("git").Add
                }
                local signs = vim.b[props.buf].gitsigns_status_dict
                local labels = {}
                if signs == nil then
                    return labels
                end
                for name, icon in pairs(icons) do
                    if tonumber(signs[name]) and signs[name] > 0 then
                        table.insert(labels, {
                            icon .. signs[name] .. ' ',
                            group = 'Diff' .. name
                        })
                    end
                end
                if #labels > 0 then
                    table.insert(labels, {require("utils.icons").get("ui").Separator .. ' '})
                end
                return labels
            end

            local function get_diagnostic_label()
                local icons = {
                    error = require("utils.icons").get("diagnostics").Error_alt2,
                    warn = require("utils.icons").get("diagnostics").Warning,
                    info = require("utils.icons").get("diagnostics").Information,
                    hint = require("utils.icons").get("diagnostics").Hint_alt2
                }
                local label = {}

                for severity, icon in pairs(icons) do
                    local n = #vim.diagnostic.get(props.buf, {
                        severity = vim.diagnostic.severity[string.upper(severity)]
                    })
                    if n > 0 then
                        table.insert(label, {
                            icon .. n .. ' ',
                            group = 'DiagnosticSign' .. severity
                        })
                    end
                end
                if #label > 0 then
                    table.insert(label, {require("utils.icons").get("ui").Separator .. ' '})
                end
                return label
            end

            local ui_icons = require("utils.icons").get("ui")
            return {{get_diagnostic_label()}, {get_git_diff()}, {
                (ft_icon or '') .. ' ',
                guifg = ft_color,
                guibg = 'none'
            }, {
                filename .. ' ',
                gui = vim.bo[props.buf].modified and 'bold,italic' or 'bold'
            }, {
                ui_icons.Separator .. ' ' .. ui_icons.Window .. ' ' .. vim.api.nvim_win_get_number(props.win),
                group = 'DevIconWindows'
            }}
        end
    }
}
