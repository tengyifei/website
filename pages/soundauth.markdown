---
title: SoundAuth: Audio authentication for mobile
published: 2014-03-14T03:26:08Z
categories: 
tags: 
---

<p>I thought a video would be much more illustrative than some long-winded explanation. So here it is:</p>
<div class="video-container"><iframe width="560" height="315" src="http://www.youtube-nocookie.com/embed/WR2UeivUz9w?rel=0" frameborder="0" allowfullscreen="allowfullscreen"></iframe></div>
<h2><strong>Introduction</strong></h2>
<p>Traditional radio frequency identification (RFID) card and fingerprint authentication systems are exposed to security risks including card duplication and data capturing. For most RFID cards, once it is lost, anyone who picks up the card can use it. My project, an audio based authentication system using mobile phone producing sound aims to enhance the security as compared to RFID cards and fingerprints in authentication. We developed applications for various phones to produce a sound signal encoding certain personal information, different analogue filtering and amplifying circuits for sound pre-processing and a Fourier transform algorithm for the microprocessors to obtain different frequency components of sound as information. Through these, the phone is able to communicate with the microprocessor and act as a card for tapping. We ran a series of tests indicating that this filtering system allowed the authentication procedure to be extremely noise-resistant.</p>
<h2><b>Translating information into sound</b></h2>
<p>Information stored in an RFID card encoding a person’s identity can be abstracted into a number of arbitrary length. In this project we chose to assign a 64 bit number to each person, which is definitely more than enough. (2<sup>64</sup>≈10<sup>20</sup>). The mobile phone converts this number into a series of binary numbers between 0000 and 1111, and produces several sinusoidal notes, each with a frequency corresponding to one of the binary numbers. </p>
<p>[table th="0"]</p>
<p>Frequency/Hz, 600, 800, 1000, 1200, 1400, 1600, 1800, ...</p>
<p>Binary, 0000, 0001, 0010, 0011, 0100, 0101, 0110, ...</p>
<p>[/table]</p>
<p>For example, if a person has identity number 1701, in binary numbers, 0110 1010 0101, the corresponding frequency series will be 1800Hz, 2600Hz and 1600Hz. In my project each note lasts for 0.05s, and there are a total of 128 bits of information to transmit. Therefore there will be a total of 128/log_2<sup>16</sup> =32 notes, lasting altogether 1.60s.</p>
<h2><b>Designing software to decode the sound</b></h2>
<p>Many failed attempts were made at decoding the frequency series back into binary data before the author finally settling on Fourier transforms. Other methods failed due to the presence of acoustic noise. Below shows two waveforms, the one above is generated in ideal situation, the other is captured in reality.</p>
[caption id="" align="aligncenter" width="620"]<a href="https://static.thinkingandcomputing.com/soundauth/spectrum_ideal.jpg"><img src="https://static.thinkingandcomputing.com/soundauth/spectrum_ideal_s.jpg" alt="Ideal spectrum" width="620" height="211" /></a> Ideal spectrum[/caption]
[caption id="" align="aligncenter" width="620"]<a href="https://static.thinkingandcomputing.com/soundauth/spectrum_real.jpg"><img src="https://static.thinkingandcomputing.com/soundauth/spectrum_real_s.jpg" alt="Real spectrum" width="620" height="209" /></a> Real spectrum[/caption]
<p>Upon first glance, the first waveform’s prominent frequency can be deduced by counting the number of times the waveform intersects zero. However such method fail to function for the second waveform. In order to determine whether the second waveform contains mainly 2000Hz note, 2200Hz note or 2400Hz note, Fourier transform has to be used, which uses several sine functions to approximate a given function. The transformation assumes that the given function comprises sinusoidal waves of infinitely many frequencies, as illustrated below:</p>
<p><img class="noshadow aligncenter" src="https://static.thinkingandcomputing.com/soundauth/eq1.png" alt="" width="253" height="64" /></p>
<p>Where the function is given by</p>
<p><img class="noshadow aligncenter" src="https://static.thinkingandcomputing.com/soundauth/eq2.png" alt="" width="431" height="41" /></p>
<p>Hence, if the waveform comprises mainly 5/4Hz wave, a<sub>2</sub> will be fairly large. If the waveform comprises mainly 1500Hz wave, a<sub>((1500∗2-1)/4)</sub> will be large. The problem reduces to finding a<sub>n</sub>. By rearranging the above equation, it can be deduced that:</p>
<p><img class="noshadow aligncenter" src="https://static.thinkingandcomputing.com/soundauth/eq3.png" alt="" width="333" height="61" /></p>
<p>The receiver can then perform numeric integration to evaluate the loudness of each frequency component of the waveform. Some analysis results are presented below:</p>
[caption id="" align="aligncenter" width="926"]<a href="https://static.thinkingandcomputing.com/soundauth/waveform.png"><img src="https://static.thinkingandcomputing.com/soundauth/waveform.png" alt="Waveform" width="926" height="322" /></a> Waveform[/caption]
[caption id="" align="aligncenter" width="1508"]<img src="https://static.thinkingandcomputing.com/soundauth/spectrum_view.png" alt="Spectrum" width="1508" height="806" /> Spectrum[/caption]
<p>As we can see a recorded sound wave generally contains frequency components over a large range. However, as we are only interested in loudness of waves of frequency 600Hz, 800Hz, … (those produced by the mobile phone), we can set the coefficient of other frequency components to be zero and the end result is very similar to that in the ideal situation.</p>
[caption id="" align="aligncenter" width="921"]<img src="https://static.thinkingandcomputing.com/soundauth/waveform_filtered.png" alt="Filtered waveform" width="921" height="318" /> Filtered waveform[/caption]
[caption id="" align="aligncenter" width="1500"]<img src="https://static.thinkingandcomputing.com/soundauth/spectrum_view_filtered.png" alt="Filtered spectrum" width="1500" height="515" /> Filtered spectrum[/caption]
<h2>Overview</h2>
<p>The figure below shows an amplitude-against-frequency-time graph when Fourier transform is applied to the entire sound signal. The higher the amplitude is, the brighter the pixel. For example, the left-most bright region indicates that before 0.40s, 500Hz sound is very loud.</p>
[caption id="" align="aligncenter" width="836"]<img src="https://static.thinkingandcomputing.com/soundauth/spectrum_graph.jpg" alt="Spectrum graph" width="836" height="466" /> Spectrum graph[/caption]
<p>The receiver will then take that sequence of frequencies and transform them back into data about the user who sent the signal. It will then search the identity information in its database, if the user is present, the authentication succeeds.</p>
<h2>SoundAuth in action</h2>
<p>User enters a password, the phone produces a sound signal:</p>
[caption id="" align="aligncenter" width="970"]<a href="https://static.thinkingandcomputing.com/soundauth/operation.jpg"><img src="https://static.thinkingandcomputing.com/soundauth/operation.jpg" alt="SoundAuth in action" width="970" height="838" /></a> SoundAuth in action[/caption]
<p>When the receiver found the information about the user in its database, it will flash a green light indicating success:</p>
<p><a href="https://static.thinkingandcomputing.com/soundauth/led.jpg"><img class="aligncenter" src="https://static.thinkingandcomputing.com/soundauth/led.jpg" alt="SoundAuth device signalling success" width="470" height="402" /></a></p>
<h2><b>What if others copy the sound?</b></h2>
<p>In order to counter this problem, we developed an advanced feature of a mutating key scheme: the correct sequence of notes that is accepted by the authentication system changes after each authentication following a complex and irreversible algorithm. This implies that any malicious user who records the sound produced from phones of legitimate users and attempts to pass through the authentication system using the recorded sound will find the sound useless since the accepted sound has already changed after the sound is recorded. In short, the key scheme can be summarized into a flowchart below:</p>
<p>[caption id="" align="aligncenter" width="602"]<a href="https://static.thinkingandcomputing.com/soundauth/flow.png"><img src="https://static.thinkingandcomputing.com/soundauth/flow.png" alt="SoundAuth Flowchart" width="602" height="373" /></a> [/caption]</p>

