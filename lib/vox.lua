local Vox = {}
local sequins = include('lib/sequins_h'); s = sequins
local musicutil = require('musicutil')

function Vox:new(args)
  local o = setmetatable( {}, {__index = Vox} )
  local args = args == nil and {} or args

  o.on = args.on == nil and true or args.on
  o.scale = args.scale == nil and {0,2,4,6,7,9,11} or args.scale -- lydian
  -- TODO either table or string
  o.transpose = args.transpose == nil and 0 or args.transpose
  o.degree = args.degree == nil and 1 or args.degree
  o.octave = args.octave == nil and 5 or args.octave -- C5
  o.synth = args.synth == nil and function(self, args) return args.note end or args.synth
  o.wrap = args.wrap ~= nil and args.wrap or false
  o.mask = args.mask -- could use MusicUtil instead
  o.negharm = args.negharm ~= nil and args.negharm or false
  
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

  args.on = self.on and (args.on == nil and true or args.on)
  
  args.scale = args.scale == nil and self.scale or args.scale
  args.transpose = self.transpose + (args.transpose == nil and 0 or args.transpose)
  args.degree = (self.degree - 1) + ((args.degree == nil and 1 or args.degree) - 1)
  args.octave = self.octave + (args.octave == nil and 0 or args.octave)
  args.synth = args.synth == nil and self.synth or args.synth
  args.wrap = args.wrap == nil and self.wrap or args.wrap
  args.mask = args.mask == nil and self.mask or args.mask
  args.negharm = args.negharm == nil and self.negharm or args.negharm
  
  args.level = math.ceil(self.level * (args.level == nil and 1 or args.level) * 127)
  args.length = self.length * (args.length == nil and 1 or args.length)
  args.channel = args.channel == nil and self.channel or args.channel
  args.device = args.device == nil and self.device or args.device
  args.user = self.user == nil and self.user or args.user

  -- TODO make this into some if statements for ease of reading
  args.octave = args.wrap and args.octave or args.octave + math.floor(args.degree / #args.scale)
  args.ix = args.mask and self.apply_mask(args.degree, args.scale, args.mask) % #args.scale + 1 or args.degree % #args.scale + 1
  -- TODO apply musicutil snap to note here
  args.val = args.negharm and (7 - args.scale[args.ix]) % 12 or args.scale[args.ix]
  args.note = args.val + args.transpose + (args.octave * 12)

  return args.on and args.synth(self, args)
end

-- TODO, function that creates sequins
-- TODO, function that creates seq

function Vox:reset()
  -- TODO some error handling
  for k, v in pairs(self.s) do
    self.s[k]:reset() -- reset sequins
  end

  self.seq:reset() -- reset seq
end

function Vox.apply_scale(scale)
  return musicutil.generate_scale_of_length(0, scale, 7)
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