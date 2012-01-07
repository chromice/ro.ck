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

public class OscControl
/*
	Abstract OSC control.
*/
{
	fun void init()
	{
		<<< "OscControl::init() is not implemented!" >>>;
	}
	
	/* ================== */
	/* = Event handling = */
	/* ================== */
	
	OscEvent @ event;
	
	fun int updated()
	{
		if (event.nextMsg() == 0)
		{
			return 0;
		}
		
		_updateValues();
		
		return 1;
	}
	
	fun void _updateValues()
	{
		<<< "OscControl::_updateValues() is not implemented!" >>>;
	}
		
	/* ================================= */
	/* = Basic show/hide functionality = */
	/* ================================= */
	
	0 => int hidden;
	
	fun void show()
	{
		0 => hidden;
	}
	
	fun void hide()
	{
		1 => hidden;
	}
}