part of history_page;

class _HistoryPageView extends WidgetView<HistoryPage, _HistoryPageController> {
  _HistoryPageView(_HistoryPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return HeaderScaffold(
      showBackButton: true,
      showSettingsButton: true,
      showProgress: state.isLoading,
      header: EncryptDecryptHeader(
        imagePath: 'assets/images/ic_history.png',
        title: Constants.HistoryPageTitle,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (state._registerStatus == WatermarkRegisterStatus.registered)
          Column(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Padding(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: SizedBox(
                      // width: 300,
                      child: MyFormField(
                    hint: 'ค้นหาไฟล์...',
                    textAlign: TextAlign.end,
                    multiline: false,
                    controller: state._searchEditingController,
                    // keyboardType: TextInputType.text,
                    rightIcon: Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(
                        FontAwesome.search,
                        color: Color.fromARGB(255, 112, 145, 172),
                      ),
                    ),
                    onEditingComplete: () {
                      state.setState(() {});
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onClickRightIcon: () {
                      state.setState(() {});
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ))),
            ]),
            Stack(
              children: [
                Positioned.fill(
                  bottom: 0.0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 5.0,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: Offset(0.0, 2.0),
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 8.0, 0.0, 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.history, size: 20.0),
                                  Text(
                                    " ประวัติการใช้งาน",
                                    style: TextStyle(fontSize: 20),
                                  )
                                ],
                              ))),
                      IconButton(
                        onPressed: () {
                          state.setState(() {});
                        },
                        icon: Icon(Icons.refresh, size: 20.0),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ]),
        if (state._registerStatus != WatermarkRegisterStatus.registered)
          MyContainer(
              //padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 32.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                if (Platform.isWindows)
                  EncryptDecryptHeader(
                    imagePath: 'assets/images/ic_history.png',
                    title: Constants.HistoryPageTitle,
                  ),
                if (state._registerStatus == WatermarkRegisterStatus.initial)
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: MyButton(
                      label:
                          'ไปหน้าตั้งค่าเพื่อขอคีย์ \nสำหรับการใช้งานประวัติ',
                      width: 250.0,
                      onClick: state._handleClicktoSettingButton,
                    ),
                  ),
                if (state._registerStatus ==
                    WatermarkRegisterStatus.waitForSecret)
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: MyButton(
                      label:
                          'ไปหน้าตั้งค่าเพื่อกรอกคีย์ที่ได้รับ\nทางอีเมลสำหรับการใช้งานประวัติ',
                      width: 300.0,
                      onClick: state._handleClicktoSettingButton,
                    ),
                  ),
              ])),
        if (state._registerStatus == WatermarkRegisterStatus.registered)
          Expanded(
              child: FutureBuilder(
                  future: state._getLog(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      List<Log> log = snapshot.data;

                      return Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          padding: EdgeInsets.all(12),
                          itemCount: log.length,
                          itemBuilder: (BuildContext context, int index) {
                            var thaiDateTime = log[index].createdAt != null
                                ? ThaiDateTime(log[index].createdAt.toLocal())
                                : null;
                            var icon = state._getIcon(
                                log[index].action, log[index].type);

                            return Column(children: [
                              ListTile(
                                onTap: () {
                                  if (log[index].action == 'share') {
                                    state._getShareLog(log[index].id);
                                  }
                                },
                                contentPadding: EdgeInsets.all(0),
                                isThreeLine: true,
                                leading: Icon(icon.icon,
                                    color: icon.color, size: 40.0),
                                title: Row(children: [
                                  Text(
                                      state._showLogAction(
                                          log[index].action, log[index].type),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  Spacer(),
                                  Text(
                                      '${thaiDateTime.formatDate()},  ${thaiDateTime.formatTime()}',
                                      // overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.grey))
                                ]),
                                subtitle: Row(children: [
                                  Flexible(
                                      child: Text(
                                    log[index].fileName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 22,
                                    ),
                                  )),
                                ]),
                                dense: true,
                              ),
                              Divider()
                            ]);
                          },
                        ),
                      );
                    } else {
                      return MyContainer(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [CircularProgressIndicator()]));
                    }
                  }))
      ]),
    );
  }
}
