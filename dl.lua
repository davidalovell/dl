-- dl




-- reload fns
function reload()
  norns.script.load('code/dl/dl.lua')
end

function r() norns.script.load(norns.script.state) end

function key(n,z)
  if n == 3 and z == 1 then
    r()
  end
end




-- libs
sequins = include('lib/sequins_unnested'); s = sequins -- hacked version of sequins
lattice = include('lib/lattice_1.2'); l = lattice:new()
vox = include('lib/vox') -- voice object
seq = include('lib/seq') -- wrapper object for sequins too allow added functionality
musicutil = require('musicutil')




-- clock helper fns
function sync(sync, fn)
  return clock.run(function() clock.sync(sync); fn() end)
end

function wait(wait, fn)
  return clock.run(function() clock.sleep(clock.get_beat_sec() * wait); fn() end)
end




-- transport fns, digitone is master clock
function clock.transport.start()
  l:start()
end

function clock.transport.stop()
  l:stop()
  l:reset()
  vox.call(voices, 'reset')
end




-- objects (vox, sequins, lattice, seq), vox is the main object and other objects are stored in its table
-- bass is a voice on digitone
bass = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  on = false,
  octave = 3,
  level = 1,
  scale = 'lydian',
  length = 1/4
}

bass.user = {
  -- cutoff = 0.5
}

bass.action = function(self, args)
  -- args.user.cutoff = args.user.cutoff == nil and 0.5 or args.user.cutoff
  -- args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
  -- args.device:cc(23, args.user.cutoff, args.channel)
end

bass.s = {
  div = s{1,7},
  -- cutoff = s{0.5,0.7,0.5,0.7,0.6}
}

bass.l = l:new_pattern{
  division = 1/16,
  action = function()
    local root = bass.seq:play{div = bass.s.div}
    if not root then
      bass2.seq:play{div = bass2.s.div}
    end
  end
}

bass.seq = seq:new{
  div = 1,
  seq = {2,6,8,6,9},
  action = function(val)
    bass:play{degree = val} --, user = {cutoff = bass.s.cutoff}}
  end
}




bass2 = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  on = false,
  octave = 4,
  level = 0.6,
  scale = 'lydian',
  length = 1/4
}

bass2.user = {
  -- cutoff = 0.5
}

bass2.action = function(self, args)
  -- args.user.cutoff = args.user.cutoff == nil and 0.5 or args.user.cutoff
  -- args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
  -- args.device:cc(23, args.user.cutoff, args.channel)
end

bass2.s = {
  div = s{4,1,2,1,1,5,3},
  -- cutoff = s{0.5,0.7,0.5,0.7,0.6}
}

bass2.seq = seq:new{
  div = 1,
  seq = {1,3,5,7,8},
  action = function(val)
    bass2:play{degree = val} --, user = {cutoff = bass.s.cutoff}}
  end
}









-- chord is a pad voice on digitone
chord = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 2,
  on = true,
  octave = 5,
  scale = 'lydian',
  length = 4
}

chord.s = {
  degree1 = s{1,1},
  degree2 = s{5,4},
  degree3 = s{9,11}
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
    wait(math.random(), function() chord:play{degree = chord.s.degree1} end)
    wait(math.random(), function() chord:play{degree = chord.s.degree2} end)
    wait(math.random(), function() chord:play{degree = chord.s.degree3} end)
  end
}




-- table of the above objects, doing this allows the reset fns to work
voices = {bass, bass2, chord}




-- functions that are called live to play the song
function init()
  p0()
end

function p0()
  bass.on = true
  bass2.on = true
end