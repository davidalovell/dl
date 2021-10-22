-- vox/seq

-- reload
function r()
  norns.script.load('code/vox_norns/voxseq.lua')
end

-- libs
engine.name = 'PolyPerc'
music = require 'musicutil'
vox = include 'lib/vox'
-- seq = include 'lib/seq'
s = include 'lib/sequins_DL'

-- music helper fn
function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

-- synths
nornssynth = function(note, level)
  engine.hz(music.note_num_to_freq(note))
end

-- declare voices and sequencers