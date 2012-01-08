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

public class Interpolator
/*
	Basic linear interpolator.
*/
{
	0.0 => float minInput;
	0.0 => float minOutput;
	1.0 => float maxInput;
	1.0 => float maxOutput;
	
	fun float interpolate(float input)
	{
		Math.max(input, minInput) => input;
		Math.min(input, maxInput) => input;
		
		return (maxOutput - minOutput) / (maxInput - minInput) * (input - minInput) + minOutput;
	}
	
	fun static Interpolator linear()
	{
		return new Interpolator;
	}
}
