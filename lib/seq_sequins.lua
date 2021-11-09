-- the idea here is to build wrapper for standard sequins
-- so it can skip, divide etc 
-- this is currently very empryonic and based on seq

-- local 
Seq = {}
-- local
sequins = require 'sequins_dl'

function Seq:new(args)
  local o = setmetatable( {}, {__index = Seq} )
  local args = args == nil and {} or args

  o.s = args.s == nil and sequins{1,2,3,4} or args.s

  o.seq = args.seq == nil and {1} or args.seq
  o.div = args.div == nil and 1 or args.div
  o.step = args.step == nil and 1 or args.step
  o.skip = args.skip == nil and 1 or args.skip
  o.prob = args.prob == nil and 1 or args.prob
  
  o.offset = args.offset == nil and 0 or args.offset
  o.action = args.action

  o.offset_count = - o.offset
  o.div_count = 0
  o.step_count = 1 - o.step
  o.ix = 1

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

  local s
  local seq, div, step, skip, prob
  local next
  
  s = args.s == nil and self.s or args.s

  seq = args.seq == nil and self.seq or args.seq
  div = self.div * (args.div == nil and 1 or args.div)
  step = self.step * (args.step == nil and 1 or args.step)
  skip = args.skip == nil and self.skip or args.skip
  prob = args.prob == nil and self.prob or args.prob

  self.offset_count = self.offset_count + 1

  self.div_count = self.offset_count >= 1
    and self.div_count % div + 1
    or self.div_count

  self.step_count = self.offset_count >= 1 and self.div_count == 1
    and ((self.step_count + step) - 1) % #seq + 1
    or self.step_count

  next = (self.offset_count - 1) % skip == 0 and prob >= math.random()
  -- self.ix = next and self.step_count or self.ix

  if next then
    return self.s()
  else
    return self.s[self.s.ix]
  end


	
  -- return next and self.offset_count >= 1 and self.div_count == 1 and self.action ~= nil
  --   and self.action(seq[self.ix])
  --   or seq[self.ix] --or 0
end

function Seq:reset()
  self.offset_count = - self.offset
  self.div_count = 0
  self.step_count = 1 - self.step
  self.ix = 1
end

-- return Seq
