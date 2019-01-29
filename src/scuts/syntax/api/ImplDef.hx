package scuts.syntax.api;


#if macro

import haxe.macro.Context as C;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.ExprTools as ET;

using scuts.macrokit.ArrayApi;

private typedef Dep = { name : String, ct : ComplexType };

class ImplDef {

	public static var store = createStore();


	static function createStore () return new Map<String, Array<Field>>();

	static var BUILD_ID = ':scuts.syntax.api.ImplDef';

	static function isApplied (cl:ClassType, key:String) {
		return cl.meta.has(key);
	}

	public static function build () {
		var cl = C.getLocalClass();
		if (cl == null) {
			C.fatalError("local class is null", C.currentPos());
		}
		var cl = cl.get();
		var applied = isApplied(cl, BUILD_ID);

		return if (!applied) {
			var fields = C.getBuildFields();
			cl.meta.add(BUILD_ID, [], C.currentPos());
			var id = cl.module + "." + cl.name;
			store.set(id, fields);
			var res = fields;
			res;
		} else {
			null;
		}
	}
}

#end