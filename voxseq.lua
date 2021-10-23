-- vox/seq

-- reload
function r()
  norns.script.load('code/vox_norns/voxseq.lua')
end

-- libs
engine.name = 'MxSynths'
local mxsynths_ = include('mx.synths/lib/mx.synths')
mxsynths = mxsynths_:new()

music = require('musicutil')
vox = include('lib/vox')
seq = include('lib/seq')
s = include('lib/sequins_DL')

-- music helper fn
function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

-- synths
mx = function(note, level, length, channel)
  engine.mx_note_on(note, level, length)
end

-- declare voices and sequencers

lead1 = vox:new{
  synth = mx,
  scale = scale('mixolydian'),
  level = 2,
  length = 0.1,
  s = {
    degree = s{1,2,3,4,5,6,7,8}:step(3),
    skip = s{3,1,4},
    level = s{1,0.2,0.5,0.2},
    octave = s{-1,0,1}
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
    div = 1,
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