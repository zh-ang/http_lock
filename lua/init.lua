print('Setting up WIFI...')
wifi.setmode(wifi.STATION)
wifi.sta.config('Northern_2.4G', 'scut2thu')
wifi.sta.connect()

if file.exists("telnet.tmp") then
    file.remove("telnet.tmp")
    dofile('telnet.lua')
else
    dofile('lock.lua')
end


