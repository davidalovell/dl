-- vox

engine.name = 'PolyPerc'

sequins = include 'lib/sequins'
Vox = include 'lib/vox'
MusicUtil = require 'musicutil'

function scale(scale) return MusicUtil.generate_scale_of_length(60, scale, 7) end
function chord(chord_type, inversion) return MusicUtil.generate_chord (1, chord_type, inversion) end
usersynth = function(note, level) engine.hz(MusicUtil.note_num_to_freq(note)) end

I = {1,3,5}
II = {2,4,6}
III = {3,5,7}
IV = {4,6,8}
V = {5,7,9}
VI = {6,8,10}
VII = {7,9,11}
--

-- 07879624907
a = Vox:new{
  synth = usersynth,
  scale = scale('mixolydian'),
  seq = {
    degree = sequins{1,3,5,7,9,11,13},
    sync = sequins{1/4,1/4,1/2},
    action = function()
      while true do
        a:play(a.seq.fn)
        clock.sync(a.seq.fn.sync())
      end
    end,
    fn = {
      degree = function() return a.seq.degree() end,
      sync = function() return a.seq.sync() end
    },
  }
}

a.clock = clock.run(a.seq.action)

