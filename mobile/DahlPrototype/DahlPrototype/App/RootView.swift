import SwiftUI

struct RootView: View {
    @State private var shopStore = ShopStore()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            MyDayView()
                .tabItem {
                    Label("My Day", systemImage: "calendar")
                }
                .tag(1)
            ECommerceView()
                .tabItem {
                    Label("Shop", systemImage: "cart")
                }
                .tag(2)
            WorkAssistantView()
                .tabItem {
                    Label("Assistant", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(3)
        }
        .environment(shopStore)
    }
}

#Preview {
    RootView()
}
