//
//  ScreenshotViewController.swift
//  Cybele
//
//  Created by Serena on 10/07/2023.
//  

import Cocoa

class ScreenshotViewController: NSViewController {
    let image: NSImage
    var imageView: NSImageView!
    let imageData: Data
    
    var doDelete: Bool = false
    
    let urlToWriteTo: URL = {
        // the `com.apple.screencapture` domain has the user set path for where they want to store screenshots or videos
        let locationPath = (UserDefaults(suiteName: "com.apple.screencapture")?.string(forKey: "location") ?? NSHomeDirectory()) as NSString
        return URL(fileURLWithPath: locationPath.expandingTildeInPath).appendingPathComponent(ScreenshotViewController.makeFormattedDate())
    }()
    
    lazy var timer = Timer(timeInterval: 1.5, repeats: false) { _ in
        self.justGo()
    }
    
    // for the screenshot filenames, we name them like how Screenshot.app does
    // "Screenshot month-date-year at hour-minute-second AM/PM"
    static func makeFormattedDate(_ date: Date = Date()) -> String {
        return "Screenshot \(DateFormatter.mediaFirstPartFormatter.string(from: date)) at \(DateFormatter.mediaSecondPartFormatter.string(from: date)).png"
    }
    
    override func loadView() {
        view = NSView()
    }
    
    init(image: NSImage, imageData: Data) {
        self.image = image
        self.imageData = imageData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window?.makeKeyAndOrderFront(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let screenshotView = NSImageView(image: image)
        let imageViewGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(didClickImage))
        screenshotView.addGestureRecognizer(imageViewGestureRecognizer)
        
        screenshotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(screenshotView)
        
        NSLayoutConstraint.activate([
            screenshotView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            screenshotView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            screenshotView.widthAnchor.constraint(equalToConstant: 150),
            screenshotView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        self.imageView = screenshotView
        
        let menu = NSMenu()
        menu.addItem(withTitle: "Close", action: #selector(justGo), keyEquivalent: "")
        menu.addItem(withTitle: "Delete", action: #selector(delete), keyEquivalent: "")
        menu.delegate = self
        screenshotView.menu = menu
        
        RunLoop.current.add(timer, forMode: .default)
    }
    
    
    @objc
    func didClickImage() {
        timer.invalidate()
        imageView.removeFromSuperview()
        try? imageData.write(to: urlToWriteTo)
        // open when clicked
        NSWorkspace.shared.open(urlToWriteTo)
    }
    
    @objc
    func delete() {
        timer.invalidate()
        doDelete = true
        justGo()
    }
    
    @objc
    func justGo() {
        var origin = imageView.frame.origin
        origin.x += NSScreen.main!.frame.maxX
        
        NSAnimationContext.runAnimationGroup { [self] context in
            context.duration = 3.5
            context.timingFunction = .init(name: .easeInEaseOut)
            context.allowsImplicitAnimation = true
            
            // The view will animate to the new origin
            imageView.animator().frame.origin = origin
        } completionHandler: { [self] in
            imageView.removeFromSuperview()
            
            if !doDelete {
                let url = urlToWriteTo
                try? imageData.write(to: url)
                view.window?.close()
            }
        }
    }
    
    deinit {
        print("deinit called")
    }
}

extension ScreenshotViewController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        timer.invalidate()
    }
    
    func menuDidClose(_ menu: NSMenu) {
        timer = Timer(timeInterval: 1.5, repeats: false) { _ in
            self.justGo()
        }
        
        RunLoop.current.add(timer, forMode: .default)
    }
    
    func confinementRect(for menu: NSMenu, on screen: NSScreen?) -> NSRect {
        return .zero
    }
}
