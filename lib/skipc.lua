-- skip closure for use with functions (such as sequins)

local function skip(fn)
  local count = 0
  return
    function(skip, mod)
      skip = skip == nil and 1 or skip
      mod = mod == nil and 0 or mod
      count = (count + 1) % skip
      local val = fn()
      return count == mod and val or nil
    end
end
    
return skip