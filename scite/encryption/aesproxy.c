#include "aes.h"
#include "aesp.h"

aes_context ctx;


//len should be 128/8=16,192/8=? or 256/8=32
void aesp_set_key(uint8* key, int len){
		aes_set_key( &ctx, key, len*8 );
}

void aesp_encrypt(uint8* buf, int len, uint8* out, int* plen){
		//enc 128bits  == 16bytes each time
		int i;
		*plen =0;
		for (i=0;  i<=len-16; i=i+16) {
				aes_encrypt( &ctx, buf+i, out+i );
				*plen = *plen + 16;
		}		
}

void aesp_decrypt(uint8* buf, int len, uint8* out,int* plen){
		//enc 128bits  == 16bytes each time
		int i;
		*plen =0;
		for (i=0;  i<=len-16; i=i+16) {
				aes_decrypt( &ctx, buf+i, out+i );
				*plen = *plen + 16;
		}		
}
