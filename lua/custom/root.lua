local Root = {}

Root.waterfall = { "lsp", "dune", { ".git", ".hg" }, "cwd_if_contains_buf", "buf_path" }

Root.path_detectors = {}
Root.buf_detectors = {}

function Root.buf_detectors.buf_path(buf)
  return vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
end

local function path_contains_other(path, other)
  for dir in vim.fs.parents(other) do
    if dir == path then
      return true
    end
  end
  return false
end

function Root.buf_detectors.cwd_if_contains_buf(buf)
  local cwd = vim.fn.getcwd()
  if path_contains_other(cwd, vim.api.nvim_buf_get_name(buf)) then
    return cwd
  end
end

function Root.path_detectors.find_names(path, names)
  local matched = vim.fs.find(names, { path = path, upward = true })[1]
  if matched then
    return vim.fs.dirname(matched)
  end
end

function Root.path_detectors.dune(path)
  local acc
  for dir in vim.fs.parents(path) do
    if vim.fn.filereadable(dir .. "/dune-workspace") == 1 then
      acc = dir .. "/dune-workspace"
    elseif vim.fn.filereadable(dir .. "/dune-project") == 1 then
      if acc and vim.fs.basename(acc) ~= "dune-workspace" then
        acc = dir .. "/dune-project"
      end
    end
  end
  if acc then
    return vim.fs.dirname(acc)
  end
end

function Root.buf_detectors.lsp(buf)
  local buf_path = vim.api.nvim_buf_get_name(buf)
  for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = buf })) do
    for _, workspace in ipairs(client.config.workspace_folders or {}) do
      local root = vim.uri_to_fname(workspace.uri)
      if path_contains_other(root, buf_path) then
        return root
      end
    end
  end
end

function Root.resolve(waterfall)
  local waterfall_fn = {}
  for key, detector_spec in ipairs(waterfall) do
    local detector_fn
    if Root.buf_detectors[detector_spec] then
      detector_fn = Root.buf_detectors[detector_spec]
    elseif Root.path_detectors[detector_spec] then
      detector_fn = function(buf)
        local path = vim.api.nvim_buf_get_name(buf)
        return Root.path_detectors[detector_spec](path)
      end
    elseif type(detector_spec) == "table" then
      detector_fn = function(buf)
        local path = vim.api.nvim_buf_get_name(buf)
        return Root.path_detectors.find_names(path, detector_spec)
      end
    elseif type(detector_spec) == "function" then
      detector_fn = detector_spec
    else
      error("root.resolve: invalid root spec")
    end
    waterfall_fn[key] = detector_fn
  end

  return function(buf)
    for _, detector_fn in ipairs(waterfall_fn) do
      local root = detector_fn(buf)
      if root then
        return root
      end
    end
    error("Unable to determine buffer root")
  end
end

function Root.get_for_buf(buf)
  if not Root.cache_get_fn then
    Root.cache_get_fn = Root.resolve(Root.waterfall)
  end

  return Root.cache_get_fn(buf or vim.api.nvim_get_current_buf())
end

return Root
