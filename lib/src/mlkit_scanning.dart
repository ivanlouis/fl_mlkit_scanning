part of '../fl_mlkit_scanning.dart';

typedef EventBarcodeListen = void Function(AnalysisImageModel data);
typedef FlMlKitScanningCreateCallback = void Function(
    FlMlKitScanningController controller);

class FlMlKitScanning extends StatefulWidget {
  FlMlKitScanning({
    Key? key,
    List<BarcodeFormat>? barcodeFormats,
    this.onListen,
    this.overlay,
    this.uninitialized,
    this.onFlashChanged,
    this.autoScanning = true,
    this.onZoomChanged,
    this.updateReset = false,
    this.camera,
    this.resolution = CameraResolution.high,
    this.fit = BoxFit.fitWidth,
    this.onCreateView,
    this.notPreviewed,
  })  : barcodeFormats =
            barcodeFormats ?? <BarcodeFormat>[BarcodeFormat.qrCode],
        super(key: key);

  /// 码识别回调
  /// Identify callback
  final EventBarcodeListen? onListen;

  /// 码识别类型
  /// Identification type
  final List<BarcodeFormat> barcodeFormats;

  /// 显示在预览框上面
  /// Display above preview box
  final Widget? overlay;

  /// 相机在未初始化时显示的UI
  /// The UI displayed when the camera is not initialized
  final Widget? uninitialized;

  /// 停止预览时显示的UI
  /// The UI displayed when the camera is not previewed
  final Widget? notPreviewed;

  /// Flash change
  final ValueChanged<FlashState>? onFlashChanged;

  /// 缩放变化
  /// zoom ratio
  final ValueChanged<CameraZoomState>? onZoomChanged;

  /// 更新组件时是否重置相机
  /// Reset camera when updating components
  final bool updateReset;

  /// 是否自动扫描 默认为[true]
  /// Auto scan defaults to [true]
  final bool autoScanning;

  /// 需要预览的相机
  /// Camera ID to preview
  final CameraInfo? camera;

  /// 预览相机支持的分辨率
  /// Preview the resolution supported by the camera
  final CameraResolution resolution;

  /// How a camera box should be inscribed into another box.
  final BoxFit fit;

  /// get Controller
  final FlMlKitScanningCreateCallback? onCreateView;

  @override
  _FlMlKitScanningState createState() => _FlMlKitScanningState();
}

class _FlMlKitScanningState extends FlCameraComposeState<FlMlKitScanning> {
  @override
  void initState() {
    super.initState();
    controller = FlMlKitScanningController();
    if (widget.onCreateView != null) {
      widget.onCreateView!(controller as FlMlKitScanningController);
    }
    uninitialized = widget.uninitialized;
    notPreviewed = widget.notPreviewed;
    WidgetsBinding.instance!
        .addPostFrameCallback((Duration time) => initialize());
  }

  Future<void> initialize() async {
    boxFit = widget.fit;
    var camera = widget.camera;
    if (camera == null) {
      final List<CameraInfo>? cameras = await controller.availableCameras();
      if (cameras == null) return;
      for (final CameraInfo cameraInfo in cameras) {
        if (cameraInfo.lensFacing == CameraLensFacing.back) {
          camera = cameraInfo;
          break;
        }
      }
    }
    if (camera == null) return;
    var scanningController = controller as FlMlKitScanningController;
    final data = await controller.initialize();
    if (data) {
      await scanningController.setBarcodeFormat(widget.barcodeFormats);
      initializeListen();
      final options = await controller.startPreview(camera.name);
      if (options != null && mounted) {
        scanningController.startScan();
        setState(() {});
      }
    }
  }

  void initializeListen() {
    if (widget.onZoomChanged != null) {
      controller.cameraZoom?.addListener(onZoomChanged);
    }
    if (widget.onFlashChanged != null) {
      controller.cameraFlash?.addListener(onFlashChanged);
    }
    if (widget.onListen != null) {
      (controller as FlMlKitScanningController)
          .analysisData
          ?.addListener(onAnalysisData);
    }
  }

  void onAnalysisData() {
    final scanningController = (controller as FlMlKitScanningController);
    if (scanningController.analysisData?.value != null) {
      widget.onListen!(scanningController.analysisData!.value!);
    }
  }

  void onZoomChanged() {
    if (controller.cameraZoom!.value != null) {
      widget.onZoomChanged!(controller.cameraZoom!.value!);
    }
  }

  void onFlashChanged() {
    if (controller.cameraFlash!.value != null) {
      widget.onFlashChanged!(controller.cameraFlash!.value!);
    }
  }

  @override
  void didUpdateWidget(covariant FlMlKitScanning oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overlay != widget.overlay ||
        oldWidget.onFlashChanged != widget.onFlashChanged ||
        oldWidget.onZoomChanged != widget.onZoomChanged ||
        oldWidget.camera != widget.camera ||
        oldWidget.resolution != widget.resolution ||
        oldWidget.uninitialized != widget.uninitialized ||
        oldWidget.barcodeFormats != widget.barcodeFormats ||
        oldWidget.autoScanning != widget.autoScanning ||
        oldWidget.fit != widget.fit ||
        oldWidget.onListen != widget.onListen) {
      uninitialized = widget.uninitialized;
      if (widget.updateReset) {
        controller.dispose().then((bool value) {
          if (value) initialize();
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initialize();
    } else {
      super.didChangeAppLifecycleState(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget camera = super.build(context);
    if (widget.overlay != null) {
      camera = Stack(children: <Widget>[
        camera,
        SizedBox.expand(child: widget.overlay),
      ]);
    }
    return camera;
  }

  @override
  void dispose() {
    super.dispose();
    final scanningController = controller as FlMlKitScanningController;
    scanningController.analysisData?.removeListener(onAnalysisData);
    scanningController.cameraZoom?.removeListener(onZoomChanged);
    scanningController.cameraFlash?.removeListener(onFlashChanged);
    controller.dispose();
  }
}
