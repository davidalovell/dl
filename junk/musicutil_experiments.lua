function reload()
  norns.script.load('code/vox_norns/tuesday.lua')
end

function r() norns.script.load(norns.script.state) end









sequins = include('lib/sequins_dl'); s = sequins
lattice = include('lib/lattice_dl'); l = lattice:new()
vox = include('lib/vox')
music = require 'musicutil'

DT = midi.connect(1)
DN = midi.connect(2)
m = DN









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








function synth(note, velocity, length, channel)
  clock.run(
    function()
      m:note_on(note, velocity, channel)
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
  -- reset
  midi_notes_off()
end










scale = music.generate_scale(60, 'lydian')






b = {}
b.s = {
  degree = s{0,2,4,6,7}
}
b.l = l:new_pattern{
  action = function()
    local root = 60
    local note = music.snap_note_to_array(b.s.degree() + root, scale)
    synth(note, 127, 1, 1)
  end
}




-- bass = vox:new{
--   on = true,
--   channel = 1,
--   synth = midisynth,
--   scale = scale('dorian'),
--   octave = 4,
--   division = 1/16
-- }

-- bass.s = {
--   f1 = s{1,1,5,5,3,3,4,4}:every(5,1),
--   f2 = s{1,1,5,5,3,3,4,4}:every(5,2),
--   degree = s{1,1,5,s{5,4,7,8},s{7,8,4}},
--   division = s{1,1,2,4,8},
--   level = s{1,1,0.5,0.5,0.5}
-- }

-- bass.l = l:new_pattern{
--   action = function()
--     bass:play{
--       degree = bass.s.degree,
--       level = bass.s.level
--     }
--     bass.l:set_division(bass.division * bass.s.division())
--   end
-- }