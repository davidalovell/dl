function reload()
  norns.script.load('code/dl/dl.lua')
end

function r() norns.script.load(norns.script.state) end

sequins = include('lib/sequins_dl'); s = sequins
lattice = include('lib/lattice_1.2'); l = lattice:new()
vox = include('lib/vox')
seq = include('lib/seq')

function sync(sync, fn)
  return clock.run(function() clock.sync(sync); fn() end)
end






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
  device = midi.connect(1),
  channel = 1,
  on = true,
  octave = 4,
  scale = 'lydian',
  length = 1/4
}

bass.device.event = function(data)
  local msg = midi.to_msg(data)
  if msg.type == 'cc' then
    -- if msg.cc == 70 then
    --   bass.seq.skip = math.floor(msg.val) + 1
    -- end
  end
end

bass.user = {
  cutoff = 0.5
}

bass.action = function(self, args)
  args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
  args.device:cc(23, args.user.cutoff, args.channel)
end

bass.s = {
  div = s{2,4,3,3,16},
  cutoff = s{0.5,0.7,0.5,0.7,0.6}
}

bass.l = l:new_pattern{
  division = 1/16,
  action = function()
    bass.seq:play{div = bass.s.div}
  end
}

bass.seq = seq:new{
  div = 1,
  seq = {1,4,5,s{7,9,6,11}},
  action = function(val)
    bass:play{degree = val, user = {cutoff = bass.s.cutoff}}
  end
}





voices = {bass}