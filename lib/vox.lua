local Vox = {}
local sequins = include('lib/sequins_dl'); s = sequins
local musicutil = require('musicutil')

function Vox:new(args)
  local o = setmetatable( {}, {__index = Vox} )
  local args = args == nil and {} or args

  o.on = args.on == nil and true or args.on
  o.scale = args.scale == nil and {0,2,4,6,7,9,11} or args.scale
  o.transpose = args.transpose == nil and 0 or args.transpose
  o.degree = args.degree == nil and 1 or args.degree
  o.octave = args.octave == nil and 5 or args.octave -- C5
  o.wrap = args.wrap ~= nil and args.wrap or false
  o.mask = args.mask
  o.negharm = args.negharm ~= nil and args.negharm or false

  o.action = args.action == nil and function(self, args) return end or args.action
  o.synth = args.synth == nil and function(self, args) return end or args.synth

  o.level = args.level == nil and 1 or args.level
  o.length = args.length == nil and 1 or args.length
  o.channel = args.channel == nil and 1 or args.channel
  o.device = args.device == nil and midi.connect(1) or args.device
  o.user = args.user == nil and {} or args.user

  o.s = args.s == nil and {} or args.s -- contaner for sequins
  o.l = args.l == nil and {} or args.l -- container for lattice
  o.seq = args.seq == nil and {} or args.seq -- container for seq

  return o
end

function Vox:play(args)
  local args = args == nil and {} or args

  local updated_args = {}

  for k, v in pairs(args) do
    if s.is_sequins(v) or type(v) == 'function' then
      updated_args[k] = v()
    else
      updated_args[k] = v
    end

    if updated_args[k] == nil then
      return
    end
  end

  args = updated_args

  args.on = self.on and (args.on == nil and true or args.on)
  args.scale = args.scale == nil and self.scale or args.scale
  args.transpose = self.transpose + (args.transpose == nil and 0 or args.transpose)
  args.degree = (self.degree - 1) + ((args.degree == nil and 1 or args.degree) - 1)
  args.octave = self.octave + (args.octave == nil and 0 or args.octave)
  args.wrap = args.wrap == nil and self.wrap or args.wrap
  args.mask = args.mask == nil and self.mask or args.mask
  args.negharm = args.negharm == nil and self.negharm or args.negharm

  args.action = args.action == nil and self.action or args.action
  args.synth = args.synth == nil and self.synth or args.synth
  
  args.level = math.ceil(self.level * (args.level == nil and 1 or args.level) * 127)
  args.length = self.length * (args.length == nil and 1 or args.length)
  args.channel = args.channel == nil and self.channel or args.channel
  args.device = args.device == nil and self.device or args.device
  args.user = args.user == nil and self.user or args.user

  args.scale = type(args.scale) == 'string' and musicutil.generate_scale_of_length(0, args.scale, 7) or args.scale
  args.octave = args.wrap and args.octave or args.octave + math.floor(args.degree / #args.scale)

  args.ix = args.degree % #args.scale + 1
  args.ix = args.mask and musicutil.snap_note_to_array(args.ix, args.mask) or args.ix
  args.note = args.negharm and (7 - args.scale[args.ix]) % 12 or args.scale[args.ix]
  args.note = args.note + args.transpose + (args.octave * 12)

  if args.on then
    args.action(self, args)
    args.synth(args)
    return args.note
  end
end

-- TODO function that creates sequins
-- TODO function that creates seq

function Vox:reset()
  -- TODO error handling if no sequins, seq or midi
  self.seq:reset()

  for k, v in pairs(self.s) do
    self.s[k]:reset()
  end

  for i = 0, 127 do
    self.device:note_off(i)
  end
end

function Vox.midisynth(args)
  clock.run(
    function()
      args.device:note_on(args.note, args.level, args.channel)
      clock.sleep(clock.get_beat_sec() * args.length)
      args.device:note_off(args.note, args.level, args.channel)
    end
  )
end

-- function Vox.apply_mask(degree, scale, mask)
--   local ix, closest_val = degree % #scale + 1, mask[1]
--   for _, val in ipairs(mask) do
--     val = (val - 1) % #scale + 1
--     closest_val = math.abs(val - ix) < math.abs(closest_val - ix) and val or closest_val
--   end
--   local degree = closest_val - 1
--   return degree
-- end

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