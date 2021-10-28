-- vox/seq

-- reload
function r()
  norns.script.load('code/vox_norns/voxseq.lua')
end

-- libs
-- engine.name = 'MxSynths'
-- local mxsynths_ = include('mx.synths/lib/mx.synths')
-- mxsynths = mxsynths_:new()

engine.name = 'PolyPerc'

music = require('musicutil')
vox = include('lib/vox')
seq = include('lib/seq')
skip = include('lib/skip')
s = include('lib/sequins_dl')

-- music helper fn
function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

-- synths
function mx(note, level, length) engine.mx_note_on(note, level, length) end
function poly(note, level) engine.hz(music.note_num_to_freq(note)) end

-- declare voices and sequencers

lead1 = vox:new{
  synth = poly,
  scale = scale('mixolydian'),
  level = 2,
  length = 0.1,
  s = {
    degree = s{1,3,4,5,s{7,9,11,13}:every(2)}:step(2),
    skip = s{3,1,4},
    level = s{1,0.2,0.5,0.2},
    octave = s{-1,0,1,s{2}:every(4)}
  },
  seq = seq:new{
    action = function(val)
      return
        lead1:play{
          degree = lead1.s.degree(),
          level = lead1.s.level(),
          octave = lead1.s.octave()
        }
    end
  },
  clk = {
    div = 1/4,
    action = function()
      return
        lead1.seq:play{
          skip = lead1.s.skip() 
        }
    end
  }
}

lead1.clock = clock.run(
  function()
    while true do
      lead1.clk.action()
      clock.sync(lead1.clk.div)
    end
  end
)