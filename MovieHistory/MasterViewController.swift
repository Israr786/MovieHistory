//
//  MasterViewController.swift
//  MovieHistory
//
//  Created by Apple on 6/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var moviesDetailArray = [MovieDetail]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
     //   navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSorting))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        DispatchQueue.global().async {
            self.fetchDataManager()
        }
        
    }

    
    func fetchDataManager(){
        
        guard let url = URL(string: "https://data.sfgov.org/api/views/yitu-d5am/rows.json?accessType=DOWNLOAD") else { return }
        //TODO coz of less time
        //     let url = URL(string:"https://itunes.apple.com/search?term=songs")
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error)
            }
            
            do {
                let json : [String : Any] = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]
                let records:NSMutableArray = json["data"] as! NSArray as! NSMutableArray
                
                for item in records {
                    let moviedetailObject = item as! [Any]
                    let movie = MovieDetail()

               
                    let m_id = moviedetailObject[0] as? Int16
                    let m_date = moviedetailObject[5] as? Double
                    let m_name = moviedetailObject[8] as? String
                    let m_year = moviedetailObject[9] as? String
                    let m_location = moviedetailObject[10] as? String
                    
                    if m_id != nil {
                        movie.id = m_id
                        // newEvent.id = movie.id!
                    }
                    else {
                        movie.id = 999
                        // newEvent.id = 999
                    }
                    
                    if m_date != nil {
                        movie.date = Date(timeIntervalSince1970: m_date!)
                        // newEvent.date = movie.date
                    }
                    else {
                        movie.date = Date(timeIntervalSince1970: 1509143469)
                        // newEvent.date = movie.date
                    }
                    
                    if m_name != nil {
                        movie.name = m_name
                        // newEvent.name = movie.name
                    }
                    else {
                        movie.name = "No Name"
                        //  newEvent.name = movie.name
                    }
                    
                    if m_year != nil {
                        movie.year = m_year
                        //   newEvent.year = movie.year
                    }
                    else {
                        movie.year = "2018"
                        //    newEvent.year = movie.year
                    }
                    
                    if m_location != nil {
                        movie.location = m_location
                        //     newEvent.location = movie.location
                    }
                    else {
                        movie.location = "No Location"
                        //     newEvent.location = movie.location
                    }
                    
                    self.moviesDetailArray.append(movie)
                    
                }
                DispatchQueue.main.async {
                     self.tableView.reloadData()
                }
               
                
            } catch {
                print("error trying to convert data to JSON")
                print(error)
            }
            }.resume()
        
    }
    
    
    @objc func  handleSorting(){
        
        let alertController = UIAlertController(title: "Sort the List", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let name = UIAlertAction(title: "Name", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
            self.handleSortingbyName()
           
        })
        
        let  location = UIAlertAction(title: "Location", style: .default, handler: { (action) -> Void in
            print("Delete button tapped")
            self.handleSortingbyLocation()
        })
        
        let  dateSort = UIAlertAction(title: "Date", style: .default, handler: { (action) -> Void in
            print("Delete button tapped")
            self.handleSortingbyDate()
        })
   
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        alertController.addAction(name)
        alertController.addAction(location)
        alertController.addAction(dateSort)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    
    }
    
    
    
    @objc func handleSortingbyLocation(){
        moviesDetailArray.sort(by: { $0.location! > $1.location! })
        tableView.reloadData()
    }
    
    @objc func handleSortingbyName(){
        moviesDetailArray.sort(by: { $0.name! > $1.name! })
        tableView.reloadData()
    }
    
    @objc func handleSortingbyDate(){
        moviesDetailArray.sort(by: { $0.date! > $1.date! })
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.movieDetailObject = moviesDetailArray[indexPath.row]
                controller.detailItem = moviesDetailArray[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return moviesDetailArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath )
        let object = moviesDetailArray[indexPath.row]
        cell.textLabel!.text = object.name
        cell.detailTextLabel?.text = object.location
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

  


}

