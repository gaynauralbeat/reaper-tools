local M   = {}

------------------------------------------------------------
-- metadata
------------------------------------------------------------
M.id      = "fade_by_bar_fraction"
M.title   = "Fade by Bar Fraction"
M.column  = 2

------------------------------------------------------------
-- UI state
------------------------------------------------------------
-- 分子は 1 固定
local den = 1 -- 分母（0 許可）

------------------------------------------------------------
-- core logic
------------------------------------------------------------
local function apply_fade(mode)
  local count = reaper.CountSelectedMediaItems(0)
  if count == 0 then return end

  reaper.Undo_BeginBlock()

  for i = 0, count - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    if item then
      local pos

      if mode == "in" then
        -- アイテム開始位置
        pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      else
        -- アイテム終了位置
        local start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local len   = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        pos         = start + len
      end

      local fade_sec = 0

      if den ~= 0 then
        local bpm = reaper.TimeMap_GetDividedBpmAtTime(pos)
        local bar_sec = (60 / bpm) * 4 -- 4拍 = 仮想的な1小節
        fade_sec = bar_sec / den       -- 分子は常に 1
      end

      if mode == "in" then
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fade_sec)
      else
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fade_sec)
      end
    end
  end

  reaper.UpdateArrange()
  reaper.Undo_EndBlock("Set item fade by bar fraction (tempo-aware)", -1)
end

------------------------------------------------------------
-- UI
------------------------------------------------------------
function M.draw(ctx)
  reaper.ImGui_Text(ctx, "Fade = 1 bar /")

  reaper.ImGui_SameLine(ctx)
  reaper.ImGui_PushItemWidth(ctx, 40)

  _, den = reaper.ImGui_InputInt(ctx, "##fade_den", den, 0, 0)

  reaper.ImGui_PopItemWidth(ctx)

  if den < 0 then den = 0 end

  if reaper.ImGui_Button(ctx, "Apply Fade In", -1, 0) then
    apply_fade("in")
  end

  if reaper.ImGui_Button(ctx, "Apply Fade Out", -1, 0) then
    apply_fade("out")
  end
end

return M
