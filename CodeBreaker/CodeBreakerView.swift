//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by RileyAlexis on 7/14/26.
//

import SwiftUI

struct CodeBreakerView: View {
    @State var game: CodeBreaker = CodeBreaker(
        pegChoices: [.brown, .yellow, .orange, .mint, .purple, .pink],
        difficulty: 4
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
                        difficulty: game.difficulty
                    )
                }
                Picker("Difficulty", selection: $game.difficulty) {
                    Text("Easy").tag(4)
                    Text("Medium").tag(5)
                    Text("Hard").tag(6)
                }.pickerStyle(.menu)
                    .onChange(of: game.difficulty) {
                        game = CodeBreaker(
                            pegChoices: game.pegChoices,
                            difficulty: game.difficulty
                        )
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
            ForEach(code.pegs.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 10)
                    .overlay {
                        if code.pegs[index] == Code.missing {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(code.pegs[index])
                    .onTapGesture {
                        if code.kind == .guess {
                            game.changeGuessPeg(at: index)
                        }
                    }
            }
            MatchMarkers(matches: code.matches)
                .overlay {
                    if code.kind == .guess {
                        guessButton
                    }
                }

            
        }.padding()
    }

}

struct Shake: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
        return ProjectionTransform(
            CGAffineTransform(translationX: translation, y: 0)
        )
    }
}


    
    #Preview {
        CodeBreakerView()
    }

