return function(player)
    for i = -1, 1 do
        local payload = { 1450115979, player.player, i }
        network.trigger_script_event(1 << player.player, payload)
    end
end
