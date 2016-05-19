package tink.sql.macros;

import haxe.macro.Context;
import tink.macro.BuildCache;
import haxe.macro.Expr;

using tink.MacroApi;

class TableBuilder {

  static function build() {
    return BuildCache.getType('tink.sql.Table', function (ctx:BuildContext) {
      return
        switch ctx.type {
          case TAnonymous(_.get() => { fields: [{ kind: FVar(_, _), name: name, type: _.reduce() => TAnonymous(_.get().fields => fields) }] } ):
            
            var cName = ctx.name;
            var names = [for (f in fields) f.name];
            
            var rowTypeFields = new Array<Field>(),
                fieldsTypeFields = new Array<Field>(),
                fieldsExprFields = [];
                
            for (f in fields) {
              var fType = f.type.toComplex(),
                  fName = f.name;
              
              var fStruct = TAnonymous([{
                name: fName,
                kind: FVar(fType),
                pos: f.pos,
              }]);
              
              rowTypeFields.push({ 
                pos: f.pos,
                name: fName,
                kind: FProp('default', 'null', fType),
              });
              
              fieldsTypeFields.push({
                pos: f.pos,
                name: fName,
                kind: FProp('default', 'null', macro : tink.sql.Expr.Field<$fType, $fStruct>)
              });
              
              fieldsExprFields.push({
                field: f.name,
                expr: macro new tink.sql.Expr.Field($v{name}, $v{f.name}),
              });
            }
            
            
              
            var rowType = TAnonymous(rowTypeFields),
                fieldsType = TAnonymous(fieldsTypeFields);
                
            var filterType = ctx.pos.makeBlankType();
            
            macro class $cName<Db> extends tink.sql.Table.TableSource<$fieldsType, $filterType, $rowType, $rowType, Db> {
              public function new(cnx) {
                if (false) 
                  (function ($name:$fieldsType):tink.sql.Expr.Condition return null : $filterType);
                super(cnx, new tink.sql.Table.TableName($v{name}), ${EObjectDecl(fieldsExprFields).at(ctx.pos)});
              }
              
              static var FIELD_NAMES = $v{names};
              @:noCompletion override public function fieldnames():Array<String>
                return FIELD_NAMES;
                
                //TODO: override sqlizeRow
            }
            
          default:
            ctx.pos.error('invalid usage of Table');
        }
      
    });
  }
  
}