import SwiftUI

extension Color {
    static let emerald = Color(red: 16/255, green: 185/255, blue: 129/255)
    static let emeraldLight = Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.1)

    static let appBackground = Color(light: Color(red: 245/255, green: 247/255, blue: 245/255),
                                     dark: Color(red: 18/255, green: 18/255, blue: 18/255))

    static let cardBackground = Color(light: .white,
                                      dark: Color(red: 28/255, green: 28/255, blue: 30/255))

    static let inputBackground = Color(light: Color(red: 245/255, green: 245/255, blue: 245/255),
                                       dark: Color(red: 44/255, green: 44/255, blue: 46/255))
}

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
