package tink.sql.drivers;

typedef SqlServerSettings = {
  @:optional var host(default, null):String;
  @:optional var port(default, null):Int;
  var user(default, null):String;
  var password(default, null):String;
}
