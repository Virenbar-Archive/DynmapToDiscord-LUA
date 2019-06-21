# [New Version on Node.JS](https://github.com/Virenbar/DynmapToDiscordJS)

# DynmapToDiscord
## Installation (CentOS)
1. Install lua
```bash
yum install gcc gcc-c++ kernel-devel
yum install readline-dev
curl -R -O http://www.lua.org/ftp/lua-5.3.4.tar.gz
tar zxf lua-5.3.4.tar.gz
cd lua-5.3.4
make linux test
sudo make install
```
2. Install luarocks and rocks
```bash
wget http://luarocks.org/releases/luarocks-2.0.6.tar.gz     
tar zxvf luarocks-2.0.6.tar.gz                                              
cd luarocks-2.0.6                                                                
./configure                                                                           
make                                                                                   
sudo make install
luarocks --local install luasocket
yum install openssl-devel
luarocks --local install luasec
```
3. Run Webhook.lua
```bash
lua Webhook.lua
```
