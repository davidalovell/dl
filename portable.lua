-- dl

function reload()
  norns.script.load('code/dl/portable.lua')
end

function r() norns.script.load(norns.script.state) end

function key(n,z)
  -- key actions: n = number, z = state
  if n == 3 and z == 1 then
    r()
  end
end

sequins = include('lib/sequins_unnested'); s = sequins
lattice = include('lib/lattice_1.2'); l = lattice:new()
vox = include('lib/vox')
seq = include('lib/seq')
musicutil = require('musicutil')




function sync(sync, fn)
  return clock.run(function() clock.sync(sync); fn() end)
end





function clock.transport.start()
  l:start()
end

function clock.transport.stop()
  l:stop()
  l:reset()
  vox.call(voices, 'reset')
end





-- typical contstruct
bass = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  on = true,
  octave = 5,
  scale = 'lydian',
  length = 1/4
}

bass.user = {
  cutoff = 0.4
}

bass.action = function(self, args)
  args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
  args.device:cc(23, args.user.cutoff, args.channel)
end

bass.s = {
  div = s{4,3,1},
  cutoff = s{0.5,0.7,0.5,0.7,0.6}
}

bass.l = l:new_pattern{
  division = 1/16,
  action = function()
    local a = bass.seq:play{div = bass.s.div}
    -- the below doesnt work, but it would be nice if it did
    -- add a property to seq which says if the val returned a note the last time
    -- if not a then 
    --   local b = bass2.seq:play{div = bass2.s.div}
    -- end
  end
}

bass.seq = seq:new{
  div = 2,
  seq = {1},
  action = function(val)
    bass:play{degree = val, user = {cutoff = bass.s.cutoff}}
  end
}



bass.device.event = function(data)
  local msg = midi.to_msg(data)
  if msg.type == 'cc' then
    -- if msg.cc == 70 then
    --   bass.seq.skip = math.floor(msg.val) + 1
    -- end
  end
end



bass2 = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  on = true,
  octave = 6,
  scale = 'lydian',
  length = 1/4,
  level = 0.5
}

bass2.user = {
  cutoff = 0.4
}

bass2.action = function(self, args)
  args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
  args.device:cc(23, args.user.cutoff, args.channel)
end

bass2.s = {
  div = s{1,2,2,1},
  cutoff = s{0.5,0.7,0.5,0.7,0.6}
}

-- bass2.l = l:new_pattern{
--   division = 1/16,
--   action = function()
--     bass2.seq:play{div = bass2.s.div}
--   end
-- }

bass2.seq = seq:new{
  div = 1,
  seq = {1,5,1,s{8,11,13}},
  step = 1,
  action = function(val)
    bass2:play{degree = val, user = {cutoff = bass2.s.cutoff}}
  end
}








voices = {bass}