local u = require('functions')

local items ={
    { text = "Todo" , fn = function() u.move_line_to_file('~/Documents/notes/TODO.md') end},
    { text = "index" , fn = function() u.move_line_to_file('~/Documents/notes/index.md') end},
}

vim.ui.select(items, {
    prompt = "Select an option:",
    format_item = function(item)
        return "Target: " .. item.text
    end,
}, function(choice, _)
    if choice then
      choice.fn()
    else
      print("Selection cancelled")
    end
  end)

local function refile()
  u.menu_commands({
    { text = "todo" , fn = function() Snacks.picker.man() end},
    { text = "Search for Plugin Spec" , fn = function() Snacks.picker.lazy() end},
    { text = "Quickfix List" , fn = function() Snacks.picker.qflist() end},
    { text = "Undo History" , fn = function() Snacks.picker.undo() end},
    { text = "Colorschemes" , fn = function() Snacks.picker.colorschemes() end},
  },"Snacks menu" )
end
