import BackgroundTasks
import Flutter
import UIKit
import WidgetKit
import native_geofence

private let widgetRefreshTaskIdentifier = "com.jp.worktimer.widgetRefresh"

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Used by plugin: native_geofence — lets it register its own plugins on
    // the background engine it spins up to handle geofence events while the
    // app isn't running.
    NativeGeofencePlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: widgetRefreshTaskIdentifier, using: nil
    ) { task in
      self.handleWidgetRefresh(task: task as! BGAppRefreshTask)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    scheduleWidgetRefresh()
  }

  private func scheduleWidgetRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: widgetRefreshTaskIdentifier)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
    try? BGTaskScheduler.shared.submit(request)
  }

  private func handleWidgetRefresh(task: BGAppRefreshTask) {
    scheduleWidgetRefresh()
    WidgetCenter.shared.reloadAllTimelines()
    task.setTaskCompleted(success: true)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
