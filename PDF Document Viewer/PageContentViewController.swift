//
//  PageContentViewController.swift
//  PDF Document Viewer
//
//  © 2022 Stephen Lardieri
//

import UIKit
import PDFKit

class PageContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var pdfPageView: PDFPageView!

    var page: PDFPage! = nil
    var titleText: String! = nil
    var pageNumberText: String! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = titleText
        pageNumberLabel.text = pageNumberText
        pdfPageView.page = page
    }

}
