//
//  InputViewController.swift
//  taskapp
//
//  Created by 	 on 01/16月.
//  Copyright © 2017年 critical-bug. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var task: Task!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentTextView.text = task.content
        datePicker.date = task.date as Date
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = titleTextField.text!
            self.task.content = contentTextView.text
            self.task.date = datePicker.date as NSDate
            self.realm.add(task, update: true)
        }
        setNotification(task)
        super.viewWillDisappear(animated)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setNotification(_ task: Task) {
        let nc = UNMutableNotificationContent()
        nc.title = task.title
        nc.body = task.content
        nc.sound = .default()
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: NSCalendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date),
                                                         repeats: false)
        let request = UNNotificationRequest.init(identifier: String(task.id), content: nc, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {(e) in print(e)}
    }
}
