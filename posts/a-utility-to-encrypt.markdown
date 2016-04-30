---
title: A utility to encrypt executable files
published: 2014-02-04T22:43:11Z
categories: Computer Science,Cryptography
tags: encryptor,Packer,PE executables
---

<p>I've made a simple utility to encrypt Win32 PE executables. While many commercial programs claiming that they provide some form of encryption merely extract the decrypted file into a temporary location on the disk, this program does all operations in memory, which makes it harder for malicious users to recover the original file. <a title="Download" href="https://static.thinkingandcomputing.com/passprot.rar" target="_blank">Download Link</a></p>
<p>After an .exe file is encrypted and executed, a window will be shown instead. Execution can only continue when the user has entered the correct password.</p>
<p><a href="https://static.thinkingandcomputing.com/2014/02/ps1.png"><img class="alignnone size-full wp-image-78" alt="ps" src="https://static.thinkingandcomputing.com/2014/02/ps1.png" width="319" height="154" /></a></p>
<p> <br />Usage: passport file_to_be_encrypted</p>
<p>Features:<br /> - AES-256 encryption<br /> - Using salted hash to verify password, hence the password is not stored in the encrypted file<br /> - Can encrypt files that are already packed</p>
<p>Limitations:<br /> - Target executable must import <em>GetProcAddress</em> and <em>LoadLibraryA </em>functions.<br /> - Currently only encrypts the first PE section</p>
<p><em>--- Update ---<br /> </em>An updated version is available <a href="http://thinkingandcomputing.com/2014/02/08/update-to-exe-encryptor/">here</a></p>


