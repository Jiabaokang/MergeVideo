import 'package:MergeVideo/page/home_page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart' as material;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //桌面应用
  if (isDesktop) {
    //异步初始化window类
    await flutter_acrylic.Window.initialize();
    //确保WindowManager已经初始化
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
  int topIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      //主题颜色
      theme: FluentThemeData(
          accentColor: Colors.purple,
          visualDensity: VisualDensity.standard,
          //焦点主题
          focusTheme: FocusThemeData(glowFactor: is10footScreen() ? 2.0 : 0.0)),
      //模式跟随系统
      themeMode: ThemeMode.system,
      color: Colors.green,
      //黑色模式
      darkTheme: FluentThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.standard,
          //焦点主题
          focusTheme: FocusThemeData(glowFactor: is10footScreen() ? 2.0 : 0.0)),
      home: NavigationView(
        //导航应用程序栏
        appBar: NavigationAppBar(
            height: 40,
            leading: const Icon(FluentIcons.a_a_d_logo),
            //拖动可以移动区域
            title:  DragToMoveArea(
              child:  Container(
                width: 120,
                height: 40,
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(100),
                //     gradient: RadialGradient(colors: [Colors.black, Colors.blue])),
                child: const Text('合并视频'),
              )
            ),
            actions: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [if (!kIsWeb) WindowButtons()],
            )),
        //左边侧边栏
        pane: NavigationPane(
            selected: topIndex,
            size: const NavigationPaneSize(compactWidth: 50, openMaxWidth: 200),
            onChanged: (int index) {
              if (mounted) {
                setState(() {
                  topIndex = index;
                });
              }
            },
            displayMode: PaneDisplayMode.auto,
            items: [
              PaneItem(
                  icon: const Icon(material.Icons.home),
                  title: const Text("HomePage"),
                  body: const HomePage())
            ]),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FluentThemeData theme = FluentTheme.of(context);
    return SizedBox(
      width: 138,
      height: 40,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
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
