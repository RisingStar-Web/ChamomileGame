//
//  ViewController.swift
//  ChamomileGame
//
//  Created by Денис Марков on 3/4/19.
//  Copyright © 2019 Денис Марков. All rights reserved.
//

import UIKit
fileprivate let centerRoundDiameter: CGFloat = 90
fileprivate let flowerInsets: CGFloat = 20


//TitanOne
protocol GameControllerDelegate {
    func levelComplete(level: Level)
}

class GameController: UIViewController {
    
    @IBOutlet weak var answerCheckLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton! {
        didSet {
//            checkButton.layer.cornerRadius = 8
//            checkButton.layer.masksToBounds = true
//            checkButton.layer.borderColor = UIColor.white.cgColor
//            checkButton.layer.borderWidth = 1
            checkButton.addTarget(self, action: #selector(checkAnswerButtonDidTap), for: .touchUpInside)
        }
    }
    @IBOutlet weak var flowerView: UIView!
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.layer.cornerRadius = 8
            backButton.layer.masksToBounds = true
            backButton.layer.borderColor = UIColor.white.cgColor
            backButton.layer.borderWidth = 1
//            let image = #imageLiteral(resourceName: "backButtonIcon").withRenderingMode(.alwaysTemplate)
//            backButton.tintColor = UIColor.white
//            backButton.setImage(image, for: .normal)
            backButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        }
    }

    //default values
    var leafCount = 12
    var minNumber = 0
    var maxNumber = 10
    
    var centerPoint = CGPoint(x: 0, y: 0)
    var numbers: [Int] = []
    var rightAnswer = 0
    var currentAnswer = 0
    var currentAnswerLabel = UILabel()
    var rightAnswerLabel = UILabel()
    var buttons: [UIButton] = []
    var level: Level?
    var delegate: GameControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let level = level {
            loadLevel(level: level)
        } else {
            createNumbersArray()
        }
        drawChamomile()
        animateShowFlower()
    }
    
    @objc func cancelButtonDidTap() {
        let vcs = self.navigationController?.viewControllers
        if ((vcs?.contains(self)) != nil) {
            self.navigationController?.popViewController(animated: false)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func animateShowFlower() {
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = 0.5
        fadeIn.fillMode = CAMediaTimingFillMode.backwards
        flowerView.layer.add(fadeIn, forKey: nil)
        
    }
    
    func animateRemoveFlower() {
        let rotate = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotate.values = [0.0, .pi/2.0, Double.pi * 3/2, Double.pi * 2]
        rotate.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        rotate.duration = 0.5
        rotate.setValue("remove_flower", forKey: "animation_name")
        rotate.delegate = self
        
        let moveUp = CASpringAnimation(keyPath: "position.y")
        //moveUp.delegate = self
        //moveUp.setValue("remove_flower", forKey: "animation_name")
        moveUp.fromValue = flowerView.layer.position.y
        moveUp.toValue = flowerView.layer.position.y - UIScreen.main.bounds.height
        moveUp.duration = moveUp.settlingDuration
        moveUp.initialVelocity = 1
        moveUp.mass = 15
        moveUp.stiffness = 75
        moveUp.damping = 12
        flowerView.layer.position.y -= UIScreen.main.bounds.height
        
        flowerView.layer.add(moveUp, forKey: nil)
        flowerView.layer.add(rotate, forKey: nil)
    }
    
    func loadLevel(level: Level) {
        leafCount = level.leafCount
        minNumber = level.minNumber
        maxNumber = level.maxNumber
        createNumbersArray()
    }
    
    func createNumbersArray() {
        for _ in 0..<leafCount {
            numbers.append(Int.random(in: minNumber ... maxNumber))
        }
        let leafForSumCount: Int = leafCount / 2 //Int.random(in: 2 ... leafCount)
        var tempNumbersArray = numbers
        for _ in 0..<leafForSumCount {
            let index = Int.random(in: 0 ..< tempNumbersArray.count)
            rightAnswer += tempNumbersArray[index]
            tempNumbersArray.remove(at: index)
        }
    }
    
    func drawChamomile() {
        centerPoint = CGPoint(x: flowerView.frame.width / 2, y: flowerView.frame.height / 2)
        let flowerWidth = flowerView.frame.width
        let leafHeight = flowerWidth / 2
        let step = 2 * Double.pi / Double(leafCount)
        let leafWidth = Double.pi * Double(leafHeight) / Double(leafCount)
        for i in 0..<leafCount {
            let leafButton = UIButton(frame: CGRect(x: centerPoint.x - CGFloat(leafWidth) / 2, y: centerPoint.y, width: CGFloat(leafWidth), height: leafHeight))
            leafButton.layer.masksToBounds = true
            leafButton.layer.cornerRadius = leafButton.frame.width / 1.5
            leafButton.backgroundColor = UIColor.white
            leafButton.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0))
            leafButton.tag = numbers[i]
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: leafWidth, height: 20))
            label.text = "\(numbers[i])"
            label.textAlignment = .center
           // label.font.withSize(14)
            
            label.font = UIFont(name: "TitanOne", size: 20)!
            label.textColor = .black
            label.center = CGPoint(x: CGFloat(leafWidth) / 2, y: leafHeight / 2)
            leafButton.addSubview(label)
            flowerView.addSubview(leafButton)
            let rotation = CGAffineTransform(rotationAngle: CGFloat(step * Double(i)))
            leafButton.transform = rotation
            label.transform = rotation.inverted()
            leafButton.addTarget(self, action: #selector(leafButtonDidTap(sender:)), for: .touchUpInside)
            buttons.append(leafButton)
        }
        setCenterRound()
    }
    
    func setCenterRound() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: centerRoundDiameter, height: centerRoundDiameter))
        button.center = centerPoint
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.orange
        rightAnswerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: centerRoundDiameter, height: 20))
        rightAnswerLabel.text = "\(rightAnswer)"
        rightAnswerLabel.textAlignment = .center
        rightAnswerLabel.font.withSize(14)
        
        rightAnswerLabel.font = UIFont(name: "TitanOne", size: 20)!
        
        rightAnswerLabel.textColor = .white
        rightAnswerLabel.center = CGPoint(x: CGFloat(centerRoundDiameter) / 2, y: (centerRoundDiameter - 20) / 2 - 5)
        currentAnswerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: centerRoundDiameter, height: 20))
        currentAnswerLabel.text = "\(currentAnswer)"
        currentAnswerLabel.textAlignment = .center
        currentAnswerLabel.font.withSize(12)
        
        currentAnswerLabel.font = UIFont(name: "TitanOne", size: 20)!
        
        
        currentAnswerLabel.textColor = .darkGray
        currentAnswerLabel.center = CGPoint(x: CGFloat(centerRoundDiameter) / 2, y: (centerRoundDiameter + 20) / 2 + 5)
        button.addSubview(currentAnswerLabel)
        button.addSubview(rightAnswerLabel)
        flowerView.addSubview(button)
        buttons.append(button)
    }
    
    @objc func leafButtonDidTap(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? .lightGray : .white
        currentAnswer += sender.isSelected ? sender.tag : -sender.tag
        currentAnswer = currentAnswer < 0 ? 0 : currentAnswer
        currentAnswerLabel.text = "\(currentAnswer)"
    }
    
    @objc func nextButtonDidTap() {
        for button in buttons {
            button.removeFromSuperview()
        }
        answerCheckLabel.isHidden = true
        numbers = []
        rightAnswer = 0
        currentAnswer = 0
        currentAnswerLabel = UILabel()
        rightAnswerLabel = UILabel()
        buttons = []
        createNumbersArray()
        drawChamomile()
    }
    
    @objc func checkAnswerButtonDidTap() {
        if rightAnswer == currentAnswer {
            setRight()
            animateRemoveFlower()
        } else {
            setWrong()
        }
        answerCheckLabel.isHidden = false
    }

    
    
    func setWrong() {
        setResultLabel(text: "Wrong!", color: UIColor.red)
        
    }
    
    
    func setRight() {
         setResultLabel(text: "Right", color: UIColor.green)
        
    }
    
    func setResultLabel(text: String, color: UIColor) {
        
        let strokeTextAttributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : UIColor.white,
            NSAttributedString.Key.foregroundColor : color,
            
            NSAttributedString.Key.strokeWidth : -3.0,
            NSAttributedString.Key.font : UIFont(name: "TitanOne", size: 33)!
            ] as [NSAttributedString.Key  : Any]
        
        let customizedText = NSMutableAttributedString(string: text,
            attributes: strokeTextAttributes)
        answerCheckLabel.attributedText = customizedText
    
        
        
    }
    

}

extension GameController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let animName = anim.value(forKey: "animation_name") as? String, animName == "remove_flower", let level = self.level else {
            return
        }
        self.delegate?.levelComplete(level: level)
        self.cancelButtonDidTap()
    }
}

extension UIButton{
    func setAnchorPoint(anchorPoint: CGPoint) {
        
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position : CGPoint = self.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x;
        
        position.y -= oldPoint.y;
        position.y += newPoint.y;
        
        self.layer.position = position;
        self.layer.anchorPoint = anchorPoint;
    }
}
