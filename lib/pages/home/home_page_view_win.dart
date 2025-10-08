part of home_page;

class _HomePageViewWin extends WidgetView<HomePage, HomePageController> {
  _HomePageViewWin(HomePageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    final heightThreshold = 840;
    final widthThreshold = 900;
    final width = screenWidth(context);
    final height = screenHeight(context);
    final menuActions = state.menuActions;

    return Scaffold(
      body: HeaderScaffold(
        showBackButton: false,
        showProgress: state.isLoading,
        progressMessage: state.loadingMessage,
        body: Container(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              width * 0.1,
              (width > widthThreshold || height > heightThreshold)
                  ? height * 0.05
                  : height * 0.02,
              width * 0.1,
              16.0,
            ),
            child: Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/ic_launcher.png',
                      height:
                          (width > widthThreshold || height > heightThreshold)
                              ? 100.0
                              : 70.0,
                    ),
                    //SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          Text(
                            'ระบบรับส่งไฟล์',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: (width > widthThreshold ||
                                      height > heightThreshold)
                                  ? 40.0
                                  : 28.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'SEND AND RECEIVE FILES',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: (width > widthThreshold ||
                                      height > heightThreshold)
                                  ? 26.0
                                  : 18.8,
                              height: 0.8,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (quickActions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: width > 1200 ? width * 0.6 : width,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16.0,
                          runSpacing: 12.0,
                          children: quickActions
                              .map(
                                (action) => _QuickActionButton(
                                  action: action,
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: width > widthThreshold
                      ? Container(
                          //width: width > 1600 ? 1200.0 : 960.0,
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Row(
                            children: [
                              for (var action in menuActions)
                                MenuItem(
                                  text: action.label,
                                  image: action.assetPath,
                                  onClick: () => action.onTap(context),
                                  size: width > 1400 ? 110.0 : null,
                                  borderWidth: width > 1400 ? 5.0 : null,
                                ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var i = 0; i < menuActions.length; i += 2)
                              Expanded(
                                child: Row(
                                  children: [
                                    for (var j = i;
                                        (j < i + 2) &&
                                            (j < menuActions.length);
                                        j++)
                                      MenuItem(
                                        text: menuActions[j].label,
                                        image: menuActions[j].assetPath,
                                        onClick: () =>
                                            menuActions[j].onTap(context),
                                        size: width > widthThreshold ||
                                                height > heightThreshold
                                            ? null
                                            : 80.0,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                //if (width > 900 || height > 840)
                FutureBuilder(
                  future: state.packageInfoFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<PackageInfo> snapshot) {
                    if (snapshot.hasData) {
                      final versionLabel =
                          state.buildVersionLabel(snapshot.data);
                      if (versionLabel.isEmpty) {
                        return SizedBox.shrink();
                      }
                      return Text(
                        versionLabel,
                        style:
                            TextStyle(fontSize: 24.0, color: Color(0xFF808080)),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
