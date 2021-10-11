-- vox
-- norns.script.load('code/vox_norns/vox_norns.lua')


engine.name = 'PolyPerc'
music = require 'musicutil'
vox = include 'lib/vox'
s = require 'sequins'
m = midi.connect()


-- scale
function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

-- diatonic triads
I = {1,3,5}
II = {2,4,6}
III = {3,5,7}
IV = {4,6,8}
V = {5,7,9}
VI = {6,8,10}
VII = {7,9,11}

-- synths
nornssynth = function(note, level)
  engine.hz(music.note_num_to_freq(note))
end

function midisynth(note, level, length, channel)
  level = math.ceil(level * 127)
  clock.run(
    function()
      m:note_on(note, level, channel)
      clock.sync(length)
      m:note_off(note, level, channel)
    end
  )
end

-- declare voices and sequencers
chord = s{1,5,4}



a = vox:new{
  octave = 3,
  synth = midisynth,

  seq = {
    degree = s{1,3,5,7},
    dyn = {
      degree = function() return a.seq.degree() end,
      length = function() return 1 / math.random(2,32) end
    }
  },

  clk = {
    division = 1,
    sync = s{2,1,1/2,1/2},
    dyn = {
      sync = function() return a.clk.sync() * a.clk.division end
    }
  },

  action = function()
    while true do
      a:play(a.seq.dyn)
      clock.sync(a.clk.dyn.sync())
    end
  end
}

b = vox:new{
  synth = midisynth,
  channel = 2,

  seq = {
    degree = s{1,3,5,7,9,11,13,15,17,19},
  },

  clk = {
    sync = s{3,6,3,2,1,1,1,5},
    division = 1/8
  },

  action = function()
    while true do
      b:play{degree = a.seq.degree()}
      clock.sync(b.clk.sync() * b.clk.division)
    end
  end
}


function clock.transport.start()
  print("we begin")
  a.clock = clock.run(a.action)
  b.clock = clock.run(b.action)
end

function clock.transport.stop()
  clock.cancel(a.clock)
  clock.cancel(b.clock)

  a.seq.degree:reset()
  a.clk.sync:reset()
  b.seq.degree:reset()
  b.clk.sync:reset()

  for i = 0, 127 do
    m:note_off(i)
  end
end