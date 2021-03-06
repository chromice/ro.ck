Monome monome;

monome.init("localhost", 18974, "left");

/* Create four virtual grids */
monome.led(7,0) @=> OscLED led1;
monome.led(6,0) @=> OscLED led2;
monome.led(5,0) @=> OscLED led3;
monome.led(4,0) @=> OscLED led4;
monome.gridRadio(0,0,2,1) @=> OscGrid grid;
monome.gridToggle(0,1,8,7) @=> OscGrid grid_1;
monome.gridPush(0,1,8,7) @=> OscGrid grid_2;
monome.grid(2,0,6,1) @=> OscGrid grid_3;

/* Create an XY control for the tilt sensor */
monome.tilt() @=> OscXY tilt;

/* Spork event hanlders */
spork ~ gridControl("Grid 1", grid_1);
spork ~ gridControl("Grid 2", grid_2);
spork ~ gridControl("Grid 3", grid_3);
spork ~ tiltControl(tilt);

fun void gridControl(string name, OscGrid grid)
{
	while (true)
	{
		grid.event => now;
	
		while (grid.updated())
		{
			<<< name + ": [" + grid.x + "," + grid.y + "]: " + grid.state >>>;
		}
	}
}

fun void tiltControl(OscXY tilt)
{
	while (true)
	{
		tilt.event => now;
	
		while (tilt.updated())
		{
			<<< "Tilt: [" + tilt.x + "," + tilt.y + "]" >>>;
		}
	}
}

// Hide the second grid and tilt sensor
tilt.hide();
grid_2.hide();
grid.set(0,0,1);

// Leds
led1.set(0.05);
led2.set(0.10);
led3.set(0.0);
led4.set(1.00);

while (true)
{
	grid.event => now;
	
	while (grid.updated())
	{
		<<< "Grid #" + (grid.x + 1) + " ON!" >>>;
		
		if (grid.x == 0)
		{
			tilt.hide();
			grid_2.hide();
			grid_1.show();
		}
		else
		{
			grid_1.hide();
			grid_2.show();
			tilt.show();
		}
	}
}
