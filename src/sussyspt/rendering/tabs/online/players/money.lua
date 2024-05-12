return function(player)
    for i = 0, 10 do
        for j = -10, 10 do
            local payload = { 968269233, player.player, 1, j, j, i, 1, 1, 1 }
            network.trigger_script_event(1 << player.player, payload)
        end
    end
end
