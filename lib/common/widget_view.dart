import 'package:flutter/material.dart';
import 'package:navy_encrypt/common/my_state.dart';

abstract class WidgetView<T1, T2> extends StatelessWidget {
  final T2 state;

  T1 get widget => (state as MyState).widget as T1;

  const WidgetView(this.state, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}

abstract class WidgetViewStateless<T1> extends StatelessWidget {
  final T1 widget;

  const WidgetViewStateless(this.widget, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}
