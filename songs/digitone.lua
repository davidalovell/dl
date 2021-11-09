function r()
  norns.script.load('code/vox_norns/digitone.lua')
end






engine.name = 'PolyPerc'
sequins = include('lib/sequins_dl'); s = sequins
lattice = include('lib/lattice_dl'); l = lattice:new()
vox = include('lib/vox')
music = require 'musicutil'
m = midi.connect()






triad = { {1,3,5}, {2,4,6}, {3,5,7}, {4,6,8}, {5,7,9}, {6,8,10}, {7,9,11} }







function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

function sync(sync, fn)
  return clock.run(function() clock.sync(sync); fn() end)
end

function reset(object)
  for k, v in pairs(object.s) do
    object.s[k]:reset()
  end
end

function midi_notes_off()
  for i = 0, 127 do
    m:note_off(i)
  end
end

function polyperc(note, level)
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







function clock.transport.start()
  l:start()
end

function clock.transport.stop()
  l:stop()
  l:reset()
  reset(lead1)
  reset(lead2)
  reset(bass)
  midi_notes_off()
end











lead1 = vox:new{
  on = true,
  channel = 1,
  synth = midisynth,
  scale = scale('mixolydian')
}

lead1.s = {
  degree = s{1,2,3,4,5,6,7,8}:step(3),
  octave = s{-1,0,1,0,-1},
  level = s{1,0.4,0.2},
  division = s{2,1,1,12}
}

lead1.l = l:new_pattern{
  action = function(t)
    lead1:play{
      degree = lead1.s.degree,
      octave = lead1.s.octave,
      level = lead1.s.level,
    }
    lead1.l:set_division(lead1.division * lead1.s.division())
  end
}


lead2 = vox:new{
  on = true,
  channel = 1,
  synth = midisynth,
  scale = scale('mixolydian'),
  degree = 3
}

lead2.s = {
  degree = s{1,2,3,4,5,6,7,8}:step(-1),
  level = s{1,0.4,0.2}:step(2),
  octave = s{-1,0,1,0,-1}:step(2),
  division = s{1,2,3,10,16}:every(2,1,1)
}

lead2.l = l:new_pattern{
  action = function(t)
    lead2:play{
      degree = lead2.s.degree,
      octave = lead2.s.octave,
      level = lead2.s.level,
    }
    lead2.l:set_division(lead2.division * lead2.s.division())
  end
}


bass = vox:new{
  on = true,
  channel = 2,
  synth = midisynth,
  scale = scale('mixolydian'),
  octave = 3,
}

bass.s = {
  degree = s{1,1,5,s{5,4,7,8}},
  division = s{1,2,3,10,16}:every(4,1,1)
}

bass.l = l:new_pattern{
  action = function()
    bass:play{
      degree = bass.s.degree
    }
    bass.l:set_division(bass.division * bass.s.division())
  end
}



function part2()
  clock.run(
    function()
      clock.sync(4)

      lead1.level = 1
    
      lead1.s = {
        degree = s{1,s{2,4,1,4},5,7,s{9,11,13,8},8},
        octave = s{0,-1,0,1},
        level = s{1,0.4,0.2},
        division = s{4,1,1,2}
      }

      lead2.level = 0.7
      lead2.division = 1/32
      lead2.octave = 4

      lead2.s = {
        degree = s{1,s{4,3},5,s{6,11},7,8,s{13,11}},
        division = s{16,2,1,3,1,9,16}:every(2,1,1)
      }

      bass.s = {
        degree = s{1,1,s{7,11},9,s{8}:every(2),5},
        division = s{14,2,3,7,2,4}:every(2,1,1)
      }
    end
  )
end


