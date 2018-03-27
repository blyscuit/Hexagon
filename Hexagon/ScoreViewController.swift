//
//  ScoreViewController.swift
//  Hexagon
//
//  Created by Bliss Watchaye on 2018-03-27.
//  Copyright © 2018 confusians. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
	var game: Game!
	var mainView: ViewController!
	@IBAction func backPress(_ sender: Any) {
		dismiss(animated: true, completion: {
			if self.game.gameOver {
				self.mainView!.dismiss(animated: true)
			}
		})
	}
}

extension ScoreViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return game.players.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// create a new cell if needed or reuse an old one
		let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
		
		// set the text from the data model
		cell.textLabel?.text = "Player \(indexPath.row+1)"
		cell.textLabel?.textColor = colorArray[game.players[indexPath.row].color]
		cell.detailTextLabel?.textColor = colorArray[game.players[indexPath.row].color]
		cell.detailTextLabel?.text = "\(game.players[indexPath.row].score)"
		
		return cell
	}
	
	
}
