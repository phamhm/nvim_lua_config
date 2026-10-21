--[[
-- when moving an item to TODO.md file, insert @started(datetime)
-- when moving an item to TODO.md file, insert @started(datetime)
--]]

-- return {
--
-- }
--
function copy_md_header()
  local buf = vim.api.nvim_get_current_buf()
  local node = vim.treesitter.get_node()

  -- Walk up the tree to find the markdown heading node
  while node and node:type() ~= "heading" do
    node = node:parent()
  end

  -- If found, extract the text and assign it to a variable
  local heading_text = ""
  if node then
    heading_text = vim.treesitter.get_node_text(node, buf)
  end

  -- Example usage: Print the result
  print("Captured Heading: " .. heading_text)
end


local query_str = [[
  (atx_heading (atx_h2_marker)) @heading2
]]

local query = vim.treesitter.query.parse("markdown", query_str)

local function create_todo_detail_file()
  local current_line = vim.api.nvim_get_current_line()
  print(current_line)
  local is_heading = current_line:match("^## ") ~= nil and current_line:match('@c(.*)')~=nil
  if is_heading == false then
    vim.notify("Not a capture heading", vim.log.levels.ERROR)
    return
  end
  local todo_item = vim.trim(current_line:match("##(.-)@c"))
  local fname = todo_item:gsub(" ", "_")
  local md_link = string.format("[%s]("..vim.g.m_notes_path.."/%s.md)", todo_item, fname)
  local new_line = string.gsub(current_line, "(##)(.-)(@c)", "%1 "..md_link.." %3")
  vim.api.nvim_set_current_line(new_line)
end


vim.keymap.set("n", "<leader>tt", function() create_todo_detail_file() end, {})
