-- TODO
-- if region, call selected_text. if not, then get cursor line
-- how to delete region after done
local u = require('functions')

local function get_lines()
  local mode = vim.api.nvim_get_mode().mode
  local opts = {}
  if mode == "v" or mode == "V" or mode == "\22" then
    -- opts = {type=mode}
    local vpos = vim.fn.getpos "v"
    local dpos = vim.fn.getpos "."
    vim.print( vpos )
    local lines = vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".", {type=mode})
    return table.concat(lines, "\n")
  else
    return vim.trim(vim.api.nvim_get_current_line())
  end
end


vim.keymap.set({"n", "v"}, "<C-n>", function()
  local m_lines = get_lines()

  local winid = vim.api.nvim_get_current_win()

  vim.notify("Winid:"..winid)
  vim.notify("Lines:\n" .. m_lines)

  Snacks.picker.files({
    cwd = "~/Documents/notes/",
    actions = {
      confirm = function(picker, item)
        if item then
          picker:close()
          local target_file_path = item._path
          u.append_text_to_file(table.concat(m_text, "\n"), target_file_path)
        end
      end
    }
  })


  vim.api.nvim_set_current_win(winid)
end )

-- vim.ui.select(items, {
--     prompt = "Select an option:",
--     format_item = function(item)
--         return "Target: " .. item.text
--     end,
-- }, function(choice, _)
--     if choice then
--       choice.fn()
--     else
--       print("Selection cancelled")
--     end
--   end)


-- vim.keymap.set('v', '<leader>gl', function()
--   -- Get the row numbers for the start and end of the selection
--   -- vim.fn.getpos('v') returns the visual selection anchor [buf, row, col, off]
--   local start_row = vim.fn.getpos('v')[2]
--   -- vim.fn.getcurpos() returns the current cursor position
--   local end_row = vim.fn.getcurpos()[2]
--
--   -- Normalize start/end if selected from bottom to top
--   if start_row > end_row then
--     start_row, end_row = end_row, start_row
--   end
--
--   -- nvim_buf_get_lines uses 0-indexed, end-exclusive line numbering
--   -- (e.g., to get lines 1-3, you request index 0 to 3)
--   local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
--
--   -- Print or process your lines array
--   print(vim.inspect(lines))
-- end, { desc = "Get lines of selected region" })
