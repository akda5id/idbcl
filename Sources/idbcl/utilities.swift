import Foundation

extension XMLElement {
    func addKeyValuePair(key: String, value: String) {
        addChild(XMLElement(name: "key", stringValue: key))
        addChild(XMLElement(name: "string", stringValue: value))
    }
    
    func addArray(key: String, values: [String]) {
        addChild(XMLElement(name: "key", stringValue: key))
        
        let arr = XMLElement(name: "array")
        for v in values { arr.addChild(XMLElement(name: "string", stringValue: v)) }
        addChild(arr)
    }
}

public func createLaunchAgent() {
    let boilerplate = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0"><dict>
        <key>Label</key>                <string>idbcl</string>
        <key>RunAtLoad</key>            <true/>
        <key>StartInterval</key>        <integer>12345</integer>
    </dict></plist>
    """
    
    let doc = try! XMLDocument(xmlString: boilerplate)
    
    guard let exe = Bundle.main.executableURL else {
        print("Error getting path to executable.")
        return
    }
    
    let dict = doc.rootElement()!.elements(forName: "dict")[0]
    dict.addArray(key: "ProgramArguments", values: [exe.path, "update"])
    dict.addKeyValuePair(key: "StandardOutPath", value: Configuration.dataDir!.appendingPathComponent("stdout").path)
    dict.addKeyValuePair(key: "StandardErrorPath", value: Configuration.dataDir!.appendingPathComponent("stderr").path)
    
    let launchAgentDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("LaunchAgents")
    let outfile = launchAgentDir?.appendingPathComponent("idbcl.plist")
    let xmlText = doc.xmlString(options: [XMLNode.Options.nodePrettyPrint, XMLNode.Options.nodeCompactEmptyElement])
   
    do {
        try FileManager.default.createDirectory(at: launchAgentDir!, withIntermediateDirectories: true, attributes: nil)
        try xmlText.write(to: outfile!, atomically: false, encoding: .utf8)
        print("Creating \(outfile!.path)")
    } catch { print("Unable to write to file.") }
}