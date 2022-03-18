-- studies

function reload()
  norns.script.load('code/dl/studies.lua')
end

function r()
  norns.script.load(norns.script.state)
end

engine.name = "PolyPerc"

musicutil = require('musicutil')
sequins = require('sequins')
lattice = require('lattice')

s = sequins
l = lattice:new()

pattern = l:new_pattern{
  action = function(x)
    scale = musicutil.generate_scale(0, 'lydian', 20)
    note = sequence() 
    -- local q_note = musicutil.snap_note_to_array(note, scale)
    local q_note = scale[note + 1] + params:get('note')
    local hz = musicutil.note_num_to_freq(q_note)
    engine.hz(hz)
  end
}

sequence = s{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21}


params:add_number(
  "note", -- id
  "note", -- name
  0, -- min
  127, -- max
  60, -- default
  function(param) return musicutil.note_num_to_name(param:get(), true) end, -- formatter
  true -- wrap
  )

function key(n,z)
  if n == 2 and z == 1 then
    l:start()
  elseif n == 3 and z == 1 then
    l:stop()
    l:reset()
    sequence:reset()
  end
end



  























-- MusicUtil = require "musicutil"
-- math.randomseed(os.time())

-- function init()
--   params:add_separator("test script")
--   params:add_group("example group",3)
--   for i = 1,3 do
--     params:add{
--       type = "option",
--       id = "example "..i,
--       name = "parameter "..i,
--       options = {"hi","hello","bye"},
--       default = i
--     }
--   end
--   params:add_number(
--     "note_number", -- id
--     "notes with wrap", -- name
--     0, -- min
--     127, -- max
--     60, -- default
--     function(param) return MusicUtil.note_num_to_name(param:get(), true) end, -- formatter
--     true -- wrap
--     )
--   local groceries = {"green onions","shitake","brown rice","pop tarts","chicken thighs","apples"}
--   params:add_option("grocery list","grocery list",groceries,1)
--   params:add_control("frequency","frequency",controlspec.FREQ)
--   params:add_file("clip sample", "clip sample")
--   params:set_action("clip sample", function(file) load_sample(file) end)
--   params:add_text("named thing", "my name is:", "")
--   params:add_taper("taper_example", "taper", 0.5, 6.2, 3.3, 0, "%")
--   params:add_separator()
--   params:add_trigger("trig", "press K3 here")
--   params:set_action("trig",function() print("boop!") end)
--   params:add_binary("momentary", "press K3 here", "momentary")
--   params:set_action("momentary",function(x) print(x) end)
--   params:add_binary("toggle", "press K3 here", "toggle",1)
--   params:set_action("toggle",function(x)
--     if x == 0 then
--       params:show("secrets")
--     elseif x == 1 then
--       params:hide("secrets")
--     end
--     _menu.rebuild_params()
--   end)
--   params:add_text("secrets","secret!!")
--   params:hide("secrets")
--   params:print()
--   random_grocery()
-- end

-- function load_sample(file)
--   print(file)  
-- end

-- function random_grocery()
--   params:set("grocery list",math.random(params:get_range("grocery list")[1],params:get_range("grocery list")[2]))  
-- end