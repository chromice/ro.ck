// Load classes
/*Machine.add("monome.ck");*/

Monome monome;

monome.init("localhost", 18974, "left");

/* Create three virtual grids */
monome.grid(0,0,2,1) @=> OscGrid grid;
monome.grid(0,1,8,7) @=> OscGrid grid_1;
monome.grid(0,1,8,7) @=> OscGrid grid_2;

/* Create an XY control for the tilt sensor*/
monome.tilt() @=> OscXY tilt;

/* Spork event hanlders */
spork ~ gridControl("Grid 1", grid_1);
spork ~ gridControl("Grid 2", grid_2);
spork ~ tiltControl(tilt);

fun void gridControl(string name, OscGrid grid)
{
	while (true)
	{
		grid.event => now;
	
		while (grid.updated())
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
	
		while (tilt.updated())
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
	
	while (grid.updated())
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
