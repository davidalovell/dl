function reload()
  norns.script.load('code/dl/dl.lua')
end

function r() norns.script.load(norns.script.state) end

sequins = require('sequins'); s = sequins
lattice = include('lib/lattice_1.2'); l = lattice:new()
vox = include('lib/vox')
seq = include('lib/seq')
m = midi.connect(1)

function sync(sync, fn)
  return clock.run(function() clock.sync(sync); fn() end)
end

function midi_notes_off()
  for i = 0, 127 do
    m:note_off(i)
  end
end

function midisynth(note, level, length, channel, user)
  print(user.test)
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
    -- if msg.cc == 70 then
    --   bass.seq.skip = math.floor(msg.val) + 1
    -- end
  end
end




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
    bass:play{degree = val, user = {test = 'success!'}}
  end
}





voices = {bass}