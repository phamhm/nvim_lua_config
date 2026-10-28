local it = vim.fs.dir(vim.g.m_notes_path )
it = vim.iter(it):map(function(name, type) return name .. '|' .. type end):totable()

vim.notify(vim.inspect(it))
