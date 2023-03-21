-- dl

-- reload
function reload()
  norns.script.load('code/dl/sc.lua')
end

function r()
  norns.script.load(norns.script.state)
end

function key(n,z)
  -- key actions: n = number, z = state
  if n == 2 and z == 1 then
    -- r()
    l:start()
    softcut.play(1,1)

  elseif n == 3 and z == 1 then
    l:stop()
    l:reset()
    vox.call(voices, 'reset')

    -- vox.set(voices, 'on', false)
  end
end

-- libs
musicutil = require('musicutil')
vox = include('lib/vox') -- voice object
seq = include('lib/seq') -- wrapper object for sequins too allow added functionality
sequins = include('lib/sequins_unnested'); s = sequins -- hacked version of sequins
lattice = include('lib/lattice_1.2'); l = lattice:new()

-- engine
engine.name = 'PolyPerc'

function vox.polyperc(args)
  engine.amp(args.level/100)
  engine.release(args.length)
  engine.cutoff(args.user.cutoff*100)
  engine.pan(args.user.pan)
  engine.hz(musicutil.note_num_to_freq(args.note))
end

-- clock helper fn
function clock.wait(wait)
  return clock.sleep(clock.get_beat_sec() * wait)
end

function init()
  voices = {bass, mid, high}
  engine.amp(0.7)
  engine.release(2) 


file = _path.dust.."audio/tape/0018.wav"

 -- clear buffer
 softcut.buffer_clear()
 -- read file into buffer
 -- buffer_read_mono (file, start_src, start_dst, dur, ch_src, ch_dst)
 softcut.buffer_read_mono(file,1,1,-1,1,1)
 
 -- enable voice 1
 softcut.enable(1,1)
 -- set voice 1 to buffer 1
 softcut.buffer(1,1)
 -- set voice 1 level to 1.0
 softcut.level(1,0.5)
 -- voice 1 enable loop
 softcut.loop(1,1)
 -- set voice 1 loop start to 1
 softcut.loop_start(1,20)
 -- set voice 1 loop end to 2
 softcut.loop_end(1,60)
 -- set voice 1 position to 1
 softcut.position(1,1)
 -- set voice 1 rate to 1.0
 softcut.rate(1,1)
 -- enable voice 1 play




end

-- typical contstruct
bass = vox:new{
  synth = vox.polyperc,
  level = 0.6,
  octave = 3,
  scale = 'dorian',
  negharm = false,
  length = 1/4,
  on = true
}

bass.user = {
  cutoff = 10,
  pan = 0
}

bass.s = {
  div = s{1,1,1,1,1,1,2},
  octave = s{0,1,0,1,1},
  length = s{4,1,2,1/2},
  cutoff = s{5,3,7,8,15,20}
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
  div = 3,
  step = 1,
  seq = {1,3,5,7},
  action = function(val)
    bass:play{degree = val, octave = bass.s.octave, length = bass.s.length, user = {cutoff = bass.s.cutoff(), pan = bass.user.pan}}
  end
}









mid = vox:new{
  synth = vox.polyperc,
  level = 0.6,
  octave = 4,
  scale = 'dorian',
  negharm = false,
  length = 1/4,
  on = true
}

mid.user = {
  cutoff = 10,
  pan = -1/4
}

mid.s = {
  div = s{1,1,1,1,1,1,2},
  octave = s{0,1,1,2,2},
  length = s{3,2,4,1/2,1},
  cutoff = s{10,11,12,13,14}
}

mid.l = l:new_pattern{
  division = 1/16,
  action = function()
    local a = mid.seq:play{div = mid.s.div}
    -- the below doesnt work, but it would be nice if it did
    -- add a property to seq which says if the val returned a note the last time
    -- if not a then
    --   local b = bass2.seq:play{div = bass2.s.div}
    -- end
  end
}

mid.seq = seq:new{
  div = 2,
  step = 3,
  seq = {1,3,5,7},
  action = function(val)
    mid:play{degree = val, octave = mid.s.octave, length = mid.s.length, user = {cutoff = mid.s.cutoff(), pan = mid.user.pan}}
  end
}










high = vox:new{
  synth = vox.polyperc,
  level = 0.5,
  octave = 4,
  scale = 'dorian',
  negharm = false,
  length = 1/4,
  on = true
}

high.user = {
  cutoff = 10,
  pan = 1/4
}

high.s = {
  div = s{1,1,1,1,1,1,2},
  octave = s{1,1,-1},
  length = s{5,2,7,1,6,3,5},
  cutoff = s{18,16,20,22}
}

high.l = l:new_pattern{
  division = 1/16,
  action = function()
    local a = high.seq:play{div = high.s.div}
    -- the below doesnt work, but it would be nice if it did
    -- add a property to seq which says if the val returned a note the last time
    -- if not a then
    --   local b = bass2.seq:play{div = bass2.s.div}
    -- end
  end
}

high.seq = seq:new{
  div = 5,
  step = 1,
  seq = {1,7,9,11},
  action = function(val)
    high:play{degree = val, octave = high.s.octave, length = high.s.length, user = {cutoff = high.s.cutoff(), pan = high.user.pan}}
  end
}




































-- lead = vox:new{
--   synth = vox.midisynth,
--   device = midi.connect(1),
--   channel = 1,
--   level = 0.6,
--   octave = 5,
--   scale = 'dorian',
--   negharm = false,
--   length = 1/4,
--   on = false
-- }

-- lead.s = {
--   div = s{2,2,1,7,36},
--   octave = s{0,1}:every(2,1,1)
-- }

-- lead.l = l:new_pattern{
--   division = 1/16,
--   action = function()
--     lead.seq:play{div = lead.s.div}
--   end
-- }

-- lead.seq = seq:new{
--   div = 1,
--   seq = {1,3,5,7,9},
--   action = function(val)
--     lead:play{degree = val, octave = lead.s.octave}
--   end
-- }

-- high = vox:new{
--   synth = vox.midisynth,
--   device = midi.connect(1),
--   channel = 1,
--   level = 0.8,
--   wrap = false,
--   octave = 6,
--   degree = 1,
--   scale = 'dorian',
--   negharm = false,
--   length = 3/4,
--   on = false
-- }

-- high.s = {
--   div = s{2,2,1,7,52},
--   octave = s{0,1}:every(2,1,1)
-- }

-- high.l = l:new_pattern{
--   division = 1/16,
--   action = function()
--     high.seq:play{div = high.s.div}
--   end
-- }

-- high.seq = seq:new{
--   div = 3,
--   seq = {1,3,4,5,9,8},
--   action = function(val)
--     high:play{degree = val, octave = high.s.octave}
--   end
-- }


-- a4 = vox:new{
--   synth = vox.midisynth,
--   device = midi.connect(2),
--   channel = 1,
--   level = 0.8,
--   wrap = false,
--   octave = 5,
--   degree = 1,
--   scale = 'dorian',
--   negharm = false,
--   length = 4,
--   on = true
-- }

-- a4.s = {
--   div = s{2},
--   -- octave = s{0,1}:every(2,1,1)
-- }

-- a4.l = l:new_pattern{
--   division = 1/16,
--   action = function()
--     a4.seq:play{div = a4.s.div}
--   end
-- }

-- a4.seq = seq:new{
--   div = 32,
--   seq = {1,5},
--   action = function(val)
--     a4:play{degree = val}
--     a4:play{degree = val + 4}
--   end
-- }

-- bd = vox:new{
--   synth = vox.midisynth,
--   device = midi.connect(3),
--   channel = 1,
--   level = 0.8,
--   wrap = false,
--   octave = 5,
--   degree = 1,
--   scale = 'dorian',
--   negharm = false,
--   length = 1/4,
--   on = true
-- }

-- bd.s = {
--   div = s{1},
-- }

-- bd.l = l:new_pattern{
--   division = 1/16,
--   action = function()
--     bd.seq:play{div = bd.s.div}
--   end
-- }

-- bd.seq = seq:new{
--   div = 8,
--   seq = {1,1,1,4,1,1,1,1},
--   action = function(val)
--     bd:play{degree = val}
--   end
-- }

-- jf = vox:new{
--   synth = vox.jfnote,
--   level = 3,
--   wrap = false,
--   octave = 0,
--   degree = 1,
--   scale = 'dorian',
--   negharm = false,
--   length = 1/4,
--   on = false
-- }

-- jf.s = {
--   degree = s{1,5, 4,1, 7,4, 7,6, 0,1},
--   offset = s{0,0,0,3,5,5},
--   div = s{2/4,13/4,1/4,  2/4,1/4,13/4}--,
--   -- octave = s{0,0,0,1,1,0,0}
-- }

-- jf.l = l:new_pattern{
--   -- division = 1/16,
--   action = function()
--     jf.l:set_division(jf.s.div())
--     jf:play{degree = jf.s.degree() + jf.s.offset()}--, octave = jf.s.octave}
--     -- jf.seq:play{div = jf.s.div}
--   end
-- }

-- -- wingie = vox:new{
-- --   synth = vox.midisynth,
-- --   device = midi.connect(2),
-- --   channel = 1,
-- --   level = 1,
-- --   octave = 6,
-- --   scale = 'dorian',
-- --   negharm = false,
-- --   length = 1/4
-- -- }




-- voices = {bass,lead,high,a4,bd,jf}



-- function go()

--   I = {1,3,4,5,7}
--   V = {1,4,6,7}
--   VII = {2,4,6,7}

--   print(1)
--   vox.set(voices, 'mask', I)

--   clock.run(
--     function()
--       while true do 
--         clock.wait(32)
--         print(5)
--         vox.set(voices, 'mask', V)
--         clock.wait(16)
--         print(7)
--         vox.set(voices, 'mask', VII)
--         clock.wait(16)
--         print(1)
--         vox.set(voices, 'mask', I)

--       end
--     end
--   )

-- end

-- -- > vox.set(voices, 'mask', {1,2,4,6})
-- -- <ok>

-- -- > vox.set(voices, 'mask', {1,2,3,5})