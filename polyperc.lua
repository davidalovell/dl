-- testing ground for sequins, lattice and vox

function r()
  norns.script.load('code/vox_norns/polyperc.lua')
end

engine.name = 'PolyPerc'

sequins = include('lib/sequins_dl'); s = sequins
vox = include('lib/vox')

-- lattice = include('lattice/lib/lattice')

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


b = s{1,2,3,4,5,6,7,8}:every(2)

lead = vox:new{
  synth = polyperc,
  scale = scale('lydian'),
  s = {
    degree = s{1,2,3,4,5,6,7,8}:every(2)
  },
  c = {
    division = 1/8,
    action = function()
      clock.sync(lead.c.division)
      lead:play{degree = lead.s.degree}
    end
  }
}

lead.clock = clock.run(function() while true do lead.c.action() end end)
