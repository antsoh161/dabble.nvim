--- @module dabble.commands
local M = {}
local api = vim.api

--- @param filetype string
--- @param config table
--- @return number|nil bufnr
function M.new_buffer(filetype, config)
  if not config.templates[filetype] then
    vim.notify("No template found for filetype: " .. filetype, vim.log.levels.ERROR)
    return
  end

  local bufnr = api.nvim_create_buf(true, true)
  api.nvim_buf_set_name(bufnr, "dabble_" .. filetype .. "_" .. os.time())
  api.nvim_win_set_buf(0, bufnr)
  vim.bo[bufnr].filetype = filetype
  vim.bo[bufnr].buftype = ""
  api.nvim_buf_set_var(bufnr, "dabble_filetype", filetype)
  local template = config.templates[filetype]
  api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(template, "\n"))
end

--- @param config table The plugin configuration
function M.run_buffer(config)
  local bufnr = api.nvim_get_current_buf()

  local ok, filetype = pcall(api.nvim_buf_get_var, bufnr, "dabble_filetype")
  if not ok then
    vim.notify("Not a dabble buffer", vim.log.levels.ERROR)
    return
  end

  if not config.runners[filetype] then
    vim.notify("No runner configured for filetype: " .. filetype, vim.log.levels.ERROR)
    return
  end

  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local temp_path = vim.fn.tempname()
  local file_extension = "." .. filetype
  local temp_file = temp_path .. file_extension

  local file = io.open(temp_file, "w")
  if not file then
    vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
    return
  end
  file:write(table.concat(lines, "\n"))
  file:close()

  local out_bufnr = M._create_output_buffer()

  local runner = config.runners[filetype]
  if runner.compile then
    local compile_cmd = string.format(runner.compile, temp_file, temp_path)
    M._execute_command(compile_cmd, out_bufnr, function(success)
      if success then
        local run_cmd = string.format(runner.run, temp_path)
        M._execute_command(run_cmd, out_bufnr)
      else
        vim.notify("Bad compile command: " .. compile_cmd)
      end
    end)
  else
    local run_cmd = string.format(runner.run, temp_file)
    M._execute_command(run_cmd, out_bufnr)
  end
end

--- @return number bufnr The buffer number of the output buffer
function M._create_output_buffer()
  local bufnr = nil

  for _, buf in ipairs(api.nvim_list_bufs()) do
    local name = api.nvim_buf_get_name(buf)
    if name:match("dabble_output$") then
      bufnr = buf
      break
    end
  end

  if not bufnr then
    bufnr = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(bufnr, "dabble_output")
    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].swapfile = false
  end

  api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

  local win_id = nil
  for _, win in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_buf(win) == bufnr then
      win_id = win
      break
    end
  end

  if not win_id then
    vim.cmd("botright split")
    win_id = api.nvim_get_current_win()
    api.nvim_win_set_buf(win_id, bufnr)
    vim.cmd("resize 10") -- Set height to 10 lines
  end

  return bufnr
end

--- @param cmd string
--- @param out_bufnr number
--- @param callback? fun(success: boolean)
function M._execute_command(cmd, out_bufnr, callback)
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        api.nvim_buf_set_lines(out_bufnr, -1, -1, false, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        api.nvim_buf_set_lines(out_bufnr, -1, -1, false, data)
      end
    end,
    on_exit = function(_, exit_code)
      if not callback or exit_code ~= 0 then
        local status = exit_code == 0 and "Success" or "Failed"
        api.nvim_buf_set_lines(out_bufnr, -1, -1, false, { "", "[" .. status .. " - Exit code: " .. exit_code .. "]" })
      end
      if callback then
        callback(exit_code == 0)
      end
    end,
  })
end

return M
