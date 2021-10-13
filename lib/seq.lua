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

  o._division = 1
  o._step = 1

  o.count = - o.offset
  o.div_count = 0
  o.step_count = 0
  o.index = 1

  return o
end

function Seq:__division() return self.division * self._division end
function Seq:__step() return self.step * self._step end

function Seq:play_seq()
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

return Seq