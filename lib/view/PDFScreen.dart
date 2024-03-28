import 'dart:async';
import 'dart:io';

//import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mobile/util/TabNavigatorRoutes.dart';
import 'package:mobile/util/Utils.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile/models/PDFScreenArgumentModel.dart';

class PDFScreen extends StatefulWidget {
  final PDFScreenArgumentModel? pdfScreenArgumentModel;
  const PDFScreen({Key? key, required this.pdfScreenArgumentModel}) : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  String pathPDF = "";
  Future<File>? pdfPath;
  String _currentPageString = Constant.blankString;
  bool? _isBackPressed;
  //PDFDocument document;

  final Completer<PDFViewController> _controller = Completer<PDFViewController>();

  @override
  void initState() {
    super.initState();

    _isBackPressed = false;


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //pdfPath = Utils.createFileOfPdfUrl(widget.base64String);
      Utils.createFileOfPdfUrl(widget.pdfScreenArgumentModel!.base64String).then((value) {
        Future.delayed(Duration(milliseconds: 350), () async {
          setState(() {
            pathPDF = value.path;
          });
          if (Platform.isIOS) {
            _controller.future.then((value) {
              debugPrint('coming_pdf');
              Future.delayed(Duration(milliseconds: 150), () async {
                value.setPage(0);
              });
            });
          }
        });
        //_getPdfDocument(value);
      });
    });
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void didUpdateWidget(covariant PDFScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('cameOnDidUpdate');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('cameOnDidChangeDepend');
  }

  @override
  void dispose() {
    if(_isBackPressed!)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp
      ]);

    super.dispose();

    debugPrint('disposeofPdf????');

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    debugPrint('AppLifeCycleState????$state');
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    /*Future.delayed(Duration(seconds: 5), () {
      setState(() {

      });
    });*/

    //widget.onPush(context, TabNavigatorRoutes.pdfScreenRoute, widget.base64String);

    if (Platform.isAndroid) {
      Navigator.pushReplacementNamed(context, TabNavigatorRoutes.pdfScreenRoute, arguments: widget.pdfScreenArgumentModel);
    }
  }



  @override
  Widget build(BuildContext context) {
    debugPrint('in build func of pdf screen');
    return WillPopScope(
      onWillPop: () async {
        _isBackPressed = true;
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                color: Constant.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _isBackPressed = true;
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.cancel,
                        color: Constant.chatBubbleGreen,
                      ),
                    ),
                    CustomTextWidget(
                      text: Constant.generateReport,
                      style: TextStyle(
                        color: Constant.chatBubbleGreen,
                        fontFamily: Constant.jostRegular,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        shareGenerateReport();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Icon(
                        Icons.share,
                        color: Constant.chatBubbleGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: pathPDF.isNotEmpty ? _getWidget() : Container(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Uri uri = Uri(
                scheme: 'mailto',
              path: 'support@bontriage.com',
              query: 'subject=MigraineMentor Monthly Report Feedback ${widget.pdfScreenArgumentModel!.monthYear}',
            );
            Utils.customLaunch(uri);
          },
          label: Text(
            Constant.feedback,
            style: TextStyle(
              color: Constant.backgroundColor,
              fontFamily: Constant.jostRegular,
              fontSize: 18,
            ),
          ),
          backgroundColor: Constant.chatBubbleGreen,
          icon: Icon(Icons.feedback_rounded, color: Constant.backgroundColor,),
        ),
      ),
    );
  }


  void shareGenerateReport() async {
    final files = <XFile>[];
    final box = context.findRenderObject() as RenderBox;
    files.add(XFile(pathPDF));
    /*Share.shareFiles(
      [pathPDF]
    );*/

    Share.shareXFiles(
        files,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
    );
  }

  /*Widget _getWidget() {
    return PDFViewer(
      document: document,
      showNavigation: false,
      showPicker: false,
      lazyLoad: false,
      scrollDirection: Axis.vertical,
    );
  }*/

  /*void _getPdfDocument(File file) async{
    document = await PDFDocument.fromFile(file);

    setState(() {
      pathPDF = file.path;
    });
  }*/

  Widget _getWidget() {
    return Stack(
      children: [
        PDFView(
          filePath: pathPDF,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: false,
          onRender: (_pages) {
            debugPrint(_pages.toString());
          },
          onError: (error) {
            debugPrint('PDFError: ${error.toString()}');
          },
          onPageError: (page, error) {
            debugPrint('PDFError1:$page: ${error.toString()}');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            debugPrint('onViewCreated: ${pdfViewController.toString()}');
            _controller.complete(pdfViewController);
          },
          onPageChanged: (int? page, int? total) {
            setState(() {
              _currentPageString = '${page !+ 1}/$total';
            });
            //print('page change: $page/$total');
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(15), right: Radius.circular(15),)
            ),
            child: CustomTextWidget(
              text: _currentPageString,
              style: TextStyle(
                color: Colors.white,
                fontFamily: Constant.jostRegular,
                fontSize: 14,
              ),
            ),
          ),
        )
      ],
    );
  }
}
