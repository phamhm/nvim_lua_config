vim.keymap.set('n', '<leader>q', ":bd<CR>", {})
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

vim.keymap.set('n', '<leader>mt', ":MarkdownPreviewToggle<CR>",{silent = true})
--

vim.keymap.set('n', '<C-h>', "<C-w>h",{})
vim.keymap.set('n', '<C-j>', "<C-w>j",{})
vim.keymap.set('n', '<C-k>', "<C-w>k",{})
vim.keymap.set('n', '<C-l>', "<C-w>l",{})

vim.keymap.set('n', '<leader>hv', ":wincmd H | :vert resize 90<CR>",{silent = true})

vim.keymap.set('n', '<leader>c<space>', 'gcc', { remap = true, silent = true, desc = 'Toggle comment' })
vim.keymap.set('v', '<leader>c<space>', 'gc', { remap = true, silent = true, desc = 'Toggle comment' })

-- end key maps
--

--vim.keymap.set("i", "<C-f>", "<C-c><Plug>(easymotion-w)", { noremap = true, silent = true, desc = "Open init.lua" })
--vim.keymap.set("i", "<C-b>", "<C-c><Plug>(easymotion-b)", { noremap = true, silent = true, desc = "Open init.lua" })
vim.keymap.set('n', '<leader><leader>l', '<Plug>(easymotion-wl)', { desc = 'EasyMotion move right on line' })
vim.keymap.set('n', '<leader><leader>h', '<Plug>(easymotion-bl)', { desc = 'EasyMotion move left on line' })

vim.keymap.set('i', '<C-l>', '<Del>', { noremap = true, silent = true })

-- Bringing the whole line up or down
-- Normal mode
vim.keymap.set('n', '<M-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<M-k>', ':m .-2<CR>==', { silent = true })

-- Insert mode
vim.keymap.set('i', '<M-j>', '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('i', '<M-k>', '<Esc>:m .-2<CR>==gi', { silent = true })

-- Visual mode
vim.keymap.set('v', '<M-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<M-k>', ":m '<-2<CR>gv=gv", { silent = true })


vim.keymap.set({ "i", "v", "n", "s" }, "<C-c>", "<Esc>:noh<CR>" , {noremap = true})

vim.keymap.set("n", "<leader>hw", ":term curl 'wttr.in' <CR>", {silent = true})

vim.keymap.set('n', '<leader>t', function()
  -- Check if a terminal buffer already exists
  local term_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      term_buf = buf
      break
    end
  end

  if term_buf then
    -- If it exists, check if it's visible in any window
    local term_win = vim.fn.bufwinid(term_buf)
    if term_win ~= -1 then
      -- Switch focus to that window
      vim.api.nvim_set_current_win(term_win)
    else
      -- If it's hidden, switch the current buffer to it
      vim.api.nvim_set_current_buf(term_buf)
    end
  else
    -- If no terminal buffer exists, open a new one
    vim.cmd("terminal")
  end
end, { desc = "Toggle/Switch to Terminal" })


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

-- Open mini.files at the current working directory (CWD)
vim.keymap.set('n', '<leader>er', function()
  require('mini.files').open(vim.uv.cwd(), true)
end, { desc = 'Open mini.files (Root)' })

-- Open mini.files targeting the directory of the active buffer
vim.keymap.set('n', '<leader>ec', function()
  require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
end, { desc = 'Open mini.files (Current File)' })

local function open_link_picker(filepath)
  local expanded_path = vim.fn.expand(filepath)

  -- Ensure the file is readable
  if vim.fn.filereadable(expanded_path) == 0 then
    vim.notify("File not found or unreadable: " .. filepath, vim.log.levels.ERROR)
    return
  end

  local items = {}

  -- Read the file line-by-line
  for line in io.lines(expanded_path) do
    -- Lua pattern matching for: [title](link)
    local title, link = line:match("^%[(.-)%]%((.-)%)")
    if title and link then
      table.insert(items, {
        text = title, -- Field used by snacks for filtering/searching
        link = link,  -- Custom field to store the URI
      })
    end
  end

  -- Launch the Snacks Picker
  Snacks.picker({
    title = "Bookmarks",
    items = items,
    layout = { preview = false},
    format = function(item, _)
      return {
        { item.text, "SnackPickerLabel"}
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item and item.link then
        if item.link:match(".applescript") then
          -- Run the link as a system script/command
          cmd = {"/usr/bin/osascript", item.link}
        elseif item.link:match(".zsh") then
          -- Run the link as a system script/command
          cmd = {"/bin/zsh", item.link}
        else
          cmd = { "open", item.link} -- 'open' is a osx  command
        end
        vim.system(cmd, {detach = true}, function(err, data)
          if err and err.code ~=0 then
            vim.schedule(function()
              vim.notify("Failed to open:" .. vim.inspect(err), vim.log.levels.ERROR)
            end)
          end
        end)

      end
    end,
  })
end

-- Example Keymap (Adjust the path to your actual file)
vim.keymap.set("n", "<leader>bm", function()
  open_link_picker("~/Documents/vimwiki/bookmarks.md")
end, { desc = "Search Bookmarks File" })

dofile(vim.fn.expand("~/Workspace/poweroninstall/nvim/poweron_upload.lua"))


vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
