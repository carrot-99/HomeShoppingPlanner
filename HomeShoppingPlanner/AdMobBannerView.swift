//  AdMobBannerView.swift

import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    let adUnitID: String
    
    init() {
        if let adUnitID = Bundle.main.infoDictionary?["AdUnitID"] as? String {
            self.adUnitID = adUnitID
        } else {
            fatalError("AdUnitID not found in Info dictionary")
        }
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: getAdSize())
        banner.adUnitID = self.adUnitID

        let request = GADRequest()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            request.scene = windowScene
            banner.rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        }

        banner.load(request)
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // バナー広告のビューを更新する必要がある場合に実装
    }
    
    private func getAdSize() -> GADAdSize {
        // 画面の幅に基づいて適切な広告サイズを取得
        let frame = UIScreen.main.bounds
        let viewWidth = frame.size.width

        // 画面の向きに応じた適切な広告サイズを返す
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
    }
}
