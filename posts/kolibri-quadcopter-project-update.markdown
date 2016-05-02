---
title: Kolibri Quadcopter project update
published: 2014-09-23T16:33:57Z
categories: Computer Science,Embedded Systems,Quadcopter
tags: soldering
---

It has been quite a while since my last article. I am now studying at University of Illinois at Urbana-Champaign, meeting amazing people everyday. This does not mean however that I will not dedicate my time to this blog. The readers (i.e. you guys) are my best support.

Back to business, my quadcopter project has been progressing steadily. I hope to write another update following [the initial one](http://www.thinkingandcomputing.com/2014/04/07/pcb-kolibri-quadcopter-project/ "PCB for Kolibri Quadcopter project"). The assembly of airframe is almost complete. My quad now boasts a 6000mAh 3S battery, 4-in-1 ESC, and full carbon fiber fuselage and propeller. As you can see, I went to great lengths to make the craft as light as possible to maximize flight time. Without further ado, here it is:

[![Quadcoper](https://static.thinkingandcomputing.com/2014/05/quad.jpg)](https://static.thinkingandcomputing.com/2014/05/quad_l.jpg)

Quadcopter, click for larger picture

The frame looks vaguely similar to the Talon V2 from HobbyKing. In fact it is a hybrid of different airframes. The arms are indeed from a salvaged Talon. The landing gear is from a heli model, while the battery holders and PCB adapters are fashioned from thin carbon fiber boards.

The next picture shows the internals. Flanked by the flight control board and the base is the Quattro ESC. This a very special ESC in that it integrates four controller circuits onto a single PCB, thus saving power and space. The three phase wires from the ESC are conveniently routed through the inside of the hollow arms, yielding a rather slick appearance as opposed to a bunch of exposed wires.

The flight control module is sandwiched between large number of diverse rubber dampers. I intend to keep vibration minimal so as to reduce the noise in accelerometers and gyroscopes. There is a Sharp IR sensor mounted on top to do some rudimentary collision avoidance, which will be improved as I add another three of them using the traces left on the PCB beforehand.

[![Side view of quadcopter](https://static.thinkingandcomputing.com/2014/05/side.jpg)](https://static.thinkingandcomputing.com/2014/05/side_l.jpg)

Side view

I was initially worried that the magnetic field from the ESC would severely interfere with magnetometer readings. But it turned out that this is not an issue. The ESC switches at a frequency so high that the magnetometer, whose measurement time averages at the order of 10 milliseconds, could barely detect the difference.

That's about all. See you next time, when I may upload some actual flight video!
