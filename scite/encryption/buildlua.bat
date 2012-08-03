gcc -c aes.c -o aes.o
gcc -c aesproxy.c -o aesp.o
gcc  -I"D:\\Program\ Files\\Lua\5.1\\include" -c aes_lua.c -o aes_lua.o
gcc -shared  -I"D:\\Program\ Files\\Lua\5.1\\include"  aes_lua.o aes.o aesp.o "D:\Program Files\Lua\5.1\lua51.dll"  -o aes.dll