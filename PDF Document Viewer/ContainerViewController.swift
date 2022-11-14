//
//  ContainerViewController.swift
//  PDF Document Viewer
//
//  © 2022 Stephen Lardieri
//

import UIKit
import PDFKit

class ContainerViewController: UIViewController {

    weak var pageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        buildPages()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "Embed UIPageViewController":
                pageViewController = (segue.destination as! UIPageViewController)
                pageViewController.dataSource = self
                pageViewController.delegate = self

            default:
                return
        }
    }

    private func buildPages() {
        var contentViewControllers: [PageContentViewController] = []

        for pageIndex in 0 ..< document.pageCount {
            let contentViewController = storyboard!.instantiateViewController(withIdentifier: "Page Content View Controller") as! PageContentViewController
            contentViewController.titleText =
                (document.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String) ??
                (document.documentURL?.lastPathComponent) ??
                "Title"
            contentViewController.pageNumberText = "Page \(pageIndex + 1) of \(document.pageCount)"
            contentViewController.page = document.page(at: pageIndex)

            contentViewControllers.append(contentViewController)
        }

        self.contentViewControllers = contentViewControllers
    }

    var contentViewControllers: [PageContentViewController] = [] {
        didSet {
            pageViewController.setViewControllers(contentViewControllers.first.flatMap { [$0] }, direction: .forward, animated: false, completion: nil)
        }
    }

    lazy var document: PDFDocument = {
        let url = Bundle.main.url(forResource: "Sample Document", withExtension: "pdf")!
        let document = PDFDocument(url: url)!
        return document
    }()

}


extension ContainerViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = contentViewControllers.firstIndex(of: viewController as! PageContentViewController)!
        guard index - 1 >= 0 else { return nil }
        return contentViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = contentViewControllers.firstIndex(of: viewController as! PageContentViewController)!
        guard index + 1 < contentViewControllers.count else { return nil }
        return contentViewControllers[index + 1]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return contentViewControllers.count

    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

}


extension ContainerViewController: UIPageViewControllerDelegate {

}

