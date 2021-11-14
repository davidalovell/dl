function reload()
  norns.script.load('code/dl/dl.lua')
end

function r() norns.script.load(norns.script.state) end

sequins = include('lib/sequins_h'); s = sequins
lattice = include('lib/lattice_1.2'); l = lattice:new()
vox = include('lib/vox')
seq = include('lib/seq')
m = midi.connect(1)

function sync(sync, fn)
  return clock.run(function() clock.sync(sync); fn() end)
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
end








-- typical contstruct
bass = vox:new{
  device = midi.connect(1),
  channel = 1,
  on = true,
  octave = 4,
  scale = vox.apply_scale('lydian'),
  length = 1/4
}

bass.user = {
  cutoff = 0.5
}

-- TODO incorporate this into vox
bass.synth = function(self, args)
  args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
  args.device:cc(23, args.user.cutoff, args.channel)
  clock.run(
    function()
      args.device:note_on(args.note, args.level, args.channel)
      clock.sync(args.length)
      args.device:note_off(args.note, args.level, args.channel)
    end
  )
end

bass.s = {
  div = s{4,4,4,1,1,2},
  cutoff = s{0.9,0.7,0.5,0.7,0.6}
}

bass.l = l:new_pattern{
  division = 1/16,
  action = function()
    bass.seq:play{div = bass.s.div}
  end
}

bass.seq = seq:new{
  div = 2,
  seq = {1,4,5,s{7,9,6,11}},
  action = function(val)
    bass:play{degree = val, user = {cutoff = bass.s.cutoff}}
  end
}





voices = {bass}