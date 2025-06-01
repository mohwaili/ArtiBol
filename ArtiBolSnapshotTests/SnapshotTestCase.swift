//
//  SnapshotTestCase.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 31/05/2025.
//

import Foundation
import XCTest
import SnapshotTesting

class SnapshotTestCase: XCTestCase {
    
    var width: CGFloat?
    var height: CGFloat?
    var record: SnapshotTestingConfiguration.Record = .never
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        CALayer.swizzleShadow()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        CALayer.swizzleShadow()
    }
    
    @MainActor
    final func assertView(
        for viewController: UIViewController,
        isDarkMode: Bool = false,
        named name: String? = nil,
        timeout: TimeInterval = 5,
        refreshLayout: Bool = true,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line) {
            viewController.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            let sut = viewController.view!
            sut.translatesAutoresizingMaskIntoConstraints = false
            if let width {
                sut.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
            if let height {
                sut.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
            
            if refreshLayout {
                sut.setNeedsLayout()
                sut.layoutIfNeeded()
            }
            
            let fileURL = URL(fileURLWithPath: "\(file)", isDirectory: false)
            let folderName = fileURL.deletingPathExtension().lastPathComponent
            
            var pathComponents = fileURL.pathComponents
            
            pathComponents.removeLast()
            pathComponents.append("__Snapshots__")
            pathComponents.append(folderName)
            let directory = String(pathComponents.joined(separator: "/").dropFirst())
            
            record(
                sut: viewController,
                isDarkMode: isDarkMode,
                directory: directory,
                named: name,
                file: file,
                testName: testName,
                line: line
            )
            
        }
    
    @MainActor
    func record(
        sut: UIViewController,
        isDarkMode: Bool,
        directory: String,
        named name: String? = nil,
        timeout: TimeInterval = 5,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line) {
            withSnapshotTesting(record: record) {
                let failure = verifySnapshot(
                    of: sut,
                    as: .image(
                        on: .iPhoneSe,
                        precision: 0.99,
                        perceptualPrecision: 0.96,
                        traits: .init(userInterfaceStyle: isDarkMode ? .dark : .light)
                    ),
                    named: name,
                    snapshotDirectory: directory,
                    timeout: timeout,
                    file: file,
                    testName: isDarkMode ? "\(testName)dark" : testName,
                    line: line
                )
                
                if let failure {
                    XCTFail(failure, file: file, line: line)
                }
            }
        }
}

extension CALayer {
    /**
     Shadow causes issues with the snapshot tests, it will make it difficult to comparse the snapshot against the reference image
     therefore we have to disable it
     https://github.com/pointfreeco/swift-snapshot-testing/issues/424
     */
    static func swizzleShadow() {
        swizzle(original: #selector(getter: shadowOpacity), modified: #selector(_swizzled_shadowOpacity))
        swizzle(original: #selector(getter: shadowRadius), modified: #selector(_swizzled_shadowRadius))
        swizzle(original: #selector(getter: shadowColor), modified: #selector(_swizzled_shadowColor))
        swizzle(original: #selector(getter: shadowOffset), modified: #selector(_swizzled_shadowOffset))
        swizzle(original: #selector(getter: shadowPath), modified: #selector(_swizzled_shadowPath))
    }
    
    private static func swizzle(original: Selector, modified: Selector) {
        let originalMethod = class_getInstanceMethod(self, original)!
        let swizzledMethod = class_getInstanceMethod(self, modified)!
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc func _swizzled_shadowOpacity() -> Float { .zero }
    @objc func _swizzled_shadowRadius() -> CGFloat { .zero }
    @objc func _swizzled_shadowColor() -> CGColor? { nil }
    @objc func _swizzled_shadowOffset() -> CGSize { .zero }
    @objc func _swizzled_shadowPath() -> CGPath? { nil }
}
