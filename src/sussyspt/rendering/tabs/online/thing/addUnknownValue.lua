return function(tbl, v)
    if tbl[v] == nil then
        tbl[v] = "??? ["..(v or "<null>").."]"
    end
end
