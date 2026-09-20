return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    cmdline = {
      view = "cmdline_popup",
      opts = { position = { row = 5, col = "50%" } },
      format = {
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { pattern = "^/", icon = " ", lang = "regex" },
        search_up = { pattern = "^%?", icon = " ", lang = "regex" },
        lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
      },
    },
    routes = {
      { -- Skip "written" and undo/redo messages to keep the UI clean
        filter = {
          event = "msg_show",
          any = { { find = "written" }, { find = "%d+L, %d+B" }, { find = "; after #%d+" } },
        },
        opts = { skip = true },
      },
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      hover = { silent = true },
    },
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
    views = {
      cmdline_popup = { border = { style = "rounded" } },
      popupmenu = { border = { style = "rounded" } },
    },
  },
}
