-- testing ground for sequins, lattice and vox

function r()
  norns.script.load('code/vox_norns/test.lua')
end

engine.name = 'PolyPerc'

s = include('lib/sequins_dl')
lattice = include('lattice/lib/lattice')
vox = include('lib/vox')
seq = include('lib/seq')

music = require 'musicutil'

function scale(scale) return music.generate_scale_of_length(0, scale, 7) end
function polyperc(note, level) engine.hz(music.note_num_to_freq(note)) end

lead = vox:new{
  synth = polyperc,
  scale = scale('lydian')


}

seq1 = s{1,4,5,s{7,9,13}:every(2,1)}:skip(3,1,1)
seq2 = s{1/4,1/16,1/16,1/8}

l = lattice:new()
pattern_a = l:new_pattern{
  division = 1/16,
  action = function()
    pattern_a:set_division(seq2())
    lead:play{degree = seq1()}
  end

}


