import Foundation

extension XMLElement {
    func addKeyValuePair(key: String, value: String) {
        addChild(XMLElement(name: "key", stringValue: key))
        addChild(XMLElement(name: "string", stringValue: value))
    }
}

public func install() {
    let boilerplate = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0"><dict>
        <key>Label</key>                <string>idbcl</string>
        <key>RunAtLoad</key>            <true/>
        <key>StartInterval</key>        <integer>3456</integer>
    </dict></plist>
    """
    
    let doc = try! XMLDocument(xmlString: boilerplate)
    
    let dict = doc.rootElement()!.elements(forName: "dict")[0]
    dict.addKeyValuePair(key: "Program", value: Configuration.executablePath.path)
    dict.addKeyValuePair(key: "StandardOutPath", value: Configuration.dataDir!.appendingPathComponent("stdout").path)
    dict.addKeyValuePair(key: "StandardErrPath", value: Configuration.dataDir!.appendingPathComponent("stderr").path)
    
    let launchAgentDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("LaunchAgents")
    let outfile = launchAgentDir?.appendingPathComponent("idbcl.plist")
    let xmlText = doc.xmlString(options: [XMLNode.Options.nodePrettyPrint, XMLNode.Options.nodeCompactEmptyElement])
   
    do {
        try xmlText.write(to: outfile!, atomically: false, encoding: .utf8)
        print("Creating \(outfile!.path)")
        print("\(xmlText)\n")
    }
    catch { print("Unable to write to file.") }
}
