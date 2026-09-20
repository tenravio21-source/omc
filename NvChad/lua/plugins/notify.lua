return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  keys = {
    {
      "<leader>un",
      function()
        require("notify").dismiss({ silent = true, pending = true })
      end,
      desc = "Dismiss All Notifications",
    },
  },
  opts = {
    stages = "static", 
    timeout = 3000,
    render = "compact", 
    icons = {
      ERROR = " ",
      WARN  = " ",
      INFO  = " ",
      DEBUG = " ",
      TRACE = "󰭦 ",
    },
    border = "rounded",
  },
  config = function(_, opts)
    local notify = require("notify")
    notify.setup(opts)
    vim.notify = notify
  end,
}
