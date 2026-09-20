return {
  "mikavilpas/yazi.nvim",
  cmd = { "Yazi" },
  keys = {
    { "-", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Open Yazi (Current File)" },
    { "<leader>wd", "<cmd>Yazi cwd<cr>", desc = "Open Yazi (CWD)" },
    { "<c-S-up>", "<cmd>Yazi toggle<cr>", desc = "Resume Last Yazi Session" },
  },
  opts = {
    open_for_directories = false,
    hijack_netrw = true,
    floating_window_border = "rounded",
    keymaps = {
      show_help = "<f1>",
      grep_in_directory = "<c-s>",
    },
  },
}
