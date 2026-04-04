local M = {}

M.id = "trim_to_source"
M.title = "Trim"
M.column = 2

local function process()
  local num_items = reaper.CountSelectedMediaItems(0)
  if num_items == 0 then return end

  reaper.Undo_BeginBlock()

  for i = 0, num_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake(item)
    if take then
      local src = reaper.GetMediaItemTake_Source(take)
      local src_len = reaper.GetMediaSourceLength(src)

      local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

      -- take start offset を考慮
      local start_offs = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
      local new_len = src_len - start_offs
      if new_len < 0 then new_len = 0 end

      -- 一旦ソース長に合わせる
      reaper.SetMediaItemInfo_Value(item, "D_LENGTH", new_len)

      -- 次アイテムとの被り防止
      local track = reaper.GetMediaItem_Track(item)
      local idx = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
      local next_item = reaper.GetTrackMediaItem(track, idx + 1)

      if next_item then
        local next_pos = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
        local end_pos = pos + new_len
        if end_pos > next_pos then
          local safe_len = next_pos - pos
          if safe_len < 0 then safe_len = 0 end
          reaper.SetMediaItemInfo_Value(item, "D_LENGTH", safe_len)
        end
      end
    end
  end

  reaper.UpdateArrange()
  reaper.Undo_EndBlock("Trim to source length (avoid overlap)", -1)
end

function M.draw(ctx)
  if reaper.ImGui_Button(ctx, "Trim to source", -1, 0) then
    process()
  end
end

return M
