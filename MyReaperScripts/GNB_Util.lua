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

package.path =
    script_path .. "?.lua;" ..
    script_path .. "?/init.lua;" ..
    package.path

local tools = {}
local tools_path = script_path .. "tools"

local i = 0
while true do
  local file = reaper.EnumerateFiles(tools_path, i)
  
  if not file then break end

  if file:match("%.lua$") then
    local module = "tools." .. file:gsub("%.lua$", "")
    local ok, tool = pcall(require, module)

    if ok and type(tool) == "table" then
      table.insert(tools, tool)
    else
      reaper.ShowConsoleMsg(
        ("Failed to load %s\n%s\n\n")
        :format(module, tostring(tool))
      )
    end
  end

  i = i + 1
end

------------------------------------------------------------
-- Sort tools
------------------------------------------------------------
table.sort(tools, function(a, b)
  local ca = a.column or 1
  local cb = b.column or 1

  if ca ~= cb then
    return ca < cb
  end
  
  local ta = a.title or a.id or ""
  local tb = b.title or b.id or ""

  return ta < tb

end)

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
