//
//  MatchMarkers.swift
//  CodeBreaker
//
//  Created by RileyAlexis on 7/14/26.
//

import SwiftUI

struct MatchMarkers: View {
    var matches: [Match]
    
    var body: some View {
        HStack {
            
            VStack {
                matchMarker(peg: 0)
                matchMarker(peg: 1)

            }
            VStack {
                matchMarker(peg: 2)
                matchMarker(peg: 3)
            }
            VStack {
                matchMarker(peg: 4)
                matchMarker(peg: 5)
            }
        }
        
    }
    
    func matchMarker(peg: Int) -> some View {
        let exactCount = matches.count { $0 == .exact}
        let foundCount: Int = matches.count(where: {match in match != .nomatch})
        return Circle()
            .fill(exactCount > peg ? Color.primary : Color.clear)
            .strokeBorder(foundCount > peg ? Color.primary : Color.clear,
                lineWidth: 2).aspectRatio(1, contentMode: .fit)
    }
}

enum Match {
    case nomatch
    case exact
    case inexact
}

#Preview {
    MatchMarkers(matches: [.exact, .inexact, .inexact, .exact])
}
