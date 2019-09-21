//
//  LevelsViewController.swift
//  ChamomileGame
//
//  Created by Денис Марков on 3/4/19.
//  Copyright © 2019 Денис Марков. All rights reserved.
//

import UIKit

fileprivate let levelCellReuseIdentifier = "levelCellReuseIdentifier"
fileprivate let levelCellNibName = "LevelCollectionViewCell"

class LevelsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetButton: UIButton! {
        didSet {
            resetButton.layer.cornerRadius = 8
            resetButton.layer.masksToBounds = true
            resetButton.layer.borderColor = UIColor.white.cgColor
            resetButton.layer.borderWidth = 1
            resetButton.addTarget(self, action: #selector(resetButtonDidTap), for: .touchUpInside)
        }
    }
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tapToPlayButton: UIButton! {
        didSet {
            tapToPlayButton.addTarget(self, action: #selector(tapToPlayButtonDidTap), for: .touchUpInside)
        }
    }
    
    var levels: [Level] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        checkFirstStart()
        collectionView.register(UINib(nibName: levelCellNibName, bundle: nil), forCellWithReuseIdentifier: levelCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        createLevels()
        loadOpenLevels()
        collectionView.reloadData()
    }
    
    func checkFirstStart() {
        if !UserDefaults.standard.bool(forKey: "first_start") {
            darkView.isHidden = false
            setResultLabel()
            UserDefaults.standard.set(true, forKey: "first_start")
        } else {
            darkView.isHidden = true
        }
    
    }
    
    func setResultLabel() {
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 10 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        
        
        let strokeTextAttributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont(name: "TitanOne", size: 19)!
            ] as [NSAttributedString.Key  : Any]
        
        
        let customizedText = NSMutableAttributedString(string: Strings.welcomeText,
                                                       attributes: strokeTextAttributes)
        customizedText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, customizedText.length))
        textView.attributedText = customizedText
        textView.textColor = UIColor.white
        textView.textAlignment = .center
        //textView.text = Strings.welcomeText
        //textView.textColor = UIColor.white
        
    }
    
    func createLevels() {
        var id = 1
        for complication in 1...3 {
            for levelNumber in 1...8 {
                let level = Level()
                level.id = id
                id += 1
                level.leafCount = 2 + levelNumber
                switch complication {
                case 1:
                    level.minNumber = 1
                    level.maxNumber = 15
                    break
                case 2:
                    level.minNumber = 15
                    level.maxNumber = 100
                    break
                case 3:
                    level.minNumber = 100
                    level.maxNumber = 999
                    break
                default:
                    break
                }
                levels.append(level)
            }
        }
    }
    
    func loadOpenLevels() {
        let id = UserDefaults.standard.integer(forKey: "last_open_level_id")
        for level in levels {
            if let currentLevelId = level.id {
                level.open = currentLevelId <= id + 1
            }
        }
    }
    
    @objc func resetButtonDidTap() {
        // Create the alert controller
        let alertController = UIAlertController(title: "Do you want to reset game?", message: "All your complete level will clear and you will have to start again from the first level", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Reset", style: UIAlertAction.Style.default) {
            UIAlertAction in
            UserDefaults.standard.set(0, forKey: "last_open_level_id")
            self.levels = []
            self.createLevels()
            self.loadOpenLevels()
            self.collectionView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func tapToPlayButtonDidTap() {
        darkView.isHidden = true
    }
    

}

extension LevelsViewController: GameControllerDelegate {
    func levelComplete(level: Level) {
        if let id = level.id, id < levels.count {
            levels[id].open = true
            UserDefaults.standard.set(id, forKey: "last_open_level_id")
            collectionView.reloadItems(at: [IndexPath(item: id, section: 0)])
        }
    }
}

extension LevelsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: levelCellReuseIdentifier, for: indexPath) as! LevelCollectionViewCell
        if indexPath.item < levels.count {
            cell.setupCell(level: levels[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < levels.count {
            let level = levels[indexPath.item]
            guard level.open else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let gameVC = storyboard.instantiateViewController(withIdentifier: "GameController") as? GameController {
                gameVC.level = level
                gameVC.delegate = self
                self.navigationController?.pushViewController(gameVC, animated: true)
            }
        }
    }
    
    
}

extension LevelsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 4 - 15
        return CGSize(width: width, height: width)
    }
}
