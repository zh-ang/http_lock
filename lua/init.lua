print('Setting up WIFI...')
wifi.setmode(wifi.STATION)
wifi.sta.config('Northern_2.4G', 'scut2thu')
wifi.sta.connect()

gpio.mode(3, gpio.OUTPUT)
gpio.write(3, gpio.HIGH);

lock_last = 0;
lock_count = 0;

tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
	if wifi.sta.getip() == nil then
		print('Waiting for IP ...')
	else
		print('IP is ' .. wifi.sta.getip())
	tmr.stop(1)
	end
end)

-- Serving static files
dofile('httpServer.lua')
httpServer:listen(80)

-- Custom API
-- Get text/html
httpServer:use('/', function(req, res)
    res:redirect('index.html')
end)

httpServer:use('/touch', function(req, res)
    if req.method == "POST" then
        gpio.write(3, gpio.LOW);
        tmr.alarm(2, 300, tmr.ALARM_SINGLE, function()
            gpio.write(3, gpio.HIGH);
        end)
        lock_count = lock_count + 1;
        lock_last = tmr.time();
        res:send("OK");
    else
        res:send("FAIL");
    end
end)

httpServer:use('/restart', function(req, res)
    res:send('Restarting in 3s ...')
    tmr.alarm(2, 3000, tmr.ALARM_SINGLE, function()
        node.restart()
    end)
end)


-- Get json
httpServer:use('/status', function(req, res)
    res:type('application/json')
    res:send('{'..
             '"chip_id": "'..node.chipid()..'",'..
             '"flash_id": "'..node.flashid()..'",'..
             '"count": "'..lock_count..'",'..
             '"last": "'..(tmr.time()-lock_last)..'",'..
             '"uptime": "'..tmr.time()..'"'..
             '}')
end)
