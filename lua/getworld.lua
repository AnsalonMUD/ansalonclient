
-- table of worlds we couldn't open
cannot_open_world = cannot_open_world or {}  -- set flag here if can't open world
-- getworld.lua
--

--[[

See forum thread:  http://www.gammon.com.au/forum/?id=7991

This simplifies sending triggered lines to another, dummy, world.

get_a_world (name) - returns a world pointer to the named world, opening it if necessary

send_to_world (name, styles) - sends the style runs to the named world, calling get_a_world
                               to get it
                               
--]]


-- make the named world, if necessary - adds "extra" lines to the world file (eg. plugins)
function make_world (name, extra, folder)

  local filename = GetInfo (57)
  if folder then
   filename = filename .. folder .. "\\"
  end -- if folder wanted
  
  filename = filename .. name .. ".mcl"
  local f = io.open (filename, "r")  
  
  if f then
    f:close ()
    return
  end -- world file exists
  
  f = io.output (filename)  -- create world file
  
  assert (f:write ([[
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE muclient>
<!-- MUSHclient world file -->
<!-- Written by Nick Gammon -->
<!-- Home Page: http://www.mushclient.com/ -->
<!-- Generated by getworld.lua plugin  -->
<muclient>
<world defaults="y"
name="]] .. name  .. [["
site="0.0.0.0"
port="4000"
/>
  ]] .. extra .. [[
  
</muclient>
  ]]))
  
  f:close ()  -- close world file now
  
  -- and open the file ;P
  Open (filename)
   
end -- make_world

-- open a world by name, return world object or nil if cannot
function get_a_world (name, folder)

  -- try to find world
  local w = GetWorld (name)  -- get world

  -- if not found, try to open it in worlds directory
  
  if not cannot_open_world [name] and not w then
    local filename = GetInfo (57)
    if folder then
     filename = filename .. folder .. "\\"
    end -- if folder wanted
    
    filename = filename .. name .. ".mcl"
    Open (filename)  -- get MUSHclient to open it
    Activate ()   -- make our original world active again
    w = GetWorld (name)  -- try again to get the world object
    if w then
      w:DeleteOutput ()  -- delete "welcome to MUSHclient" message
    else
      ColourNote ("white", "red", "Can't open world file: " .. filename)
      cannot_open_world [name] = true -- don't repeatedly show failure message
    end -- can't find world 
  end -- can't find world first time around

  return w

end -- get_a_world

-- send the styles (eg. from a trigger) to the named world, opening it if necessary
function send_to_world (name, styles)

  local w = get_a_world (name)
  
  if w then  -- if present
    for _, v in ipairs (styles) do
      w:ColourTell (RGBColourToName (v.textcolour), 
                    RGBColourToName (v.backcolour), 
                    v.text)  
    end -- for each style run
    w:Note ("")  -- wrap up line

  end -- world found

  return w  -- so they can check if we succeeded
  
end -- send_to_world 
