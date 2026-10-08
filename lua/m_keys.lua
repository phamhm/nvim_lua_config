local function truncate(str, max_len)
  if #str > max_len then
    return str:sub(1, max_len - 3) .. ".."
  end
  return str
end

vim.keymap.set('n', '<C-q><C-q><C-q>', ":q!<CR>", {})
vim.keymap.set('n', '<leader>vn', ":vnew<CR>", {})
vim.keymap.set('n', 'j', "gj", {silent=true})
vim.keymap.set('n', 'k', "gk", {silent=true})

vim.keymap.set('n', '<leader>1', ":only<CR>",{})
vim.keymap.set('n', '<leader>2', ":vsp<CR>",{})
vim.keymap.set('n', '<leader>3', ":sp<CR>",{})
vim.keymap.set('n', '<leader>0', ":clo<CR>",{})

vim.keymap.set({'n', 'i'}, '<C-s>', "<Esc>:w<CR>",{silent = true})
--vim.keymap.set('i', '<C-j>', "<CR>",{silent = true})
vim.keymap.set('n', '<F3>', "Go<C-R><C-c>## <C-R>=strftime(\"%Y-%m-%d %a %I:%M %p\")<CR><Esc>o - Idea:<CR>- Thought:<Esc>kA",{})
vim.keymap.set('i', '<F3>', "<Esc>0Di## <C-R>=strftime(\"%Y-%m-%d %a %I:%M %p\")<CR><Esc>o- Idea:<CR>- Thought:<Esc>kA",{})

-- vim.keymap.set('n', '<leader>mt', ":MarkdownPreviewToggle<CR>",{silent = true})

vim.keymap.set('n', '<leader>hv', ":wincmd H | :vert resize 90<CR>",{silent = true})

vim.keymap.set("n", "<leader>vt", ":e ~/Documents/vimwiki/trade_journal.md<CR>Gzt", { noremap = true, silent = true, desc = "Open init.lua" })

--vim.keymap.set("i", "<C-f>", "<C-c><Plug>(easymotion-w)", { noremap = true, silent = true, desc = "Open init.lua" })
--vim.keymap.set("i", "<C-b>", "<C-c><Plug>(easymotion-b)", { noremap = true, silent = true, desc = "Open init.lua" })
vim.keymap.set({'n', 'v'}, '<leader><leader>l', '<Plug>(easymotion-wl)', { desc = 'EasyMotion move right on line' })
vim.keymap.set({'n', 'v'}, '<leader><leader>h', '<Plug>(easymotion-bl)', { desc = 'EasyMotion move left on line' })

-- vim.keymap.set('i', '<C-j>', '<CR>', { remap = true })
-- vim.keymap.set('i', '<C-l>', '<Del>', { noremap = true, silent = true })

-- Bringing the whole line up or down
-- Normal mode
local move_line_prefix = "C-M"
vim.keymap.set('n', '<' .. move_line_prefix .. '-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('i', '<' .. move_line_prefix .. '-j>', '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('v', '<' .. move_line_prefix .. '-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('n', '<' .. move_line_prefix .. '-k>', ':m .-2<CR>==', { silent = true })
vim.keymap.set('i', '<' .. move_line_prefix .. '-k>', '<Esc>:m .-2<CR>==gi', { silent = true })
vim.keymap.set('v', '<' .. move_line_prefix .. '-k>', ":m '<-2<CR>gv=gv", { silent = true })

vim.keymap.set("v", "<leader>td", ":'<,'>m ?^# Capture$?-2 <CR>")
vim.keymap.set("n", "<leader>td", ":m ?^# Capture$?-2 <CR>")

vim.keymap.set("v", "<leader>tc", ":'<,'>m /^# Capture$/ <CR>")
vim.keymap.set("n", "<leader>tc", ":m /^# Capture$/ <CR>")

vim.keymap.set({ "i", "v", "n", "s" }, "<C-c>", "<Esc>:noh<CR>" , {noremap = true})

vim.keymap.set("n", "<leader>hw", ":term curl 'wttr.in' <CR>", {silent = true})

-- shortcut to google
local google_shortcut ="<leader>gg"
local google_prompt = "Google: "
local opts = { noremap=true, silient=true}

local function google_search(input)
    if input and input ~="" then
        local query = vim.uri_encode(input)
        vim.ui.open("https://www.google.com/search?q=" .. query)
    end
end

vim.keymap.set("n", google_shortcut, function()
    vim.ui.input( { prompt = google_prompt}, google_search)
end, opt)

vim.keymap.set("v", google_shortcut, function()
   vim.cmd('noautocmd normal! "vy') -- yank selected into register v

   local selected_text = vim.fn.getreg('v')

   vim.ui.input({
       prompt = google_prompt,
       default = selected_text,
     },
   google_search)
end, opt)
-- end googling, }

-- capture

vim.keymap.set('n', '<leader>gc', function()
  vim.ui.input({ prompt = 'Todo: ' }, function(input)
    if input and input ~= '' then
      vim.fn.writefile({ "- " .. input }, vim.fn.expand("~/Documents/vimwiki/daily_reminder.md"), "a")
    end
  end)
end, { desc = 'Ask for text and append to end of file' })

vim.keymap.set('n', '<leader>gw', function()
  local reg_p = vim.fn.getreg('+')
  vim.ui.input({ prompt = "Bookmarking: " .. truncate(reg_p, 40) }, function(input)
    if input and input ~= '' and reg_p and reg_p ~='' then
      vim.fn.writefile({ "[" .. input .. "](" .. reg_p .. ")"  }, vim.fn.expand("~/Documents/vimwiki/bookmarks.md"), "a")
    end
  end)
end, {silent = true, desc = 'Ask for text and append to end of file' })

vim.keymap.set('n', '<leader>vd',
function()
  local today_date = os.date('%Y-%m-%d')
  local file_path = "~/Documents/vimwiki/diary/" .. today_date .. ".md"
  file_path = vim.fn.expand(file_path)
  vim.ui.input({ prompt = "Today Diary Entry:"}, function(content)
    local file = io.open(file_path, "a")
    if file then
      file:write("- " .. content .. '\n')
      file:close()
      print("Saved to " .. file_path)
    else
      vim.notify("Error: could not write diary entry", vim.log.levels.ERROR)
    end
  end)
end, { desc = 'Ask for text and append to end of file' })

vim.keymap.set('n', "<leader>hf", function() vim.cmd.help(vim.bo.filetype) end, { desc = "get help for current file type" } )
-- end capture

vim.keymap.set("n", "<leader>c<space>", "gcc", {remap = true, silent=true, desc = "toggle comment"})
vim.keymap.set("v", "<leader>c<space>", "gc", {remap = true, silent=true, desc = "toggle comment"})

local function prompt_and_run_lua()
  vim.ui.input({ prompt = 'Execute Lua: ' }, function(input)
    -- If the user hits Esc or Cancels, input is nil
    if not input or input == "" then return end

    -- Compile the string into an executable Lua chunk
    local chunk, err = load(input)

    if chunk then
      -- Safely execute the compiled chunk
      local success, result = pcall(chunk)
      if not success then
        vim.notify("Runtime Error: " .. tostring(result), vim.log.levels.ERROR)
      end
    else
      vim.notify("Syntax Error: " .. tostring(err), vim.log.levels.ERROR)
    end
  end)
end

-- Map it to a key (e.g., <leader>le for "Lua Execute")
vim.keymap.set('n', '<leader>lu', prompt_and_run_lua, { desc = 'Prompt and execute Lua code' })

