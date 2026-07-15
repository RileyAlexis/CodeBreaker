//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by RileyAlexis on 7/14/26.
//

import SwiftUI

extension Peg {
    var displayColor: Color {
        switch self {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "brown": return .brown
        case "orange": return .orange
        case "mint": return .mint
        case "purple": return .purple
        case "pink": return .pink
        case Code.missingPeg: return .clear
        default: return .gray
        }
    }
}

struct CodeBreakerView: View {
    @State var game: CodeBreaker = .init(
        //        pegChoices: ["🦣", "🐋", "🦜", "🦨", "🦢", "🐓"],
        pegChoices: ["pink", "green", "blue", "yellow", "purple", "orange"],
        difficulty: 4,
        pegStyle: .color
    )
    @State private var shakeAttempts: CGFloat = 0

    var body: some View {
        VStack {
            view(for: game.masterCode)
            ScrollView {
                view(for: game.guess)
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
                }
            }
            HStack {
                Button("Restart") {
                    game = CodeBreaker(
                        pegChoices: game.pegChoices,
                        difficulty: game.difficulty,
                        pegStyle: game.pegStyle
                    )
                }
                Picker("Difficulty", selection: $game.difficulty) {
                    Text("Easy").tag(4)
                    Text("Medium").tag(5)
                    Text("Hard").tag(6)
                }.pickerStyle(.automatic)
                    .onChange(of: game.difficulty) {
                        withAnimation(.none) {
                            game = CodeBreaker(
                                pegChoices: game.pegChoices,
                                difficulty: game.difficulty,
                                pegStyle: game.pegStyle
                            )
                        }
                    }
            }
        }
    }

    var guessButton: some View {
        Button("Guess") {
            withAnimation {
                let result = game.attemptGuess()
                if !result {
                    withAnimation(.default) {
                        shakeAttempts += 1
                    }
                }
            }
        }.font(.system(size: 80))
            .minimumScaleFactor(0.1)
            .modifier(Shake(animatableData: shakeAttempts))
    }

    func view(for code: Code) -> some View {
        HStack {
//            if let @Environment(\.menuOrder)
            ForEach(code.pegs.indices, id: \.self) { index in
                Group {
                    switch game.pegStyle {
                    case .color:
                        RoundedRectangle(cornerRadius: 10)
                            .overlay {
                                if code.pegs[index] == Code.missingPeg {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.gray)
                                }
                            }
                            .foregroundStyle(code.pegs[index].displayColor)
                    case .emoji:
                        Text(code.pegs[index] == Code.missingPeg ? "" : code.pegs[index])
                            .font(.system(size: 40))
                            .minimumScaleFactor(0.1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay {
                                if code.pegs[index] == Code.missingPeg {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.gray)
                                }
                            }
                    }
                }
                .contentShape(Rectangle())
                .aspectRatio(1, contentMode: .fit)
                .onTapGesture {
                    if code.kind == .guess {
                        game.changeGuessPeg(at: index)
                    }
                }
            }
            Rectangle()
                .foregroundStyle(Color.clear)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
            if let matches = code.matches {
                MatchMarkers(matches: matches)
            } else {
                if code.kind == .guess {
                    guessButton
                }}
            }
        }
        .padding()
    }

    struct Shake: GeometryEffect {
        var amount: CGFloat = 5
        var shakesPerUnit = 3
        var animatableData: CGFloat

        func effectValue(size _: CGSize) -> ProjectionTransform {
            let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
            return ProjectionTransform(
                CGAffineTransform(translationX: translation, y: 0)
            )
        }
    }
}

#Preview {
    CodeBreakerView()
}
