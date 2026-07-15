//
//  CodeBreaker.swift
//  CodeBreaker
//
//  Created by RileyAlexis on 7/15/26.
//

import Foundation

typealias Peg = String

enum PegStyle {
    case color
    case emoji
}

struct CodeBreaker {
    var masterCode: Code
    var guess: Code
    var difficulty: Int
    var attempts: [Code] = []
    let pegChoices: [Peg]
    let pegStyle: PegStyle

    init(
        pegChoices: [Peg] = ["red", "green", "blue", "yellow"],
        difficulty: Int? = 4,
        pegStyle: PegStyle = .color
    ) {
        let resolvedDifficulty = difficulty ?? Int.random(in: 4 ... 6)
        self.pegChoices = pegChoices
        self.pegStyle = pegStyle
        self.difficulty = resolvedDifficulty
        masterCode = Code(kind: .masterCode, length: resolvedDifficulty)
        guess = Code(kind: .guess, length: resolvedDifficulty)
        masterCode.randomize(from: pegChoices)
        print(masterCode)
    }

    mutating func attemptGuess() -> Bool {
        var attempt = guess
        let isDuplicate = attempts.contains { $0.pegs == guess.pegs }
        let isMissing = guess.pegs.contains(Code.missingPeg)

        guard !isDuplicate else { return false }
        guard !isMissing else { return false }

        attempt.kind = .attempt(guess.match(against: masterCode))
        attempts.append(attempt)
        return true
    }

    mutating func changeGuessPeg(at index: Int) {
        let existingPeg = guess.pegs[index]
        if let indexOfExistingPegInPegChoices = pegChoices.firstIndex(
            of: existingPeg
        ) {
            let newPeg = pegChoices[(indexOfExistingPegInPegChoices + 1) % pegChoices.count]
            guess.pegs[index] = newPeg
        } else {
            guess.pegs[index] = pegChoices.first ?? Code.missingPeg
        }
    }
}

struct Code {
    var kind: Kind
    var pegs: [Peg]
    static let missingPeg: Peg = "clear"

    init(kind: Kind, length: Int) {
        self.kind = kind
        pegs = Array(repeating: Code.missingPeg, count: length)
    }

    enum Kind: Equatable {
        case masterCode
        case guess
        case attempt([Match])
        case unknown
    }

    mutating func randomize(from pegChoices: [Peg]) {
        for index in pegs.indices {
            pegs[index] = pegChoices.randomElement() ?? Code.missingPeg
        }
    }

    var matches: [Match]? {
        switch kind {
        case let .attempt(matches): return matches
        default: return nil
        }
    }

    func match(against otherCode: Code) -> [Match] {
        var pegsToMatch = otherCode.pegs

        let backExactMatches = pegs.indices.reversed().map { index in
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                pegsToMatch.remove(at: index)
                return Match.exact
            } else {
                return .nomatch
            }
        }
        let exactMatches = Array(backExactMatches.reversed())
        
        return pegs.indices.map { index in
            if exactMatches[index] != .exact, let matchIndex = pegsToMatch.firstIndex(of: pegs[index]) {
                        pegsToMatch.remove(at: matchIndex)
                        return Match.inexact
            } else {
                return exactMatches[index]
            }
        }
    }
}
