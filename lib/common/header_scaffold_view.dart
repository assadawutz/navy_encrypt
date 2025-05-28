part of header_scaffold;

class _HeaderScaffoldView extends WidgetViewStateless<HeaderScaffold> {
  const _HeaderScaffoldView(HeaderScaffold widget) : super(widget);

  @override
  Widget build(BuildContext context) {
    print(widget.floatingActionButton);
    return Scaffold(
      resizeToAvoidBottomInset:
          widget.floatingActionButton == null ? true : false,
      floatingActionButton: widget.floatingActionButton,
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Container(
                    child: Image.asset(
                      widget.headerAssetPath ??
                          widget._getHeaderImageAsset(context),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: widget.header,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.showBackButton
                                  ? () => widget._handleClickBackButton(context)
                                  : null,
                              borderRadius: BorderRadius.circular(30.0),
                              child: Container(
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: widget.showBackButton
                                    ? Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      )
                                    : SizedBox.shrink(),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: widget.showSettingsButton
                                ? () =>
                                    widget._handleClickSettingsButton(context)
                                : null,
                            child: widget.showSettingsButton
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 30.0,
                                        height: 30.0,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(2.0, 2.0),
                                              blurRadius: 4.0,
                                              color: Color.fromARGB(
                                                  255, 80, 80, 80),
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.settings_outlined,
                                            size: 22.0),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
                  child: widget.body,
                ),
              )
            ],
          ),
          if (widget.showProgress)
            ProgressOverlay(
              progressMessage: widget.progressMessage,
              progressValue: widget.progressValue,
            ),
        ],
      ),
    );
  }
}
