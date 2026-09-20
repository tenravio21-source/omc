-- ==========================================
-- 1. COMMENTS & VARIABLES
-- ==========================================

-- Single line comment
--[[
    Multi-line
    comment
]]

local x = 10 -- number
local name = "Sid" -- string
local isAlive = true -- boolean
local empty = nil -- no value

-- Incrementing
local n = 1
n = n + 1 -- n is now 2

-- Concatenation (joining strings)
local phrase = "I am " .. name -- "I am Sid"

-- ==========================================
-- 2. OPERATORS & CONDITIONALS
-- ==========================================

-- Operators: == (equal), ~= (not equal), <, >, <=, >=

local age = 20

if age > 18 then
	print("Adult")
elseif age == 18 then
	print("Just turned 18")
else
	print("Minor")
end

-- Logic: 'and', 'or', 'not'
if age > 18 and isAlive then
	print("Living adult")
end

if not isAlive then
	print("Ghost!")
end

-- ==========================================
-- 3. FUNCTIONS & SCOPE
-- ==========================================

-- Local functions are preferred for performance and safety
local function add(a, b)
	return a + b
end

-- Scope example
local function scope_test()
	local internal_var = "hidden"
end
-- print(internal_var) --> This would be nil (variable died inside the function)

-- ==========================================
-- 4. LOOPS
-- ==========================================

-- While loop
local counter = 1
while counter <= 3 do
	print("Count: " .. counter)
	counter = counter + 1
end

-- For loop (start, end, step)
for i = 1, 3 do
	print("Loop: " .. i)
end

-- ==========================================
-- 5. TABLES (The Only Data Structure in Lua)
-- ==========================================

-- ARRAYS (Lists) - Note: Lua starts at index 1, not 0!
local colors = { "red", "green", "blue" }
print(colors[1]) -- "red"
print(#colors) -- 3 (Length of table)

-- Looping through Arrays (ipairs)
for index, value in ipairs(colors) do
	print(index .. ": " .. value)
end

-- DICTIONARIES (Key-Value pairs)
local user = {
	username = "siduck",
	age = 20,
}
print(user.username) -- "siduck" (Dot notation)
print(user["age"]) -- 20 (Bracket notation)

-- Looping through Dictionaries (pairs)
for key, value in pairs(user) do
	print(key .. " is " .. tostring(value))
end

-- ==========================================
-- 6. MODULES & REQUIRING
-- ==========================================

-- If you have a file 'lua/my_config.lua' or 'lua/my_config/init.lua':
-- local config = require("my_config")

-- ==========================================
-- 7. NEOVIM SPECIFICS (vim.tbl_deep_extend)
-- ==========================================

-- Used to merge user settings with default settings
local defaults = { theme = "dark", icons = true, plugins = { "git", "fzf-lua" } }
local user_config = { theme = "nord", plugins = { "fzf" } }

-- "force" means user_config wins if there's a conflict
-- Note: It merges keys, but replaces whole arrays/lists!
local final_config = vim.tbl_deep_extend("force", defaults, user_config)

-- Result: theme="nord", icons=true, plugins={"fzf"}
