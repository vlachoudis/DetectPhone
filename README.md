DetectPhone
===========
                                                                        o o
                                                                      ____oo_
                                detect_phone                         /||    |\
                             vvlachoudis@gmail.ch                     ||    |
                                    2012                              `.___.'

About
=====
detect_phone is a tiny little bash script that detects the presence of a
person by pinging his bluetooth phone. If the person is in close range (<10m)
then it kills the screen saver if any.


The problem
===========
In my work I have set my linux desktop to start the screen saver
locked with password after 1 min of inactivity. Many times per day I have to
leave my office, which immediately locks the computer. When I return I have to
type in my password... which becomes somehow annoying :)


The idea
========
I was thinking if there was a way to avoid all this password typing, just by
detecting my presence in the office. Moreover, not to launch at all the screen
saver if I am present and not working in front of the computer.


Solution
========
The solution was simple, a bash shell script, with an infinite loop, checking
periodically if the screen saver is running (every 5s). If yes then ping my
telephone's bluetooth (which has a short range ~5-10m), and if it replies then
kill the screen saver.

I am using KDE with the kscreenlocker as screen saver. The program starts
automatically in KDE by placing the program in the ~/.kde/Autostart.
However it can easily be modified to work for any desktop environment
(gnome, xfce, lxde...)


Future
======
More correct would be to incorporate this functionality inside the screen savers
and not as a separate shell script...


Customize
=========
For the moment there is not any initialization apart editing directly the
script file. You have to modify the 3 lines

1. BTHW="xx:xx:xx:xx:xx"
   with the appropriate bluetooth hardware address you want to detect. To
   Find out your hardware address either you have to look on your phone's
   system settings, or by making it visible and scan it with the command
   $ hciconfig scan

2. LOCKPRG="xscreensaver"
    This script is limited to xscreensaver (it use some xscreensaver magic)
    You can check out original source: https://github.com/vlachoudis/DetectPhone
    But original source wont correctly work with xscreensaver

3. MIN_SIGNAL_STRENGTH=-11
   Replace with bluetooth strength level (less is worse) on which we try to do "autounlocking"
   To check those levels set DEBUG=true & run script & watch for level index

4. SLEEP=5
   Set the sleep time (seconds) for checking.

5. TIMEOUT_AFTER_LOCK=30
   Delay in seconds after lock event

6. DEBUG=false
   Set true to get some additional info for adjusting setting to your case 

Install
=======
Autostart the program when login in the desktop enviornment
- KDE:   Copy the programin the ~/.kde/Autostart/ directory
- GNOME:
- XFCE:
- LXDE:

Just start this script in background (setsid ./detect_phone.sh)

