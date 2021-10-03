-- vox

engine.name = 'PolyPerc'

sequins = include 'lib/sequins'
Vox = include 'lib/vox'

MusicUtil = require 'musicutil'

scale = MusicUtil.generate_scale_of_length(60, 'lydian', 7)
synth = function(note, level) engine.hz(MusicUtil.note_num_to_freq(note)) end


-- scales and chords
-- modes
ionian = {0,2,4,5,7,9,11}
dorian = {0,2,3,5,7,9,10} -- flat 3rd, flat 7th
phrygian = {0,1,3,5,7,8,10} -- flat 2nd, flat 6th
lydian = {0,2,4,6,7,9,11} -- sharp 4th
mixolydian = {0,2,4,5,7,9,10} -- flat 7th
aeolian = {0,2,3,5,7,8,10} -- flat 3rd, flat 6th, flat 7th
locrian = {0,1,3,5,6,8,10} -- flat 2nd, flat 5th, flat 6th, flat 7th

-- other
chromatic = {0,1,2,3,4,5,6,7,8,9,10,11}
harmoninc_min = {0,2,3,5,7,8,11} -- aeolian, sharp 7th
diminished = {0,2,3,5,6,8,9,11}
whole = {0,2,4,6,8,10}

-- scale mask function
function mask(scale, degrees)
  local m = {}
  for k, v in ipairs(degrees) do
    m[k] = scale[v]
  end
  return m
end

-- pentatonic scales
penta_maj = mask(ionian, {1,2,3,5,6})
penta_sus = mask(dorian, {1,2,4,5,7})
blues_min = mask(phrygian, {1,3,4,6,7})
blues_maj = mask(mixolydian, {1,2,4,5,6})
penta_min = mask(aeolian, {1,3,4,5,7})
japanese = mask(phrygian, {1,2,4,5,6})

-- chords
I = {1,3,5}
II = {2,4,6}
III = {3,5,7}
IV = {4,6,8}
V = {5,7,9}
VI = {6,8,10}
VII = {7,9,11}
--
