-- seqwrap is a wrapper for sequins
-- allows division, skip, beat (i.e. which 'beat' division or skip occurs), hold (allows for ratcheting), probability that a note will return (sequins will advance)

local Seq = {}
local sequins = require('sequins'); s = sequins

function Seq:new(args)
  local o = setmetatable( {}, {__index = Seq} )
  local args = args == nil and {} or args

  o.seq = args.seq == nil and {1,2,3,4,5,6,7} or args.s; o.s = s(o.seq)
  o.step = args.step == nil and 1 or args.step; o.s:step(o.step)

  o.div = args.div == nil and 1 or args.div
  o.skip = args.skip == nil and 1 or args.skip
  o.beat = args.beat == nil and 1 or args.beat
  o.prob = args.prob == nil and 1 or args.prob
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

    if updated_args[k] == nil then
		  return
		end
	end

	args = updated_args

  local seq = args.seq == nil and self.seq or args.seq; self.s:settable(seq)
  local step = args.step == nil and self.step or args.step; self.s:step(step)

  local div = self.div * (args.div == nil and 1 or args.div)
  local skip = args.skip == nil and self.skip or args.skip
  local beat = args.beat == nil and self.beat or args.beat
  local prob = args.prob == nil and self.prob or args.prob
  local hold = args.hold == nil and self.hold or args.hold
  local held

  self.count = self.count + 1

  if self.count >= 1 then
    if self.count % div == beat % div then
      held = false
      self.val = self.s()
    else
      held = true
      self.val = self.s[self.s.ix]
    end
    if self.count % (skip * div) == beat % (skip * div) and prob >= math.random() then
      held = false
      self.last = self.val
    else
      held = true
      self.val = self.last
    end
  end

  if not hold and held then
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

return Seq