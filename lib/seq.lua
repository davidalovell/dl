local Seq = {}

function Seq:new(args)
  local o = setmetatable( {}, {__index = Seq} )
  local args = args == nil and {} or args

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
  local args = args == nil and {} or self.update(args)
  local seq, div, step, skip, prob
  local next
  
  seq = args.seq == nil and self.seq or args.seq
  div = self.div * (args.div == nil and 1 or args.div)
	  -- div = args.div == nil and self.div or args.div
  step = args.step == nil and self.step or args.step
	  -- step = self.step * (args.step == nil and 1 or args.step)
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
  self.ix = next and self.step_count or self.ix
	
  return next and self.offset_count >= 1 and self.div_count == 1 and self.action ~= nil
    and self.action(seq[self.ix])
    or seq[self.ix] --or 0
end

function Seq:reset(args)
  self.offset_count = - self.offset
  self.div_count = 0
  self.step_count = 1 - self.step
  self.ix = 1
end

function Seq.update(data)
  local updated = {}
  for k, v in pairs(data) do
    updated[k] = type(v) == 'function' and data[k]() or data[k]
  end
  return updated
end

function Seq.call_if_fn(val)
  return type(val) == 'function' and val() or val
end

return Seq
