//
//  ViewController.swift
//  taskapp
//
//  Created by 	 on 01/12木.
//  Copyright © 2017年 critical-bug. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate,  UIPickerViewDataSource {

    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    var taskArray: Results<Task>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        taskArray = realm.objects(Task.self).sorted(byProperty: "date", ascending: false)
        tableView.delegate = self
        tableView.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        categoryPicker.reloadAllComponents()
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray!.count
    }
    // MARK: UITableViewDataSourceプロトコルのメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray![indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.detailTextLabel?.text = formatter.string(from: task.date as Date)
        return cell
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    // MARK: UITableViewDelegateプロトコルのメソッド
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        // セルが削除が可能なことを伝える
        return .delete
    }
    // MARK: UITableViewDelegateプロトコルのメソッド
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        print(editingStyle)
        let realm = try! Realm()
        if editingStyle == UITableViewCellEditingStyle.delete {
            let task = taskArray![indexPath.row]
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            try! realm.write {
                realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            taskArray = realm.objects(Task.self).sorted(byProperty: "date", ascending: false)
            categoryPicker.reloadAllComponents()
            tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController = segue.destination as! InputViewController
        let realm = try! Realm()
        if segue.identifier == "cellSegue" {
            try! realm.write {
                let indexPath = self.tableView.indexPathForSelectedRow
                inputViewController.task = taskArray![indexPath!.row]
            }
        } else {
            // "+"ボタン
            let task = Task()
            task.date = NSDate()
            
            if taskArray!.count != 0 {
                task.id = taskArray!.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let realm = try! Realm()
        let categories = Set(realm.objects(Task.self).value(forKey: "category") as! [String])
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let realm = try! Realm()
        let categories = Set(realm.objects(Task.self).value(forKey: "category") as! [String])
        return categories.sorted()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let realm = try! Realm()
        let allTasks = realm.objects(Task.self)
        let categories = Set(allTasks.value(forKey: "category") as! [String])
        let selectedCategory =  categories.count > 0 ? categories.sorted()[row] : ""
        if selectedCategory.isEmpty {
            taskArray = allTasks.sorted(byProperty: "date", ascending: false)
        } else {
            taskArray = allTasks.sorted(byProperty: "date", ascending: false).filter("category = '\(selectedCategory)'")
        }
        tableView.reloadData()
    }
}

