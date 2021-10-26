s = require('lib/sequins_dl')
vox = require('lib/vox')
seq = require('lib/seq')
skip = require('lib/skip')


a = s{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
b = s{2,5,7}
c = skip:new{skip = 2, mod = 0, action = a}