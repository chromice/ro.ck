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

public class OscGrid extends OscControl
/*
	Abstract grid control. It has three modes of operation: push, toggle and radio. Plus optional feedback.
*/
{
	int width;
	int height;
	
	int _state[0][0];
	int _feedback;
	string _mode;
	
	/* ================== */
	/* = Initialization = */
	/* ================== */
	
	fun void init(int w, int h, string mode, int feedback)
	{
		w => width;
		h => height;
		feedback => _feedback;
		
		if (mode == "radio" || mode == "toggle")
		{
			mode => _mode;
		}
		else
		{
			"push" => _mode;
		}
		
		// Initialize state array
		for (0 => int _x; _x < width; _x++)
		{
			int col[0];

			for (0 => int _y; _y < height; _y++)
			{
				col << 0;
			}

			_state << col;
		}
	}
	
	/* ================= */
	/* = State control = */
	/* ================= */
	
	fun int get(int x, int y)
	{
		return _state[x][y];
	}
	
	fun void set(int x, int y, int state)
	{
		if (_mode == "push")
		{
			state => _state[x][y];
		}
		else if (_mode == "toggle" && state > 0)
		{
			if (_state[x][y] > 0)
			{
				0 => _state[x][y];
			}
			else
			{
				1 => _state[x][y];
			}
		}
		else if (_mode == "radio" && state > 0)
		{
			for (0 => int _x; _x < width; _x++)
			{
				for (0 => int _y; _y < height; _y++)
				{
					0 => _state[_x][_y];
				}
			}
			
			1 => _state[x][y];
		}
		
		_draw(x,y);
	}
	
	fun void _draw(int x, int y)
	{
		// Implementation specific drawing routine
	}
	
	/* ================== */
	/* = Event handling = */
	/* ================== */
	
	int x;
	int y;
	int state;
	
	fun int _updateValues()
	{
		event.getInt() => x;
		event.getInt() => y;
		event.getInt() => state;
		
		set(x, y, state);
		
		return _updateModeValues();
	}
	
	fun int _updateModeValues()
	{
		if (_mode == "push" || state > 0)
		{
			if (_mode != "push")
			{
				_state[x][y] => state;
			}
			
			return true;
		}
		else
		{
			return false;
		}
	}

}