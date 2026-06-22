local M = {}

------------------------------------------------------------
-- metadata
------------------------------------------------------------
M.id = "set_source_offsets_from_timeline"
M.title = "Set Source Offsets"
M.column = 2

------------------------------------------------------------
-- main
------------------------------------------------------------
local function execute()

  local count = reaper.CountSelectedMediaItems(0)
  if count == 0 then return end

  ----------------------------------------------------------
  -- collect items
  ----------------------------------------------------------
  local items = {}

  for i = 0, count - 1 do
    items[#items + 1] = reaper.GetSelectedMediaItem(0, i)
  end

  ----------------------------------------------------------
  -- sort by position
  ----------------------------------------------------------
  table.sort(items, function(a, b)
    return reaper.GetMediaItemInfo_Value(a, "D_POSITION")
         < reaper.GetMediaItemInfo_Value(b, "D_POSITION")
  end)

  ----------------------------------------------------------
  -- first position
  ----------------------------------------------------------
  local first_pos =
    reaper.GetMediaItemInfo_Value(items[1], "D_POSITION")

  ----------------------------------------------------------
  -- apply
  ----------------------------------------------------------
  reaper.Undo_BeginBlock()

  for _, item in ipairs(items) do
    local take = reaper.GetActiveTake(item)

    if take then
      local pos =
        reaper.GetMediaItemInfo_Value(item, "D_POSITION")

      local offset = pos - first_pos

      reaper.SetMediaItemTakeInfo_Value(take, "D_STARTOFFS", offset )
    end
  end

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Set source offsets from timeline positions", -1)
end

------------------------------------------------------------
-- UI
------------------------------------------------------------
function M.draw(ctx)
  if reaper.ImGui_Button(ctx, "実時間で開始位置設定", -1, 0) then
    execute()
  end
end

return M
