//
//  ViewController.swift
//  NotCardCounting
//
//  Created by Sam Owen on 16/01/2019.
//  Copyright © 2019 EskiSoftware. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AudioToolbox

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var Counter: UILabel!
    @IBOutlet weak var betweenBuzz: UITextField!
    @IBOutlet weak var giveashit: UITextField!
    @IBAction func ResetButton(_ sender: Any) {
        count = 0;
        updateCounter();
    }
    
    func updateCounter() {
        let oldValue = Int (Counter.text!)
        Counter.text = String (count);
        let gasValue : Int? = Int (giveashit.text!)
        if (gasValue == nil) {
            return
        }
        let betweenValue : Int? = Int (betweenBuzz.text!)
        
        if (count == gasValue!){
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        if (count > gasValue!) {
                if (betweenValue == nil) {return}
                else if (((count - gasValue!) % betweenValue! == 0) && (count > oldValue!)) {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    perform(#selector(buzz), with: nil, afterDelay: 0.1)
                } else if (((count - gasValue!) % betweenValue! == 0) && (count < oldValue!)) {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    perform(#selector(self.buzz), with: nil, afterDelay: 0.3)
            }
        }
            // Disapointingly it looks like this doesn't work for iphone 7 below...
            //let peek = SystemSoundID(1519)
            //AudioServicesPlayAlertSound(peek)
        
    }

    @objc func buzz() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    var count : Int = 0;
    
    func textField(_ giveashit: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let volumeView = MPVolumeView(frame: CGRect.zero)
        for subview in volumeView.subviews {
            if let button = subview as? UIButton {
                button.setImage(nil, for: .normal)
                button.isEnabled = false
                button.sizeToFit()
            }
        }
        UIApplication.shared.windows.first?.addSubview(volumeView)
        UIApplication.shared.windows.first?.sendSubview(toBack: volumeView)
        
        giveashit.delegate = self
        giveashit.keyboardType = .numberPad
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        do { try AVAudioSession.sharedInstance().setActive(true) }
        catch { debugPrint("\(error)") }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        do { try AVAudioSession.sharedInstance().setActive(false) }
        catch { debugPrint("\(error)") }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else { return }
        switch key {
        case "outputVolume":
            guard let dict = change, let temp = dict[NSKeyValueChangeKey.newKey] as? Float, temp != 0.5 else { return }
            let systemSlider = MPVolumeView().subviews.first { (aView) -> Bool in
                return NSStringFromClass(aView.classForCoder) == "MPVolumeSlider" ? true : false
                } as? UISlider
            
            let up : Bool = temp >= 0.5 ? true : false
            
            systemSlider?.setValue(0.5, animated: false)
            guard systemSlider != nil else { return }
            
            if (up) {
                count += 1
                updateCounter()
            } else {
                count -= 1
                updateCounter()
            }
        default:
            break
        }
    }
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

