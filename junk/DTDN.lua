-- norns.script.load('code/vox_norns/DTDN.lua')
function r() norns.script.load(norns.script.state) end


engine.name = 'PolyPerc'
sequins = include('lib/sequins_dl'); s = sequins
lattice = include('lib/lattice_dl'); l = lattice:new()
vox = include('lib/vox')
music = require 'musicutil'

m = midi.connect(1)

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
  reset(bass)
  midi_notes_off()
end









bass = vox:new{
  on = true,
  channel = 1,
  synth = midisynth,
  scale = scale('mixolydian'),
  octave = 5,
  division = 1/8
}

bass.s = {
  degree = s{1,1,5,s{5,4,7,8},s{7,8,4}},
  division = s{7,1,6,1,1}
}

bass.l = l:new_pattern{
  action = function()
    bass:play{
      degree = bass.s.degree
    }
    bass.l:set_division(bass.division * bass.s.division())
  end
}