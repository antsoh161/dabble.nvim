--- @module dabble
local M = {}

--- @type table
M.config = {

  --- @type table<string, string>
  templates = require("dabble.templates").default,

  --- @type table<string, table>
  runners = {
    cpp = {
      compile = "g++ -std=c++17 %s -o %s.out",
      run = "%s.out",
    },
    python3 = {
      run = "python3 %s",
    },
  },
}

--- @param opts? table
function M.setup(opts)
  print("Dabble module loaded and setup() called")
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_user_command("DabbleNew", function(args)
    local filetype = args.args
    require("dabble.commands").new_buffer(filetype, M.config)
  end, {
    nargs = 1,
    desc = "Create new dabble buffer for specified filetype",
    complete = function(arg_lead)
      local completions = {}
      for ft, _ in pairs(M.config.templates) do
        if ft:sub(1, #arg_lead) == arg_lead then
          table.insert(completions, ft)
        end
      end
      return completions
    end,
  })

  vim.api.nvim_create_user_command("DabbleRun", function()
    require("dabble.commands").run_buffer(M.config)
  end, {
    desc = "Run the current dabble buffer",
  })
end

return M
