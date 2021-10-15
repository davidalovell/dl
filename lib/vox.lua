local Vox = {}

function Vox:new(args)
  local o = setmetatable( {}, {__index = Vox} )
  local args = args == nil and {} or args

  o.on = args.on == nil and true or args.on
  o.level = args.level == nil and 1 or args.level -- max cc velocity
  o.scale = args.scale == nil and {0,2,4,6,7,9,11} or args.scale -- lydian
  o.transpose = args.transpose == nil and 0 or args.transpose -- C0
  o.degree = args.degree == nil and 1 or args.degree
  o.octave = args.octave == nil and 5 or args.octave -- C5
  o.synth = args.synth == nil and function(note, level, length, channel) return note, level, length, channel end or args.synth
  o.wrap = args.wrap ~= nil and args.wrap or false
  o.mask = args.mask -- could use snap?
  o.negharm = args.negharm ~= nil and args.negharm or false

  -- midi specific
  o.length = args.length == nil and 1 or args.length
  o.channel = args.channel == nil and 1 or args.channel

  -- empty tables
  o.seq = args.seq == nil and {} or args.seq -- change to s
  o.clk = args.clk == nil and {} or args.clk -- change to c
  o.action = args.action == nil and {} or args.action

  return o
end

function Vox:play(args)
  local args = args == nil and {} or self.update(args)
  local on, level, scale, transpose, degree, octave, synth, mask, wrap, negharm, ix, val, note
  local length, channel

  on = self.on and (args.on == nil and true or args.on)
  level = self.level * (args.level == nil and 1 or args.level)
  scale = args.scale == nil and self.scale or args.scale
  transpose = self.transpose + (args.transpose == nil and 0 or args.transpose)
  degree = (self.degree - 1) + ((args.degree == nil and 1 or args.degree) - 1)
  octave = self.octave + (args.octave == nil and 0 or args.octave)
  synth = args.synth == nil and self.synth or args.synth
  wrap = args.wrap == nil and self.wrap or args.wrap
  mask = args.mask == nil and self.mask or args.mask
  negharm = args.negharm == nil and self.negharm or args.negharm

  -- midi specific
  length = self.length * (args.length == nil and 1 or args.length)
  channel = args.channel == nil and self.channel or args.channel

  octave = wrap and octave or octave + math.floor(degree / #scale)
  ix = mask and self.apply_mask(degree, scale, mask) % #scale + 1 or degree % #scale + 1
  val = negharm and (7 - scale[ix]) % 12 or scale[ix]
  note = val + transpose + (octave * 12)

  return on and synth(note, level, length, channel)
end

function Vox.update(data)
  local updated = {}
  for k, v in pairs(data) do
    updated[k] = type(v) == 'function' and data[k]() or data[k]
  end
  return updated
end

function Vox.apply_mask(degree, scale, mask)
  local ix, closest_val = degree % #scale + 1, mask[1]
  for _, val in ipairs(mask) do
    val = (val - 1) % #scale + 1
    closest_val = math.abs(val - ix) < math.abs(closest_val - ix) and val or closest_val
  end
  local degree = closest_val - 1
  return degree
end

-- *****
-- function Voice:play_voice(val)
--   self:action(val)
--   self:play_note()
-- end

-- function Voice:new_seq(args)
--   args.action = type(args.action) == 'function' and args.action or args.action and function(val) self:play_voice(val) end
--   self.s[#self.s + 1] = Seq:new(t) -- may need updating to find specified name of object i.e. Seq
-- end

-- function Voice:play_seq(index)
--   if index == nil then
--     for k, v in pairs(self.seq) do
--       local play = self.s[k].action and self.s[k]:play_seq()
--     end
--   else
--     return self.s[index]:play_seq()
--   end
-- end

-- function Voice:reset()
--   for k, v in pairs(self.seq) do
--     self.s[k]:reset()
--   end
-- end
-- *****

function Vox.set(objects, property, val)
  for k, v in pairs(objects) do
    v[property] = val
  end
end

function Vox.call(objects, method, args)
  for k, v in pairs(objects) do
    v[method](v, args)
  end
end

return Vox
