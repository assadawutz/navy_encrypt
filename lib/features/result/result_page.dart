import 'package:flutter/material.dart';

import '../../shared/widgets/adaptive_page_scaffold.dart';
import 'result_page_args.dart';
import 'result_view.dart';
import 'result_view_win.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.args});

  static const routeName = 'result';
  static const routeSegment = 'result';

  final ResultPageArgs args;

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).platform == TargetPlatform.windows
        ? ResultViewWin(args: args)
        : ResultView(args: args);

    return AdaptivePageScaffold(
      selectedRoute: '/${ResultPage.routeSegment}',
      pageTitle: 'Results',
      body: body,
    );
  }
}
