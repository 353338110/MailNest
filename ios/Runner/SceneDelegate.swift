import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for context in URLContexts {
      if OAuthCallbackStreamHandler.shared.handle(url: context.url) {
        return
      }
    }
    super.scene(scene, openURLContexts: URLContexts)
  }
}
