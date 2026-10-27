local M = require('markdowns')
local F = require('functions')

function move_block_of_text(picker, item)
  -- local items = picker:selected({ fallback = true })

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

function picker_block_move(path)
  Snacks.picker.files({
    cwd = vim.g.m_notes_path,
    exclude = {
      "archive",
      "todo_notes",
    },
    confirm = move_block_of_text
  })
end


-- select heading 1 and all its content
--
--

function get_h1_sections(bufnr, filter)
  local query_string = [[
  (section
    (atx_heading
      (atx_h1_marker)
    ) @h1_marker
  ) @h1_section
]]

  bufnr = bufnr or 0
  local parser = vim.treesitter.get_parser(bufnr, 'markdown')
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = vim.treesitter.query.parse('markdown', query_string)
  local results = {}

  for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
    local capture_name = query.captures[id]
    if capture_name == 'h1_section' then
      local start_row, _, end_row, _ = node:range()
      local text = vim.treesitter.get_node_text(node, bufnr)
      text = vim.split(text, "\r?\n", { plain = false })

      local h1 = text[1]

      local result = {
        node = node,
        range = {
          start_row = start_row,
          end_row   = end_row,
        },
        h1_block = text
      }
      if vim.trim(h1) == vim.trim(filter) then
        return {result}
      end
      table.insert(results, result)
    end
  end

  -- vim.notify(vim.inspect(results))
  return results
end

F.map(
  "n",
  "<leader>mt",
  function()
    local res = get_h1_sections(nil, "# Headers")
    vim.notify(vim.inspect(res))
  end
)
