//
//  ProgressVc.swift
//  ProgressLoadingView
//
//  Created by Sadham Hussain on 3/14/17.
//  Copyright © 2017 CIPL. All rights reserved.
//

import UIKit

class ProgressVc: UIViewController {

    var progressText : String!
    
    @IBOutlet weak var lblProgressText: UILabel!
    @IBOutlet weak var myActivity: UIActivityIndicatorView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Progress Vw Did load")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func startProgressLoader(progressText: String){
        lblProgressText.text = progressText
        myActivity.startAnimating()
    }
    
    func stopProgressLoader(){
        myActivity.stopAnimating()
    }
}
