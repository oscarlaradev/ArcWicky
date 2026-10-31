import SwiftUI
import AppKit
import WebKit

// MARK: - Screen 1: Animated Typographic Living Sculpture Intro
// Pure sculptural typography with zero progress bars and zero secondary text.
public struct ArcWickyIntroView: View {
    var onContinue: () -> Void
    @State private var hasProceeded = false
    @State private var opacity: Double = 0

    public init(onContinue: @escaping () -> Void = {}) {
        self.onContinue = onContinue
    }

    public var body: some View {
        ZStack {
            ArcWickyTheme.Palette.canvas.ignoresSafeArea()

            ArcWickySculptureWebView(onTap: {
                proceed()
            })
            .opacity(opacity)
            .ignoresSafeArea()
        }
        .frame(minWidth: 1040, minHeight: 700)
        .onAppear {
            // Smooth fade-in
            withAnimation(.easeInOut(duration: 0.6)) {
                opacity = 1.0
            }

            // Auto-proceed like a real, polished splash/loading screen (no clicking needed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                proceed()
            }
        }
    }

    private func proceed() {
        guard !hasProceeded else { return }
        hasProceeded = true
        withAnimation(.easeInOut(duration: 0.5)) {
            opacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            onContinue()
        }
    }
}

// MARK: - Native WebKit Sculpture Renderer
struct ArcWickySculptureWebView: NSViewRepresentable {
    var onTap: () -> Void

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "introProceed")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator

        if let htmlPath = Bundle.main.path(forResource: "arcwicky_sculpture_clean", ofType: "html") ??
            Bundle(for: AppState.self).path(forResource: "arcwicky_sculpture_clean", ofType: "html"),
           let htmlString = try? String(contentsOfFile: htmlPath) {
            webView.loadHTMLString(htmlString, baseURL: nil)
        } else {
            // Inline fallback
            webView.loadHTMLString(ArcWickySculptureHTML.fallbackHTML, baseURL: nil)
        }

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: ArcWickySculptureWebView

        init(_ parent: ArcWickySculptureWebView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "introProceed" {
                DispatchQueue.main.async {
                    self.parent.onTap()
                }
            }
        }
    }
}

// MARK: - Offline Static HTML Fallback
enum ArcWickySculptureHTML {
    static var fallbackHTML: String {
        // Reads from the bundled/local clean file or embeds the full sculpture
        if let bundlePath = Bundle.main.path(forResource: "arcwicky_sculpture_clean", ofType: "html"),
           let content = try? String(contentsOfFile: bundlePath) {
            return content
        }
        let localPath = "/Users/oscaralfredoperezlara/Developer/01_Desarrollo_y_Software/ArcWicky/Resources/arcwicky_sculpture_clean.html"
        if let content = try? String(contentsOfFile: localPath) {
            return content
        }
        return """
        <!DOCTYPE html>
        <html class="dark" lang="en">
        <head>
          <meta charset="UTF-8"/>
          <style>
            html, body {
              margin: 0; padding: 0; width: 100vw; height: 100vh;
              background-color: #090B11; overflow: hidden; user-select: none;
              display: flex; align-items: center; justify-content: center;
              position: relative;
            }
            .bloom-base {
              position: absolute; inset: 0;
              background: radial-gradient(ellipse 80% 70% at 50% 52%, #111725 0%, #090B11 100%);
            }
            .bloom-mist {
              position: absolute; top: 52%; left: 50%; transform: translate(-50%, -50%);
              width: 1200px; height: 440px; background-color: #F0EAFE; opacity: 0.04;
              filter: blur(130px); border-radius: 9999px;
            }
            .wordmark {
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
              font-size: 78px; font-weight: 900; letter-spacing: -2px;
              color: #DCE8FF; text-shadow: 0 10px 0 #141B2D, 0 20px 40px rgba(0,0,0,0.8);
              animation: dropInBoing 0.9s cubic-bezier(0.28, 0.84, 0.42, 1.4);
            }
            @keyframes dropInBoing {
              0% { opacity: 0; transform: translateY(-120px) scale(0.7, 1.3); }
              60% { opacity: 1; transform: translateY(18px) scale(1.15, 0.85); }
              80% { transform: translateY(-8px) scale(0.96, 1.04); }
              100% { opacity: 1; transform: translateY(0) scale(1, 1); }
            }
          </style>
        </head>
        <body>
          <div class="bloom-base"></div>
          <div class="bloom-mist"></div>
          <div class="wordmark">ARCWICKY</div>
          <script>
            function signal() {
              if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.introProceed) {
                window.webkit.messageHandlers.introProceed.postMessage("proceed");
              }
            }
            window.addEventListener('click', signal);
            window.addEventListener('keydown', signal);
            setTimeout(signal, 3000);
          </script>
        </body>
        </html>
        """
    }
}
