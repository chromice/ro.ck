// Load classes
/*Machine.add("monome.ck");*/

Monome monome;

18974 => monome.port;
0 => monome.rotation;
8 => monome.intensity;

monome.connect();
monome.grid(0,0,2,1) @=> OscGrid grid;
monome.grid(0,1,8,7) @=> OscGrid grid_1;
monome.grid(0,1,8,7) @=> OscGrid grid_2;
monome.tilt() @=> OscXY tilt;

spork ~ gridControl("Grid 1", grid_1);
spork ~ gridControl("Grid 2", grid_2);
spork ~ tiltControl(tilt);

fun void gridControl(string name, OscGrid grid)
{
	while (true)
	{
		grid.event => now;
	
		while (grid.changed())
		{
			<<< name + ": [" + grid.x + "," + grid.y + "]: " + grid.state >>>;
		
			grid.set(grid.x, grid.y, grid.state);
		}
	}
}

fun void tiltControl(OscXY tilt)
{
	while (true)
	{
		tilt.event => now;
	
		while (tilt.changed())
		{
			<<< "Tilt: [" + tilt.x + "," + tilt.y + "]" >>>;
		}
	}
}

// Hide the second grid
grid_2.hide();

while (true)
{
	grid.event => now;
	
	while (grid.changed())
	{
		<<< "Switch [" + grid.x + "," + grid.y + "]: " + grid.state >>>;
		
		if (grid.state)
		{
			if (grid.x == 0)
			{
				grid_2.hide();
				grid_1.show();
			}
			else
			{
				grid_1.hide();
				grid_2.show();
			}
		}
		
		grid.set(grid.x, grid.y, grid.state);
	}
}
