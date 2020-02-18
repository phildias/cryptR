############################################################
###     Stitch and Decrypt - General Setup Area          ###
### ---------------------------------------------------- ###
### Change the names of the working directory and files. ###
### Also remember to edit the passphrase if needed.      ###
############################################################

# Setting working directory
#setwd("~/")

# List of encrypted unstitched files. Only add the ".enc.001" for each file.
encrypted_files = c("test.mp4.enc.001")


# Passphrase used for decryption
passphrase = "..."


##################################################
###                 Code Area                  ###
### ------------------------------------------ ###
### No need to edit anything beyond this point ###
##################################################

# Setting up decryptor function
my_decryptor = function(cipher_data_filename,passphrase)
{
  # Hashing passphrase
  key = sodium::hash(charToRaw(passphrase))
  
  # Reading encrypted file and nonce as binary data
  cipher_binary_data = readBin(cipher_data_filename, raw(), file.info(cipher_data_filename)$size)
  nonce_filename = paste0(substr(cipher_data_filename,1,nchar(cipher_data_filename)-7),"non",substr(cipher_data_filename,nchar(cipher_data_filename)-3,nchar(cipher_data_filename)))
  nonce_data = readBin(nonce_filename,raw(),file.info(nonce_filename)$size,endian="big")
  
  # Decrypting the ciphertext and writing the file to disk
  decrypted_data = sodium::data_decrypt(cipher_binary_data, key, nonce_data)

  file.remove(c(cipher_data_filename,nonce_filename))
  return(decrypted_data)
}

# Decrypting each file in encrypted_files and appending data to disk
for (this_unstitched_file in encrypted_files)
{
  output_filename = substr(this_unstitched_file,1,nchar(this_unstitched_file)-8)
  
  file_to_search = substr(this_unstitched_file,1,nchar(this_unstitched_file)-3)
  all_pieces_for_file = grep(file_to_search,list.files(),value = TRUE)

  # Make sure the output file doesn't already exist
  if (file.exists(output_filename))
    file.remove(output_filename)
  
  # Decrypt chunk and append decrypted data to output file
  for (this_piece_filename in all_pieces_for_file)
  {
    decrypted_chunk = my_decryptor(this_piece_filename,passphrase)
    output_file = file(description=output_filename,open="a+b")
    writeBin(decrypted_chunk, output_file)
    close(output_file)
  }
  remove(this_unstitched_file,output_filename,file_to_search,all_pieces_for_file,decrypted_chunk,output_file)
}

remove(encrypted_files,passphrase)
