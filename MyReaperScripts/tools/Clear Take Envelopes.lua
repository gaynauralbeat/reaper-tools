local M = {}

------------------------------------------------------------
-- metadata
------------------------------------------------------------
M.id = "clear_take_envelopes"
M.title = "Clear Take Envelopes"
M.column = 2

------------------------------------------------------------
-- clear envelopes
------------------------------------------------------------
local function execute()

    local itemCount = reaper.CountSelectedMediaItems(0)
    if itemCount == 0 then return end

    reaper.Undo_BeginBlock()

    for i = 0, itemCount - 1 do

        local item = reaper.GetSelectedMediaItem(0, i)
        local take = reaper.GetActiveTake(item)

        if take then

            local envIndex = 0

            while true do

                local env = reaper.GetTakeEnvelope(take, envIndex)
                if not env then break end

                -- 全ポイント削除
                reaper.DeleteEnvelopePointRangeEx(
                    env,
                    -1,
                    -math.huge,
                    math.huge
                )

                reaper.Envelope_SortPointsEx(env, -1)

                -- エンベロープを非表示
                local _, chunk = reaper.GetEnvelopeStateChunk(env, "", false)
                chunk = chunk:gsub("VIS %d", "VIS 0")
                chunk = chunk:gsub("ACT %d", "ACT 0")
                reaper.SetEnvelopeStateChunk(env, chunk, false)

                envIndex = envIndex + 1
            end
        end
    end

    reaper.UpdateArrange()

    reaper.Undo_EndBlock(
        "Clear take envelopes",
        -1
    )

end

------------------------------------------------------------
-- UI
------------------------------------------------------------
function M.draw(ctx)

    if reaper.ImGui_Button(ctx, "Clear Take Envelopes", -1, 0) then
        execute()
    end

end

return M
