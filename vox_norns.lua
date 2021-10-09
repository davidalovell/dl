-- vox

engine.name = 'PolyPerc'

engine.name = 'PolyPerc'
MusicUtil = require 'musicutil'
Vox = include 'lib/vox'
sequins = require 'sequins'
m = midi.connect()

function scale(scale)
  return MusicUtil.generate_scale_of_length(60, scale, 7)
end

function snap(note_num, snap_array)
  return MusicUtil.snap_note_to_array(note_num, snap_array)
end

m.event = function(data)
  local msg = midi.to_msg(data)
  msg.note = snap(msg.note, scale('lydian'))
  local data = midi.to_data(msg)
  m:send(data)
end

usersynth = function(note, level) engine.hz(MusicUtil.note_num_to_freq(note)) end
midisynth = function(note, level)
  clock.run(
    function()
      m:note_on(note, level * 127)--[[; m:note_off(note)]]
      clock.sync(1/16)
      m:note_off(note)
    end
  )
end

I = {1,3,5}
II = {2,4,6}
III = {3,5,7}
IV = {4,6,8}
V = {5,7,9}
VI = {6,8,10}
VII = {7,9,11}
--


a = Vox:new{
  synth = midisynth,
  scale = scale('mixolydian'),

  vox = {
    degree = sequins{1,3,5,7,9,11,13},
    dyn = {
      degree = function() return a.vox.degree() end
    }
  },

  clk = {
    sync = sequins{1/4,1/4,1/2},
    dyn = {
      sync = function() return a.clk.sync() end
    }
  },

  action = function()
    while true do
      a:play(a.vox.dyn)
      clock.sync(a.clk.dyn.sync())
    end
  end
}

m:start()
a.clock = clock.run(a.action)


b = Vox:new{
  synth = midisynth,
  scale = scale('mixolydian')
}


