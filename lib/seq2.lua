sequins = require('sequins'); s = sequins

Seq = {}

function Seq:new(args)
  local o = setmetatable( {}, {__index = Seq} )
  local args = args == nil and {} or args

  o.seq = args.seq == nil and {1,2,3,4,5,6,7} or args.s
  o.s = s(o.seq)
  o.div = args.div == nil and 1 or args.div
  o.step = args.step == nil and 1 or args.step
  o.skip = args.skip == nil and 1 or args.skip
  o.prob = args.prob == nil and 1 or args.prob

  o.mod = args.mod == nil and 1 or args.mod
  o.hold = args.hold == nil and false or args.hold

  o.offset = args.offset == nil and 0 or args.offset
  o.action = args.action

  o.count = - o.offset
  o.val = 0
  o.last = o.val

  return o
end

function Seq:play(args)
  local args = args == nil and {} or args
  
	local updated_args = {}
	for k, v in pairs(args) do
	  if sequins.is_sequins(v) or type(v) == 'function' then
	    updated_args[k] = v()
	  else
	    updated_args[k] = v
	  end

    -- for use for functions that return nil
    -- for use with ALTERED sequins if you want to use the 'nested methods' out with nested sequins
    if updated_args[k] == nil then
		  return
		end

	  -- -- for use with UNALTERED sequins if you want to use the 'nested methods' out with nested sequins
		-- -- untested
    -- if type(updated_args) == 'table' then
		-- 	if updated_args[1] == nil then -- sequins returns an empty table so the first index will be nil in this instance
		-- 		return
		-- 	end
		-- end

	end

	args = updated_args

  local seq, div, step, skip, prob
  local mod, hold
  local held
  
  seq = args.seq == nil and self.seq or args.seq; self.s:settable(seq)
  div = self.div * (args.div == nil and 1 or args.div)
  step = args.step == nil and self.step or args.step; self.s:step(step)
  skip = args.skip == nil and self.skip or args.skip
  prob = args.prob == nil and self.prob or args.prob

  mod = args.mod == nil and self.mod or args.mod
  hold = args.hold == nil and self.hold or args.hold

  self.count = self.count + 1

  if self.count >= 1  then
    if self.count % div == mod % div then
      held = false
      self.val = self.s()
    else
      held = true
      self.val = self.s[self.s.ix]
    end
    if self.count % (skip * div) == mod % (skip * div) and prob >= math.random() then
      held = false
      self.last = self.val
    else
      held = true
      self.val = self.last
    end
  end

  if not hold and held then
    -- self.val = nil
    return
  end
  
  if self.action then 
    return self.action(self.val)
  else
    return self.val
  end

end

function Seq:reset()
  self.count = - self.offset
  self.val = 0
  self.last = self.val
  self.s:reset()
end