import SwiftUI

struct CustomDivider: View {
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 52)
            Rectangle()
                .fill(Color.gray)
                .frame(height: 0.5)
        }
    }
}

struct CustomDivider_Previews: PreviewProvider {
    static var previews: some View {
        CustomDivider()
    }
}
