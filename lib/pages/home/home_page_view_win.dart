part of home_page;

class _HomePageViewWin extends WidgetView<HomePage, HomePageController> {
  _HomePageViewWin(HomePageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    final heightThreshold = 840;
    final widthThreshold = 900;
    final width = screenWidth(context);
    final height = screenHeight(context);

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
                Expanded(
                  child: width > widthThreshold
                      ? Container(
                          //width: width > 1600 ? 1200.0 : 960.0,
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Row(
                            children: [
                              for (var item in state._menuData)
                                MenuItem(
                                  text: item['text'],
                                  image: item['image'],
                                  onClick: () {
                                    item['onClick'](context);
                                  },
                                  size: width > 1400 ? 110.0 : null,
                                  borderWidth: width > 1400 ? 5.0 : null,
                                ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var i = 0; i < state._menuData.length; i += 2)
                              Expanded(
                                child: Row(
                                  children: [
                                    for (var j = i;
                                        (j < i + 2) &&
                                            (j < state._menuData.length);
                                        j++)
                                      MenuItem(
                                        text: state._menuData[j]['text'],
                                        image: state._menuData[j]['image'],
                                        onClick: () {
                                          state._menuData[j]
                                              ['onClick'](context);
                                        },
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
                  future: state._getPackageInfo(),
                  builder: (BuildContext context,
                      AsyncSnapshot<PackageInfo> snapshot) {
                    if (snapshot.hasData) {
                      var packageInfo = snapshot.data;
                      return Text(
                        'เวอร์ชัน 3.0.1+4',
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
