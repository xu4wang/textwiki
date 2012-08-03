#include <stdlib.h>
#include <stdio.h>

/* Include the Lua API header files. */
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include "aes.h"
#include "aesp.h"

#define LUA_AESLIBNAME	"aes"
#define AES_VERSION 1

#define TRACE 0

#ifdef TRACE
#define TRC(a)		printf("TRACE: "); printf a; printf(" (%s %d)\n",__FILE__,__LINE__);
#define MAKESURE(message,test) do { if (!(test)) printf("ASSERT Failed File(%s) Line(%d): %s\n", __FILE__, __LINE__,message); } while (0)
#else
#define TRC(a)
#define MAKESURE(message,test)
#endif

static int L_set_key (lua_State *L)
{
  int len;
  const char * key = luaL_checklstring(L, 1, &len);
  aesp_set_key(key, len);
  return 0;
}

static int L_encrypt (lua_State *L)
{
  int len;
  const char * buf = luaL_checklstring(L, 1, &len);
  char* out = (char*) lua_newuserdata(L,len);
  aesp_encrypt(buf,  len, out, &len);
  lua_pushlstring(L,out,len);
  return 2;
}

static int L_decrypt (lua_State *L)
{
  int len;
  const char * buf = luaL_checklstring(L, 1, &len);
  char* out = (char*) lua_newuserdata(L,len);
  aesp_decrypt(buf, len, out, &len);
  lua_pushlstring(L,out,len);
  return 2;
}


static const luaL_reg aes_lib[] = {
  {"set_key", L_set_key},  
  {"encrypt", L_encrypt},  
  {"decrypt", L_decrypt},    
  {0, 0}
};


/* This defines a function that opens up iip library. */

LUALIB_API int luaopen_aes (lua_State *L) {
  luaL_register(L, LUA_AESLIBNAME, aes_lib);
  lua_pushnumber(L, AES_VERSION);
  lua_setfield(L, -2, "version");
  return 1;                           /* return methods on the stack */
}
