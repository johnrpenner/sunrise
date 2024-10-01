# sunrise 2.5
sunrise is Swift commandline that computes sunrise sunset times given latitude longitude and date. It also computes Synodic Lunar Phase. 

The Sunrise Sunset code is written entirely by me based off a FutureBASIC implementation I wrote in 2001. It was literally implemented from a manual method decscribed in the Nautical Almanac for Computers (1990), published by the United States Naval Observatory in Washington. 

The Synodic Moonphase is based on C code in Moontool by John Walker in 1987. Ive replaced his astronimical constants with newer, higher accuracy values obtained in the intervening decades. 

The essential motivation of this project is to connect the digital world to the rhythms of the natural world. My itch to scratch was dimming my monitor automatically when it got darker at sunset. This was my original intention in seeking the US Naval Methods book and writing the BASIC code. I never completed the project (2001); however Apple delivered NightShift based on this concept (2016). The usefulness of being able to turn things on and off based on Sunrise is more broadly useful however — so i decided to write a more modern implementation. 

Ive borrowed bits and snippets from available sources (and tried to give attribution to each in the comments) to bring together everything that is needed to provide basic astronimical calculations into the Swift language - when I was unable to find Swift implementations of many of these basic computations. 

The original code (v2.0) failed on the Daylight (Not) Savings Change — so v2.1 added an API call to macOS CoreLocation which adds the requirement of this Library to account for Daylight (Not) Savings based on Time Zone and Location (not easy!). 

I have used it now for several years, and it correlates accurately (within 30seconds) with every local weather Sunrise Sunset. Ive checked this now for over two years (in Toronto only), without a fail. I need testers in other locations to verify accurate results, and submit bug fixes if any are necessary. 


sunrise -help
SUNRISE: Calculates Sunrise Sunset + Moonphase  ©2024 johnrolandpenner

USAGE: 
sunrise [mm dd yyyy] [latitude longitude timezone verbose]

e.g. sunrise 12 18 2021 43.6532 -79.3832 -5 1
e.g. sunrise 12 18 2021

sunrise --help  Displays this Help

sunrise without arguments will use today's date, and look for 
a .sunrc file in $HOME to supply: Latitude Longitude Timezone Verbose City

echo "43.6532 -79.3832 -5 1 Toronto" > .sunrc

sunrise with only [mm dd yyyy] uses location from .sunrc

The command is configured by creating a .sunrc file in your ~ home directory. 

cat .sunrc
43.6532 -79.3832 -5 0 Toronto

five parameters separated by spaces: Latitude, Longitude, Time Zone (EST = -5), Verbosity Level, Location Label


USE CASES: 

you can use it to turn things on in the morning, and turn them off again at night. 
i currently put the sunrise command in my .bashrc so it runs every time i open a terminal: 

Last login: Mon Sep 30 22:51:11 on ttys002
🌅 7:14  🌃 18:58  🌘 95% 
Death-Star:~ john$

Version 2.5 Adds Astronimical computation of the Moonphase() which currently seems to work. 

sunrise 9 30 2024 43.6532 -79.3832 -5 4 0  //synodic moonPhase
sunrise 9 30 2024 43.6532 -79.3832 -5 4 1  //astronomical moonPhase

Once testing is complete, will build into a macOS BREW command: brew sunrise — this is the goal. 🌅 

peace out 🍃 jrp on toronto island [ September 30, 2024 ]
