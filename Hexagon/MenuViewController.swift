//
//  ViewController.swift
//  Hexagon
//
//  Created by Bliss Watchaye on 2018-03-22.
//  Copyright © 2018 confusians. All rights reserved.
//

import UIKit

var globalPlayerCount = 2

class MenuViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		switch identifier {
		case "p2":
			globalPlayerCount = 2
		case "p3":
			globalPlayerCount = 3
		case "p4":
			globalPlayerCount = 4
		default:
			globalPlayerCount = 2
		}
		return true
	}
}

class HexButton: UIButton {
	var hexX: Int!
	var hexY: Int!
	var hexZ: Int!
	var hexColor: Int!
	var wasHexColor: Int!
}

struct HexCoor {
	var hexX: Int!
	var hexY: Int!
	var hexZ: Int!
	init(x: Int, y: Int, z: Int) {
		hexX = x
		hexY = y
		hexZ = z
	}
	init(arr: [Int]) {
		hexX = arr[0]
		hexY = arr[1]
		hexZ = arr[2]
	}
	
	func match(x: Int, y: Int, z: Int) -> Bool {
		if z == hexZ && y == hexY && hexX == x {
			return true
		}
		return false
	}
	
	func match(hex: HexCoor?) -> Bool {
		guard let hex = hex else {
			return false
		}
		if hex.hexZ == hexZ && hex.hexY == hexY && hexX == hex.hexX {
			return true
		}
		return false
	}
}

extension UIImage {
	
	func maskWithColor(color: UIColor) -> UIImage? {
		let maskImage = cgImage!
		
		let width = size.width
		let height = size.height
		let bounds = CGRect(x: 0, y: 0, width: width, height: height)
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
		
		context.clip(to: bounds, mask: maskImage)
		context.setFillColor(color.cgColor)
		context.fill(bounds)
		
		if let cgImage = context.makeImage() {
			let coloredImage = UIImage(cgImage: cgImage)
			return coloredImage
		} else {
			return nil
		}
	}
	
}
