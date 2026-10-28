-- find the fence with the name timekeep
-- ```timekeep
-- {"entries":[{"name":"working on it","startTime":"2026-10-28T05:41:46.741Z","endTime":"2026-10-28T05:42:07.909Z","subEntries":null},{"name":"working on it again","startTime":"2026-10-28T05:42:35.190Z","endTime":"2026-10-28T05:42:52.018Z","subEntries":null}]}
-- ```
-- this is created by an community Obsidan app called TimeKeep
local function find_timekeep_blocks()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get the parser and AST root
  local parser = vim.treesitter.get_parser(bufnr, "markdown")
  if not parser then return end
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Define the query string
  local query_str = [[
    ((fenced_code_block
        (info_string
          (language) @lang (#eq? @lang "timekeep"))) @codeblock)
  ]]

  local query = vim.treesitter.query.parse("markdown", query_str)

  -- Use iter_captures for direct, bulletproof access to the nodes
  for id, node, _, _ in query:iter_captures(root, bufnr, 0, -1) do
    local capture_name = query.captures[id]

    if capture_name == "codeblock" then
      -- Safely extract coordinates (0-indexed)
      local full_text = vim.treesitter.get_node_text(node, bufnr)
      local lines = vim.split(full_text, "\n", {trimempty = true})
      table.remove(lines, 1)
      table.remove(lines, #lines)
      local json_str = table.concat(lines)

      local success, result = pcall(vim.json.decode, json_str)
      if success then
        vim.notify(vim.inspect(result.entries[1]))         -- Output: Neovim
      else
        print("Failed to parse JSON: " .. result)
      end


      -- If you want to jump your cursor to the start of this block:
      -- vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
    end
  end
end

vim.keymap.set("n", "<leader>wk", function() find_timekeep_blocks() end, {desc = "wikilink"})

-- lua doesn't track milliseconds. thus, 000Z
local timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
vim.notify(timestamp)
