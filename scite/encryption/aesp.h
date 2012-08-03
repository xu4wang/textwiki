#ifndef _AESP_H
#define _AESP_H

void aesp_set_key(uint8* buf, int len);
void aesp_encrypt(uint8* buf, int len, uint8* out, int* plen);
void aesp_decrypt(uint8* buf, int len, uint8* out, int* plen);

#endif /* aesp.h */
