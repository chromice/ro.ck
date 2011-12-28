// 
// Copyright 2011 Anton Muraviev <chromice@gmail.com>
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 

class MonomeGrid extends OscGrid
{
	// Offsets
	int offset_x;
	int offset_y;
	
	// Connection to monome
	Monome @ monome;
	
	fun int changed()
	{
		while (event.nextMsg() != 0)
		{
			event.getInt() - offset_x => int _x;
			event.getInt() - offset_y => int _y;
			event.getInt() => int _state;
			
			if (hidden || _x < 0 || _x >= width || _y < 0 || _y >= height)
			{
				continue;
			}
			
			_x => x;
			_y => y;
			_state => state;
			
			return 1;
		}
		
		return 0;
	}
	
	fun void set(int x, int y, int state)
	{
		state => _state[x][y];
		
		if (!hidden && x < width && y < height)
		{
			monome.set(offset_x + x, offset_y + y, state);
		}
	}
	
	fun	void show()
	{
		if (!hidden) return;
		
		0 => hidden;
		
		// Set all LEDs
		_update();
	}
	
	fun void hide()
	{
		// FIXME: A button may remain pressed! What should we do?
		
		if (hidden) return;
		
		1 => hidden;
		
		// Clear all LEDs
		_update();
	}
	
	fun void _update()
	{
		for (0 => int _x; _x < _state.cap(); _x++)
		{
			for (0 => int _y; _y < _state[_x].cap(); _y++)
			{
				if (hidden)
				{
					
					monome.set(offset_x + _x, offset_y + _y, 0);
				}
				else
				{
					monome.set(offset_x + _x, offset_y + _y, _state[_x][_y]);
				}
			}
		}
	}
}

public class Monome
/*
	TODO: Handling multiple monomes & using a different incoming port.
	TODO: Support 128 & 256 boards.
*/
{
	OscSend _to;
	OscRecv _from;
	
	"localhost" => string host;
	18000 => int port;
	
	string prefix;
	0 => int rotation; // Cable position: 0 - left; 90 - top; 180 - right; 270 - bottom.
	8 => int intensity; // [0,15]
	
	fun void connect()
	{
		// Establish conncetion to serialOSC
		_to.setHost(host, port);
		
		// Start listening
		_from.port(8000);
		_from.listen();
		
		// Tell serialOSC where we expect to hear from it
		_to.startMsg("/sys/host", "s");
			"localhost" => _to.addString;
		_to.startMsg("/sys/port", "i");
			8000 => _to.addInt;
		
		if (prefix == "")
		{
			"monome_" + Std.rand() => prefix;
		}
		
		// Configure monome
		_to.startMsg("/sys/prefix", "s");
			prefix => _to.addString;
		_to.startMsg("/sys/rotation", "i");
			rotation => _to.addInt;
		_to.startMsg("/"+ prefix + "/grid/led/intensity", "i");
			intensity => _to.addInt;
		
		clear();
	}
	
	fun void clear()
	/*
		Display "RO" symbol to confirm connection
	*/
	{
		16 => int frames;

		for (0 => int frame; frame < frames; frame++)
		{
			_to.startMsg("/"+ prefix + "/grid/led/intensity", "i");
				(4 + (intensity - 4) * (frame / frames $float)) $int => _to.addInt;
			
			map([255,255,195,195,195,255,255,195]);

			if (frame == frames - 1)
				1::second => now;
			else
				20::ms => now;

			all(0);

			100::ms * (1 - frame / frames $float) => now;
		}
	}

	/* ======================= */
	/* = Outgoing OSC events = */
	/* ======================= */
	
	fun void set(int x, int y, int state)
	{
		_to.startMsg("/"+ prefix + "/grid/led/set", "iii");
			x => _to.addInt;
			y => _to.addInt;
			state => _to.addInt;
	}

	fun void all(int state)
	{
		_to.startMsg("/"+ prefix + "/grid/led/all", "i");
			state => _to.addInt;
	}
	
	fun void map(int masks[])
	{
		if (masks.cap() != 8)
		{
			return;
		}
		
		_to.startMsg("/"+ prefix + "/grid/led/map", "iiiiiiiiii");
			0 => _to.addInt;
			0 => _to.addInt;
		
		for(0 => int i; i < 8; i++)
		{
			masks[i] => _to.addInt;
		}
	}

	fun void row(int y, int mask)
	{
		_to.startMsg("/"+ prefix + "/grid/led/row", "iii");
			0 => _to.addInt;
			y => _to.addInt;
			mask => _to.addInt;
	}
	
	fun void col(int x, int mask)
	{
		_to.startMsg("/"+ prefix + "/grid/led/col", "iii");
			x => _to.addInt;
			0 => _to.addInt;
			mask => _to.addInt;
	}
	
	/* ======================= */
	/* = Incoming OSC events = */
	/* ======================= */
	
	fun OscEvent keyEvent()
	{
		return _from.event("/"+ prefix + "/grid/key, iii");
	}
	
	fun	OscEvent tiltEvent()
	{
		// Turn the tilt sensor ON.
		_to.startMsg("/"+ prefix + "/tilt/set", "ii");
			0 => _to.addInt;
			1 => _to.addInt;
		
		return _from.event("/"+ prefix + "/tilt, iiii");
	}

	/* ================ */
	/* = OSC Controls = */
	/* ================ */
	
	fun OscGrid grid(int x, int y, int w, int h)
	{
		MonomeGrid grid;
		
		x => grid.offset_x;
		y => grid.offset_y;
		w => grid.width;
		h => grid.height;
		
		this @=> grid.monome;
		keyEvent() @=> grid.event;
		
		grid.init();
		
		return grid;
	}
}