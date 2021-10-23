-- vox

-- reload
function r()
  norns.script.load('code/vox_norns/vox_norns.lua')
end

-- libs
engine.name = 'PolyPerc'
music = require 'musicutil'
vox = include 'lib/vox'
seq = include 'lib/seq'
s = include 'lib/sequins_DL'
m = midi.connect()

-- music helper fn
function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

triad = { {1,3,5}, {2,4,6}, {3,5,7}, {4,6,8}, {5,7,9}, {6,8,10}, {7,9,11} }

-- sequins helper (cs = call sequins)
function cs(sequins)
  local s = sequins()
  return type(s) == 'table' and sequins.ix or s
end

-- midi helper fn
function midi_notes_off()
  for i = 0, 127 do
    m:note_off(i)
  end
end

-- clock helper fn
function cancel(object)
  clock.cancel(object.clock)
  object.seq:reset()
  for k, v in pairs(object.s) do
    object.s[k]:reset()
  end
end

-- midi transport
function clock.transport.start()
  clock.run(function() clock.sync(16) end)
  lead1.clock = clock.run(
    function()
      while true do
        lead1.clk.action()
        clock.sync(lead1.clk.div)
      end
    end
  )

  lead2.clock = clock.run(
    function() 
      while true do
        lead2.clk.action()
        clock.sync(lead2.clk.div)
      end
    end
  )

  bass.clock = clock.run(
    function() 
      while true do
        bass.clk.action()
        clock.sync(bass.clk.div)
      end
    end
  )

end

function clock.transport.stop()
  cancel(lead1)
  cancel(lead2)
  cancel(bass)
  midi_notes_off()
end

-- synths
function nsynth(note, level)
  engine.hz(music.note_num_to_freq(note))
end

function msynth(note, level, length, channel)
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

lead1 = vox:new{
  on = true,
  channel = 1,
  synth = msynth,
  scale = scale('mixolydian'),
  octave = 6,

  s = {
    degree = s{1,2,3,4,5,6,7,8}:step(3),
    level = s{10,4,2},
    octave = s{-1,0,1,0,-1},
    skip = s{1,2,3,10,16}:every(4)
  },

  seq = seq:new{
    action = function(val)
      return
        lead1:play{
          degree = cs(lead1.s.degree),
          level = cs(lead1.s.level) / 10,
          octave = cs(lead1.s.octave)
        }
    end
  },

  clk = {
    div = 1/4,
    action = function()
      return
        lead1.seq:play{
          skip = cs(lead1.s.skip)
        }
    end
  }
}



lead2 = vox:new{
  on = true,
  channel = 1,
  synth = msynth,
  scale = scale('mixolydian'),
  octave = 5,
  degree = 5,

  s = {
    degree = s{1,2,3,4,5,6,7,8}:step(-2),
    level = s{10,4,2}:step(2),
    octave = s{-1,0,1,0,-1}:step(2),
    skip = s{1,2,3,10,16}:every(4)
  },

  seq = seq:new{
    offset = 4,
    action = function(val)
      return
        lead2:play{
          degree = cs(lead2.s.degree),
          level = cs(lead2.s.level) / 10,
          octave = cs(lead2.s.octave)
        }
    end
  },

  clk = {
    div = 1/2,
    action = function()
      return
        lead2.seq:play{
          skip = cs(lead2.s.skip)
        }
    end
  }
}

bass = vox:new{
  channel = 2,
  synth = msynth,
  scale = scale('mixolydian'),
  octave = 3,

  s = {
    degree = s{1,1,5,s{5,4,7,8}},
    skip = s{1,2,3,10,16}:every(4)
  },

  seq = seq:new{
    action = function(val)
      return
        bass:play{
          degree = cs(bass.s.degree),
          level = math.random(5,10) / 10
        }
    end
  },

  clk = {
    div = 1/2,
    action = function()
      return
        bass.seq:play{
          skip = cs(bass.s.skip)
        }
    end
  }
}


function part2()
  bass.s.degree:settable{8,5,3,1}
end