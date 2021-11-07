-- norns.script.load('code/vox_norns/DN.lua')
function r() norns.script.load(norns.script.state) end


sequins = include('lib/sequins_dl'); s = sequins
lattice = include('lib/lattice_dl'); l = lattice:new()
vox = include('lib/vox')
music = require 'musicutil'

DT = midi.connect(1)
DN = midi.connect(2)
m = DN

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
  reset(bass)
  reset(lead)
  reset(harm)
  midi_notes_off()
end









bass = vox:new{
  on = true,
  channel = 1,
  synth = midisynth,
  scale = scale('dorian'),
  octave = 4,
  division = 1/16
}

bass.s = {
  degree = s{1,1,5,s{5,4,7,8},s{7,8,4}},
  division = s{1,1,2,4,8}
}

bass.l = l:new_pattern{
  action = function()
    bass:play{
      degree = bass.s.degree
    }
    bass.l:set_division(bass.division * bass.s.division())
  end
}

lead = vox:new{
  on = true,
  level = 0.5,
  channel = 2,
  synth = midisynth,
  scale = scale('dorian'),
  division = 1/16
}

lead.s = {
  degree =   s{1,3,4,5,7,8,7,6,4},
  division = s{1,1,1,1,1,1,2,4,8} 
}

lead.l = l:new_pattern{
  action = function()
    lead:play{
      degree = lead.s.degree
    }
    lead.l:set_division(lead.division * lead.s.division())
  end
}

harm = vox:new{
  on = true,
  channel = 2,
  synth = midisynth,
  scale = scale('dorian'),
  degree = 8,
  division = 1/16
}

harm.s = {
  degree =   s{1,5,3,7,9}, --dont like much
  division = s{4,2} 
}

harm.l = l:new_pattern{
  action = function()
    lead:play{
      degree = harm.s.degree -- vox bug, doesn't add to existing degree
    }
    harm.l:set_division(harm.division * harm.s.division())
  end
}