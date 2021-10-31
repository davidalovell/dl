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
  vox.call({lead1.s}, reset)
  midi_notes_off()
end











lead1 = vox:new{
  channel = 1,
  synth = midisynth,
  scale = scale('mixolydian')
}

lead1.s = {
  degree = s{1,2,3,4,5,6,7,8}
}

lead.l = l:new_pattern{
  swing = 60,
  division = 1/16,
  action = function(t)
    lead:play{degree = lead1.s.degree}
  end
}