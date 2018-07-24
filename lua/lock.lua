
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
httpServer:use('/', function(req, res)
    res:redirect('index.html')
    return false
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

httpServer:use('/telnet', function(req, res)
    if req.query['pwd'] == "mydoorguard" then
        file.open("telnet.tmp", "a+")
        file.write("do")
        file.close()
        res:send('Restarting in 3s ...')
        tmr.alarm(2, 2000, tmr.ALARM_SINGLE, function()
            node.restart()
        end)
        return
    end
    res:send('<!DOCTYPE html>'..
             '<html lang="en">'..
             '<head><meta charset="UTF-8"><title>telnet</title></head>'..
             '<body>'..
             '<form action="" method="get">'..
             '<input type="password" name="pwd" placeholder="TELNET PASSWORD" /><input type="submit" value="SUBMIT"/>'..
             '</form>'..
             '</body>'..
             '</html>')
end)

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