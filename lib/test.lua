vox = require('vox')
seq = require('seqwrap')
sequins = require('sequins'); s = sequins

lead = vox:new()
lead.s.octave = s{-1,0,1}
lead.seq = seq:new{
  action = function(s) return lead:play{degree = s, octave = lead.s.octave} end
}