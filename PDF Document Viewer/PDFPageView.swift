//
//  PDFPageView.swift
//  PDF Document Viewer
//
//  © 2022 Stephen Lardieri
//

import UIKit
import PDFKit

@IBDesignable
class PDFPageView: UIView {

    // MARK: - Public properties

    @IBInspectable
    var useCropBox: Bool = true

    var page: PDFPage? {
        didSet {
            if let page = page {
                bounds = CGRect(origin: .zero, size: bounds.size).applying(page.transform(for: .cropBox))
            } else {
                bounds = CGRect(origin: .zero, size: bounds.size)
            }

            setNeedsDisplay()
        }
    }

    // MARK: - Initialization

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        layer.isGeometryFlipped = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.isGeometryFlipped = true
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        let configuration = UIImage.SymbolConfiguration(pointSize: 100.0, weight: .medium, scale: .large)
        defaultImage = UIImage(systemName: "doc.richtext", withConfiguration: configuration)!
    }

    // MARK: - UIView overrides

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()

        if let page = page {

            let cropBox = page.bounds(for: .cropBox)
            let cropBoxTransform = page.transform(for: .cropBox)
            let transformedCropBox = cropBox.applying(cropBoxTransform)
            let contentModeTransform = transformToDrawImage(withRect: transformedCropBox, inViewWithBounds: bounds, usingContentMode: contentMode)

            context.concatenate(contentModeTransform)

            if useCropBox {
                page.draw(with: .cropBox, to: context)
            } else {
                context.concatenate(cropBoxTransform)
                page.draw(with: .mediaBox, to: context)
            }

        } else if let image = defaultImage {

            let imageRect = CGRect(origin: .zero, size: image.size)
            let contentModeTransform = transformToDrawImage(withRect: imageRect, inViewWithBounds: bounds, usingContentMode: contentMode)
            let transformedImageRect = imageRect.applying(contentModeTransform)

            context.translateBy(x: +transformedImageRect.origin.x, y: +transformedImageRect.origin.y + transformedImageRect.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: -transformedImageRect.origin.x, y: -transformedImageRect.origin.y)

            image.draw(in: transformedImageRect)

        }

        context.restoreGState()
    }

    override var intrinsicContentSize: CGSize {
        if let page = page {
            return page.bounds(for: .cropBox).size
        } else if let image = defaultImage {
            return image.size
        } else {
            return .zero
        }
    }

    // MARK: - Private functions

    private func transformToDrawImage(withRect imageRect: CGRect, inViewWithBounds bounds: CGRect, usingContentMode contentMode: ContentMode) -> CGAffineTransform {

        func scaleAndCenter(scaleX: CGFloat, scaleY: CGFloat) -> CGAffineTransform {
            let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            let scaledImageRect = imageRect.applying(scaleTransform)

            let transX = bounds.midX - scaledImageRect.midX
            let transY = bounds.midY - scaledImageRect.midY
            let translationTransform = CGAffineTransform(translationX: transX, y: transY)

            return scaleTransform.concatenating(translationTransform)
        }

        let transX, transY: CGFloat

        switch contentMode {

            case .scaleToFill:
                let scaleX = bounds.width / imageRect.width
                let scaleY = bounds.height / imageRect.height
                return scaleAndCenter(scaleX: scaleX, scaleY: scaleY)

            case .scaleAspectFit:
                let scale = min(bounds.width / imageRect.width, bounds.height / imageRect.height)
                return scaleAndCenter(scaleX: scale, scaleY: scale)

            case .scaleAspectFill:
                let scale = max(bounds.width / imageRect.width, bounds.height / imageRect.height)
                return scaleAndCenter(scaleX: scale, scaleY: scale)

            case .center:
                transX = bounds.midX - imageRect.midX
                transY = bounds.midY - imageRect.midY

            case .top:
                transX = bounds.midX - imageRect.midX
                transY = bounds.maxY - imageRect.maxY

            case .bottom:
                transX = bounds.midX - imageRect.midX
                transY = bounds.minY - imageRect.minY

            case .left:
                transX = bounds.minX - imageRect.minX
                transY = bounds.midY - imageRect.midY

            case .right:
                transX = bounds.maxX - imageRect.maxX
                transY = bounds.midY - imageRect.midY

            case .topLeft:
                transX = bounds.minX - imageRect.minX
                transY = bounds.maxY - imageRect.maxY

            case .topRight:
                transX = bounds.maxX - imageRect.maxX
                transY = bounds.maxY - imageRect.maxY

            case .bottomLeft:
                transX = bounds.minX - imageRect.minX
                transY = bounds.minY - imageRect.minY

            case .bottomRight:
                transX = bounds.maxX - imageRect.maxX
                transY = bounds.minY - imageRect.minY

            case .redraw:
                fallthrough

            @unknown default:
                transX = 0.0
                transY = 0.0

        }

        return CGAffineTransform(translationX: transX, y: transY)
    }

    // MARK: - Private properties

    private var defaultImage: UIImage? = nil

}

