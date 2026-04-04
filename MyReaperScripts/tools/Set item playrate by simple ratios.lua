local M = {}

M.id = "playrate"
M.title = "Playrate"
M.column = 1

------------------------------------------------------------
-- ratios (tool-local data)
------------------------------------------------------------
local ratios = {
  {label = "1/4 (0.250)", value = 1/4},
  {label = "1/3 (0.333)", value = 1/3},
  {label = "1/2 (0.500)", value = 1/2},
  {label = "2/3 (0.667)", value = 2/3},
  {label = "3/4 (0.750)", value = 3/4},
  {label = "1x",  value = 1/1},
  {label = "1+1/4 (1.250)", value = 5/4},
  {label = "1+1/3 (1.333)", value = 4/3},
  {label = "1+1/2 (1.500)", value = 3/2},
  {label = "1+2/3 (1.667)", value = 5/3},
  {label = "1+3/4 (1.750)", value = 7/4},
  {label = "2x", value = 2/1},
}

------------------------------------------------------------
-- check mixed playrates
------------------------------------------------------------
local function has_mixed_playrates()
  local count = reaper.CountSelectedMediaItems(0)
  if count <= 1 then return false end

  local base_rate = nil

  for i = 0, count - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake(item)
    if take then
      local rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
      if not base_rate then
        base_rate = rate
      elseif math.abs(rate - base_rate) > 1e-6 then
        return true
      end
    end
  end

  return false
end

------------------------------------------------------------
-- apply playrate
------------------------------------------------------------
local function apply_playrate(rate)
  local count = reaper.CountSelectedMediaItems(0)
  if count == 0 then return end

  if has_mixed_playrates() then
    local ret = reaper.ShowMessageBox(
      "選択アイテムに異なる再生速度が含まれています。\nこのまま上書きしますか？",
      "Playrate warning",
      1 -- OK / Cancel
    )
    if ret ~= 1 then return end
  end

  reaper.Undo_BeginBlock()

  for i = 0, count - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake(item)
    if take then
      reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", rate)
    end
  end

  reaper.UpdateArrange()
  reaper.Undo_EndBlock("Set item playrate", -1)
end

------------------------------------------------------------
-- UI
------------------------------------------------------------
function M.draw(ctx)
  for _, r in ipairs(ratios) do
    if reaper.ImGui_Button(ctx, r.label, -1, 0) then
      apply_playrate(r.value)
    end
  end
end

return M
