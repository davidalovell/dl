-- vox

function r()
  norns.script.load('code/vox_norns/vox_norns.lua')
end

engine.name = 'PolyPerc'
music = require 'musicutil'
vox = include 'lib/vox'
seq = include 'lib/seq'

s = include 'lib/sequins_DL'
-- sequins helper fn
function ns(sequins)
  local s = sequins()
  return type(s) == 'table' and sequins.ix or s
end
-- attempt to add to the object
-- function s:ns(self)
--   local s = self()
--   return type(s) == 'table' and self.ix or s
-- end

m = midi.connect()
-- midi helper fn
function midi_notes_off()
  for i = 0, 127 do
    m:note_off(i)
  end
end

-- transport
function clock.transport.start()
  clock.run(function() clock.sync(16) end)
  a.clock = clock.run(a.action)
  b.clock = clock.run(b.action)
end

function clock.transport.stop()
  cancel(a)
  cancel(b)
  midi_notes_off()
end

function cancel(object)
  clock.cancel(object.clock)
  object.seq:reset()

  for k, v in pairs(object.s) do
    object.s[k]:reset()
  end
end

-- scale
function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

-- diatonic triads
triad = { {1,3,5}, {2,4,6}, {3,5,7}, {4,6,8}, {5,7,9}, {6,8,10}, {7,9,11} }

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
    step = -3,
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

b = vox:new{
  chanel = 1,
  synth = midisynth,
  scale = scale('mixolydian'),
  octave = 5,
  degree = 5,
  s = {
    level = s{10,4,2}:step(2),
    octave = s{-1,0,1,0,-2}:step(2),
    skip = s{1,2,3,10,16}:every(4)
  },
  seq = seq:new{
    offset = 4,
    seq = {1,2,3,4,5,6,7,8},
    step = 3,
    action = function(val)
      b.seq.skip = ns(b.s.skip)
      return
        b:play{
          degree = val,
          level = b.s.level()/10,
          octave = b.s.octave()
        }
    end
  },
  action = function()
    while true do
      b.seq:play()
      clock.sync(1/4)
    end
  end
}