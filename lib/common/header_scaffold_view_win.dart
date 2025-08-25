part of header_scaffold;

class _HeaderScaffoldViewWin extends WidgetViewStateless<HeaderScaffold> {
  const _HeaderScaffoldViewWin(HeaderScaffold widget) : super(widget);

  @override
  Widget build(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);

    return Scaffold(
      floatingActionButton: widget.floatingActionButton,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: width > 1400 ? 180.0 : 140.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/win/bg_header_4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: width > 1400 ? 16.0 : 8.0),
                              child: Image.asset(
                                  'assets/images/win/logo_navy_small.png'),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: width > 1400 ? 24.0 : 16.0,
                                  bottom: width > 1400 ? 55.0 : 30.0),
                              child: Row(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('กองทัพเรือ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 32.0,
                                              height: 0.8)),
                                      Text('ROYAL THAI NAVY',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 21.0,
                                              height: 0.8)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: SizedBox.shrink()),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: width > 1400 ? 24.0 : 16.0,
                                  bottom: width > 1400 ? 55.0 : 30.0),
                              child: Row(
                                children: [
                                  //_buildHeaderButton(FontAwesome.home, 'หน้าหลัก'),
                                  //SizedBox(width: 8.0),
                                  if (widget.showSettingsButton)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: _buildHeaderButton(
                                          Icons.settings,
                                          'ตั้งค่า',
                                          () =>
                                              widget._handleClickSettingsButton(
                                                  context)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      widget.showBackButton
                          ? Positioned(
                              top: 16.0,
                              left: 16.0,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () =>
                                      widget._handleClickBackButton(context),
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: Container(
                                    width: 60.0,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      //color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: widget.body,
              ),
              Container(
                height: 20.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF4081FF),
                      Color(0xFF6EE4FE),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.showProgress)
            ProgressOverlay(
              progressMessage: widget.progressMessage,
              progressValue: widget.progressValue,
            ),
          if (kDebugMode)
            Align(
              alignment: Alignment.bottomCenter,
              child: Text('WIDTH: $width, HEIGHT: $height',
                  style: TextStyle(fontSize: 16.0, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  OutlinedButton _buildHeaderButton(
      IconData icon, String label, Function onClick) {
    return OutlinedButton(
      onPressed: onClick,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        side: BorderSide(
          width: 2.5,
          color: Colors.white,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 2.0,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.0),
            SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

/*void _handleClickBackButton(BuildContext context) {
    print('BACK BUTTON CLICKED!');
    if (onClickBackButton != null) {
      onClickBackButton();
    } else {
      Navigator.pop(context);
    }
  }

  void _handleClickSettingsButton(BuildContext context) {
    print('SETTINGS BUTTON CLICKED!');
    Navigator.pushNamed(
      context,
      SettingsPage.routeName,
    ).then((_) {
      if (onResume != null) onResume();
    });
  }*/
}
