require("nvchad.mappings")

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- In Terminal mode ('t'), double Esc will toggle (hide) the floating terminal
map("t", "<Esc><Esc>", function()
	require("nvchad.term").toggle({ pos = "float", id = "floatTerm" })
end, { desc = "Terminal Toggle floating term" })

-- Resize window using leader + arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })

--clear search highlights
map("n", "<leader>sc", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

--Window Management
map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Lazy & Plugin Management
map("n", "<leader>pl", "<cmd>Lazy log<CR>", { desc = "Show Lazy logs" })
map("n", "<leader>ph", "<cmd>Lazy health<CR>", { desc = "Check plugin health" })
map("n", "<leader>pm", "<cmd>messages<CR>", { desc = "Show recent messages" })

-- Startup Stats
map("n", "<leader>ps", function()
	local stats = require("lazy").stats()
	local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
	vim.notify(
		string.format("⚡ Neovim loaded %d/%d plugins in %s ms", stats.loaded, stats.count, ms),
		vim.log.levels.INFO,
		{ title = "Lazy Startup" }
	)
end, { desc = "Show startup time" })

-- Path Copying
map("n", "<leader>pp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("Copied: " .. path, vim.log.levels.INFO, { title = "Path Copy" })
end, { desc = "Copy current file path" })

map("n", "<leader>pP", function()
	local dir = vim.fn.expand("%:p:h")
	vim.fn.setreg("+", dir)
	vim.notify("Copied: " .. dir, vim.log.levels.INFO, { title = "Path Copy" })
end, { desc = "Copy current file directory" })
