---
title: Passprot exe encryptor 0.2 released
published: 2014-02-07T22:30:18Z
categories: Computer Science,Cryptography
tags: encryptor,Packer,PE executables
---

I have made several improvements to my exe encryptor. [v0.2 download](https://static.thinkingandcomputing.com/passprot_v0.2.rar "Download")

Changes:

- Randomized initialization vector
- Backing up registers in a scratch area in memory and recovering them before invocation of the original entry point to increase compatibility
- Keeping entry point in the same section after encryption i.e. not pointing to the extra PE section housing the encryption stub. This prevents most false positives from anti-virus products.

Future plans:
Some executables come with a relocation table, which records areas within the program that should be updated when the image is loaded on a different address than the preferred one stipulated in file header. After encryption, those records are no longer valid, but the Windows PE loader nonetheless alters the areas accordingly, thus corrupting the encrypted data. Maybe I should implement some custom handler for .reloc sections, or probably just strip the section altogether?

Right now passprot relies on `LoadLibraryA` and `GetProcAddress` API to locate the methods required to display windows. If the two functions are absent from the exe's import table, passprot cannot encrypt the executable. Packing the file with UPX is a quick and dirty solution since UPX automatically adds those functions to the import table, but that coupled with encryption would again trigger a new set of anti-virus false positives.
