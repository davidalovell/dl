a = vox:new{
  chanel = 1,
  synth = midisynth,
  scale = scale('mixolydian'),
  octave = 6,
  s = {
    level = s{10,4,2},
    octave = s{-1,0,1,0,-2},
    skip = s{1,2,3,10,16}:every(4)
  },
  seq = seq:new{
    seq = {1,2,3,4,5,6,7,8},
    step = 3,
    action = function(val)
      a.seq.skip = ns(a.s.skip)
      return
        a:play{
          degree = val,
          level = a.s.level()/10,
          octave = a.s.octave()
        }
    end
  },
  action = function()
    while true do
      a.seq:play()
      clock.sync(1/4)
    end
  end
}