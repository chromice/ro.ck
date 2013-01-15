string prefix;


if (prefix == "")
{
	"monome_" + Std.rand() => prefix;
	<<< prefix >>>;
}


"localhost" => string host;

/* Connect transmiter */
OscSend toGrid;
toGrid.setHost(host, 18974);

/* Connect receiver */
OscRecv fromGrid;
fromGrid.port(8000);
fromGrid.listen();

/* Configure serialosc */
toGrid.startMsg("/sys/host", "s");
	host => toGrid.addString;
toGrid.startMsg("/sys/port", "i");
	8000 => toGrid.addInt;
toGrid.startMsg("/sys/prefix", "s");
	"prefix" => toGrid.addString;
toGrid.startMsg("/sys/rotation", "i");
 	90 => toGrid.addInt; // Cable position: 0 - left; 90 - top; 180 - right; 270 - bottom.
toGrid.startMsg("/prefix/grid/led/intensity", "i");
	8 => toGrid.addInt;
toGrid.startMsg("/prefix/tilt/set", "ii");
	0 => toGrid.addInt;
	1 => toGrid.addInt;

/* Push all button press events into the queue */
fromGrid.event("/prefix/grid/key, iii") @=> OscEvent gridKeyEvent;
fromGrid.event("/prefix/tilt, iiii") @=> OscEvent gridTiltEvent;
fromGrid.event("/prefix/tilt, iiii") @=> OscEvent gridTiltEvent2;

/*
	Logo
*/
16 => int frames;

for (0 => int frame; frame < frames; frame++)
{
	toGrid.startMsg("/prefix/grid/led/intensity", "i");
		(4 + 8 * (frame / frames $float)) $int => toGrid.addInt;
	
	toGrid.startMsg("/prefix/grid/led/map", "iiiiiiiiii");
	0 => toGrid.addInt; // x
	0 => toGrid.addInt; // y
	255 => toGrid.addInt; // r1
	255 => toGrid.addInt; // r2
	195 => toGrid.addInt; // r3
	195 => toGrid.addInt; // r4
	195 => toGrid.addInt; // r5
	255 => toGrid.addInt; // r6
	255 => toGrid.addInt; // r7
	195 => toGrid.addInt; // r8

	if (frame == frames - 1)
		1::second => now;
	else
		20::ms => now;

	toGrid.startMsg("/prefix/grid/led/all", "i");
	0 => toGrid.addInt; // s
	
	100::ms * (1 - frame / frames $ float) => now;
}



/*
	Sound patch
*/

SawOsc s => Envelope e => JCRev r => dac;
SinOsc lfo => blackhole;
5.0 => lfo.freq;
0.1 => lfo.gain;
.5 => s.gain;
.05 => r.mix;
.5 => r.gain;

// Start event loops
spork ~ keyProcessor();
spork ~ tiltProcessor(gridTiltEvent);
spork ~ tiltProcessor2(gridTiltEvent2);

// Let the shreds run and apply filters each sample
while(10::ms => now) {
    (0.5 + lfo.last()) => s.gain;   // Here we add the last value of lfo and a little booster.
}
/*
	Event loop
*/

fun void keyProcessor()
{
	int x, y, last_x, last_y, on;
	
	while (true)
	{
		gridKeyEvent => now;

		while (gridKeyEvent.nextMsg() != 0)
		{
			gridKeyEvent.getInt() => x;
			gridKeyEvent.getInt() => y;
			gridKeyEvent.getInt() => on;


			if (on && (last_x != x || last_y != y))
			{
				Std.mtof( 57 + x + y * 8 ) => s.freq;
				 
				x => last_x;
				y => last_y;
				e.keyOn();
			}
			else if (!on && last_x == x && last_y == y)
			{
				e.keyOff();
			}
				
			toGrid.startMsg("/prefix/grid/led/set", "iii");
			x => toGrid.addInt;
			y => toGrid.addInt;
			on => toGrid.addInt;
		}
	}
}

fun void tiltProcessor(OscEvent event)
{
	int t, x, y, z;
	
	while (true)
	{
		event => now;

		while (event.nextMsg() != 0)
		{
			event.getInt() => t;
			event.getInt() => x;
			event.getInt() => y;
			event.getInt() => z;

			15.0 - (128 - y) * 10.0 / 45 => lfo.freq;
			0.3 - (128 - x) * 0.2 / 45 => lfo.gain; 
		}
	}
}
fun void tiltProcessor2(OscEvent event)
{
	int t, x, y, z;
	
	while (true)
	{
		event => now;

		while (event.nextMsg() != 0)
		{
			event.getInt() => t;
			event.getInt() => x;
			event.getInt() => y;
			event.getInt() => z;

			<<< "Tilt (" + t + ")" , x, y, z >>>;
		}
	}
}
