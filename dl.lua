-- dl

function reload()
  norns.script.load('code/dl/dl.lua')
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
  octave = 4,
  scale = 'lydian',
  length = 1/4
}

bass.user = {
  cutoff = 0.5
}

bass.action = function(self, args)
  args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
  args.device:cc(23, args.user.cutoff, args.channel)
end

bass.s = {
  div = s{2,4,3,3,1,16},
  cutoff = s{0.5,0.7,0.5,0.7,0.6}
}

bass.l = l:new_pattern{
  division = 1/16,
  action = function()
    bass.seq:play{div = bass.s.div}
  end
}

bass.seq = seq:new{
  div = 2,
  seq = {1,4,5,s{7,9,6,11}},
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




chord = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 2,
  on = true,
  octave = 4,
  scale = 'lydian',
  length = 4
}

chord.s = {
  degree1 = s{1,  2},
  degree2 = s{5,  6},
  degree3 = s{10, 10, 10, 10, 10, 10, 12, 11}
}

chord.l = l:new_pattern{
  division = 1/16,
  seq = {1},
  action = function()
    chord.seq:play()
  end
}

chord.seq = seq:new{
  div = 64,
  action = function(val)
    chord:play{degree = chord.s.degree1}
    chord:play{degree = chord.s.degree2}
    chord:play{degree = chord.s.degree3}
  end
}





a4 = vox:new{
  synth = vox.midisynth,
  device = midi.connect(2),
  channel = 1,
  on = true,
  scale = 'lydian',
  length = 1/4
}

a4.s = {
  div = s{32,3,5,1,5}
}

a4.l = l:new_pattern{
  division = 1/16,
  action = function()
    a4.seq:play{div = a4.s.div}
  end
}

a4.seq = seq:new{
  div = 3,
  seq = {s{11,5,13},10,9,7,s{6,4,3}},
  action = function(val)
    a4:play{degree = val}
  end
}



voices = {bass, chord, a4}