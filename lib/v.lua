--[[local]] Vox, Voice = {}, {}

function r()
  norns.script.load('code/vox_norns/lib/v.lua')
end

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

  return o
end

function Vox:new_voice(args)
  self.id_count = self.id_count + 1
  local args = args == nil and {} or args
  args.id = self.id_count
    -- WORK HERE
  args.action = args.action == nil and function(t) return end or args.action
  args.division = args.division == nil and 1/4 or args.division
  args.enabled = args.enabled == nil and true or args.enabled
  args.phase = args.division * self.ppqn * self.meter
  args.swing = args.swing == nil and 50 or args.swing
  args.delay = args.delay == nil and 0 or args.delay
  local pattern = Pattern:new(args)
  self.patterns[self.pattern_id_counter] = pattern
  return pattern
end

function Voice:new(args)
  local o = setmetatable( {}, {__index = Voice} )
  local args = args == nil and {} or args
  return o
end

-- return V