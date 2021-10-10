-- vox

engine.name = 'PolyPerc'
music = require 'musicutil'
vox = include 'lib/vox'
s = require 'sequins'
m = midi.connect()

function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

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

-- masks
I = {1,3,5}
II = {2,4,6}
III = {3,5,7}
IV = {4,6,8}
V = {5,7,9}
VI = {6,8,10}
VII = {7,9,11}
--

-- declare voices and sequencers
a = vox:new{
  octave = 3,
  synth = midisynth,
  scale = scale('mixolydian'),

  seq = {
    degree = s{1,1,5,7,s{9,9,9,-2},s{8,5,11,0}},
    level = s{1,0.3,1,0.4,0.7,0.6},
    dyn = {
      degree = function() return a.seq.degree() end,
      level = function() return a.seq.level() end,
      length = function() return 1 / math.random(2,32) end
    }
  },

  clk = {
    division = 1/2,
    sync = s{2,2,2,1,1/2,1/2},
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

-- start clocks
m:start()
a.clock = clock.run(a.action)

-- start
function start()
  norns.script.load('code/vox_norns/vox_norns.lua')
end

-- stop
function stop()
  for i = 0, 127 do
    m:note_off(i)
  end
  m:stop()
  clock.cleanup()
end

