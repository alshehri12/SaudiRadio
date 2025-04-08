import SwiftUI

struct CategoryButton: View {
    let category: StationCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.accentColor : Color(category.color))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        CategoryButton(category: .news, isSelected: false, action: {})
        CategoryButton(category: .music, isSelected: true, action: {})
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
