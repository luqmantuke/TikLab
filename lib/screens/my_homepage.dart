import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:simple_downloader/simple_downloader.dart';
import 'package:tiklab/models/get_tiktok_video_model.dart';
import 'package:tiklab/utilities/colors.dart';
import 'package:tiklab/widgets/option_view.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController tiktokLink = TextEditingController();
  Future getTikTokVideoResult() async {
    var headers = {
      'x-rapidapi-key': 'YOUR RAPID API KEY',
      'x-rapidapi-host':
          'tiktok-downloader-download-videos-without-watermark1.p.rapidapi.com',
      'useQueryString': 'true',
      'x-rapidapi-ua': 'RapidAPI-Playground',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
      'Expires': '0',
      'Origin': 'https://rapidapi.com',
      'Connection': 'keep-alive',
      'Referer': 'https://rapidapi.com/',
      'TE': 'trailers',
    };

    var url = Uri.parse(
        'https://tiktok-downloader-download-videos-without-watermark1.p.rapidapi.com/media-info/?link=${tiktokLink.text}');
    var res = await http.get(url, headers: headers);
    var decodedResponse = json.decode(res.body);

    if (res.statusCode != 200) {
      throw Exception('http.get error: statusCode= ${res.statusCode}');
    }
    if (decodedResponse["ok"] == true) {
      if (decodedResponse["result"] == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: tealColor,
          duration: Duration(milliseconds: 1000),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          padding: EdgeInsets.all(15),
          behavior: SnackBarBehavior.floating,
          content: Text('Invalid Link! Video Not Found Check Link Again'),
        ));
      } else {
        var pullTikTokVideoResult =
            GetTikTokVideoModel.fromJson(decodedResponse);
        setState(() {
          tiktokvideoResult = pullTikTokVideoResult;
          videoFetched = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: tealColor,
        duration: Duration(milliseconds: 1000),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        padding: EdgeInsets.all(15),
        behavior: SnackBarBehavior.floating,
        content: Text('Invalid Link! Video Not Found Check Link Again'),
      ));
    }
  }

  late SimpleDownloader _downloader;
  bool downloading = false;
  bool videoDownloading = false;
  int videoprogress = 0;
  int audioprogress = 0;
  int offset = 0;
  int total = 0;
  GetTikTokVideoModel tiktokvideoResult = GetTikTokVideoModel();
  bool loading = false;
  bool videoFetched = false;
  bool isDownloaded = false;

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    Directory dir = await getApplicationDocumentsDirectory();

    path = '${dir.path}/$uniqueFileName.pdf';

    return path;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: blackColor,
          title: const Text("TikLab"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 40.0,
                        right: 10,
                        left: 10,
                        bottom: 15,
                      ),
                      child: TextField(
                        onSubmitted: (value) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        controller: tiktokLink,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          labelText: 'Video Link',
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          loading = true;
                        });
                        getTikTokVideoResult();
                        setState(() {
                          loading = false;
                        });
                      },
                      child: loading == true
                          ? const Center(
                              child: CircularProgressIndicator(
                              backgroundColor: tealColor,
                            ))
                          : SizedBox(
                              width: MediaQuery.of(context).size.width / 1.5,
                              child: ButtonView(
                                blackColor,
                                "Get Video",
                                padding: 12,
                              )),
                    ),
                  ],
                ),
                videoFetched == true
                    ? Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.35,
                            padding: const EdgeInsets.all(15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: VideoPlayerWidget(
                                  url: tiktokvideoResult
                                      .result!.video!.urlList!.first
                                      .toString(),
                                  thumbnail: tiktokvideoResult.result!
                                      .awemeDetail!.video!.cover!.urlList!.first
                                      .toString()),
                            ),
                          ),
                          InkWell(
                            onTap: videoDownloading == true
                                ? null
                                : () {
                                    setState(() {
                                      videoDownloading = true;
                                    });
                                    Future<void> init() async {
                                      var directoryCheck =
                                          await Directory.fromUri(Uri.parse(
                                                  "/storage/emulated/0/Download/"))
                                              .exists();
                                      if (directoryCheck == false) {
                                        Directory(
                                                '/storage/emulated/0/Download/TikLab')
                                            .create()
                                            // The created directory is returned as a Future.
                                            .then((Directory directory) {
                                          // print(directory.path);
                                        });
                                      } else {
                                        DownloadStatus status =
                                            DownloadStatus.undefined;
                                        DownloaderTask task = DownloaderTask(
                                          url: tiktokvideoResult
                                              .result!.video!.urlList!.first
                                              .toString(),

                                          fileName:
                                              "${tiktokvideoResult.result!.awemeId}.mp4",
                                          bufferSize:
                                              1024, // if bufferSize value not set, default value is 64 ( 64 Kb )
                                        );

                                        const pathFile =
                                            "/storage/emulated/0/Download/TikLab";
                                        if (!mounted) return;

                                        task = task.copyWith(
                                          downloadPath: pathFile,
                                        );

                                        _downloader =
                                            SimpleDownloader.init(task: task);

                                        _downloader.callback.addListener(() {
                                          setState(() {
                                            videoprogress = _downloader
                                                .callback.progress
                                                .toInt();
                                            status =
                                                _downloader.callback.status;
                                            total = _downloader.callback.total;
                                            offset =
                                                _downloader.callback.offset;
                                            videoDownloading = false;
                                          });
                                        });
                                        _downloader.download().whenComplete(
                                            () => ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  backgroundColor: tealColor,
                                                  duration: Duration(
                                                      milliseconds: 1000),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                                  padding: EdgeInsets.all(15),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                      'Video Downloaded Successful Check Your Gallery/Storage'),
                                                )));
                                        _downloader.open();
                                      }
                                    }

                                    init();
                                  },
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: ButtonView(
                                  blackColor,
                                  "Download Video $videoprogress% ",
                                  padding: 12,
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              Future<void> init() async {
                                var directoryCheck = await Directory.fromUri(
                                        Uri.parse(
                                            "/storage/emulated/0/Download/"))
                                    .exists();
                                if (directoryCheck == false) {
                                  Directory(
                                          '/storage/emulated/0/Download/TikLab')
                                      .create()
                                      // The created directory is returned as a Future.
                                      .then((Directory directory) {
                                    // print(directory.path);
                                  });
                                } else {
                                  DownloadStatus status =
                                      DownloadStatus.undefined;
                                  DownloaderTask task = DownloaderTask(
                                    url: tiktokvideoResult
                                        .result!.music!.urlList!.first
                                        .toString(),

                                    fileName:
                                        "${tiktokvideoResult.result!.awemeId}.mp3",
                                    bufferSize:
                                        1024, // if bufferSize value not set, default value is 64 ( 64 Kb )
                                  );

                                  const pathFile =
                                      "/storage/emulated/0/Download/TikLab";
                                  if (!mounted) return;

                                  task = task.copyWith(
                                    downloadPath: pathFile,
                                  );

                                  _downloader =
                                      SimpleDownloader.init(task: task);

                                  _downloader.callback.addListener(() {
                                    setState(() {
                                      audioprogress =
                                          _downloader.callback.progress.toInt();
                                      status = _downloader.callback.status;
                                      total = _downloader.callback.total;
                                      offset = _downloader.callback.offset;
                                      videoDownloading = false;
                                    });
                                  });
                                  _downloader.download();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    backgroundColor: tealColor,
                                    duration: Duration(milliseconds: 1000),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    padding: EdgeInsets.all(15),
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                        'Audio Downloaded Successful Check Your Storage'),
                                  ));
                                  _downloader.open();
                                }
                              }

                              init();
                            },
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: ButtonView(
                                  blackColor,
                                  "Download Audio Only $audioprogress%",
                                  padding: 12,
                                )),
                          ),
                        ],
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
