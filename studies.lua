-- studies

function reload()
  norns.script.load('code/dl/studies.lua')
end

function r()
  norns.script.load(norns.script.state)
end

engine.name = "PolySub"

function redraw()
  screen.clear()
  screen.move(0,40)
  screen.level(15)
  screen.text('Hi')
  screen.update()
end