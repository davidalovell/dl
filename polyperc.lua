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
  synth = polyperc,
  scale = scale('lydian')
}

lead.s = {
    d1 = s{1,5,s{-2,-5,-7,-6}:every(2,1),s{9,13,11,7}:every(2)},
    d2 = s{1,3,5,7}:every(4,1,0),
    d3 = s{1,3,5,7,9,11,13}:skip(3,1):step(-1)
  }

lead.l = l:new_pattern{
  division = 1/16,
  swing = 60,
  action = function()
    lead:play{degree = lead.s.d1}
    lead:play{degree = lead.s.d2, octave = 1}
    lead:play{degree = lead.s.d3, octave = 2}
  end
}


l:start()