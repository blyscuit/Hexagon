//
//  ViewController.swift
//  Hexagon
//
//  Created by Bliss Watchaye on 2018-03-22.
//  Copyright © 2018 confusians. All rights reserved.
//

import UIKit
//ase red, blue, yellow, green, black
var colorArray = [UIColor(hexString: "#A90027"), UIColor(hexString: "#8FA6D4"), UIColor(hexString: "#F5C14D"), UIColor(hexString: "#76B746"), UIColor(hexString: "#111111")]

class ViewController: UIViewController {
	@IBOutlet weak var mainScrollView: UIScrollView!
	@IBOutlet weak var mainLabel: UILabel!
	@IBOutlet weak var mainButton: UIButton!
	@IBOutlet weak var cardCollection: UICollectionView!
	
	
	var hexSize = [66,52]
	
	var throwingIndex: Int! = -1
	var game: Game!
	var selectedCoordinate: HexCoor? = nil
	
	var currentPlayerUsingPower = false
	
	var changingColorHex: [HexCoor] = []
	
	var spinningIcon: NVActivityIndicatorView!
	
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
						let hexLocation = atHexLocation(i: i, j: j, k: k)
						let button: HexButton = HexButton(frame: CGRect(x: Int(hexLocation.x), y: Int(hexLocation.y), width: hexSize[0], height: hexSize[0]))
						button.hexX = i
						button.hexY = j
						button.hexZ = k
						button.hexColor = game.gameGrid[i+4][j+4][k+4]
						var myImage = UIImage(named: "hexagonal")
						let nowColor = button.hexColor
						myImage = myImage?.maskWithColor(color: colorArray[button.hexColor])
						button.setImage(myImage, for: .normal)
						button.addTarget(self, action:#selector(self.tapHex(sender:)), for: .touchUpInside)
						self.mainScrollView.addSubview(button)
						
						for player in game.players {
							for position in player.location {
								if position[0] == i && position[1] == j && position[2] == k {
									let pawn: UIImageView = UIImageView(frame: CGRect(x: Double(hexSize[0])/2.5, y: Double(hexSize[0])/5.0, width: Double(hexSize[0])/(1.7*3.43), height: Double(hexSize[0])/1.7))
									pawn.contentMode = .scaleAspectFill
									pawn.backgroundColor = UIColor.white
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
						var spinningLocation = atHexLocation(i: 0, j: 0, k: 0)
						spinningIcon = NVActivityIndicatorView(frame: CGRect(x: Double(spinningLocation.x)+Double(hexSize[0])/5.0, y: Double(spinningLocation.y)+Double(hexSize[0])/5.0, width: Double(hexSize[0])/1.4, height: Double(hexSize[0])/1.4), type: .ballScaleMultiple, color: .white, padding: 0)
						spinningIcon.isUserInteractionEnabled = false
						mainScrollView.addSubview(spinningIcon)
						if let coor = selectedCoordinate {
							moveSpinning()
							spinningIcon.startAnimating()
						} else {
							spinningIcon.stopAnimating()
						}
					}
				}
			}
		}
		mainScrollView.contentSize = CGSize(width: hexSize[0]*9, height: hexSize[1]*9)
	}
	
	@objc func tapHex(sender: HexButton) {
		print("\(sender.hexX) \(sender.hexY) \(sender.hexZ)")
		if game.nowTurnState == TurnState.changeColor.rawValue {
			game.currentPlayerchangeColorAt(coor: HexCoor(x: sender.hexX, y: sender.hexY, z: sender.hexZ))
			self.generateHex()
		} else {
			let newCoor = HexCoor(x: sender.hexX, y: sender.hexY, z: sender.hexZ)
			if newCoor.match(hex: self.selectedCoordinate) {
				self.selectedCoordinate = nil
			} else {
				self.selectedCoordinate = newCoor
			}
		}
		if self.selectedCoordinate != nil {
			moveSpinning()
			spinningIcon.startAnimating()
		} else {
			spinningIcon.stopAnimating()
		}
	}
	
	func reColor() {
		mainLabel.textColor = colorArray[game.getCurrentPlayerColor()]
		mainButton.backgroundColor = colorArray[game.getCurrentPlayerColor()]
	}
	
	func atHexLocation(i: Int, j: Int, k: Int) -> CGPoint {
		var left = abs(k) + (i+4)*2
		if k < 0 {
			left = abs(k) + (-j+4)*2
		}
		return CGPoint(x: left*hexSize[0]/2, y: hexSize[1]*(k+4))
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
				game.currentPlayerThrowCard(index: throwingIndex, useSkill: currentPlayerUsingPower)
				throwingIndex = -1
				currentPlayerUsingPower = false
				cardCollection.isUserInteractionEnabled = false
			} else {
				return
			}
		case TurnState.choosePawn.rawValue:
			if let selectCoor = self.selectedCoordinate {
				if game.checkCurrentPlayerPawnLocation(x: selectCoor.hexX, y: selectCoor.hexY, z: selectCoor.hexZ) {
					game.currentPlayerSelectPawn(hex: selectCoor)
				} else {
					return
				}
				self.selectedCoordinate = nil
				spinningIcon.stopAnimating()
			} else {
				return
			}
		case TurnState.chooseMove.rawValue:
			if let selectCoor = self.selectedCoordinate {
				if game.checkAvailablePawnLocation(x: selectCoor.hexX, y: selectCoor.hexY, z: selectCoor.hexZ) {
					game.currentPlayerSelectMove(hex: selectCoor)
				} else {
					return
				}
				self.selectedCoordinate = nil
				spinningIcon.stopAnimating()
				self.generateHex()
			} else {
				return
			}
		case TurnState.changeColor.rawValue:
			game.confirmColorChange()
			break
		case TurnState.kill.rawValue:
			if let selectCoor = self.selectedCoordinate {
				if !game.checkAvailablePawnLocation(x: selectCoor.hexX, y: selectCoor.hexY, z: selectCoor.hexZ) {
					game.removePawnAt(x: selectCoor.hexX, y: selectCoor.hexY, z: selectCoor.hexZ)
				} else {
					return
				}
				self.selectedCoordinate = nil
				spinningIcon.stopAnimating()
				self.generateHex()
				if game.gameOver {
					performSegue(withIdentifier: "iden", sender: self)
				}
			} else {
			}
			break
		default:
			break
		}
		let newRound = game.nextState()
		switch newRound["turn"]! {
		case TurnState.chooseCard.rawValue:
			mainLabel.text = "Choose a card to play"
			cardCollection.isUserInteractionEnabled = true
			cardCollection.reloadData()
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
	}
	
	func moveSpinning() {
		if let coor = selectedCoordinate {
			let spinningLocation = atHexLocation(i: coor.hexX, j: coor.hexY, k: coor.hexZ)
			spinningIcon.frame = CGRect(x: Double(spinningLocation.x)+Double(hexSize[0])/5.0, y: Double(spinningLocation.y)+Double(hexSize[0])/5.0, width: Double(hexSize[0])/1.7, height: Double(hexSize[0])/1.7)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "iden" {
			let nav = segue.destination as! ScoreViewController
			nav.game = game
			nav.mainView = self
		}
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
		bColor = colorArray[currentHand[indexPath.row]]
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

extension UIColor {
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt32()
		Scanner(string: hex).scanHexInt32(&int)
		let a, r, g, b: UInt32
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
}
