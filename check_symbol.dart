void main() {
  print('Symbol("c").toString(): ${Symbol("c").toString()}');
  print('Symbol("c") == Symbol("c"): ${Symbol("c") == Symbol("c")}');

  var map = {'foo': 1};
  // print('map.entries: ${map.entries}'); // This works in Dart

  var s = {Symbol('c')};
  print('Set<Symbol>: $s');
}
