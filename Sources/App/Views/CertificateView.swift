import SwiftUI
import SwiftData

/// The completion certificate (§10): shown when every fact is mastered. Renders to
/// an image that can be shared or printed via the system share sheet. Personalized
/// with the child's avatar, real stats, and the seven conquered worlds.
struct CertificateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var vSize   // compact = iPhone landscape
    @Query(filter: #Predicate<Profile> { $0.isActive }) private var activeProfiles: [Profile]
    let name: String
    private var compact: Bool { vSize == .compact }

    @State private var rendered: Image?

    private var profile: Profile? { activeProfiles.first }
    private static let gold = Color(hex: "#C9A24B")
    private static let goldDeep = Color(hex: "#A87F2E")

    var body: some View {
        VStack(spacing: compact ? 12 : 20) {
            certificate
                .frame(width: compact ? 440 : 680, height: compact ? 300 : 470)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 16, y: 8)

            HStack(spacing: 14) {
                if let rendered {
                    ShareLink(item: rendered,
                              preview: SharePreview("Certificate of Mastery", image: rendered)) {
                        Label("Share / Print", systemImage: "square.and.arrow.up")
                            .font(Theme.Font.display(18)).padding(.horizontal, 20).padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent).tint(Theme.Color.primary)
                }
                Button("Done") { dismiss() }
                    .font(Theme.Font.display(18)).padding(.horizontal, 20).padding(.vertical, 14)
                    .buttonStyle(.bordered)
            }
        }
        .padding(Theme.Metric.pad)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.bg)
        .onAppear(perform: render)
    }

    private func render() {
        let r = ImageRenderer(content: certificate.frame(width: 1360, height: 940))
        r.scale = 2
        #if canImport(UIKit)
        if let ui = r.uiImage { rendered = Image(uiImage: ui) }
        #endif
    }

    /// The renderable certificate artwork. When the generated `certificate_bg`
    /// asset exists (ornate frame + trophy baked into the art, empty center
    /// band for text), it becomes the whole page and we only overlay the text;
    /// until then a drawn parchment stands in.
    private var certificate: some View {
        ZStack {
            if Art.exists("certificate_bg") {
                Color.clear
                    .overlay(Image("certificate_bg").resizable().scaledToFill())
                    .clipped()
            } else {
                LinearGradient(colors: [Color(hex: "#FFF9EC"), Color(hex: "#FBE7C2")],
                               startPoint: .top, endPoint: .bottom)
                RoundedRectangle(cornerRadius: 12).strokeBorder(
                    LinearGradient(colors: [Self.gold, Self.goldDeep, Self.gold],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 8).padding(14)
                RoundedRectangle(cornerRadius: 8).strokeBorder(Self.gold.opacity(0.45), lineWidth: 2)
                    .padding(24)
            }

            VStack(spacing: compact ? 5 : 10) {
                // Trophy: baked into certificate_bg art when present; drawn gold
                // SF trophy on the interim parchment.
                if !Art.exists("certificate_bg") {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: compact ? 36 : 62))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 1, green: 0.85, blue: 0.35),
                                     Color(red: 0.95, green: 0.63, blue: 0.1)],
                            startPoint: .top, endPoint: .bottom))
                        .shadow(color: Self.gold.opacity(0.5), radius: 8, y: 3)
                        .padding(.bottom, 2)
                }
                // Every internal element is compact-scaled, not just the outer
                // frame — the frame alone shrinking (680→440pt wide) while text
                // stayed full-size was what clipped "CERTIFICATE OF MASTERY" to
                // "CERTIFICATE OF MA…" and pushed it into the trophy icon.
                Text("CERTIFICATE OF MASTERY")
                    .font(Theme.Font.label(compact ? 13 : 22)).tracking(compact ? 2 : 5)
                    .lineLimit(1).minimumScaleFactor(0.7)
                    .foregroundStyle(Theme.Color.ink)
                Text("This certifies that")
                    .font(Theme.Font.body(compact ? 11 : 15)).foregroundStyle(Theme.Color.inkSoft)

                Text(name)
                    .font(Theme.Font.display(compact ? 26 : 44))
                    .foregroundStyle(Theme.Color.primary)
                    .lineLimit(1).minimumScaleFactor(0.6)

                Text("has mastered all \(FactUniverse.count) addition facts —\nsums from 0+0 to \(FactUniverse.maxFactor)+\(FactUniverse.maxFactor) — and conquered the Seven Worlds.")
                    .multilineTextAlignment(.center)
                    .font(Theme.Font.body(compact ? 11 : 16))
                    .foregroundStyle(Theme.Color.ink)

                // Earned stats + date.
                HStack(spacing: compact ? 10 : 20) {
                    statBadge("star.fill", "\(profile?.questStars ?? 0) stars")
                    statBadge("bolt.fill", "best streak \(profile?.bestStreak ?? 0)")
                    statBadge("calendar", Date().formatted(date: .abbreviated, time: .omitted))
                }
                .padding(.top, compact ? 4 : 8)
            }
            .padding(.horizontal, compact ? 40 : 90).padding(.vertical, compact ? 16 : 40)
        }
    }

    private func statBadge(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: compact ? 10 : 13, weight: .semibold))
                .foregroundStyle(Self.goldDeep)
            Text(text).font(Theme.Font.label(compact ? 10 : 14)).foregroundStyle(Theme.Color.inkSoft)
        }
    }
}
