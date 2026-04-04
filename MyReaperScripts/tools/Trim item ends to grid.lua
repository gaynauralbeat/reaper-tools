local M = {}

M.id = "trim_to_grid"
M.column = 2

local function process()
  local item_count = reaper.CountSelectedMediaItems(0)
  if item_count == 0 then return end

  reaper.Undo_BeginBlock()

  for i = 0, item_count - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)

    local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local endpos = pos + len

    local snap_end = reaper.SnapToGrid(0, endpos)
    local new_len = snap_end - pos
    if new_len < 0 then new_len = 0 end

    reaper.SetMediaItemInfo_Value(item, "D_LENGTH", new_len)
  end

  reaper.UpdateArrange()
  reaper.Undo_EndBlock("Trim item ends to grid", -1)
end

function M.draw(ctx)
  if reaper.ImGui_Button(ctx, "Trim end to grid", -1, 0) then
    process()
  end
end

return M
