gcc -c aes.c -o aes.o
gcc -c aesproxy.c -o aesp.o
gcc  -I"lua\include" -c aes_lua.c -o aes_lua.o
gcc -shared -I"lua\include" aes_lua.o aes.o aesp.o libscite.a  -o aes.dll