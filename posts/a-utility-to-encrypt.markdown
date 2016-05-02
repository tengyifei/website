---
title: A utility to encrypt executable files
published: 2014-02-04T22:43:11Z
categories: Computer Science,Cryptography
tags: encryptor,Packer,PE executables
---

I've made a simple utility to encrypt Win32 PE executables. While many commercial programs claiming that they provide some form of encryption merely extract the decrypted file into a temporary location on the disk, this program does all operations in memory, which makes it harder for malicious users to recover the original file. [Download Link](https://static.thinkingandcomputing.com/passprot.rar "Download")

After an .exe file is encrypted and executed, a window will be shown instead. Execution can only continue when the user has entered the correct password.

[![ps](https://static.thinkingandcomputing.com/2014/02/ps1.png)](https://static.thinkingandcomputing.com/2014/02/ps1.png)

Usage: passport file_to_be_encrypted

Features:
- AES-256 encryption
- Using salted hash to verify password, hence the password is not stored in the encrypted file
- Can encrypt files that are already packed

Limitations:
- Target executable must import _GetProcAddress_ and _LoadLibraryA_ functions.
- Currently only encrypts the first PE section

--- Update ---
An updated version is available [here](http://thinkingandcomputing.com/2014/02/08/update-to-exe-encryptor/)
