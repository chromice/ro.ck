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
/*
	A virtual grid abstraction on top of real monome grid.
	
	Multiple grids may overlap. It is up to the user to resolve such conflicts.
*/
{
	// Offsets
	int _offset_x;
	int _offset_y;
	
	// Connection to monome
	Monome @ _monome;
	
	fun int updated()
	{
		while (event.nextMsg() != 0)
		{
			event.getInt() - _offset_x => int _x;
			event.getInt() - _offset_y => int _y;
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
			_monome.set(_offset_x + x, _offset_y + y, state);
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
					_monome.set(_offset_x + _x, _offset_y + _y, 0);
				}
				else
				{
					_monome.set(_offset_x + _x, _offset_y + _y, _state[_x][_y]);
				}
			}
		}
	}
}

class MonomeTilt extends OscXY
/*
	TODO: show/hide support
*/
{
	fun void _updateValues()
	{
		event.getInt(); // n
		event.getInt() => x;
		event.getInt() => y;
		event.getInt(); // z
	}
}

public class Monome
/*
	TODO: Support 128 & 256 boards.
*/
{
	static int _incomingPortOffset;
	
	OscSend _to;
	OscRecv _from;
	
	string _prefix;
	int _intensity;
	
	/* ================== */
	/* = Initialization = */
	/* ================== */
	
	fun void init(string host, int port, string orientation, int intensity, string prefix)
	{
		if (_incomingPortOffset == 0)
		{
			8000 => _incomingPortOffset;
		}
		
		// Establish conncetion to serialOSC
		_to.setHost(host, port);
		
		// Start listening
		_from.port(_incomingPortOffset);
		_from.listen();
		
		// Tell serialOSC where we expect to hear from it
		_to.startMsg("/sys/host", "s");
			"localhost" => _to.addString;
		_to.startMsg("/sys/port", "i");
			_incomingPortOffset => _to.addInt;
		
		_incomingPortOffset++;
		
		// Set prefix
		if (prefix == "")
		{
			"monome_" + Std.rand() => _prefix;
		}
		else
		{
			prefix => _prefix;
		}
		
		_to.startMsg("/sys/prefix", "s");
			_prefix => _to.addString;
		
		// Set cable orientation
		_to.startMsg("/sys/rotation", "i");
		
		if (orientation == "top")
			90 => _to.addInt;
		else if (orientation == "right")
			180 => _to.addInt;
		else if (orientation == "bottom")
			270 => _to.addInt;
		else
			0 => _to.addInt;
		
		// Set intensity
		intensity => _intensity;
		_to.startMsg("/" + _prefix + "/grid/led/intensity", "i");
			_intensity => _to.addInt;
		
		clear();
	}
	
	fun void init(string host, int port, string orientation, int intensity)
	{
		init(host, port, orientation, intensity, "");
	}
	
	fun void init(string host, int port, string orientation)
	{
		init(host, port, orientation, 8);
	}
	
	fun void init(string host, int port)
	{
		init(host, port, "left");
	}
	
	fun void clear()
	/*
		Display "RO" symbol to confirm connection
	*/
	{
		16 => int frames;

		for (0 => int frame; frame < frames; frame++)
		{
			_to.startMsg("/" + _prefix + "/grid/led/intensity", "i");
				(4 + (_intensity - 4) * (frame / frames $float)) $int => _to.addInt;
			
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
		_to.startMsg("/" + _prefix + "/grid/led/set", "iii");
			x => _to.addInt;
			y => _to.addInt;
			state => _to.addInt;
	}

	fun void all(int state)
	{
		_to.startMsg("/" + _prefix + "/grid/led/all", "i");
			state => _to.addInt;
	}
	
	fun void map(int masks[])
	{
		if (masks.cap() != 8)
		{
			return;
		}
		
		_to.startMsg("/" + _prefix + "/grid/led/map", "iiiiiiiiii");
			0 => _to.addInt;
			0 => _to.addInt;
		
		for(0 => int i; i < 8; i++)
		{
			masks[i] => _to.addInt;
		}
	}

	fun void row(int y, int mask)
	{
		_to.startMsg("/" + _prefix + "/grid/led/row", "iii");
			0 => _to.addInt;
			y => _to.addInt;
			mask => _to.addInt;
	}
	
	fun void col(int x, int mask)
	{
		_to.startMsg("/" + _prefix + "/grid/led/col", "iii");
			x => _to.addInt;
			0 => _to.addInt;
			mask => _to.addInt;
	}
	
	/* ======================= */
	/* = Incoming OSC events = */
	/* ======================= */
	
	fun OscEvent keyEvent()
	{
		return _from.event("/" + _prefix + "/grid/key, iii");
	}
	
	fun	OscEvent tiltEvent()
	{
		// Turn the tilt sensor ON.
		_to.startMsg("/" + _prefix + "/tilt/set", "ii");
			0 => _to.addInt;
			1 => _to.addInt;
		
		return _from.event("/" + _prefix + "/tilt, iiii");
	}

	/* ================ */
	/* = OSC Controls = */
	/* ================ */
	
	fun OscGrid grid(int x, int y, int w, int h)
	{
		MonomeGrid grid;
		
		x => grid._offset_x;
		y => grid._offset_y;
		this @=> grid._monome;
		
		keyEvent() @=> grid.event;
		
		grid.init(w, h);
		
		return grid;
	}
	
	fun OscXY tilt()
	{
		MonomeTilt tilt;
		
		tiltEvent() @=> tilt.event;
		
		tilt.init();
		
		return tilt;
	}
}