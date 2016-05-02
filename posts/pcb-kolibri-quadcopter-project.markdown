---
title: PCB for Kolibri Quadcopter project
published: 2014-04-07T13:23:53Z
categories: Computer Science,Embedded Systems,Quadcopter
tags: soldering
---

I ordered custom printed circuit boards from Oshpark in February. I scrutinized every component for possible source of error, but ignored the most important part: postal service. In my haste, I left the option for using which postal service to deliver the boards in its default state, USPS. Being infamous for its questionable quality of service, USPS took months to get the item across the pacific (did they use a ocean mail liner? I thought I signed up for air mail...)

Fortunately the PCB boards did arrive in the end. I could now move on to the next stage in my quadcopter development.

[![Custom fabricated PCB board](https://static.thinkingandcomputing.com/2014/04/pcb.jpg)](https://static.thinkingandcomputing.com/2014/04/pcb_l.jpg)
<tnc-caption>Worthy of the delay</tnc-caption>

The quality and finish of the boards is very good. The electroless nickel immersion gold (ENIG) plating process offered excellent oxidation protection, which kept the pads shiny even months after they are produced. Minimal flux was used to solder even the most complex joints.

After a day of intensive soldering: 

[![(Nearly) fully assembled quadcopter control board](https://static.thinkingandcomputing.com/2014/04/cboard.jpg)](https://static.thinkingandcomputing.com/2014/04/cboard_l.jpg)
<tnc-caption>(Nearly) fully assembled quadcopter control board</tnc-caption>

The quadcopter features GPS-IMU positioning using Kalman filters and PID controller with knowledge of the physical model. This allows it to automatically navigate over a stipulated path with precision down to the centimeter. Four infrared sensors gives it the ability to detect obstacles, and when connected to a Raspberry Pi computer, remember their positions and generate a route to avoid them.

The design is a compromise between performance and space. While the Raspberry Pi is capable of all the heavy lifting, it lacks real-time support and low-level I/O, thus rendering it less appropriate to maneuver the aircraft, which requires guaranteed response time.  Therefore, a Cortex-M3 micro-controller was added to fill the role. However, both of these processors are of 3.3V logic, hence interfacing them with other 5V peripherals turned out to be problematic. So I added an Arduino board to act as the middle man, receiving commands from the Cortex-M3 micro-controller and altering voltage levels of corresponding pins.
