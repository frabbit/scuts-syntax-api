package a;
import Expect.match as m;

import scuts.syntax.ImplicitInstance;
import scuts.syntax.ApiDef;
import scuts.syntax.ApiOf;

interface Show<X> extends ApiDef {
	public function foo (s:X):String;
}

class ShowString implements Show<String> implements ImplicitInstance {
	public function foo (s:String):String {
		return "bar";
	}
}

class ShowApi implements ApiOf<Show<_>> {}

class A {
	public static function main () {
		m( ShowApi.foo("h1"), "bar" );
	}
}