sequins = require('sequins_dl'); s = sequins

Seq = {}

function Seq:new(args)
  local o = setmetatable( {}, {__index = Seq} )
  local args = args == nil and {} or args

  o.s = args.s == nil and s{1,2,3,4} or args.s
  o.div = args.div == nil and 1 or args.div -- sequins is only called on division
  o.step = args.step == nil and 1 or args.step -- make it is so step is the same step as in sequins
  o.skip = args.skip == nil and 1 or args.skip -- sequins is called, but result not returned
  o.prob = args.prob == nil and 1 or args.prob -- sequins is called, but only returns if true
  
  o.offset = args.offset == nil and 0 or args.offset -- how many steps to wait before starting
  o.action = args.action -- if there is a function then the sequins() is passed to the action, or just returns the sequins

  o.offset_count = - o.offset
  o.div_count = 0
  o.val = 0

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

  local s, div, step, skip, prob
  local next
  
  s = self.s
  div = self.div * (args.div == nil and 1 or args.div)
  step = args.step == nil and self.step or args.step
  skip = args.skip == nil and self.skip or args.skip
  prob = args.prob == nil and self.prob or args.prob

  self.s:step(step) -- untested

  self.offset_count = self.offset_count + 1

  self.div_count = self.offset_count >= 1
    and self.div_count % div + 1
    or self.div_count

  -- or just do some if statements
  -- skip currently does what div should do
  -- and div does nothing

  -- self.val = self.offset_count >= 1 and self.div_count == 1 -- combine with next
  --   and self.s()
  --   or self.s[self.s.ix]
    
  next = (self.offset_count - 1) % skip == 0 and prob >= math.random()
  self.val = next and self.s() or self.s[self.s.ix]
	
  return next and self.offset_count >= 1 and self.div_count == 1 and self.action ~= nil
    and self.action(self.val)
    or self.val
end

function Seq:reset()
  self.offset_count = - self.offset
  self.div_count = 0
  self.s:reset()
end

function Seq:set_div()
end

function Seq:set_skip()
end

function Seq:set_prob()
end

function Seq:set_step()
end