-- seq is a wrapper for sequins

local Seq = {}
local sequins = include('lib/sequins_dl'); s = sequins

function Seq:new(args)
  local o = setmetatable( {}, {__index = Seq} )
  local args = args == nil and {} or args

  o.seq = args.seq == nil and {1,2,3,4,5,6,7} or args.seq; o.s = s(o.seq) -- passes a table to sequins
  o.step = args.step == nil and 1 or args.step; o.s:step(o.step)

  o.div = args.div == nil and 1 or args.div
  o.skip = args.skip == nil and 1 or args.skip
  o.beat = args.beat == nil and 1 or args.beat
  o.prob = args.prob == nil and 1 or args.prob
  o.hold = args.hold == nil and false or args.hold
  o.abs = args.abs == nil and false or args.abs -- absolute division, default is relative division

  o.offset = args.offset == nil and 0 or args.offset
  o.action = args.action

  o.count = - o.offset
  o.div_count = - o.offset
  o.skip_count = - o.offset
  o.val = 0
  o.last = o.val
  o.held = false

  return o
end

function Seq:play(args)
  local args = args == nil and {} or args
  
  local updated_args = {}

  for k, v in pairs(args) do
    if s.is_sequins(v) or type(v) == 'function' then
      if self.held == false then
        updated_args[k] = v()
      else
        updated_args[k] = v[v.ix]
      end
    else
      updated_args[k] = v
    end

    if updated_args[k] == nil then
      return
    end
  end
  
  args = updated_args

  args.seq = args.seq == nil and self.seq or args.seq; self.s:settable(args.seq)
  args.step = args.step == nil and self.step or args.step; self.s:step(args.step)
  args.div = self.div * (args.div == nil and 1 or args.div)
  args.skip = args.skip == nil and self.skip or args.skip
  args.beat = args.beat == nil and self.beat or args.beat
  args.prob = args.prob == nil and self.prob or args.prob
  args.hold = args.hold == nil and self.hold or args.hold
  args.abs = args.abs == nil and self.abs or args.abs

  self.count = self.count + 1

  if self.count < 1 then
    return
  end
  
  self.div_count = self.div_count % args.div + 1
  self.skip_count = self.skip_count % (args.skip * args.div) + 1

  local div_cond
  local skip_cond 

  if args.abs then
    div_cond = self.count % args.div == args.beat % args.div
    skip_cond = self.count % (args.skip * args.div) == args.beat % (args.skip * args.div)
  else
    div_cond = self.div_count == args.beat
    skip_cond = self.skip_count == args.beat 
  end
  
  if div_cond then
    self.held = false
    self.val = self.s()
  else
    self.held = true
    self.val = self.s[self.s.ix]
  end

  if skip_cond and args.prob >= math.random() then
    self.held = false
    self.last = self.val
  else
    self.held = true
    self.val = self.last
  end

  if not args.hold and self.held then
    return
  end
  
  -- if self.action then
  --   return self.action(self.val)
  -- else
  --   return self.val
  -- end
  
  if self.action then
    self.action(self.val)
  end
  
  return self.val
end

function Seq:reset()
  self.count = - self.offset
  self.div_count = - self.offset
  self.skip_count = - self.offset
  self.val = 0
  self.last = self.val
  self.s:reset()
end

return Seq