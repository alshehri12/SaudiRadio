import SwiftUI

// Extend the Color struct to add our custom Saudi Green color
extension Color {
    static let saudiGreen = Color(red: 0/255, green: 106/255, blue: 58/255)
}

// You can also define it as a separate constant if you prefer,
// but extending Color is common practice for reusable colors.
// struct AppColors {
//     static let saudiGreen = Color(red: 0/255, green: 106/255, blue: 58/255)
// }
// If you use the struct approach, you'd call it like AppColors.saudiGreen
