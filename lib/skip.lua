Skip = {}

function Skip:new(args)
  local o = setmetatable( {}, {__index = Skip} )
  local args = args == nil and {} or args

  o.skip = args.skip == nil and 1 or args.skip
  o.mod = args.mod == nil and 0 or args.mod
  o.action = args.action == nil and function() return true end or args.action
  o.count = 0

  return o
end

function Skip:play(args)
  local args = args == nil and {} or args
  
	local updated_args = {}
	for k, v in pairs(args) do
	  if sequins.is_sequins(v) or type(v) == 'function' then
	    updated_args[k] = v()
	  else
	    updated_args[k] = v
	  end
		if updated_args[k] == nil then
		  return
		end
	  -- -- for use with unaltered sequins
		-- if type(updated_args) == 'table' then
		-- 	if updated_args[1] == nil then -- sequins returns an empty table so the first index will be negative in this instance
		-- 		return
		-- 	end
		-- end
	end
	args = updated_args
  
  local skip, mod, val
  
  skip = args.skip == nil and self.skip or args.skip
  mod = args.mod == nil and self.mod or args.mod
  val = self.action()
  
  self.count = self.count + 1

  return self.count % skip == mod % skip and val or nil
end

function Skip:reset()
  self.count = 0
end

function Skip.update(data)
  local updated = {}
  for k, v in pairs(data) do
    updated[k] = type(v) == 'table' and data[k]() or data[k]
  end
  return updated
end

return Skip