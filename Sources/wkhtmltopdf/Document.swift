import Foundation

public class Document {
    let topMargin: Int
    let rightMargin: Int
    let bottomMargin: Int
    let leftMargin: Int
    let launchPath: String
    
    let paperSize: String
    let weasyArgs: [String]
    public var pages: [Page] = []
    
    public init(size: String = "Letter", margins: Int = 20, path: String = "/usr/local/bin/weasyprint", weasyArgs: [String] = []) {
        self.paperSize = size
        self.topMargin = margins
        self.rightMargin = margins
        self.bottomMargin = margins
        self.leftMargin = margins
        self.launchPath = path
        self.weasyArgs = weasyArgs
    }
}
