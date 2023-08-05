import Foundation
import NIO

extension Document {
    public func generatePDF(on threadPool: NIOThreadPool, eventLoop: EventLoop) -> EventLoopFuture<Data> {
        return threadPool.runIfActive(eventLoop: eventLoop) {
            let fileManager = FileManager.default
            
            // Create the temp folder if it doesn't already exist
            let workDir = "/tmp/vapor-weasyprint"
            try fileManager.createDirectory(atPath: workDir, withIntermediateDirectories: true)
            
            // Save input pages to temp files, and build up args to WeasyPrint
            var weasyArgs: [String] = [
                "-s", self.paperSize,
                "-m", "margin:\(self.topMargin)mm \(self.rightMargin)mm \(self.bottomMargin)mm \(self.leftMargin)mm",
            ]
            
            weasyArgs += self.weasyArgs
            
            let pageFiles: [String] = try self.pages.map { page in
                let name = UUID().uuidString + ".html"
                let filename = "\(workDir)/\(name)"
                try page.content.write(to: URL(fileURLWithPath: filename))
                return filename
            }
            defer {
                try? pageFiles.forEach(fileManager.removeItem)
            }
            
            weasyArgs += pageFiles
            
            // Call WeasyPrint and retrieve the result data
            let wp = Process()
            let stdout = Pipe()
            wp.launchPath = self.launchPath
            wp.arguments = weasyArgs
            wp.arguments?.append("-") // output to stdout
            wp.standardOutput = stdout
            wp.launch()
            
            let pdf = stdout.fileHandleForReading.readDataToEndOfFile()
            return pdf
        }
    }
}

