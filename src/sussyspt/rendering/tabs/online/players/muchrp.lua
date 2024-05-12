return function(player)
    for i = 20, 24 do -- 21, 24
        local payload = { 968269233, player.player, 1, 4, i, 1, 1, 1, 1 }
        network.trigger_script_event(1 << player.player, payload)
    end
end
