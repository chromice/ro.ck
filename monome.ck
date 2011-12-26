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

public class Monome
{
	OscSend _to;
	OscRecv _from;
	
	OscEvent _keyEvent;
	OscEvent _tiltEvent;
	
	"localhost" => string host;
	18000 => int port;
	
	string prefix;
	0 => int tilt;
	0 => int rotation; // Cable position: 0 - left; 90 - top; 180 - right; 270 - bottom.
	8 => int intensity;
	
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
		_to.startMsg("/"+ prefix + "/tilt/set", "ii");
			0 => _to.addInt;
			tilt => _to.addInt;
		
		clear();
		
		_from.event("/"+ prefix + "/grid/key, iii") @=> OscEvent gridKeyEvent;
		
		if (tilt)
		{
			_from.event("/"+ prefix + "/tilt, iiii") @=> OscEvent gridTiltEvent;
		}
	}
	
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
	
	fun void clear()
	/*
		Display "RO" logo to confirm connection
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

			100::ms * (1 - frame / frames $ float) => now;
		}
	}
}