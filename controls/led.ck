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

public class OscLED extends OscControl
/*
	Abstract LED.
*/
{
	0.0 => float _brightness;
	
	fun float get()
	{
		return _brightness;
	}
	
	fun void set(float brightness)
	{
		// Clamp to [0.0, 1.0] range
		Math.max(0.0, Math.min(1.0, brightness)) => _brightness;
		
		_draw();
	}
	
	fun void _draw()
	{
		// Implementation specific drawing routine
	}
}
