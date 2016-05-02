---
title: Fixing my broken 3DR Radio and FTDI chip
published: 2014-02-12T22:02:39Z
categories: Computer Science,Embedded Systems,Quadcopter
tags: 3DR radio,FTDI,soldering
---

I bought a 3DR radio unit (a pair of UHF transmitter and receiver operating at 915Mhz) from Hobbyking, plugged it into my computer, and discovered that the ground unit was bricked. The red LED lights flashes periodically, as seen below, and the transmitter unit was not detected by my computer.

<div class="video-container"><iframe width="560" height="315" src="http://www.youtube-nocookie.com/embed/jfLEBMeVQBc?rel=0" frameborder="0" allowfullscreen="allowfullscreen"></iframe></div>

Unwilling to acquiesce the loss of 30+ dollars, I decided to see if I could fix it. I searched for the problem of undetectable 3DR radio online, but most answers recommended upgrading/downgrading drivers. I followed those instructions closely, but my actions were in vain: the chip was still not detected. I tried plugging it into other computers, same result. The two strong LEDs flashing in unison looked like two penetrating eyes mocking my efforts. After hours of fiddling, it was clear that _the cause was a hardware problem, not a software one. _

I scrutinized the PCB board and found an abnormal capacitor. One side of the tantalum capacitor circled below was very dark. Normally the dark stripe was used to indicate the positive pin, but for this stripe the edge is blurred by a brownish tint one would easily relate to heat/fire damage. See image for the contrast between that particular capacitor on my 3DR board and a standard tantalum capacitor.

![Difference between a normal capacitor and the one on my 3DR radio](https://static.thinkingandcomputing.com/2014/02/ftdi_tan_vs.jpg)
<tnc-caption>Comparison between a normal capacitor and the one on my 3DR radio</tnc-caption>

I employed a quick test of capacitors. Using a digital multimeter, I switched to Ω (resistance) mode and connected the probes to the two legs of the capacitor. Should the capacitor be functioning, the resistance value would have steadily increased as the critical voltage for further charges to be stored increases proportionately with the amount of charges inside. This time, the resistance value fluctuated wildly, before stabilizing at a low 12Ω. _The capacitor is definitely broken_, I thought, _giving rise to a near short circuit._ The text on the faulty capacitor says "106A", meaning that it has capacitance of 10µF and a rated voltage of merely 4V. [This](http://www.sparkfun.com/news/1271 "Why You Should De-Rate Capacitors") article in Sparkfun suggests that one should de-rate tantalum capacitor ratings by at least 60%-70%. Given the 3.3V logic level of the 3DR radio, it is very likely that the capacitor have failed under pressure.

After identifying the source of the problem, I went to an local electronics store and bought a strip of 10µF capacitors. Instead of purchasing again the lowly-rated A-class capacitors, I went for 106C capacitors, which generally has 10V-16V rated voltage. I replaced the capacitor and plugged the radio in my computer. The chip was correctly identified by the operating system. Unfortunately, before I could perform any testing, it failed again. I had to search for another solution from scratch.

![3DR shematic](https://static.thinkingandcomputing.com/2014/02/schem.png)

A section of the schematic

I obtained the [schematic](http://cdn.basic-antivirus.com/media/3drradiousb.pdf) for 3DR radio transmitter unit online. Looking at the schematic, I was able to get a full view of the problem. The faulting capacitor, namely C3 in the schematic, was actually a bypass capacitor designed to stabilize the voltage output of the voltage regulator MIC5219\. When the capacitor shorted, the regulator was unable to sustain such high current, and was forced to output at a lower voltage than the stipulated 3.3V instead. This caused the radio unit to be under-powered, and possibly unable to respond to queries from the OS. In my case, after rectifying the capacitor issue, the device was still not functioning. The only explanation would be that there was _another_ source of hardware error.

But where? I had to choose between the radio chipset and the FTDI chip, which acts as a pipe between serial messages and USB. Luckily, I found a [post](http://www.sparkfun.com/products/retired/8772#comment-4eaad844757b7fd35100317f) by a user named Redyns that described the same situation, and which stated that the FTDI chip was the culprit. Hence I decided to replace the onboard FTDI chip with another one and see if this solves the problem.

The chip was particularly hard to desolder. It was apparently bonded with a solder which my soldering iron cannot easily melt. As a result, I broke off a few golden pads while plucking the chip. This meant that I would not be able to solder on the new FTDI chip. So I wired radio chipset directly with a FTDI breakout board.

![Repaired transmitter](https://static.thinkingandcomputing.com/2014/02/ftdi_converter.jpg)

Not an elegant solution? Well...I could live with that.

Some hot glue was added to reinforce the weak soldering joints. On the bottom you can see the removed FTDI chip.

I plugged the radio into my computer and finally, it worked like a charm.
