import 'dart:convert';
import 'dart:io';
import 'package:ffmpeg_cli/ffmpeg_cli.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktop) {
    //await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(755, 545));
      await windowManager.setMinimumSize(const Size(350, 600));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Platform.isWindows
          ? null
          : AppBar(
              title: const Text('合并视频'),
            ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              TextButton.icon(
                label: const Text('合并文件'),
                icon: const Icon(Icons.video_file),
                onPressed: executeMergeVideo,
              )
            ],
          ),
        ),
      ),
    );
  }
}

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

///执行视频合并
void executeMergeVideo() async {
  final commandBuilder = FfmpegBuilder();
  final butterflyStream = commandBuilder.addAsset("assets/Butterfly-209.mp4");
  final beeStream =
      commandBuilder.addAsset("C:/Users/jiaba/Videos/Captures/bee.mp4");
  final outputStream =
      commandBuilder.createStream(hasVideo: true, hasAudio: true);

  commandBuilder.addFilterChain(
    //我们使用“concat”过滤器将两个示例视频合并为一个。
    FilterChain(
      inputs: [
        //“concat”过滤器的输入是FFMPEG生成的源视频的输入ID。
        butterflyStream,
        beeStream,
      ],
      filters: [
        //使用“concat”过滤器将两个源视频一个接一个地组合起来。
        ConcatFilter(
          segmentCount: 2,
          outputVideoStreamCount: 1,
          outputAudioStreamCount: 1,
        ),
      ],
      outputs: [
        // 这个“concat”过滤器将产生视频流和音频流。在这里，我们给这些流ID，
        // 以便将它们传递到其他FilterChain中，或将它们映射到输出文件。
        outputStream,
      ],
    ),
  );

  Directory tempDir = await getTemporaryDirectory();
  String fileName = path.join(tempDir.path, 'test_render.mp4');
  print("fileName==>$fileName");

  ///构建一个查询命令
  final cliCommand = commandBuilder.build(
    args: [
      // 设置FFMPEG日志级别。
      CliArg.logLevel(LogLevel.info),

      ///将过滤器图中的最终流ID映射到输出文件。
      CliArg(name: 'map', value: outputStream.videoId!),
      CliArg(name: 'map', value: outputStream.audioId!),
      const CliArg(name: 'vsync', value: '2'),
    ],
    //文件的输出目录
    outputFilepath: fileName,
  );

  print('');
  print('Expected command input: ');
  print(cliCommand.expectedCliInput());
  print('');

  // Run the FFMPEG command.
  final process = await Ffmpeg().run(cliCommand);

  // Pipe the process output to the Dart console.
  process.stderr.transform(utf8.decoder).listen((data) {
    print(data);
  });

  ///允许用户响应FFMPEG查询，例如文件覆盖确认。
  stdin.pipe(process.stdin);
  await process.exitCode;

  print('DONE');
}
