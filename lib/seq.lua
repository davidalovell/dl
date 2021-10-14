local Seq = {}

function Seq:new(args)
  local o = setmetatable( {}, {__index = Seq} )
  local args = args == nil and {} or args

  o.sequence = args.sequence == nil and {1} or args.sequence
  o.division = args.division == nil and 1 or args.division
  o.step = args.step == nil and 1 or args.step
  o.every = args.every == nil and 1 or args.every
  o.prob = args.prob == nil and 1 or args.prob
  o.offset = args.offset == nil and 0 or args.offset
  o.action = args.action

  o.count = - o.offset
  o.div_count = 0
  o.step_count = 0
  o.index = args.index == nil and 1 or args.index

  return o
end

function Seq:play(args)
  -- TODO:
  -- 1. add other args
  -- 4. comments to define count, div_count, step_count
  -- 5. step(2) starts and index = 2, and should start at 1
  -- 5. ? remove s = self (low priority)  

  local args = args == nil and {} or self.update(args)
  local sequence, division, step, every, prob, action, index
  local next
  
  sequence = args.sequence == nil and self.sequence or args.sequence
  division = self.division * (args.division == nil and 1 or args.division)
  step = self.step * (args.step == nil and 1 or args.step)
  every = args.every == nil and self.every or args.every
  prob = args.prob == nil and self.prob or args.prob
  action = args.action == nil and self.action or args.action
  index = args.index == nil and self.index or args.index -- todo

  self.count = self.count + 1

  self.div_count = self.count >= 1
    and self.div_count % division + 1
    or self.div_count

  self.step_count = self.count >= 1 and self.div_count == 1
    and ((self.step_count + step) - 1) % #sequence + 1
    or self.step_count

  next = (self.count - 1) % every == 0 and prob >= math.random()
  self.index = next and self.step_count or self.index

  return next and self.count >= 1 and self.div_count == 1 and self.action ~= nil
    and self.action(sequence[self.index])
    or sequence[self.index] --or 0
end

function Seq:reset()
  -- TODO add args here?
  self.count = - self.offset
  self.div_count = 0
  self.step_count = 0
  self.index = 1
end

function Seq.update(data)
  local updated = {}
  for k, v in pairs(data) do
    updated[k] = type(v) == 'function' and data[k]() or data[k]
  end
  return updated
end

return Seq
