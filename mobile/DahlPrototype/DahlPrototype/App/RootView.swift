import SwiftUI

struct RootView: View {
    @State private var shopStore = ShopStore()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            MyDayView()
                .tabItem {
                    Label("My Day", systemImage: "calendar")
                }
            ECommerceView()
                .tabItem {
                    Label("Shop", systemImage: "cart")
                }
            WorkAssistantView()
                .tabItem {
                    Label("Assistant", systemImage: "bubble.left.and.bubble.right")
                }
        }
        .environment(shopStore)
    }
}

#Preview {
    RootView()
}
