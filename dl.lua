-- dl
-- the code for norns recording 0077


-- reload fns
function reload()
  norns.script.load('code/dl/dl.lua')
end

function r() norns.script.load(norns.script.state) end

function key(n,z)
  if n == 2 and z ==1 then
    next(current_part)
  elseif n == 3 and z == 1 then
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




-- objects (vox, sequins, lattice, seq), vox is the main object and other objects are stored in its table
main = {}
main.s = {
  -- transpose = s{0,2,4,6}:every(64,1,1)
  transpose = s{0,3,7,5}:every(64,1,1)
}
main.l = l:new_pattern{
  division = 1/32,
  action = function()
    main.transpose = main.s.transpose()
    -- for i = 1,4 do
    --   ooh[i]:play{transpose = main.transpose}
    -- end
  end
}

jf = vox:new{
  synth = vox.jfnote,
  octave = 1,
  transpose = 7,
  level = 0.5,
  scale = 'minor pentatonic'
}

jf.s = {
  div = s{1,1,1,1,1,36},
  octave = s{0,1}:every(4,1,1)
}

jf.l = l:new_pattern{
  division = 1/32,
  action = function()
    jf.seq:play{div = jf.s.div, step = math.random(1,4)}
  end
}

jf.seq = seq:new{
  div = 2,
  step = -1,
  seq = {1,2,3,4,5,6,7},
  action = function(val)
    -- clock.run(
    --   function()
    --     clock.sleep(math.random()/10)
    --     jf:play{degree = val, octave = jf.s.octave}
    --   end
    -- )
    jf:play{degree = val , transpose = main.s.transpose, octave = jf.s.octave}
  end
}

lead = vox:new{
  synth = vox.midisynth,
  device = midi.connect(1),
  channel = 1,
  level = 1,
  octave = 6,
  scale = 'ionian',
  length = 1/4
}

lead.s = {
  div = s{2,1,1},
  skip = s{1,2}:every(8,1,1)
}

lead.l = l:new_pattern{
  division = 1/32,
  action = function()
    lead.seq:play{div = lead.s.div, step = math.random(1,4), skip = lead.s.skip}
  end
}

lead.seq = seq:new{
  div = 2,
  step = 1,
  offset = 1,
  prob = 0.7,
  seq = {1,4,5,4},
  action = function(val)
    -- clock.run(
    --   function()
    --     clock.sleep(math.random()/10)
    --     jf:play{degree = val, octave = jf.s.octave}
    --   end
    -- )
    lead:play{degree = val, transpose = main.transpose, octave = math.random(-1,0)}
  end
}

mangrove = vox:new{
  synth = function(args)
    crow.output[3].volts = args.note/12
    crow.output[4]()
  end,
  scale = 'ionian',
  octave = 0
}

mangrove.s = {
  div = s{2,1,1,3},
  octave = s{0,-1}:every(2,1,1),
  skip = s{2,1}:every(8,1,1)
}

mangrove.l = l:new_pattern{
  division = 1/32,
  action = function()
    mangrove.seq:play{div = mangrove.s.div, skip = mangrove.s.skip}
  end
}

mangrove.seq = seq:new{
  div = 4,
  skip = 1,
  step = -1,
  seq = {1,4,5},
  action = function(val)
    mangrove:play{degree = val, transpose = main.transpose, octave = mangrove.s.octave}
  end
}

ooh = {}
for i = 1, 4 do
  ooh[i] = vox:new{
    synth = vox.midisynth,
    device = midi.connect(3),
    channel = 5 + (i - 1),
    level = 0.6 + (i * 0.1),
    octave = 4 - math.floor(i / 2),
    degree = 1 + (2 * i),
    scale = 'ionian',
    length = 1/2
  }

  ooh[i].s = {
    div = s{i},
  }
  
  ooh[i].l = l:new_pattern{
    division = 1/32,
    action = function()
      ooh[i].seq:play{div = ooh[i].s.div, step = math.random(1,4)}
    end
  }
  
  ooh[i].seq = seq:new{
    div = 32,
    step = 1,
    offset = i - 1,
    seq = {1},
    action = function(val)
      -- clock.run(
      --   function()
      --     clock.sleep(math.random()/10)
      --     jf:play{degree = val, octave = jf.s.octave}
      --   end
      -- )
      ooh[i]:play{degree = val, transpose = main.transpose}
    end
  }
end

voices = {jf,lead,mangrove,ooh[1],ooh[2],ooh[3],ooh[4]}












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
--   div = s{4,4,6,2}
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
--   seq = {1,1,1,9, 1,1,1,9, 1,1,1,9, 1,1,1,9, 1,1,1,9, 1,1,1,9, 2,2,2,9, 2,2,6,13},
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
--     clock.run(
--       function()
--         clock.wait(1)
--         clock.sleep(math.random()/10)
--         chord:play{degree = chord.s.degree1}
--         clock.sleep(math.random()/10)
--         chord:play{degree = chord.s.degree2}
--         clock.sleep(math.random()/10)
--         chord:play{degree = chord.s.degree3}
--         clock.sleep(math.random()/10)
--         chord:play{degree = chord.s.degree4}
--       end
--     )
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
--   octave = s{0}
-- }

-- jf.l = l:new_pattern{
--   division = 1/16,
--   action = function()
--     jf.seq:play{div = jf.s.div}
--   end
-- }

-- jf.seq = seq:new{
--   div = 3,
--   seq = {6,11,5,9,1,10,3,7},
--   action = function(val)
--     clock.run(
--       function()
--         clock.sleep(math.random()/10)
--         jf:play{degree = val, octave = jf.s.octave}
--       end
--     )
--     -- jf:play{degree = val, octave = jf.s.octave}
--   end
-- }

-- mangrove1 = vox:new{
--   synth = function(args)
--     crow.output[2]()
--     crow.output[3].volts = args.note/12
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
--   seq = {1,5,3,2},
--   action = function(val)
--     mangrove1:play{degree = val}
--   end
-- }

-- mangrove2 = vox:new{
--   synth = function(args)
--     crow.output[4].volts = args.note/12
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
--   seq = {3,1,5,6},
--   action = function(val)
--     mangrove2:play{degree = val}
--   end
-- }

-- -- table of the above objects, doing this allows the reset fns to work
-- voices = {bass, bass2, chord, jf, mangrove1, mangrove2}




-- functions that are called live to play the song
function init()
  crow.ii.jf.mode(1)
  crow.output[4].action = "ar(0.01, 0.02, linear)"
  -- crow.output[3].volts = 0/12
  -- crow.output[3].slew = 0.4
  -- crow.output[4].volts = 4/12
  -- crow.output[4].slew = 0.4
  
  current_part = 1
  parts = 7
  next(current_part)
end



-- arrangement


function next(part, beat)
  beat = beat == nil and 4 or beat

  if part == 1 then
    clock.run(
      function()
        clock.sync(beat)
        -- bass.on = true
        -- bass2.on = true
        -- bass2.seq.div = 4
        -- chord.on = true
        -- jf.on = false
        -- mangrove1.on = true
        -- mangrove2.on = true
      end
    )

  elseif part == 2 then
    clock.run(
      function()
        clock.sync(beat)
        -- jf.seq.seq = {6,11,5,9,1,10,3,7}
        -- jf.seq.div = 3
        -- jf.seq.prob = 0.7
        -- jf.on = true
      end
    )

  elseif part == 3 then
    clock.run(
      function()
        clock.sync(beat)
        -- bass2.seq.div = 2
        -- jf.seq.prob = 1
        -- jf.seq.div = 2
        -- jf.seq.seq = {12,10,9,6,5,3,2}
        -- jf.s.div:settable{2,1,1,1,1,2,3,16}
        -- jf.s.octave:settable{0,s{1}:every(5)}
      end
    )

  elseif part == 4 then
    clock.run(
      function()
        clock.sync(beat)
        -- vox.set(voices, 'degree', -1)
      end
    )

  elseif part == 5 then
    clock.run(
      function()
        clock.sync(beat)
        -- vox.set(voices, 'degree', 0)
      end
    )

  elseif part == 6 then
    clock.run(
      function()
        clock.sync(beat)
        -- jf.octave = 1
        -- jf.seq.step = -1
        -- jf.s.div:settable{2,1,1,1,1,2,3}
        -- vox.set(voices, 'degree', 1)
      end
    )
  end

  print(current_part)
  current_part = current_part % parts + 1
end