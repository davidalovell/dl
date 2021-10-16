-- vox extensions
-- requires sequins

Vox = {}

function Vox:new_sequins(...)
  self.sequins = self.sequins == nil and {} or self.sequins
  local id = #self.sequins + 1
  self.sequins[id] = sequins(data)
end

function vox:next_sequins(id)
  local call_sequins = self.sequins[id]()
  return type(call_sequins) == 'table' and self.sequins[id] or call_sequins
end

return Vox