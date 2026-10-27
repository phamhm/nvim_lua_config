local M = require('markdowns')

function note_hl(picker, item)
  local items = picker:selected({ fallback = true })

  choices = {"Yes", "No"}
  vim.ui.select(choices, {prompt = "Move Line(s) to " .. item.text},
    function(choice)
      if choice == "Yes" then
        picker:close()
        local mode = vim.api.nvim_get_mode().mode
        -- Check for characterwise (v), linewise (V), or blockwise (\22) visual mode
        local lines
        if mode:match("^[vV\22]") then
          local row = vim.fn.getpos('v')[2]
          local row2= vim.fn.getpos('.')[2]
          if row>row2 then
            row, row2 = row2, row
          end

          lines = vim.api.nvim_buf_get_lines(0, row-1, row2, false)
          vim.api.nvim_buf_set_lines(0, row-1, row2, false, {})
        else
          lines = vim.api.nvim_get_current_line()
          -- 2. Delete the current line from the buffer
          vim.api.nvim_del_current_line()
        end

        vim.fn.writefile(lines, vim.fn.expand(item._path), "a")
      end
    end)
end

Snacks.picker.files({
  cwd = vim.g.m_notes_path,
  exclude = {
    "archive",
    "todo_notes",
  },
  confirm = note_hl
})
