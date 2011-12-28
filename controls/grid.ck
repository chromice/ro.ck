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
{
	int width;
	int height;
	
	int _state[0][0];
	
	fun void init()
	{
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
	
	fun void set(int x, int y, int state)
	{
		state => _state[x][y];
	}
	
	int x;
	int y;
	int state;
	
	fun void _updateValues()
	{
		event.getInt() => x;
		event.getInt() => y;
		event.getInt() => state;
	}

}