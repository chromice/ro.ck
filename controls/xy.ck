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

public class OscXY extends OscControl
/*
	Abstract XY control.
*/
{
	Interpolator interpolatorX;
	Interpolator interpolatorY;
	
	float x;
	float y;
	
	fun int _updateValues()
	{
		interpolatorX.interpolate(event.getFloat()) => x;
		interpolatorY.interpolate(event.getFloat()) => y;
		
		return true;
	}
}