import 'dart:collection';

class MyStack<T> {
  final _stack = Queue<T>();

  int get length => _stack.length;

  bool canPop() => _stack.isNotEmpty;

  void clearStack() {
    while (_stack.isNotEmpty) {
      _stack.removeLast();
    }
  }

  void push(T element) {
    _stack.addLast(element);
  }

  T pop() {
    if (_stack.isEmpty) return null;

    T lastElement = _stack.last;
    _stack.removeLast();
    return lastElement;
  }

  T popTo(T element) {
    while (peak != element && _stack.isNotEmpty) {
      pop();
    }
    return peak;
  }

  T get peak => _stack.isEmpty ? null : _stack.last;

  List<T> toList() => _stack.toList();
}
