-- vox

-- norns.script.load('code/vox_norns/vox_norns.lua')
engine.name = 'PolyPerc'

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

  vox = {
    degree = s{1,1,5,7,9,8},
    dyn = {
      degree = function() return a.vox.degree() end
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
      a:play(a.vox.dyn)
      clock.sync(a.clk.dyn.sync())
    end
  end
}

-- start clocks
m:start()
a.clock = clock.run(a.action)