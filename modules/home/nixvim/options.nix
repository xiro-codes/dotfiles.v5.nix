{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.local.nixvim;
in
{
  globals.mapleader = ";";
  opts = {
    number = true;
    relativenumber = true;
    shiftwidth = 2;
    tabstop = 2;
    expandtab = true;
    undofile = true;
    undolevels = 10000;
    termguicolors = false;
  };
  extraConfigLua = mkIf cfg.smartUndo ''
    local function setup_smart_undo()
      local dot_git = vim.fn.finddir(".git", ".;")
      if dot_git ~= "" then
        local repo_root = vim.fn.fnamemodify(dot_git, ":h")
        local marker = repo_root .. "/.undo"
        if vim.fn.filereadable(marker) == 1 or vim.fn.isdirectory(marker) == 1 then
          local undo_path = repo_root .. "/.undo_dir"
          if vim.fn.isdirectory(undo_path) == 0 then vim.fn.mkdir(undo_path, "p") end
          vim.opt.undodir = undo_path
          return
        end
      end
      local permanent_path = vim.fn.expand("~/.cache/nvim/undo-permanent")
      if vim.fn.isdirectory(permanent_path) == 0 then vim.fn.mkdir(permanent_path, "p") end
      vim.opt.undodir = permanent_path
    end

    vim.api.nvim_create_user_command("SmartUndoInit", function()
      local dot_git = vim.fn.finddir(".git", ".;")
      if dot_git ~= "" then
        local repo_root = vim.fn.fnamemodify(dot_git, ":h")
        local marker = repo_root .. "/.undo"
        local f = io.open(marker, "w")
        if f then f:close() end
        local undo_path = repo_root .. "/.undo_dir"
        if vim.fn.isdirectory(undo_path) == 0 then vim.fn.mkdir(undo_path, "p") end
        vim.opt.undodir = undo_path
        print("Smart Undo initialized for this repo")
      else
        print("Not in a git repository")
      end
    end, {})

    vim.api.nvim_create_user_command("SmartUndoClear", function()
      local dir = vim.opt.undodir:get()
      if dir and vim.fn.isdirectory(dir) == 1 then
        for _, file in ipairs(vim.fn.globpath(dir, "*", 0, 1)) do
          vim.fn.delete(file)
        end
        print("Cleared " .. dir)
      end
    end, {})

    vim.api.nvim_create_user_command("SmartUndoPlayback", function(opts)
      local speed = tonumber(opts.args) or 150
      local tree = vim.fn.undotree()

      -- If at the latest state, try going back to the last file save
      if tree.seq_cur == tree.seq_last then
        pcall(function() vim.cmd("earlier 1f") end)
      end

      local function step()
        local before = vim.fn.undotree().seq_cur
        pcall(function() vim.cmd("redo") end)
        local after = vim.fn.undotree().seq_cur

        if before ~= after then
          vim.cmd("redraw")
          vim.defer_fn(step, speed)
        else
          print("Playback complete")
        end
      end

      vim.defer_fn(step, speed)
    end, { nargs = "?" })

    -- Automatically start a server for Godot to connect to
    local function start_godot_server()
      local path = vim.fn.getcwd() .. "/project.godot"
      if vim.loop.fs_stat(path) then
        -- Using a pipe for Linux/NixOS environments
        vim.fn.serverstart('/tmp/godot.pipe')
      end
    end

    start_godot_server()
    setup_smart_undo()

  '';
}
