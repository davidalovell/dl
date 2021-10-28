local Vox = {}
local sequins = require('sequins_dl') -- comment out if not using on norns

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
  o.s = args.s == nil and {} or args.s -- contaner for sequencers (sequins)
  o.c = args.c == nil and {} or args.c -- container for clock

  return o
end

function Vox:p(args)
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

  return not nul and on and synth(note, level, length, channel)
end

function Vox.update(data)
  local updated = {}
  for k, v in pairs(data) do
    updated[k] = type(v) == 'function' or sequins.is_sequins(v)
			and data[k]()
      or data[k]
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

function Vox:play(data) -- a way of playing sequins that return nil values, requires sequins lib to be modified
	data = data == nil and {} or data
	local t = {}
	for k,v in pairs(data) do
		-- this line needs work 
		-- if type(v) == 'function' or type(v) == sequins.is_sequins(v) then
			-- t[k] = v()
		-- else
			-- t[k] = v
		-- end
		t[k] = type(v) == 'function' or sequins.is_sequins(v) and v() or v
		-- t[k] = v()
		if t[k] == nil then return end
	end
	return self.p(self,t)
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
