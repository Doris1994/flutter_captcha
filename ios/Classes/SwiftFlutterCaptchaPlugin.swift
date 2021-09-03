import Flutter
import UIKit
import WebKit
import ReCaptcha


public class SwiftFlutterCaptchaPlugin: NSObject, FlutterPlugin {
    var wkwebview: WKWebView?;
    var recaptcha: ReCaptcha?;
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_captcha", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterCaptchaPlugin()

    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let name = call.method;
     switch name {
     case "validate":
        do {
            let arguments  = call.arguments as? Dictionary<String,String>
            if arguments == nil {
                return
            }
            validate(key: arguments?["key"], domain: arguments?["domain"],complete: result)
        }
        break
      
     default: break
      
     }
  }

    func validate(key: String?, domain: String?,complete: @escaping FlutterResult){
        if key == nil || domain == nil {
            let flutterError = FlutterError(code: "FlutterCaptcha Error", message: "key and domain can not be null", details: nil)
              complete (flutterError);
            return
        }
         recaptcha = try? ReCaptcha(apiKey: key!, baseURL: URL(string: domain!)!, endpoint: .default, locale: nil)
        if recaptcha == nil {
            let flutterError = FlutterError(code: "FlutterCaptcha Error", message: "ReCaptcha init failed", details: nil)
            complete (flutterError);
            return
        }
        recaptcha?.configureWebView {[weak self] webview in
            webview.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)
            self?.wkwebview = webview
        }
        
        let view = getCurrentViewController().view!
        recaptcha?.validate(on: view) { [weak self] (result: ReCaptchaResult) in
             self?.wkwebview?.removeFromSuperview()
              switch(result)
              {
              case .token(let token):
                  complete(token);
                  break;
              case .error(let error):
                //ReCaptchaError
                let flutterError = FlutterError(code: "FlutterCaptcha Error", message: error.description, details: nil)
                  complete (flutterError);
                  break;
              }
          }
   }
    
    func getCurrentViewController(base: UIViewController? = UIApplication.shared.keyWindow!.rootViewController) -> UIViewController {
            if let nav = base as? UINavigationController {
                return getCurrentViewController(base: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                return getCurrentViewController(base: tab.selectedViewController)
            }
            if let presented = base?.presentedViewController {
                return getCurrentViewController(base: presented)
            }
        return base ?? UIApplication.shared.keyWindow!.rootViewController!
        }
}
