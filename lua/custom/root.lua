local Root = {}

Root.waterfall = { "lsp", "dune", { ".git", ".hg" }, "cwd_if_contains_buf", "buf_path" }

Root.path_detectors = {}
Root.buf_detectors = {}

local realpath = vim.loop.fs_realpath

---@return string|nil
local function get_cwd()
  local dir = vim.loop.cwd()
  if dir ~= nil then
    return realpath(dir)
  end
end

---@param buf integer
---@return string|nil
function Root.buf_detectors.buf_path(buf)
  local buf_name = vim.api.nvim_buf_get_name(buf)
  if buf_name == "" then
    return get_cwd()
  end

  if vim.fn.isdirectory(buf_name) == 1 then
    return realpath(buf_name)
  end
  return realpath(vim.fs.dirname(buf_name))
end

---@param path string
---@param other string
---@return boolean
local function path_contains_other(path, other)
  for dir in vim.fs.parents(other) do
    if dir == path then
      return true
    end
  end
  return false
end

---@param buf integer
---@return string|nil
function Root.buf_detectors.cwd_if_contains_buf(buf)
  local cwd = get_cwd()
  local buf_path = Root.buf_detectors.buf_path(buf)
  if cwd ~= nil and buf_path ~= nil and path_contains_other(cwd, buf_path) then
    return cwd
  end
end

---@param path string
---@param names string[]
---@return string|nil
function Root.path_detectors.find_names(path, names)
  local matched = vim.fs.find(names, { path = path, upward = true })[1]
  if matched then
    return realpath(vim.fs.dirname(matched))
  end
end

---@param path string
---@return string|nil
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
    return realpath(vim.fs.dirname(acc))
  end
end

---@param buf integer
---@return string|nil
function Root.buf_detectors.lsp(buf)
  local buf_path = Root.buf_detectors.buf_path(buf)
  if buf_path ~= nil then
    for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = buf })) do
      for _, workspace in ipairs(client.config.workspace_folders or {}) do
        local root = realpath(vim.uri_to_fname(workspace.uri))
        if root ~= nil and path_contains_other(root, buf_path) then
          return root
        end
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
        local path = Root.buf_detectors.buf_path(buf)
        if path ~= nil then
          return Root.path_detectors[detector_spec](path)
        end
      end
    elseif type(detector_spec) == "table" then
      detector_fn = function(buf)
        local path = Root.buf_detectors.buf_path(buf)
        if path ~= nil then
          return Root.path_detectors.find_names(path, detector_spec)
        end
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
  end
end

---@param buf integer
---@return string
function Root.get_for_buf(buf)
  if not Root.cache_get_fn then
    Root.cache_get_fn = Root.resolve(Root.waterfall)
  end

  return Root.cache_get_fn(buf or vim.api.nvim_get_current_buf())
end

return Root
