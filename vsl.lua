-- vsl
-- vox
-- ?seq
-- sequins
-- lattice

engine.name = 'PolyPerc'
music = require 'musicutil'
vox = include 'lib/vox'
seq = include 'lib/seq'
s = include 'lib/sequins_DL'
lattice = require 'lattice'

function r()
  norns.script.load('code/vox_norns/vsl.lua')
end

function scale(scale)
  return music.generate_scale_of_length(0, scale, 7)
end

-- function cs(sequins) -- returns a val rather than table
--   local s = sequins()
--   return type(s) == 'table' and sequins.ix or s
-- end

-- function skips(sequins) -- returns nil rather than a table
--   local s = sequins()
--   return type(s) == 'table' and nil or s
-- end

function nsynth(note, level)
  engine.hz(music.note_num_to_freq(note))
end

lead1 = vox:new{
  synth = nsynth
}
-- sequence = s{1,2,3,4}:every(4)

-- l = lattice:new()

-- pattern_a = l:new_pattern{
--   action = function(t)
--     local sequence_val = sequence()
--     if type(sequence_val) == 'number' then
--       return lead1:play{degree = cs(sequence)}
--     end
--   end,
--   division = 1/16,
--   enabled = true
-- }

step = s{1/2,1/8,1/8,1/4}

lat = lattice:new()
p1 = lat:new_pattern{
  division = 1/8,
  action = function()
    p2.enabled = true
    p2.division = step()
    p2.enabled = false
  end
}

p2 = lat:new_pattern{
  action = function()
    lead1:play()
  end
}