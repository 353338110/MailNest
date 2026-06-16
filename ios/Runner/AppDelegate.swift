import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let oauthCallbacks = OAuthCallbackStreamHandler.shared

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if oauthCallbacks.handle(url: url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "OAuthCallbackStream"
    ) else {
      return
    }
    let channel = FlutterEventChannel(
      name: "com.funmaster.mailnest/oauth_callbacks",
      binaryMessenger: registrar.messenger()
    )
    channel.setStreamHandler(oauthCallbacks)
  }
}

final class OAuthCallbackStreamHandler: NSObject, FlutterStreamHandler {
  static let shared = OAuthCallbackStreamHandler()

  private var eventSink: FlutterEventSink?
  private var pendingUrl: String?

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    if let pendingUrl {
      events(pendingUrl)
      self.pendingUrl = nil
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  func handle(url: URL) -> Bool {
    let value = url.absoluteString
    guard value.hasPrefix("com.funmaster.mailnest://oauth/outlook") else {
      return false
    }
    if let eventSink {
      eventSink(value)
    } else {
      pendingUrl = value
    }
    return true
  }
}
