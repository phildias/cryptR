############################################################
###       Encrypt and Break - General Setup Area         ###
### ---------------------------------------------------- ###
### Change the names of the working directory and files. ###
### Also remember to edit the passphrase if needed.      ###
############################################################

# Setting working directory
#setwd("~/")
setwd("E:/Encr/")

# List of files to encrypt
in_files = c("test.mp4")

# List of master file names for encrypted chunks. Should end in ".enc"
chunk_files = c("test.mp4.enc")

# Passphrase used for encryption
passphrase = "..."

# Chunk size used for file split. !!!!WARNING!!!! CANNOT BE LARGER THAN 2GB!!!!
chunk_size = 1024 * 1024 * 200 

##################################################
###                  Code Area                 ###
### ------------------------------------------ ###
### No need to edit anything beyond this point ###
##################################################

# Setting up encryptor function
my_encryptor = function(unencrypted_data,nonce_filename,encrypted_data_filename,passphrase)
{
  # Create key and nonce
  key = sodium::hash(charToRaw(passphrase))
  nonce = sodium::random(24)
  writeBin(nonce, nonce_filename,endian="big")
  
  # Encrypt and return ciphertext file
  nonce_data = readBin(nonce_filename,raw(),file.info(nonce_filename)$size,endian="big")
  encrypted_data = sodium::data_encrypt(unencrypted_data, key, nonce_data)
  attr(encrypted_data,which="nonce") = NULL # Removing the nonce attr. to save binary
  writeBin(encrypted_data, encrypted_data_filename,endian="big")
}

# Splitting each file into chunks and then encrypting all chunks 
for (i in 1:length(in_files))
{
  input_filename = in_files[i]
  chunk_master_filename = chunk_files[i]
  nonce_master_filename = paste0(substr(chunk_master_filename,1,nchar(chunk_master_filename)-3),"non")
  unencrypted_data = readBin(input_filename, raw(), file.info(input_filename)$size)
  number_of_chunks = ceiling(length(unencrypted_data)/chunk_size)

  for (j in 1:number_of_chunks)
  {
    start_byte = ((j - 1) * chunk_size) + 1
    end_byte = start_byte + chunk_size - 1
    if (j == number_of_chunks)
      end_byte = length(unencrypted_data)
    this_chunk_unencrypted = unencrypted_data[start_byte:end_byte]
    this_chunk_filename = paste0(chunk_master_filename,".",stringr::str_pad(j, 3, pad = "0"))
    this_nonce_filename = paste0(nonce_master_filename,".",stringr::str_pad(j, 3, pad = "0"))
    my_encryptor(this_chunk_unencrypted,this_nonce_filename,this_chunk_filename,passphrase)
    remove(this_chunk_unencrypted)
  }
  remove(unencrypted_data)
  file.remove(input_filename)
}

