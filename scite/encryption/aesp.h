#ifndef _AESP_H
#define _AESP_H

void aesp_set_key(char* buf, int len);
void aesp_encrypt(char* buf, int len, char* out, int* plen);
void aesp_decrypt(char* buf, int len, char* out, int* plen);

#endif /* aesp.h */
