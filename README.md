# cryptR
R code that allows you to encrypt and decrypt large sensitive files using a passphrase. 

The encryptor code breaks the input into smaller chunks and encrypts them, generating "nonce" files for each chunk. 

The decryptor code unscrambles the encrypted chunks and stitches them back into the original file.

Libraries needed: sodium and stringr
