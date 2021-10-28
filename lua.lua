s = require('lib/sequins_dl')
vox = require('lib/vox2')

a = vox:new{
  s = {
    degree = s{1,2,3,4,5}:every(2,1)
  }
}