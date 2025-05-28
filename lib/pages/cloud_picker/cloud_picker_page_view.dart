part of drive_list_page;

class _CloudPickerPageView
    extends WidgetView<CloudPickerPage, _CloudPickerPageController> {
  _CloudPickerPageView(_CloudPickerPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: state._handleClickDeviceBackButton,
      child: HeaderScaffold(
        showBackButton: true,
        showProgress: state.isLoading,
        progressMessage: state.loadingMessage,
        progressValue: state.loadingValue,
        /*floatingActionButton:
            state._cloudDrive.pickerMode == CloudPickerMode.folder
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 64.0),
                    child: FloatingActionButton(
                      backgroundColor: Color(0xFFFFC818),
                      //Constants.LIST_DIALOG_ICON_COLOR,
                      onPressed: () {},
                      child: Icon(FontAwesomeIcons.folderPlus),
                    ),
                  )
                : null,*/
        header: EncryptDecryptHeader(
          imagePath: state._headerImagePath,
          title: state._title,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //_buildDivider(),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildBreadcrumb(context)),
                      IconButton(
                        //padding: const EdgeInsets.all(0.0),
                        onPressed: state._handleClickRefreshButton,
                        icon: Icon(Icons.refresh, size: 20.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //_buildDivider(opacity: 1.0),
            Expanded(
              child: Stack(
                children: [
                  if (state._fileList.isNotEmpty)
                    NotificationListener(
                      onNotification: state._handleScrollNotification,
                      child: _buildList(context),
                    ),
                  if (false &&
                      state._fileList.isEmpty &&
                      !state.isLoading &&
                      !state.isError)
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.frown,
                            size: 40.0,
                            color: Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            state._cloudDrive.pickerMode == CloudPickerMode.file
                                ? 'โฟลเดอร์ว่าง\nหรือไม่มีประเภทไฟล์ที่แอปรองรับ'
                                : 'ไม่มีโฟลเดอร์ย่อย',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22.0),
                          ),
                        ],
                      ),
                    ),
                  if (state.isError)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.sadTear,
                            size: 40.0,
                            color: Color(0xFFCCCCCC),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            state.errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22.0, color: Colors.redAccent),
                          ),
                          SizedBox(height: 32.0),
                          MyButton(
                            onClick: state._handleClickRefreshButton,
                            label: 'ลองใหม่',
                            width: 120.0,
                            rightIcon: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  //if (state.isLoading) SizedBox.shrink()
                ],
              ),
            ),
            if (state._cloudDrive.pickerMode == CloudPickerMode.folder)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  /*boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      offset: Offset(0.0, -2.0),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    )
                  ],*/
                ),
                child: MyButton(
                  label:
                      'บันทึกลงในโฟลเดอร์นี้ (${state._folderIdStack.peak.name})',
                  /*rightIcon: Icon(
                    FontAwesomeIcons.solidFolder,
                    size: 14.0,
                    color: Colors.yellow.shade600,
                  ),*/
                  onClick: state._handleClickSaveButton,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 0.0, 8.0),
      child: state._folderIdStack.length > 0
          ? BreadCrumb(
              items: state._folderIdStack
                  .toList()
                  .map(
                    (item) => BreadCrumbItem(
                      content: InkWell(
                        onTap: () => state._handleClickBreadcrumbItem(item),
                        borderRadius: BorderRadius.circular(4.0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Platform.isWindows ? 12.0 : 4.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.solidFolder,
                                size: 16.0,
                                color: Colors.yellow.shade600,
                              ),
                              SizedBox(width: 4.0),
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(item.name,
                                    style: TextStyle(fontSize: 20.0)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              divider: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Icon(Icons.chevron_right,
                    size: 16.0, color: Theme.of(context).primaryColor),
              ),
              overflow: WrapOverflow(
                keepLastDivider: false,
                direction: Axis.horizontal,
              ),
              /*overflow: ScrollableOverflow(
                keepLastDivider: false,
                reverse: false,
                direction: Axis.horizontal,
              ),*/
            )
          : Text('.', style: TextStyle(fontSize: 20.0)),
    );
  }

  Widget _buildList(BuildContext context) {
    if (Platform.isWindows) {
      final width = screenWidth(context);
      var numColumn = 1;
      if (width > 1600) {
        numColumn = 4;
      } else if (width > 1200) {
        numColumn = 3;
      } else if (width > 800) {
        numColumn = 2;
      }

      double ratio = 3;
      if (state._fileItemSize != null) {
        ratio = state._fileItemSize.width / state._fileItemSize.height;
      }

      return GridView.builder(
        padding: const EdgeInsets.only(bottom: 16.0),
        itemCount: state._fileList.length,
        itemBuilder: _buildFileItem,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: numColumn,
          childAspectRatio: ratio,
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 16.0),
        //separatorBuilder: (context, index) => _buildDivider(),
        itemCount: state._fileList.length,
        itemBuilder: _buildFileItem,
      );
    }
  }

  /*Widget _buildDivider({double opacity = 0.3}) {
    return Divider(
      color: Colors.black.withOpacity(opacity),
      height: 0.0,
      thickness: 0.0,
    );
  }*/

  Widget _buildFileItem(BuildContext context, int index) {
    var file = state._fileList[index];
    return FileItem(
      file: file,
      icon: state._getIcon(file),
      onClick: () => state._handleClickFileItem(file),
      onLongClick: () => state._handleLongClickFileItem(file),
      onSizeChange: state._handleFileItemSizeChange,
    );
  }
}

class FileItem extends StatefulWidget {
  final CloudFile file;
  final Icon icon;
  final Function onClick;
  final Function onLongClick;
  final Function(Size) onSizeChange;

  FileItem({
    @required this.file,
    @required this.icon,
    this.onClick,
    this.onLongClick,
    this.onSizeChange,
  }) : super(key: Key(file.id));

  @override
  _FileItemState createState() => _FileItemState();
}

class _FileItemState extends State<FileItem> {
  static const PREVIEW_WIDTH = 200.0;
  var _showPreview = false;

  @override
  Widget build(BuildContext context) {
    var file = widget.file;
    var thaiDateTime = file.modifiedTime != null
        ? ThaiDateTime(file.modifiedTime.toLocal())
        : null;
    var fileSize = FileSize.fromString(file.size);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 0.0, color: Colors.black.withOpacity(0.2)),
          bottom: BorderSide(width: 0.0, color: Colors.black.withOpacity(0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MeasureSize(
            onChange: (size) {
              print("onChange ${size}");
              widget.onSizeChange(size);
            },
            child: GestureDetector(
              onLongPress: widget.onLongClick,
              child: InkWell(
                onTap: widget.onClick,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 45.0,
                        height: 45.0,
                        child: FittedBox(
                          //fit: BoxFit.cover,
                          child: widget.icon,
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              file.name,
                              style: TextStyle(fontSize: 22.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!file.isFolder)
                              Row(
                                children: [
                                  if (thaiDateTime != null)
                                    Expanded(
                                      child: FileAttributeItem(
                                        text:
                                            '${thaiDateTime.formatDate()},  ${thaiDateTime.formatTime()}',
                                        icon: FontAwesomeIcons.solidEdit,
                                      ),
                                    ),
                                  if (fileSize != null)
                                    Row(
                                      children: [
                                        FileAttributeItem(
                                          text: fileSize.getDisplaySize(),
                                          icon: FontAwesomeIcons.solidFileAlt,
                                        ),
                                        Container(
                                          //margin: const EdgeInsets.only(left: 8.0),
                                          width: 14.0,
                                          height: 14.0,
                                          decoration: BoxDecoration(
                                            color: fileSize.getColor(),
                                            border: Border.all(
                                                color: Color(0xFFA8A8A8)),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (!file.isFolder &&
                          (file.thumbnailLink == null ||
                              file.thumbnailLink.isEmpty))
                        SizedBox(width: 16.0),
                      if (!file.isFolder &&
                          file.thumbnailLink != null &&
                          file.thumbnailLink.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showPreview = !_showPreview;
                            });
                          },
                          icon: Icon(
                            _showPreview
                                ? FontAwesomeIcons.chevronUp
                                : FontAwesomeIcons.chevronDown,
                            //color: Color(0xFF888888),
                          ),
                          iconSize: 14.0,
                          padding: const EdgeInsets.all(0.0),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_showPreview &&
              file.thumbnailLink != null &&
              file.thumbnailLink.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              color: Colors.blueGrey,
              child: Platform.isAndroid || Platform.isIOS
                  ? Center(
                      child: CachedNetworkImage(
                        width: PREVIEW_WIDTH,
                        imageUrl: file.thumbnailLink,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                          color: Colors.white,
                        ),
                        fit: BoxFit.contain,
                      ),
                    )
                  : Center(
                      child: Image.network(
                        file.thumbnailLink,
                        width: PREVIEW_WIDTH,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class FileAttributeItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const FileAttributeItem({
    Key key,
    @required this.text,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*Icon(icon, size: 12.0, color: Colors.blueGrey.withOpacity(0.8)),
          SizedBox(width: 3.0),*/
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              text,
              style: TextStyle(fontSize: 18.0, color: Color(0xFF888888)),
            ),
          ),
        ],
      ),
    );
  }
}
