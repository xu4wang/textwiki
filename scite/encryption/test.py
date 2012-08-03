import aes
key="12345678901234567890123456789012"
buf="1234567890qwertyuiopasdfghjkl;zx1234567890qwertyuiopasdfghjkl;zx1234567890qwertyuiopasdfghjkl;zx111234567890qwertyuiopasdfghjkl;zx1234567890qwertyuiopasdfghjkl;zx1234567890qwertyuiopasdfghjkl;zx11"
aes.aesp_set_key(key)
out=aes.aesp_encrypt(buf,1024)
#print(out)
plain=aes.aesp_decrypt(out,1024)
print(plain)