local Seq = {}

function Seq:new(args)
  local o = setmetatable( {}, {__index = Seq} )
  local t = args or {}

  o.sequence = t.sequence == nil and {1} or t.sequence
  o.division = t.division == nil and 1 or t.division
  o.step = t.step == nil and 1 or t.step
  o.every = t.every == nil and 1 or t.every
  o.prob = t.prob == nil and 1 or t.prob
  o.offset = t.offset == nil and 0 or t.offset
  o.action = t.action

  o._division = 1 -- remove
  o._step = 1 -- remove

  o.count = - o.offset
  o.div_count = 0
  o.step_count = 0
  o.index = t.index == nil and 1 or t.index

  return o
end

function Seq:__division() return self.division * self._division end
function Seq:__step() return self.step * self._step end

function Seq:play_seq()
  -- NEW 
  local args = args == nil and {} or self.update(args)
  local sequence, division, step, every, prob, --[[offset,]] action, index
  
  sequence = args.sequence == nil and self.sequence or args.sequence
  division = args.division == nil and self.division or args.division
  step = args.step == nil and self.step or args.step
  every = args.every == nil and self.every or args.every
  prob = args.prob == nil and self.prob or args.prob
  -- offset = args.offset == nil and self.offset or args.offset
  action = args.action == nil and self.action or args.action
  index = args.index == nil and self.index or args.index
 
  -- TODO:
  -- 1. add other args
  -- 2. remove _division, _step
  -- 2. change from __division() and __step() to something like that in Vox
  -- 4. comments to define count, div_count, step_count
  -- 5. ? remove s = self (low priority)  
  
  local s = self
  s.count = s.count + 1

  s.div_count = s.count >= 1
    and s.div_count % s:__division() + 1
    or s.div_count

  s.step_count = s.count >= 1 and s.div_count == 1
    and ((s.step_count + s:__step()) - 1) % #s.sequence + 1
    or s.step_count

  s.next = (s.count - 1) % s.every == 0 and s.prob >= math.random()
  s.index = s.next and s.step_count or s.index

  return s.next and s.count >= 1 and s.div_count == 1 and s.action ~= nil
    and s.action(s.sequence[s.index])
    or s.sequence[s.index] --or 0
end

function Seq:reset()
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
