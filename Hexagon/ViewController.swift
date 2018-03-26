//
//  ViewController.swift
//  Hexagon
//
//  Created by Bliss Watchaye on 2018-03-22.
//  Copyright © 2018 confusians. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var mainScrollView: UIScrollView!
	@IBOutlet weak var mainLabel: UILabel!
	@IBOutlet weak var mainButton: UIButton!
	@IBOutlet weak var cardCollection: UICollectionView!
	
	var hexSize = [66,52]
	
	var throwingIndex: Int! = -1
	var game: Game!
	
	var currentPlayerUsingPower = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		cardCollection.dataSource = self
		cardCollection.delegate = self
		print(globalPlayerCount)
		self.game = Game(players: globalPlayerCount)
		// Do any additional setup after loading the view, typically from a nib.
		mainLabel.text = "Choose a card to play"
		reColor()
		generateHex()
		mainScrollView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//		mainScrollView.scrollIndicatorInsets = mainScrollView.contentInset
	}
	
	func generateHex() {
		for v in mainScrollView.subviews{
			v.removeFromSuperview()
		}
		for i in -4...4 {
			for j in -4...4 {
				for k in -4...4 {
					if game.gameGrid[i+4][j+4][k+4] != -1 {
						var left = abs(k) + (i+4)*2
						if k < 0 {
							left = abs(k) + (-j+4)*2
						}
						let button: HexButton = HexButton(frame: CGRect(x: left*hexSize[0]/2, y: hexSize[1]*(k+4), width: hexSize[0], height: hexSize[0]))
						button.hexX = i
						button.hexY = j
						button.hexZ = k
						button.hexColor = game.gameGrid[i+4][j+4][k+4]
						var myImage = UIImage(named: "hexagonal")
						switch button.hexColor {
						case ColorCode.red.rawValue:
							myImage = myImage?.maskWithColor(color: UIColor.red)
						case ColorCode.green.rawValue:
							myImage = myImage?.maskWithColor(color: UIColor.green)
						case ColorCode.yellow.rawValue:
							myImage = myImage?.maskWithColor(color: UIColor.yellow)
						case ColorCode.blue.rawValue:
							myImage = myImage?.maskWithColor(color: UIColor.blue)
						default:
							myImage = myImage?.maskWithColor(color: UIColor.black)
						}
						button.setImage(myImage, for: .normal)
						button.addTarget(self, action:#selector(self.doSomething(sender:)), for: .touchUpInside)
						self.mainScrollView.addSubview(button)
						
						for player in game.players {
							for position in player.location {
								if position[0] == i && position[1] == j && position[2] == k {
									let pawn: UIImageView = UIImageView(frame: CGRect(x: Double(hexSize[0])/5.0, y: Double(hexSize[0])/5.0, width: Double(hexSize[0])/1.7, height: Double(hexSize[0])/1.7))
									pawn.contentMode = .scaleAspectFit
									switch player.color {
									case ColorCode.red.rawValue:
										pawn.image = UIImage(named: "pawn-r")
									case ColorCode.green.rawValue:
										pawn.image = UIImage(named: "pawn-g")
									case ColorCode.yellow.rawValue:
										pawn.image = UIImage(named: "pawn-y")
									case ColorCode.blue.rawValue:
										pawn.image = UIImage(named: "pawn-b")
									default:
										break
									}
									button.addSubview(pawn)
								}
							}
						}
					}
				}
			}
		}
		mainScrollView.contentSize = CGSize(width: hexSize[0]*9, height: hexSize[1]*9)
	}
	
	@objc func doSomething(sender: HexButton) {
		self.generateHex()
		print("\(sender.hexX) \(sender.hexY) \(sender.hexZ)")
	}
	
	func reColor() {
		switch game.getCurrentPlayerColor() {
		case ColorCode.red.rawValue:
			mainLabel.textColor = UIColor.red
		case ColorCode.green.rawValue:
			mainLabel.textColor = UIColor.green
		case ColorCode.yellow.rawValue:
			mainLabel.textColor = UIColor.yellow
		case ColorCode.blue.rawValue:
			mainLabel.textColor = UIColor.blue
		default:
			mainLabel.textColor = UIColor.white
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func mainButtonPress(_ sender: Any) {
		switch game.nowTurnState {
		case TurnState.chooseCard.rawValue:
			if throwingIndex != -1 {
				mainButton.setTitle("Confirm", for: .normal)
				game.currentPlayerThrowCard(index: throwingIndex)
				throwingIndex = -1
			} else {
				return
			}
		case TurnState.chooseMove.rawValue:
			break
		case TurnState.changeColor.rawValue:
			break
		case TurnState.kill.rawValue:
			break
		case TurnState.choosePawn.rawValue:
			break
		default:
			break
		}
		let newRound = game.nextState()
		switch newRound["turn"]! {
		case TurnState.chooseCard.rawValue:
			mainLabel.text = "Choose a card to play"
		case TurnState.chooseMove.rawValue:
			mainLabel.text = "Choose a position to move to"
			break
		case TurnState.changeColor.rawValue:
			mainLabel.text = "Choose areas to change color"
			break
		case TurnState.kill.rawValue:
			mainLabel.text = "Choose a pawn to kill"
			break
		case TurnState.choosePawn.rawValue:
			mainLabel.text = "Choose a pawn to change move"
			break
		default:
			break
		}
		reColor()
		cardCollection.reloadData()
	}
	
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return game.listCurrentPlayerCards().count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
													  for: indexPath)
		let currentHand = game.listCurrentPlayerCards()
		var bColor = UIColor.white
		switch currentHand[indexPath.row] {
		case ColorCode.red.rawValue:
			bColor = UIColor.red
		case ColorCode.green.rawValue:
			bColor = UIColor.green
		case ColorCode.yellow.rawValue:
			bColor = UIColor.yellow
		case ColorCode.blue.rawValue:
			bColor = UIColor.blue
		default:
			bColor = UIColor.white
		}
		cell.backgroundColor = bColor
		// Configure the cell
		if throwingIndex == indexPath.row {
			cell.layer.cornerRadius = cell.frame.size.width/2
		} else {
			cell.layer.cornerRadius = 10
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if game.nowTurnState != TurnState.chooseCard.rawValue {
			return
		}
		if throwingIndex == indexPath.row {
			currentPlayerUsingPower = !currentPlayerUsingPower
		}
		if currentPlayerUsingPower {
			mainButton.setTitle("Use Power", for: .normal)
		} else {
			mainButton.setTitle("Confirm", for: .normal)
		}
		throwingIndex = indexPath.row
		collectionView.reloadData()
	}
	
}
