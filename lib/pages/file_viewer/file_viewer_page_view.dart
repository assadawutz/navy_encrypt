part of file_viewer_page;

class _FileViewerPageView
    extends WidgetView<FileViewerPage, _FileViewerPageController> {
  _FileViewerPageView(_FileViewerPageController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: _getContentView(),
          ),
          //IconButton(onPressed: () {}, icon: Icon(Icons.close, color: Colors.white,))
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _getContentView() {
    if (Platform.isWindows) {
      return PhotoViewGalleryWindows(filePathList: state._filePathList);
    } else {
      return PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(state._filePathList[index])),
            initialScale: PhotoViewComputedScale.contained * 0.9,
            heroAttributes:
                PhotoViewHeroAttributes(tag: state._filePathList[index]),
          );
        },
        itemCount: state._filePathList.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          ),
        ),
        /*backgroundDecoration: widget.backgroundDecoration,
                  pageController: widget.pageController,
                  onPageChanged: onPageChanged,*/
      );
    }
  }

  Widget _buildCloseButton(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.all(Platform.isWindows ? 16.0 : 0.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30.0),
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black
                      .withOpacity(0.4), //Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PhotoViewGalleryWindows extends StatefulWidget {
  static const thumbnailSize = 160.0;
  final List<String> filePathList;

  const PhotoViewGalleryWindows({
    Key key,
    @required this.filePathList,
  }) : super(key: key);

  @override
  State<PhotoViewGalleryWindows> createState() =>
      _PhotoViewGalleryWindowsState();
}

class _PhotoViewGalleryWindowsState extends State<PhotoViewGalleryWindows> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: PhotoViewGalleryWindows.thumbnailSize,
            child: ListView.builder(
              itemCount: widget.filePathList.length,
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        if (index == 0) SizedBox(height: 8.0),
                        Container(
                          width: PhotoViewGalleryWindows.thumbnailSize,
                          height: PhotoViewGalleryWindows.thumbnailSize,
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: index == _selectedIndex
                                ? Colors.blueAccent
                                : Colors.black.withOpacity(0.3),
                            border: Border.symmetric(
                              vertical:
                                  BorderSide(width: 10.0, color: Colors.white),
                              horizontal:
                                  BorderSide(width: 5.0, color: Colors.white),
                            ),
                          ),
                          child: Image.file(
                            File(widget.filePathList[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          'หน้า ${index + 1}/${widget.filePathList.length}',
                          style: TextStyle(
                            fontSize: 20.0,
                            height: 0.9,
                            fontWeight: index == _selectedIndex
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        if (index == widget.filePathList.length - 1)
                          SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: PhotoView(
              imageProvider:
                  FileImage(File(widget.filePathList[_selectedIndex])),
            ),
          ),
        ],
      ),
    );
  }
}
