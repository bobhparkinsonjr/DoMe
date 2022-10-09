/*

USAGE:

void main() {
  String a = 'bye';
  foo(Ref<String>(() {return a;}, (String v) {a = v;}));
  print('main: $a');
}

void foo(Ref<String> dest) {
  print('foo 1: ${dest.value}');
  dest.value = 'hello';
  print('foo 2: ${dest.value}');
}

*/
class Ref<T> {
  final T Function() _get;
  final void Function(T) _set;

  Ref(this._get, this._set);

  T get value => _get();
  set value(T value) {
    _set(value);
  }
}
