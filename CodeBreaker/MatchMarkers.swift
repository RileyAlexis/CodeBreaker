struct MatchMarkers: View {
    var body: some View {
        HStack {
            VStack {
                Circle().fill()
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 3)
                    .aspectRatio(1, contentMode: .fit)
            }
            VStack {
                Circle()
                Circle().opacity(0)
            }
        }
    }