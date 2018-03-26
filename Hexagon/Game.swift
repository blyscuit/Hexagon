//
//  Game.swift
//  Hexagon
//
//  Created by Bliss Watchaye on 2018-03-22.
//  Copyright © 2018 confusians. All rights reserved.
//
enum ColorCode: Int {
	case red, blue, yellow, green, black
}
enum TurnState: Int {
	case chooseCard, choosePawn, chooseMove, kill, changeColor, turnEnd
	static var count: Int { return TurnState.turnEnd.hashValue + 1}
}
import Foundation
class Game {
	let startPosition = ["2": [[[0,-4,4], [1,-4,3], [-1, -3, 4]], [[0,4,-4], [-1,4,-3], [1, 3, -4]]], "3": [[[0,4,-4], [-1,4,-3], [1, 3, -4]], [[-4,0,4], [-4,1,3], [-3, -1, 4]], [[4,-4,0], [3,-4,1], [4, -3, -1]] ], "4": [[[0,-4,4],[1,-4,3]], [[-4,0,4],[-4,1,3]],[[0,4,-4], [-1,4,-3]],[[4, 0,-4],[4,-1,-3]]]]
	var gameGrid: [[[Int]]]!
	var color = [14, 14, 14, 14, 5]
	var players: [Player] = []
	var turn = 0
	var nowTurnState = 0
	var mainDeck: Deck!
	init(players: Int) {
		reset(players: players)
	}
	
	func reset(players: Int) {
		mainDeck = Deck()
		var grid: [[[Int]]]! = []
		for i in -4...4 {
			grid.append([])
			for j in -4...4 {
				grid[i+4].append([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1])
				for k in -4...4 {
					if i+j+k == 0 {
						var dice: Int!
						while dice == nil || color[dice] == 0 {
							dice = Int(arc4random_uniform(UInt32(color.count)))
							if (abs(k) == 4 || abs(j) == 4 || abs(i) == 4) && dice == color.count-1 {
								dice = nil
							}
						}
						grid[i+4][j+4][k+4] = dice
						color[dice]-=1
					}
				}
			}
		}
		let startPositionStuff = self.startPosition[String(players)]
		self.players = []
		for i in 0..<players {
			self.players.append(Player(location: startPositionStuff![i], deck: mainDeck, color:i))
		}
		self.players.shuffle()
		gameGrid = grid
	}
	
	func changeColorAt(i: Int, j: Int, k: Int, to: Int) {
		gameGrid[i][j][k] = to
	}
	
	func nextState() -> [String: Int] {
		nowTurnState = (nowTurnState+1)
		if nowTurnState == TurnState.turnEnd.rawValue {
			nowTurnState = 0
			turn = (turn + 1) % players.count
		}
		if nowTurnState == 0 && turn == 0 && players[turn].hand.count <= 2 {
			for player in players {
				player.fullHandFrom(deck: mainDeck)
			}
		}
		return ["turn": nowTurnState, "color": turn]
	}
	
	func listCurrentPlayerCards() -> [Int] {
		return players[turn].hand
	}
	
	func currentPlayerThrowCard(index: Int) {
		players[turn].useCard(index: index)
	}
	var currentHex: HexCoor!
	func currentPlayerSelectPawn(hex: HexCoor) {
		currentHex = hex
		print("\(currentHex.hexX) \(currentHex.hexY) \(currentHex.hexZ)")
	}
	func currentPlayerSelectMove(hex: HexCoor) {
		var i = 0
		for location in players[turn].location {
			if location.elementsEqual([currentHex.hexX, currentHex.hexY, currentHex.hexZ]) {
				players[turn].location[i] = [hex.hexX, hex.hexY, hex.hexZ]
				break
			}
			i += 1
		}
	}
	
	func removePawnAt(x: Int, y: Int, z: Int) {
		for player in players {
			let result = player.removePawn(killLocation: [x, y, z])
			if result["kill"]! == 1 {
				players[turn].score += 1
			}
		}
	}
	
	func getCurrentPlayerColor() -> Int {
		return players[turn].color
	}
	
	func getCrrentPlayer() -> Player {
		return players[turn]
	}
	
	func checkCurrentPlayerPawnLocation(x: Int, y: Int, z: Int) -> Bool {
		for location in players[turn].location {
			if location.elementsEqual([x, y, z]) {
				return true
			}
		}
		return false
	}
	
	func checkAvailablePawnLocation(x: Int, y: Int, z: Int) -> Bool {
		if gameGrid[x+4][y+4][z+4] != ColorCode.black.rawValue {
			for player in players {
				for location in player.location {
					if location.elementsEqual([x, y, z]) {
						return false
					}
				}
			}
			return true
		} else {
			return false
		}
	}
}

class Deck {
	var cards: [Int]! = []
	let startCards = [20,20,20,20]
	
	init() {
		reshuffle()
	}
	
	func reshuffle() {
		for i in 0..<self.startCards.count {
			for j in 0..<startCards[i] {
				cards.append(i)
			}
		}
		cards.shuffle()
	}
	
	func drawTop() -> Int {
		if cards.count <= 0 {
			reshuffle()
		}
		return cards.removeFirst()
	}
}

class Player {
	var hand: [Int] = []
	var location: [[Int]] = []
	var score = 0
	var color: Int!
	init(location: [[Int]]) {
		self.location = location
	}
	
	init(location: [[Int]], deck: Deck, color: Int) {
		self.location = location
		fullHandFrom(deck: deck)
		self.color = color
	}
	
	func drawFrom(deck: Deck) {
		hand.append(deck.drawTop())
	}
	
	func useCard(index: Int) {
		hand.remove(at: index)
	}
	
	func fullHandFrom(deck: Deck) {
		hand = []
		for i in 0..<6 {
			hand.append(deck.drawTop())
		}
	}
	
	func removePawn(killLocation:[Int]) -> [String: Int] {
		var i = 0
		for location in self.location {
			if location[0] == killLocation[0] && location[1] == killLocation[1] && location[2] == killLocation[2] {
				self.location.remove(at: i)
				return ["kill": 1, "life": self.location.count]
			}
			i += 1
		}
		return ["kill": 0, "life": self.location.count]
	}
}

extension MutableCollection {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
}

extension Sequence {
	/// Returns an array with the contents of this sequence, shuffled.
	func shuffled() -> [Element] {
		var result = Array(self)
		result.shuffle()
		return result
	}
}
