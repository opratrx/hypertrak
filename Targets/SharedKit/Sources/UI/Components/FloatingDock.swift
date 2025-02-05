import SwiftUI

public struct FloatingDock: View {
    @Binding public var selectedTab: Int
    
    public init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 32) {
            TabButton(
                icon: "house.fill",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            TabButton(
                icon: "bolt.fill",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            TabButton(
                icon: "person.fill",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            #if DEBUG
            TabButton(
                icon: "lock.shield.fill",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
            #endif
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
        }
        .padding(.bottom, 8)
    }
}

private struct TabButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(width: 44, height: 44)
                .background {
                    if isSelected {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .primary.opacity(0.2), radius: 8, x: 0, y: 2)
                    }
                }
                .animation(.spring(response: 0.3), value: isSelected)
        }
    }
}

