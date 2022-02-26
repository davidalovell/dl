-- dl



-- reload fns
function reload()
  norns.script.load('code/dl/dl.lua')
end

function r() norns.script.load(norns.script.state) end

function key(n,z)
  if n == 2 and z ==1 then
    start()
  elseif n == 3 and z == 1 then
    r()
  end
end




-- libs
sequins = include('lib/sequins_unnested'); s = sequins -- hacked version of sequins
lattice = include('lib/lattice_1.2'); l = lattice:new()
vox = include('lib/vox') -- voice object
seq = include('lib/seq') -- wrapper object for sequins too allow added functionality
musicutil = require('musicutil')




-- clock helper fn
function clock.wait(wait, fn)
  return clock.run(function() clock.sleep(clock.get_beat_sec() * wait); fn() end)
end


function start()
  l:start()
end

function stop()
  l:stop()
  l:reset()
  vox.call(voices, 'reset')
end

-- transport fns, digitone is master clock
function clock.transport.start()
  start()
end

function clock.transport.stop()
  stop()
end






main = l:new_pattern{
  division = 1/16,
  action = function()
    local bass = bass.seq:play{div = bass.s.div}
    if not bass then
      local lead = lead.seq:play{div = lead.s.div}
      if not lead then
        local high = high.seq:play{div = high.s.div}
      end
    end
  end
}




bass = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  length = 1/4,
  scale = 'lydian',
  octave = 3
}

bass.s = {
  div = s{1,2,3,1}
}

bass.seq = seq:new{
  div = 4,
  step = 2,
  seq = {1,2,3,4,5,6,7},
  action = function(val)
    bass:play{degree = val}
  end
}

lead = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  length = 1/8,
  scale = 'lydian',
  octave = 4
}

lead.s = {
  div = s{1,1,1,7}
}

lead.seq = seq:new{
  div = 1,
  prob = 0.5,
  seq = {1,2,3,4,5,6,7},
  action = function(val)
    lead:play{degree = val, step = math.random(1,6)}
  end
}

high = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  length = 1/8,
  scale = 'lydian',
  octave = 5
}

high.s = {
  div = s{1,2,8,1,1,1,1,16}
}

high.seq = seq:new{
  div = 1,
  prob = 0.75,
  seq = {1,2,3,4,5,6,7},
  action = function(val)
    high:play{degree = val, step = math.random(1,6)}
  end
}






voices = {bass, lead, high}







-- -- objects (vox, sequins, lattice, seq), vox is the main object and other objects are stored in its table
-- -- bass is a voice on digitone
-- bass = vox:new{
--   synth = vox.midisynth,
--   device = midi.connect(1),
--   channel = 1,
--   on = false,
--   octave = 3,
--   level = 1,
--   scale = 'lydian',
--   length = 1/4
-- }

-- bass.user = {
--   -- cutoff = 0.5
-- }

-- bass.action = function(self, args)
--   -- args.user.cutoff = args.user.cutoff == nil and 0.5 or args.user.cutoff
--   -- args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
--   -- args.device:cc(23, args.user.cutoff, args.channel)
-- end

-- bass.s = {
--   div = s{4,4,6,2},
--   -- cutoff = s{0.5,0.7,0.5,0.7,0.6}
-- }

-- bass.l = l:new_pattern{
--   division = 1/16,
--   action = function()
--     local root = bass.seq:play{div = bass.s.div}
--     if not root then
--       bass2.seq:play{div = bass2.s.div}
--     end
--   end
-- }

-- bass.seq = seq:new{
--   div = 2,
--   seq = {1,1,1,9},
--   action = function(val)
--     bass:play{degree = val} --, user = {cutoff = bass.s.cutoff}}
--   end
-- }




-- bass2 = vox:new{
--   synth = vox.midisynth,
--   device = midi.connect(1),
--   channel = 1,
--   on = false,
--   octave = 4,
--   level = 0.6,
--   scale = 'lydian',
--   length = 1/4,
--   wrap = true
-- }

-- bass2.user = {
--   -- cutoff = 0.5
-- }

-- bass2.action = function(self, args)
--   -- args.user.cutoff = args.user.cutoff == nil and 0.5 or args.user.cutoff
--   -- args.user.cutoff = math.ceil(self.user.cutoff * args.user.cutoff() * 127)
--   -- args.device:cc(23, args.user.cutoff, args.channel)
-- end

-- bass2.s = {
--   div = s{4,1,2,1,1,5,3},
--   -- cutoff = s{0.5,0.7,0.5,0.7,0.6}
-- }

-- bass2.seq = seq:new{
--   div = 2,
--   step = 2,
--   prob = 0.5,
--   seq = {1,3,5,7,9},
--   action = function(val)
--     bass2:play{degree = val} --, user = {cutoff = bass.s.cutoff}}
--   end
-- }









-- -- chord is a pad voice on digitone
-- chord = vox:new{
--   synth = vox.midisynth,
--   device = midi.connect(1),
--   channel = 2,
--   on = false,
--   octave = 5,
--   scale = 'lydian',
--   length = 2,
--   wrap = false,
-- }

-- chord.s = {
--   degree1 = s{1,1,1,2},
--   degree2 = s{3,3,2,4},
--   degree3 = s{5,5,5,6},
--   degree4 = s{7,9,11,9}
-- }

-- chord.l = l:new_pattern{
--   division = 1/16,
--   seq = {1},
--   action = function()
--     chord.seq:play()
--   end
-- }

-- chord.seq = seq:new{
--   div = 64,
--   action = function(val)
--     clock.wait(1/math.random(1,4), function() chord:play{degree = chord.s.degree1} end)
--     clock.wait(1/math.random(1,4), function() chord:play{degree = chord.s.degree2} end)
--     clock.wait(1/math.random(1,4), function() chord:play{degree = chord.s.degree3} end)
--     clock.wait(1/math.random(1,4), function() chord:play{degree = chord.s.degree4} end)
--   end
-- }


-- jf = vox:new{
--   synth = function(args) crow.ii.jf.play_note(args.note/12, args.level/127) end,
--   scale = 'lydian',
--   octave = 1,
--   level = 0.3
-- }

-- jf.s = {
--   div = s{2,1,6,1,5,1,8},
--   -- cutoff = s{0.5,0.7,0.5,0.7,0.6}
-- }

-- jf.l = l:new_pattern{
--   division = 1/16,
--   action = function()
--     -- local root = bass.seq:play{div = bass.s.div}
--     -- if not root then
--     --   bass2.seq:play{div = bass2.s.div}
--     -- end
--     jf.seq:play{div = jf.s.div}
--   end
-- }

-- jf.seq = seq:new{
--   div = 3,
--   seq = {6,11,5,9,1,10,3,7},
--   action = function(val)
--     jf:play{degree = val} --, user = {cutoff = bass.s.cutoff}}
--   end
-- }

-- mangrove1 = vox:new{
--   synth = function(args)
--     crow.output[3].volts = args.note/12
--     -- crow.output[2](true)
--   end,
--   scale = 'lydian',
--   octave = 1
-- }

-- mangrove1.s = {
--   div = s{1}
-- }

-- mangrove1.l = l:new_pattern{
--   division = 1/4,
--   action = function()
--     mangrove1.seq:play{div = mangrove1.s.div}
--   end
-- }

-- mangrove1.seq = seq:new{
--   div = 16,
--   seq = {1,1,3,2},
--   action = function(val)
--     -- print('mangrove1: ', val)
--     mangrove1:play{degree = val}
--   end
-- }

-- mangrove2 = vox:new{
--   synth = function(args)
--     crow.output[4].volts = args.note/12
--     -- crow.output[2](true)
--   end,
--   scale = 'lydian',
--   octave = 0
-- }

-- mangrove2.s = {
--   div = s{1}
-- }

-- mangrove2.l = l:new_pattern{
--   division = 1/4,
--   action = function()
--     mangrove2.seq:play{div = mangrove2.s.div}
--   end
-- }

-- mangrove2.seq = seq:new{
--   div = 16,
--   seq = {3,5,5,6},
--   action = function(val)
--     -- print('mangrove2: ', val)
--     mangrove2:play{degree = val}
--   end
-- }

-- -- table of the above objects, doing this allows the reset fns to work
-- voices = {bass, bass2, chord, jf, mangrove1, mangrove2}




-- -- functions that are called live to play the song
-- function init()
--   crow.ii.jf.mode(1)
--   crow.output[3].volts = 0/12
--   crow.output[3].slew = 0.4
--   crow.output[4].volts = 4/12
--   crow.output[4].slew = 0.4
  
--   current_part = 1
--   parts = 7
--   next(current_part)
-- end



-- -- arrangement


-- function next(part, beat)
--   beat = beat == nil and 4 or beat

--   if part == 1 then
--     clock.run(
--       function()
--         clock.sync(beat)
--         bass.on = true
--         bass2.on = false
--         bass2.seq.div = 4
--         chord.on = true
--         jf.on = false
--         mangrove1.on = true
--         mangrove2.on = true
--       end
--     )

--   elseif part == 2 then
--     clock.run(
--       function()
--         clock.sync(beat)
--         bass.on = true
--         bass2.on = true
--         bass2.seq.div = 4
--       end
--     )

--   elseif part == 3 then
--     clock.run(
--       function()
--         clock.sync(beat)
--         jf.seq.prob = 0.7
--         jf.on = true
--       end
--     )

--   elseif part == 4 then
--     clock.run(
--       function()
--         clock.sync(beat)
--         bass2.seq.div = 2
--         jf.seq.prob = 1
--         jf.seq.skip = 1
--         jf.seq.seq = {6,11,5,9,1,10,3,s{7,14}}
--       end
--     )

--   elseif part == 5 then
--     clock.run(
--       function()
--         clock.sync(beat)
--         vox.set(voices, 'degree', -1)
--       end
--     )

--   elseif part == 6 then
--     clock.run(
--       function()
--         clock.sync(beat)
--         vox.set(voices, 'negharm', true)
--         vox.set(voices, 'degree', 5)
--       end
--     )

--   elseif part == 7 then
--     clock.run(
--       function()
--         clock.sync(beat)
--         vox.set(voices, 'negharm', false)
--         vox.set(voices, 'degree', 1)
--       end
--     )
--   end

--   print(current_part)
--   current_part = current_part % parts + 1
-- end
