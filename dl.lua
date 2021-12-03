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

function wait(wait, fn)
  return clock.run(function() clock.sleep(clock.get_beat_sec() * wait); fn() end)
end





function clock.transport.start()
  l:start()
  print('start')
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
  on = false,
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
  on = false,
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
  on = false,
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



bd = vox:new{
  synth = vox.midisynth,
  device = midi.connect(3),
  channel = 1,
  on = false
}

bd.s = {
  div = s{8,8,8,5,3}
}

bd.l = l:new_pattern{
  division = 1/16,
  action = function()
    bd.seq:play{div = bd.s.div}
  end
}

bd.seq = seq:new{
  div = 1,
  seq = {1},
  action = function(val)
    bd:play()
  end
}




cym = vox:new{
  synth = vox.midisynth,
  device = midi.connect(3),
  channel = 3,
  on = false
}

cym.s = {
  div = s{32,26,1,5},
  level = s{1,0.5,0.7}
}

cym.l = l:new_pattern{
  division = 1/16,
  action = function()
    cym.seq:play{div = cym.s.div}
  end
}

cym.seq = seq:new{
  div = 1,
  offset = 4,
  seq = {1},
  action = function(val)
    cym:play{level = cym.s.level}
  end
}



voices = {bass, chord, a4, bd, cym}








function init()
  p0()
end

function p0()
  sync(1, function() chord.on = true end)
end

function p1()
  sync(8, function() bass.on = true end)
end

function p2()
  sync(8, function() a4.on = true; bd.on = true end)
end

function p3()
  sync(8,
    function()
      bd:play()
      bd.on = false
      bass.on = false
      wait(3, function() cym.on = true; cym:play(); cym.on = false end)
    end
  )
end

function p4()
  sync(8, function() bd.on = true; bass.on = true; cym.on = true end)
end

function p5()
  sync(8,
    function()
      bd.on = false
      chord:play{degree = chord.s.degree1}
      chord:play{degree = chord.s.degree2}
      chord:play{degree = chord.s.degree3}
      chord.on = false
      cym:play()
      cym.on = false
    end
  )
end

function p6()
  bass.on = false
end

function p7()
  a4.on = false
end
