require "system"
gpu = system.getDevice("gpu")
gamepad = system.getDevice("gamepad")
display = system.getDevice("display")

zoom = {x=-0.478,y=0, s=0.028}
states = {x=0, y=0, a=false, b=false}

function setStates()
   states.a = gamepad.getButton(0)
   states.b = gamepad.getButton(1)
   states.x = gamepad.getAxis(0)
   states.y = gamepad.getAxis(1)
end

function calculateZoom()
	zoom.x = zoom.x + states.x*zoom.s
	zoom.y = zoom.y + states.y*zoom.s
	if states.a then
		zoom.s = zoom.s * 1.1
	end
	if states.b then
		zoom.s = zoom.s / 1.1
	end
	return states.x ~= 0 or states.y  ~= 0 or states.a or states.b
end

function isIn(x, y)
	zx, zy = 0, 0
	for i = 1, 80 do
		if zx*zx+zy*zy > 4 then
			return false
		end
		zx, zy = zx*zx-zy*zy+x, 2*zx*zy+y
	end
	return true
end

function drawPixel(x, y)
	rx = zoom.x+(x-32)*zoom.s
	ry = zoom.y+(y-32)*zoom.s
	gpu.drawPixel(x, y, isIn(rx, ry) and 1 or 0)
end

function drawPart(f)
	for y = 8*f, 8*f+7 do
		for x = 0,63 do
			drawPixel(x, y)
		end
	end
end

function redraw()
	for f = 0, 7 do
		drawPart(f)
		system.sleep(0)
	end	
end

function moveRedraw()
	gpu.drawImage(-states.x, -states.y, display.getImage():copy())
	if states.y ~= 0 then
		y = (states.y+1)/2*63
		for x = 0, 63 do
			drawPixel(x, y)
		end
	end
	if states.x ~= 0 then
		x = (states.x+1)/2*63
		for y = 0, 63 do
			drawPixel(x, y)
		end
	end
	system.sleep(0)
end

function main()
	redraw()
	while true do
		setStates()
		if calculateZoom() then
			if states.a or states.b then
				redraw()
			else
				moveRedraw()
			end
		else
			system.sleep(0)
		end
	end
end

main()