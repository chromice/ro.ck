I started this project a year ago, when I purchased my monome. I needed a way to bridge OSC inputs (monome and potentially other devices) with any OSC–enabled music app. But then I bought an iPad and it rendered this project useless to me for the foreseeable future, because I find it more rewarding to actually make music in the plethora of music apps for iOS.

At the moment only monome driver and related controls (push, toggle and radio grids; standalone LEDs; XY pad) have been implemented. At some point, I may implement TouchOSC controls and make a few examples.

In order to start using this piece of code: shred the `import.ck`, which will import all classes; connect your monome 64; make sure that the correct port is set in `test_monome.ck` and shred it as well. It used to work in ChucK 1.2.x.x (Dracula). GL. ;-)
