--- sequins
-- nestable tables with sequencing behaviours & control flow
-- TODO i think ASL can be defined in terms of a sequins...

local S = {}

function S.new(t)
    -- wrap a table in a sequins with defaults
    local s = { data   = t
              , length = #t -- memoize table length for speed
              , set_ix = 1 -- force first stage to start at elem 1
              , ix     = 1 -- current val
              , n      = 1 -- can be a sequin
              }
    s.action = {up = s}
    setmetatable(s, S)
    return s
end

local function wrap_index(s, ix) return ((ix - 1) % s.length) + 1 end

-- can this be generalized to cover every/count/times etc
function S.setdata(self, t)
    self.data   = t
    self.length = #t
    self.ix = wrap_index(self, self.ix)
end

function S.is_sequins(t) return getmetatable(t) == S end

local function turtle(t, fn)
    -- apply fn to all nested sequins. default to 'next'
    if S.is_sequins(t) then
        if fn then
            return fn(t)
        else return S.next(t) end
    end
    return t
end


------------------------------
--- control flow execution

function S.next(self)
    local act = self.action
    local ix = self.ix -- *** @DL *** 
    if act.action then
        return S.do_ctrl(act, ix) -- *** @DL *** 
    else return S.do_step(act) end
end

function S.select(self, ix)
    rawset(self, 'set_ix', ix)
    return self
end

function S.do_step(act)
    local s = act.up
    -- if .set_ix is set, it will be used, rather than incrementing by s.n
    local newix = wrap_index(s, s.set_ix or s.ix + turtle(s.n))
    local retval, exec = turtle(s.data[newix])


    if act.hold == 1 and retval == nil then -- *** @DL *** 
        retval = ix
    end


    if exec ~= 'again' then s.ix = newix; s.set_ix = nil end
    -- FIXME add protection for list of dead sequins. for now we just recur, hoping for a live sequin in nest
    if exec == 'skip' then return S.next(s) end
    return retval, exec
end


------------------------------
--- control flow manipulation

function S.do_ctrl(act, ix) -- *** @DL *** modified
    act.ix = act.ix + 1

    local cond, skip = act.cond(act)

    if not act.cond or cond then
        retval, exec = S.next(act)
        if skip then retval = nil end
        if exec then act.ix = act.ix - 1 end
    else
        retval, exec = nil, 'skip'
    end

    if act.hold == 1 and retval == nil then
        retval = ix
    end

    if act.rcond then
        if act.rcond(act) then
            if exec == 'skip' then
                retval, exec = S.next(act)
            else
                exec = 'again'
            end
        end
    end

    return retval, exec
end

function S.reset(self)
    self.ix = self.length
    for _,v in ipairs(self.data) do turtle(v, S.reset) end
    local a = self.action
    while a.ix do
        a.ix = 0
        turtle(a.n, S.reset)
        a = a.action
    end
end

--- behaviour modifiers
function S.step(self, s) self.n = s; return self end


function S.extend(self, t)
    self.action = { up     = self -- containing sequins
                  , action = self.action -- wrap nested actions
                  , ix     = 0
                  }
    for k,v in pairs(t) do self.action[k] = v end
    return self
end

function S._every(self)
    self.mod = self.mod == nil and 0 or self.mod
    return (self.ix % turtle(self.n)) == self.mod -- *** @DL *** changed so that returns val the first time it is called rather than the last time
end

function S._times(self)
    return self.ix <= turtle(self.n)
end

function S._count(self)
    if self.ix < turtle(self.n) then return true
    else self.ix = 0 end -- reset
end

function S._skip(self) -- *** @DL *** 
    self.mod = self.mod == nil and 1 or self.mod
    local skip = S._every(self) == false and true or false
    return true, skip
end

function S.cond(self, p, hold) return S.extend(self, {cond = p, hold = hold}) end -- *** @DL *** added hold argument: if hold == 1 then return index else return nil
function S.condr(self, p, hold) return S.extend(self, {cond = p, rcond = p, hold = hold}) end
function S.every(self, n, mod, hold) return S.extend(self, {cond = S._every, n = n, mod = mod, hold = hold}) end -- *** @DL *** mod = 0 is default (ie. last time it is called), mod = 1 is first time
function S.times(self, n, hold) return S.extend(self, {cond = S._times, n = n, hold = hold}) end
function S.count(self, n, hold) return S.extend(self, {rcond = S._count, n = n, hold = hold}) end
function S.skip(self, n, mod, hold) return S.extend(self, {cond = S._skip, n = n, mod = mod, hold = hold}) end -- *** @DL *** default mod = 1

--- helpers in terms of core
function S.all(self) return self:count(self.length) end
function S.once(self) return self:times(1) end


--- metamethods

S.__call = function(self, ...)
    return (self == S) and S.new(...) or S.next(self)
end

S.metaix = { settable = S.setdata
           , step     = S.step
           , cond     = S.cond
           , condr    = S.condr
           , every    = S.every
           , times    = S.times
           , count    = S.count
           , skip     = S.skip -- *** @DL ***
           , all      = S.all
           , once     = S.once
           , reset    = S.reset
           , select   = S.select
           }
S.__index = function(self, ix)
    -- runtime calls to step() and select() should return values, not functions
    if type(ix) == 'number' then return self.data[ix]
    else
        return S.metaix[ix]
    end
end

S.__newindex = function(self, ix, v)
    if type(ix) == 'number' then self.data[ix] = v
    elseif ix == 'n' then rawset(self,ix,v)
    end
end


setmetatable(S, S)

return S