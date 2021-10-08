-- vox

engine.name = 'PolyPerc'

sequins = require 'sequins'
MusicUtil = require 'musicutil'
Vox = include 'lib/vox'
m = midi.connect()

function scale(scale)
  return MusicUtil.generate_scale_of_length(60, scale, 7)
end

function note(note_num, snap_array)
  return MusicUtil.snap_note_to_array(note_num, snap_array)
end

usersynth = function(note, level) engine.hz(MusicUtil.note_num_to_freq(note)) end
midisynth = function(note, level)
  clock.run(
    function()
      m:note_on(note, level * 127)--[[; m:note_off(note)]]
      clock.sync(1/4)
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

a.clock = clock.run(a.action)


b = Vox:new{
  synth = midisynth,
  scale = scale('mixolydian')
}


m.event = function(data)


  
  local d = midi.to_msg(data)

  if d.type == 'note_on' then
    m:note_on(d.note, d.vel)
    m:note_on(d.note + 7, d.vel)
  end

  if d.type == 'note_off' then
    m:note_off(d.note, d.vel)
    m:note_off(d.note + 7, d.vel)
  end
end

