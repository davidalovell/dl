local Vox = {}

function Vox:new(args)
  local o = setmetatable( {}, {__index = Vox} )
  local args = args == nil and {} or args

  o.on = args.on == nil and true or args.on
  
  o.scale = args.scale == nil and {0,2,4,6,7,9,11} or args.scale -- lydian
  o.transpose = args.transpose == nil and 0 or args.transpose -- C0
  o.degree = args.degree == nil and 1 or args.degree
  o.octave = args.octave == nil and 5 or args.octave -- C5
  o.synth = args.synth == nil and function(note, level, length, channel) return note, level, length, channel end or args.synth
  o.wrap = args.wrap ~= nil and args.wrap or false
  o.mask = args.mask -- could use MusicUtil
  o.negharm = args.negharm ~= nil and args.negharm or false
  
  o.level = args.level == nil and 1 or args.level
  o.length = args.length == nil and 1 or args.length
  o.channel = args.channel == nil and 1 or args.channel

  -- empty tables
  o.s = args.s == nil and {} or args.s -- contaner for sequins
  o.seq = args.seq == nil and {} or args.seq -- container for seq
  o.l = args.l == nil and {} or args.l -- container for lattice

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
	  -- -- for use with unaltered sequins
		-- if type(updated_args) == 'table' then
		-- 	if updated_args[1] == nil then -- sequins returns an empty table so the first index will be negative in this instance
		-- 		return
		-- 	end
		-- end
	end
	args = updated_args

  local on, level, scale, transpose, degree, octave, synth, mask, wrap, negharm, ix, val, note
  local length, channel

  on = self.on and (args.on == nil and true or args.on)
  
  scale = args.scale == nil and self.scale or args.scale
  transpose = self.transpose + (args.transpose == nil and 0 or args.transpose)
  -- degree = (self.degree - 1) + ((args.degree == nil and 1 or args.degree) - 1)
  degree = (self.degree - 1) + (args.degree == nil and 0 or (args.degree - 1))
  octave = self.octave + (args.octave == nil and 0 or args.octave)
  synth = args.synth == nil and self.synth or args.synth
  wrap = args.wrap == nil and self.wrap or args.wrap
  mask = args.mask == nil and self.mask or args.mask
  negharm = args.negharm == nil and self.negharm or args.negharm
  
  level = self.level * (args.level == nil and 1 or args.level)
  length = self.length * (args.length == nil and 1 or args.length)
  channel = args.channel == nil and self.channel or args.channel

  octave = wrap and octave or octave + math.floor(degree / #scale)
  ix = mask and self.apply_mask(degree, scale, mask) % #scale + 1 or degree % #scale + 1
  val = negharm and (7 - scale[ix]) % 12 or scale[ix]
  note = val + transpose + (octave * 12)

  return not nul and on and synth(note, level, length, channel)
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
