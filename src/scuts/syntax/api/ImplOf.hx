package scuts.syntax.api;


#if macro
import scuts.syntax.api.ImplDef;
import haxe.macro.Context as C;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.ExprTools as ET;
import haxe.macro.TypeTools as TT;

using scuts.macrokit.ArrayApi;

private typedef Dep = { name : String, ct : ComplexType };

class ImplOf {

	static var BUILD_ID = ':scuts.syntax.api.ImplOf';

	static function isApplied (cl:ClassType, key:String) {
		return cl.meta.has(key);
	}

	static function mapField(f:Field, params:Array<Type>, cl:ClassType) {
		return switch f.kind {
			case FieldType.FFun(fun):

				var tparam:TypeParam = TPType(TPath({
					pack: cl.pack,
					name: cl.name,
					params: [for (p in cl.params) TPType(TT.toComplexType(p.t))],
				}));

				var tp:TypePath = {
					pack : ["scuts", "implicit"],
					name : "Implicit",
					params: [tparam],
				}

				var iType:ComplexType = TPath(tp);

				var implicitArg:FunctionArg = {
					name: "_X",
					opt: true,
					type: iType,
				};

				var eargs = fun.args.map(a -> {
					var name = a.name;
					macro $i{name};
				});

				var name = f.name;

				var nexpr = macro return _X.$name($a{eargs});

				var decls:Array<TypeParamDecl> = cl.params.map(p -> ({ name: p.name}:TypeParamDecl) );

				var nargs = fun.args.concat([implicitArg]);

				var n:Function = {
					args : nargs,
					ret : fun.ret,
					expr : nexpr,
					params : fun.params.concat(decls),
				}

				var hasPublic = f.access.any(a -> a.match(APublic));
				var hasInline = f.access.any(a -> a.match(AInline));

				var access = f.access.concat([AStatic]).concat(hasPublic ? [] : [APublic]).concat(hasInline ? [] : [AInline]);

				var newFun = FFun(n);
				{
					access: access,
					doc: f.doc,
					kind: newFun,
					meta: f.meta,
					name: f.name,
					pos: f.pos,
				}
			case _:
				f;
		}

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
			var res = fields;
			for (i in cl.interfaces) {
				var cl = i.t.toString();
				if (cl == "scuts.syntax.ApiOf") {
					switch (i.params) {
						case [TInst(t, params)]:
							var cl = t.get();
							var name = cl.module + "." + cl.name;
							var fieldLookup = [for (f in fields) f.name => true];

							var apiFields = ImplDef.store.get(name).filter(f -> !fieldLookup.exists(f.name)).filter(f -> f.kind.match(FFun(_)));



							res = fields.concat(apiFields.map(mapField.bind(_, params, cl) ));
						case _:
							C.fatalError("error", C.currentPos());
					}

				}

			}


			res;
		} else {
			null;
		}
	}
}

#end