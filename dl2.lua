-- dl

function reload()
  norns.script.load('code/dl/dl2.lua')
end

function r() norns.script.load(norns.script.state) end

function key(n,z)
  -- key actions: n = number, z = state
  if n == 3 and z == 1 then
    r()
  end
end

-- libs
musicutil = require('musicutil')
vox = include('lib/vox') -- voice object
seq = include('lib/seq') -- wrapper object for sequins too allow added functionality
sequins = include('lib/sequins_unnested'); s = sequins -- hacked version of sequins
lattice = include('lib/lattice_1.2'); l = lattice:new()




-- clock helper fn
function clock.wait(wait)
  return clock.sleep(clock.get_beat_sec() * wait)
end


-- transport fns, digitone is master clock
function clock.transport.start()
  l:start()
end

function clock.transport.stop()
  l:stop()
  l:reset()
  vox.call(voices, 'reset')
end





-- typical contstruct
bass = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  level = 0.6,
  octave = 4,
  scale = 'dorian',
  negharm = true,
  length = 1/4
}

bass.user = {
  cutoff = 0.4
}

bass.action = function(self, args)
  -- args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
  -- args.device:cc(23, args.user.cutoff, args.channel)
end

bass.s = {
  div = s{2,1,1},
  cutoff = s{0.5,0.7,0.5,0.7,0.6}
}

bass.l = l:new_pattern{
  division = 1/16,
  action = function()
    local a = bass.seq:play{div = bass.s.div}
    -- the below doesnt work, but it would be nice if it did
    -- add a property to seq which says if the val returned a note the last time
    -- if not a then 
    --   local b = bass2.seq:play{div = bass2.s.div}
    -- end
  end
}

bass.seq = seq:new{
  div = 4,
  step = 2,
  seq = {1,4,5,7,9},
  action = function(val)
    bass:play{degree = val, user = {cutoff = bass.s.cutoff}}
  end
}



bass.device.event = function(data)
  local msg = midi.to_msg(data)
  if msg.type == 'cc' then
    -- if msg.cc == 70 then
    --   bass.seq.skip = math.floor(msg.val) + 1
    -- end
  end
end




lead = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  level = 0.6,
  octave = 5,
  scale = 'dorian',
  negharm = true,
  length = 1/4
}

lead.s = {
  div = s{2,2,1,7,16},
  octave = s{0,1}:every(4,1,1)
}

lead.l = l:new_pattern{
  division = 1/16,
  action = function()
    lead.seq:play{div = lead.s.div}
  end
}

lead.seq = seq:new{
  div = 1,
  seq = {1,3,4,5,7},
  action = function(val)
    lead:play{degree = val, octave = lead.s.octave}
  end
}

high = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  level = 0.8,
  wrap = true,
  octave = 5,
  degree = 5,
  scale = 'dorian',
  negharm = true,
  length = 3/4
}

high.s = {
  div = s{2,2,1,7,15},
  octave = s{0,1}:every(4,1,1)
}

high.l = l:new_pattern{
  division = 1/16,
  action = function()
    high.seq:play{div = high.s.div}
  end
}

high.seq = seq:new{
  div = 3,
  seq = {1,3,4,5,7},
  action = function(val)
    high:play{degree = val, octave = high.s.octave}
  end
}


wingie = vox:new{
  synth = vox.midisynth,
  device = midi.connect(2),
  channel = 1,
  level = 1,
  octave = 5,
  scale = 'dorian',
  negharm = true,
  length = 1/4
}


voices = {bass,lead,high}




-- clock.run(
--   function()
--     while true do 
--       clock.wait(16)
--       print(1)
--       vox.set(voices, 'degree', 1)
--       vox.set(voices, 'negharm', true)

--       clock.wait(16)
--       print(2)
--       vox.set(voices, 'degree', 1)
--       vox.set(voices, 'negharm', false)

--       clock.wait(16)
--       print(3)
--       vox.set(voices, 'degree', -3)
--       vox.set(voices, 'negharm', false)

--       clock.wait(16)
--       print(4)
--       vox.set(voices, 'degree', -2)
--       vox.set(voices, 'negharm', true)
      
--       -- clock.wait(8)
--       -- print(3)
--       -- vox.set(voices, 'degree', 0)
--       -- vox.set(voices, 'negharm', false)

--       -- clock.wait(8)
--       -- print(4)
--       -- vox.set(voices, 'degree', -2)
--       -- vox.set(voices, 'negharm', false)

--       -- clock.wait(8)
--       -- print(1)
--       -- vox.set(voices, 'degree', 1)
--       -- vox.set(voices, 'negharm', true)

      
--     end
--   end
-- )