package c;
import Expect.match as m;

import scuts.implicit.Implicit;
import scuts.syntax.ImplicitInstance;
import scuts.syntax.ApiDef;
import scuts.syntax.ApiOf;

interface Show<X> extends ApiDef {
	function foo (s:X):String;
}

class ShowString implements Show<String> implements ImplicitInstance {
	public function foo (s:String):String {
		return "bar";
	}
}

class ShowApi implements ApiOf<Show<_>> {
	public static function foo <X>(s:X, ?S:Implicit<Show<X>>):String {
		return S.foo(s);
	}
}

class C {
	public static function main () {
		m( ShowApi.foo("h1"), "bar" );
	}
}