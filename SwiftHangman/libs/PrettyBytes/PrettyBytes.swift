//
//  From Jody Hagins
//  http://stackoverflow.com/questions/10091816/nsfilesystemfreesize-translating-result-into-user-friendly-display-of-mb-gb
//
//  Converted to swift by Phil Eggel on 30/11/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

func prettyBytes(numBytes: Int) -> String {
    let scale: Double = 1024
    let abbrevs = [ "EB", "PB", "TB", "GB", "MB", "KB", "Bytes"]
    let numAbbrevs = abbrevs.count
    
    let bytes = Double(numBytes)
    var maximum = pow(Double(scale), Double(numAbbrevs - 1))
    
    for i in 0..<numAbbrevs {
        if bytes > maximum {
            return String(format: "%0.2f %@", arguments: [bytes / maximum, abbrevs[i]])
        }
        
        maximum /= scale
    }
    
    return "\(numBytes) Bytes"
}