require"aes"
key="12345678901234567890123456789012"
buf="1234567890qwertyuiopasdfghjkl;zx1234567890qwertyuiopasdfghjkl;zx1234567890qwertyuiopasdfghjkl;zx111234567890qwertyuiopasdfghjkl;zx1234567890qwertyuiopasdfghjkl;zx1234567890qwertyuiopasdfghjkl;zx11"
aes.set_key(key)
out=aes.encrypt(buf)
print(out)
plain=aes.decrypt(out)
print(plain)