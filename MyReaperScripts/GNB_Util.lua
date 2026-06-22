-- =========================================================
-- main.lua
-- Batch Item Tools (ImGui)
-- =========================================================

local reaper = reaper

------------------------------------------------------------
-- ImGui context
------------------------------------------------------------
local ctx = reaper.ImGui_CreateContext("Batch Item Tools")
reaper.ImGui_SetNextWindowDockID(ctx, 0)

------------------------------------------------------------
-- Load tools
------------------------------------------------------------
local script_path = debug.getinfo(1, "S").source:match("@?(.*[\\/])")
package.path = script_path .. "?.lua;" .. script_path .. "?/init.lua;" .. package.path

local tools = {
  require("tools/Set item playrate by simple ratios"),
  require("tools/Trim to source length (and avoid overlap)"),
  require("tools/Trim item ends to grid"),
  require("tools/Fade by bar fraction"),
  require("tools/Set source offsets from timeline"),
}

------------------------------------------------------------
-- Calculate column count
------------------------------------------------------------
local max_column = 1
for _, tool in ipairs(tools) do
  if type(tool.column) == "number" and tool.column > max_column then
    max_column = tool.column
  end
end

------------------------------------------------------------
-- Main loop
------------------------------------------------------------
local function main_loop()
  if reaper.ImGui_IsKeyPressed(ctx, reaper.ImGui_Key_Space()) then
    reaper.Main_OnCommand(40044, 0) -- Transport: Play/Stop
  end

  local visible, open = reaper.ImGui_Begin(ctx, "Batch Item Tools", true, reaper.ImGui_WindowFlags_NoDocking())

  if visible then
    if reaper.ImGui_BeginTable(ctx, "tools_table", max_column) then
      for col = 1, max_column do
        reaper.ImGui_TableNextColumn(ctx)

        for _, tool in ipairs(tools) do
          if tool.column == col then
            if tool.title and tool.title ~= "" then
              reaper.ImGui_Text(ctx, tool.title)
              reaper.ImGui_Separator(ctx)
            end

            tool.draw(ctx)
            reaper.ImGui_Spacing(ctx)
          end
        end
      end

      reaper.ImGui_EndTable(ctx)
    end

    reaper.ImGui_End(ctx)
  end

  -- continue or quit
  if open then
    reaper.defer(main_loop)
  else
    if reaper.ImGui_DestroyContext then
      reaper.ImGui_DestroyContext(ctx)
    end
  end
end

------------------------------------------------------------
-- Entry
------------------------------------------------------------
reaper.defer(main_loop)
