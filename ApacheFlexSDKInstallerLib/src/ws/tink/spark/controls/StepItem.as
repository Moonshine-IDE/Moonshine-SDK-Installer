/*

Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/
package ws.tink.spark.controls
{
	import flash.events.EventDispatcher;

	[Bindable]
	public class StepItem extends EventDispatcher
	{
		
		public static const NORMAL:String = "normal";
		public static const ACTIVE:String = "active";
		public static const COMPLETE:String = "complete";
		public static const ERROR:String = "error";
		
		public function StepItem(l:String)
		{
			label = l;
		}
		
		private var _label:String = "";
		public function get label():String { return _label; }
		
		public function set label(value:String):void
		{
			if (_label == value)
				return;
			_label = value;
		}
		
		private var _status:String = NORMAL;
		public function get status():String { return _status; }
		
		public function set status(value:String):void
		{
			if (_status == value)
				return;
			_status = value;
		}
		
		
	}
}
