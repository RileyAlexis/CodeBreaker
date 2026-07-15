//
//  CodeBreaker.swift
//  CodeBreaker
//
//  Created by RileyAlexis on 7/15/26.
//

import SwiftUI

typealias Peg = Color

struct CodeBreaker {
    var masterCode: Code
    var guess: Code
    var difficulty: Int
    var attempts: [Code] = []
    let pegChoices: [Peg]
    
    init (pegChoices: [Peg] = [.red, .green, .blue, .yellow], difficulty: Int = 4) {
        self.pegChoices = pegChoices
        self.difficulty = difficulty
        self.masterCode = Code(kind: .masterCode, length: difficulty)
        self.guess = Code(kind: .guess, length: difficulty)
        masterCode.randomize(from: pegChoices)
        print(masterCode)
    }
    
    
    mutating func attemptGuess() -> Bool {
        var attempt = guess
        let isDuplicate = attempts.contains { $0.pegs == guess.pegs }
        let isMissing = guess.pegs.contains(Code.missing)
        
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
            guess.pegs[index] = pegChoices.first ?? Code.missing
        }
    }
}

struct Code {
    var kind: Kind
    var pegs: [Peg]
    static let missing: Peg = .clear
    
    init(kind: Kind, length: Int) {
        self.kind = kind
        self.pegs = Array(repeating: Code.missing, count: length)
    }
    
    
    
    enum Kind: Equatable {
        case masterCode
        case guess
        case attempt([Match])
        case unknown
    }
    
    mutating func randomize(from pegChoices: [Peg]) {
        for index in pegs.indices {
            pegs[index] = pegChoices.randomElement() ?? Code.missing
        }
    }
    
    var matches: [Match] {
        switch kind {
        case .attempt(let matches): return matches
        default: return []
        }
    }
    
    
    func match(against otherCode: Code) -> [Match] {
        var results: [Match] = Array(repeating: .nomatch, count: pegs.count)
        var pegsToMatch = otherCode.pegs
        for index in pegs.indices.reversed() {
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                results[index] = .exact
                pegsToMatch.remove(at: index)
            }
        }
        
        for index in pegs.indices {
            if results[index] != .exact {
                if let matchindex = pegsToMatch.firstIndex(of: pegs[index]) {
                    results[index] = .inexact
                    pegsToMatch.remove(at: matchindex)
                }
            }
        }
        return results
    }
}
