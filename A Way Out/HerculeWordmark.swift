//
//  HerculeWordmark.swift
//  A Way Out
//

import SwiftUI

/// The Hercule brand colour (#FF4500) shared by the logo and the "ercule" text.
let herculeBrandColor = Color(red: 1.0, green: 69.0 / 255.0, blue: 0.0)

/// Destination opened when the user taps the Hercule wordmark.
let herculeWebsiteURL = URL(string: "https://herculewebsite.pages.dev")!

/// Renders the word "Hercule" with the Hercule logo standing in for the leading
/// "H" — i.e. {logo}ercule. The logo is sized to sit on the text baseline like a
/// capital letter, and the "ercule" text uses the brand colour.
struct HerculeWordmark: View {
    /// Point size of the "ercule" text. The logo is scaled relative to it.
    var fontSize: CGFloat = 22
    var weight: Font.Weight = .semibold

    private var logoSide: CGFloat { fontSize * 1.35 }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: logoSide, height: logoSide)
            Text("ercule")
                .font(.system(size: fontSize, weight: weight))
                .foregroundColor(herculeBrandColor)
        }
    }
}

/// The "by {logo}ercule" credit shown as a subtitle under the app title.
struct HerculeCredit: View {
    var fontSize: CGFloat = 22
    var weight: Font.Weight = .semibold

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text("by")
                .font(.system(size: fontSize, weight: weight))
                .foregroundStyle(.primary)
            Link(destination: herculeWebsiteURL) {
                HerculeWordmark(fontSize: fontSize, weight: weight)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    HerculeCredit()
}
