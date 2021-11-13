function reload()
  norns.script.load('code/V/V.lua')
end

function r() norns.script.load(norns.script.state) end

sequins = include('lib/sequins'); s = sequins
lattice = include('lib/lattice_dl'); l = lattice:new()
vox = include('lib/vox')
seq = include('lib/seq')
music = require('musicutil')

DN = midi.connect(1)
m = DN

function sync(sync, fn)
  return clock.run(function() clock.sync(sync); fn() end)
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






-- m.event = function(data)
--   local msg = midi.to_msg(data)
--   if msg.type == 'cc' then
--     print(msg.cc, msg.val)
--     if msg.cc == 70 then

--       lead.degree = math.floor(msg.val)
--     end

--     -- if msg.cc == 70 then
--     --   bass.division = 1/msg.val
--     -- elseif msg.cc == 71 then
--     --   lead.division = 1/msg.val
--     -- end
--     -- if msg.cc == 70 and msg.val < 10 then
--     --   sync(4, part1)
--     -- elseif msg.cc == 70 and msg.val >= 10 and msg.val < 20 then
--     --   sync(4, part2)
--     -- end
--   elseif msg.type == 'note_on' then
--     for k,v in pairs(msg) do
--       print(k,v)
--     end
--   end
  
-- end




function clock.transport.start()
  l:start()
end

function clock.transport.stop()
  l:stop()
  l:reset() -- ?put this inside vox
  vox.call(voices, 'reset')
  midi_notes_off()
end








-- typical contstruct
bass = vox:new{
  on = true,
  channel = 1,
  synth = midisynth,
  scale = vox.apply_scale('lydian'),
  octave = 4,
  length = 0.1
}

bass.s = {
  div = s{4,4,4,1,1,2}
}

bass.l = l:new_pattern{
  division = 1/16,
  action = function()
    bass.seq:play{div = bass.s.div}
  end
}

bass.seq = seq:new{
  div = 2,
  seq = {1,3,5,s{7,9,4,11}},
  action = function(val)
    bass:play{degree = val}
  end
}





voices = {bass}