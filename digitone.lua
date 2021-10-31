function r()
  norns.script.load('code/vox_norns/digitone.lua')
end






engine.name = 'PolyPerc'
sequins = include('lib/sequins_dl'); s = sequins
lattice = include('lib/lattice_dl'); l = lattice:new()
vox = include('lib/vox')
music = require 'musicutil'
m = midi.connect()






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