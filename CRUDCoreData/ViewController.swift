//
//  ViewController.swift
//  CRUDCoreData
//
//  Created by tcs on 1/20/17.
//  Copyright © 2017 Raj. All rights reserved.
//

import UIKit
import  CoreData

class ViewController: UIViewController {

    var error: NSError? = nil
    
    //reused for multiple in fetchrequest results // if needed it can be chnaged
    var result: [AnyObject]?
    
    // #pragma mark - Core Data Helper
    lazy var cdstore: CoreDataStore = {
        let cdstore = CoreDataStore()
        return cdstore
    }()
    
    lazy var cdh: CoreDataHelper = {
        let cdh = CoreDataHelper()
        return cdh
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        demoCRUDOperation()
        
    }
    
    func demoCRUDOperation(){
        NSLog(" ======== Insert Organisation ======== ")
        let orgzn = insertOrganisation()
        
         NSLog(" ======== Insert Employees ======== ")
        _ = insertEmployees(orgzn: orgzn)
        
        NSLog(" ======== Fetch Employees ======== ")
        fetchEmployees()
        
        NSLog(" ======== Update Employee with the new name  ======== ")
        updateEmployees()
        
        NSLog(" ======== After Employee name Update with the new name  ======== ")
        fetchEmployees()
        
        NSLog(" ======== Fetch Organisation  and all employees related to it ======== ")
        fetchEmployeeAndOrganisationRelation()
        
        NSLog(" ======== Cascaded Delete of Organization will delete all the employees ======== ")
        cascadedDelete()
        
    }
    
    func insertOrganisation() -> Organsiation {
        let orgzn: Organsiation = NSEntityDescription.insertNewObject(forEntityName: "Organsiation", into: self.cdh.backgroundContext!) as! Organsiation
        orgzn.name = "IT Company"
       return orgzn
    }
    
    
    func insertEmployees(orgzn: Organsiation) {
          let newEmployess = ["Raj":"1", "Ram":"2", "Rajesh":"3", "Ramesh":"4", "Ramaker":"5", "Remo":"6"]
        for (name,id) in newEmployess {
            let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: self.cdh.backgroundContext!) as! Employee
            employee.name = name
            employee.id = id
            employee.organisation = orgzn
        }
        self.cdh.saveContext(self.cdh.backgroundContext!)
    }
    
    func insertDept() {
        let newDepts = ["IT", "Inventory", "Retail", "Engineering", "HR", "Industrial"]
        for name in newDepts {
            let dept = NSEntityDescription.insertNewObject(forEntityName: "Department", into: self.cdh.backgroundContext!) as! Employee
            dept.name = name
        }
        self.cdh.saveContext(self.cdh.backgroundContext!)
    }
    
    
    func fetchEmployees() {
        //fetch Employees
        let fReq: NSFetchRequest = NSFetchRequest<Employee>(entityName: "Employee")
        fReq.predicate = NSPredicate(format:"name CONTAINS 'Ra'")
        
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "name" , ascending: false)
        fReq.sortDescriptors = [sorter]
 
        do {
            result = try self.cdh.managedObjectContext.fetch(fReq)
        } catch let nserror1 as NSError{
            error = nserror1
            result = nil
        }

        for resultemployeeItem in result! {
            let employeeItem = resultemployeeItem as! Employee
            NSLog("Fetched Employee for \(employeeItem.organisation?.name) , \(employeeItem.name)")
        }
    }
    
    
    func updateEmployees() {
        for resultemployeeItem in result! {
            let employeeItem = resultemployeeItem as! Employee
            employeeItem.name = "Raj"
        }
        self.cdh.saveContext(self.cdh.managedObjectContext)
    }
    
    func fetchEmployeeAndOrganisationRelation() {
        let fReqGroup: NSFetchRequest = NSFetchRequest<Organsiation>(entityName: "Organsiation")
        
        do {
            result = try self.cdh.managedObjectContext.fetch(fReqGroup)
        } catch let nserror1 as NSError{
            error = nserror1
            result = nil
        }
        for resultOrgznItem in result! {
            let orgznItem = resultOrgznItem as! Organsiation
            NSLog("Fetched Orgn  \(orgznItem.name) ")
            
            for employeeItem in orgznItem.employees! {
                NSLog("Fetched employee for Organisation \((employeeItem as! Employee).name) ")
            }
        }
    }
    
    
    func cascadedDelete() {
        let orgznItem = result![0] as! Organsiation
        self.cdh.managedObjectContext.delete(orgznItem)
        self.cdh.saveContext(self.cdh.managedObjectContext)
        
        let fReq: NSFetchRequest = NSFetchRequest<Employee>(entityName: "Employee")
        
        do {
            result = try self.cdh.managedObjectContext.fetch(fReq)
        } catch let nserror1 as NSError{
            error = nserror1
            result = nil
        }
        if result!.isEmpty {
            NSLog("Delete Success")
        }
        else{
            for resultItem in result! {
                let employeeItem = resultItem as! Employee
                NSLog("Delete Failed, \(employeeItem.name)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

