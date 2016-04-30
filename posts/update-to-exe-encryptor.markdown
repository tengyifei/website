---
title: Passprot exe encryptor 0.2 released
published: 2014-02-07T22:30:18Z
categories: Computer Science,Cryptography
tags: encryptor,Packer,PE executables
---

<p>I have made several improvements to my exe encryptor. <a title="Download" href="https://static.thinkingandcomputing.com/passprot_v0.2.rar" target="_blank">v0.2 download</a></p>
<p>Changes:<br /> - Randomized initialization vector<br /> - Backing up registers in a scratch area in memory and recovering them before invocation of the original entry point to increase compatibility<br /> - Keeping entry point in the same section after encryption i.e. not pointing to the extra PE section housing the encryption stub. This prevents most false positives from anti-virus products.</p>
<p>Future plans:<br /> Some executables come with a relocation table, which records areas within the program that should be updated when the image is loaded on a different address than the preferred one stipulated in file header. After encryption, those records are no longer valid, but the Windows PE loader nonetheless alters the areas accordingly, thus corrupting the encrypted data. Maybe I should implement some custom handler for .reloc sections, or probably just strip the section altogether?</p>
<p>Right now passprot relies on LoadLibraryA and GetProcAddress API to locate the methods required to display windows. If the two functions are absent from the exe's import table, passprot cannot encrypt the executable. Packing the file with UPX is a quick and dirty solution since UPX automatically adds those functions to the import table, but that coupled with encryption would again trigger a new set of anti-virus false positives.</p>

