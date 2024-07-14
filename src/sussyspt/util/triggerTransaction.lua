local values = require("sussyspt/values")

return function(rs, hash, amount)
    local b = values.g.transaction_base
    globals.set_int(b + 1, 2147483646)
    globals.set_int(b + 7, 2147483647)
    globals.set_int(b + 6, 0)
    globals.set_int(b + 5, 0)
    globals.set_int(b + 3, hash)
    globals.set_int(b + 2, amount)
    globals.set_int(b, 1)
    if rs ~= nil then
        rs:yield()
        globals.set_int(b + 1, 2147483646)
        globals.set_int(b + 7, 2147483647)
        globals.set_int(b + 6, 0)
        globals.set_int(b + 5, 0)
        globals.set_int(b + 3, 0)
        globals.set_int(b + 2, 0)
        globals.set_int(b, 16)
    end
end
