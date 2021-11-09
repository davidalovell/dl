function reload()
  norns.script.load('code/vox_norns/gairloch.lua')
end

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






m.event = function(data)
  local msg = midi.to_msg(data)
  if msg.type == 'cc' then
    print(msg.cc, msg.val)
    if msg.cc == 70 then

      lead.degree = math.floor(msg.val)
    end

    -- if msg.cc == 70 then
    --   bass.division = 1/msg.val
    -- elseif msg.cc == 71 then
    --   lead.division = 1/msg.val
    -- end
    -- if msg.cc == 70 and msg.val < 10 then
    --   sync(4, part1)
    -- elseif msg.cc == 70 and msg.val >= 10 and msg.val < 20 then
    --   sync(4, part2)
    -- end
  elseif msg.type == 'note_on' then
    for k,v in pairs(msg) do
      print(k,v)
    end
  end
  
end




function clock.transport.start()
  l:start()
end

function clock.transport.stop()
  l:stop()
  l:reset()
  reset(bass)
  reset(lead)
  reset(chord)
  reset(hh)
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
  f1 = s{1,1,5,5,3,3,4,4}:every(5,1),
  f2 = s{1,1,5,5,3,3,4,4}:every(5,2),
  degree = s{1,1,5,s{5,4,7,8},s{7,8,4}},
  division = s{1,1,2,4,8},
  level = s{1,1,0.5,0.5,0.5}
}

bass.l = l:new_pattern{
  action = function()
    bass:play{
      degree = bass.s.degree,
      level = bass.s.level
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
  division = 1/16,
  octave = 7
}

lead.s = {
  degree = s{1,3,4,5,7,8,7,6,4},
  division = s{1,1,1,1,1,1,2,4,8,8},
  octave = s{0,1,0,-1}
}

lead.l = l:new_pattern{
  action = function()
    lead:play{
      degree = lead.s.degree,
      octave = lead.s.octave
    }
    lead.l:set_division(lead.division * lead.s.division())
  end
}

chord = vox:new{
  on = true,
  channel = 3,
  octave = 4,
  length = 4,
  synth = midisynth,
  scale = scale('dorian'),
  division = 1/16
}

chord.s = {
  d1 = s{1,3,4,1}:every(2,1),
  d2 = s{5,7,6,5}:every(2,1),
  division = s{16} 
}

chord.l = l:new_pattern{
  action = function()
    chord:play{
      degree = chord.s.d1
    }
    chord:play{
      degree = chord.s.d2
    }
    chord.l:set_division(chord.division * chord.s.division())
  end
}

hh = vox:new{
  on = true,
  channel = 4,
  synth = midisynth,
  scale = scale('dorian')
}

hh.s = {
  division = s{1},
  d1 = s{1}:every(8,3),
  d2 = s{1}:every(8,6),
  d3 = s{1}:every(16,16),
  d4 = s{1}:every(64,61),
  level = s{1,0.5,0.2}
}

hh.l = l:new_pattern{
  action = function()
    hh:play{degree = hh.s.d1, level = hh.s.level}
    hh:play{degree = hh.s.d2, level = hh.s.level}
    hh:play{degree = hh.s.d3, level = hh.s.level}
    hh:play{degree = hh.s.d4, level = hh.s.level}
    hh.l:set_division(hh.division * hh.s.division())
  end
}


function part1()
  bass.s = {
    f1 = s{1,1,5,5,3,3,4,4}:every(5,1),
    f2 = s{1,1,5,5,3,3,4,4}:every(5,2),
    degree = s{1,1,5,s{5,4,7,8},s{7,8,4}},
    division = s{1,1,2,4,8},
    level = s{1,1,0.5,0.5,0.5}
  }

  lead.on = true
  lead.s = {
    degree = s{1,3,4,5,7,8,7,6,4},
    division = s{1,1,1,1,1,1,2,4,8,8},
    octave = s{0,1,0,-1}
  }

  chord.on = true
  chord.s = {
    d1 = s{1,3,4,1}:every(2,1),
    d2 = s{5,7,6,5}:every(2,1),
    division = s{16} 
  }

  hh.on = true
  hh.s = {
    division = s{1},
    d1 = s{1}:every(8,3),
    d2 = s{1}:every(8,6),
    d3 = s{1}:every(16,16),
    d4 = s{1}:every(64,61),
    level = s{1,0.5,0.2}
  }
end

function part2()
  bass.on = true
  lead.on = false
  chord.on = false
  hh.on = true

  bass.s.degree = s{1}
end


function part3()
end

function part4()
end