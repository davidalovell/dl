-- vox


engine.name = 'PolyPerc'
music = require 'musicutil'
vox = include 'lib/vox'
seq = include 'lib/seq'
s = include 'lib/sequins'
-- s = require 'sequins'
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
  scale = scale('mixolydian'),

  seq = {
    degree = s{1,5,7,7}:every(4),
    dyn = {
      degree = function() a.seq.degree() return a.seq.degree[a.seq.degree.ix] end,
      length = function() return 1 / math.random(2,4) end
    }
  },

  clk = {
    division = 1/2,
    sync = s{2,1,1/2,1/2},
    dyn = function() return a.clk.sync() * a.clk.division end
  },

  action = function(t)
    while true do
      a:play(a.seq.dyn)
      clock.sync(a.clk.dyn())
    end
  end
}

b = vox:new{
  on = false,
  synth = midisynth,
  channel = 2,

  seq = {
    degree = s{1,3,5,7},
    dyn = {
      degree = function() b.seq.degree() return b.seq.degree[b.seq.degree.ix] - 1 end
    }
  },

  clk = {
    sync = s{3,6,3,2,1,1,1,5},
    division = 1/8,
    dyn = function() return b.clk.sync() * b.clk.division end
  },

  action = function()
    while true do
      b:play(b.seq.dyn)
      clock.sync(b.clk.dyn())
    end
  end
}


function clock.transport.start()
  clock.run(function() clock.sync(16) end)
  a.clock = clock.run(a.action)
  b.clock = clock.run(b.action)
end

function clock.transport.stop()
  clock.cancel(a.clock)
  a.seq.degree:reset()
  a.clk.sync:reset()

  clock.cancel(b.clock)
  b.seq.degree:reset()
  b.clk.sync:reset()

  midi_notes_off()
end

function midi_notes_off()
  for i = 0, 127 do
    m:note_off(i)
  end
end

function r()
  norns.script.load('code/vox_norns/vox_norns.lua')
end


c = s{10,20,30,40}:every(2)
-- c()
-- c:select(4)
function helper()
  local val = c()
  print(val, c.ix, c[c.ix])
end

