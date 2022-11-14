#  PDF Page View

A UIView subclass to display PDF pages

## Usage

1. Copy the PDFPageView.swift source file from the demo app into your Xcode project.

2. On your Storyboard, add a UIView to one of your view controllers and set the class to PDFPageView.
   - Turn off the Opaque property.
   - Set the Content Mode property appropriately. (Aspect Fit is recommended.)
   - Set the Use Crop Box property appropriately, depending on whether your PDF expects cropping.  
     **NOTE:** *Content Mode always positions the content using the crop box, not the media box.*
   - Don't forget your layout constraints!

...or do the equivalent in your view controller's `loadView()` code.

3. In your view controller's `viewDidLoad()`, set the page view's `.page` property to the PDFPage you want to display.
   - You need to import PDFKit at the top of your source file.
   - You need to load your PDF file as a PDFDocument object.

## Document Viewer Demo app

1. Download the entire Xcode project.

2. Build and run for the Simulator. (Or a real device, if you add your developer license to the project.)

3. The demo app hosts the PDFPageView in a UIPageViewController, so swipe left and right to turn pages.

## If I had to do it all over again...

I'd use a layer hierarchy instead of doing everything directly in the view.
- Create a CALayer to hold the PDF content.
- Flip its geometry to match the PDF.
- Set the bounds of the layer using the size of the media box and the origin of the crop box.
- Use the `.position` and `.anchorPoint` of the layer to implement content gravity, rather than transforms.
- Only use a scaling transform for the Aspect Fill, Aspect Fit, and Size to Fit content modes.
