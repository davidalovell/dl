-- testing ground for sequins, lattice and vox

function r()
  norns.script.load('code/vox_norns/polyperc.lua')
end

engine.name = 'PolyPerc'
sequins = include('lib/sequins_dl'); s = sequins
lattice = include('lib/lattice_dl'); l = lattice:new()
vox = include('lib/vox')
music = require 'musicutil'

function scale(scale) return music.generate_scale_of_length(0, scale, 7) end
function polyperc(note, level) engine.hz(music.note_num_to_freq(note)) end

function sync(sync, fn)
  return
    clock.run(
      function()
        clock.sync(sync)
        fn()
      end
    )
end

lead = vox:new{
  on = false,
  synth = polyperc,
  scale = scale('lydian')
}

lead.s = {
    d1 = s{1,5,s{-2,-5,-7,-6}:every(2,1),s{9,13,11,7}:every(2)}:every(1,0)
  }

lead.l = l:new_pattern{
  division = 1/16,
  swing = 50,
  action = function()
    lead:play{degree = lead.s.d1}
  end
}

bass = vox:new{
  on = true,
  synth = polyperc,
  scale = scale('lydian'),
  octave = 4,
  degree = 1
}

bass.s = {
  deg1 = s{1,3,5,7,9,11,13,14},
  deg2 = s{5,4,1}:every(4,1,1),
  div1 = s{1,1,1,1,8},
  division = 1/32
}

bass.l = l:new_pattern{
  swing = 60,
  action = function()
    bass.l.division = bass.s.div1() * bass.s.division
    bass:play{degree = bass.s.deg1() + bass.s.deg2()}
  end
}

l:start()