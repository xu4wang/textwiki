/* File : aes.i 
D:\work\q200\swigwin-2.0.4\swig -python aes.i
python setup.py build_ext --compiler=mingw32 --inplace 
*/

%module aes
%include cstring.i

%{
#include "aes.h"
#include "aesp.h"
%}

%apply (char *STRING, int LENGTH) { (char *buf, int len) };
%cstring_output_withsize(char* out, int* plen);

void aesp_set_key(char* buf, int len);
void aesp_encrypt(char* buf, int len, char* out, int* plen);
void aesp_decrypt(char* buf, int len, char* out, int* plen);
