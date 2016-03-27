//
//  PAssert.swift
//
//  Created by keygx on 2015/08/06.
//  Copyright (c) 2015年 keygx. All rights reserved.
//

import XCTest

// MARK: - PAssert
public func PAssert<T>(@autoclosure lhs: () -> T, _ comparison: (T, T) -> Bool, @autoclosure _ rhs: () -> T,
                       filePath: StaticString = #file, lineNumber: UInt = #line, function: String = #function) {
    
    let pa = PAssertHelper()
    
    let result = comparison(lhs(), rhs())

    if !result {
        var source = pa.readSource(filePath.stringValue)
        
        if !source.isEmpty {
            source = pa.removeComment(source)
            source = pa.removeMultilinesComment(source)
            let out = pa.output(source: source, comparison: result, lhs: lhs(), rhs: rhs(),
                fileName: pa.getFilename(filePath.stringValue), lineNumber: lineNumber, function: function)
            
            XCTFail(out, file: filePath, line:UInt(lineNumber))
        }
    } else {
        print("")
        print("[\(pa.getDateTime()) \(pa.getFilename(filePath.stringValue)):\(lineNumber) \(function)] \(lhs())")
        print("")
    }
}

private class PAssertHelper {
    
    // MARK: - get datetime
    private func getDateTime() -> String {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        let localeIdentifier = NSLocale.currentLocale().localeIdentifier
        dateFormatter.locale = NSLocale(localeIdentifier: localeIdentifier)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.stringFromDate(now)
    }
    
    // MARK: - read source file
    private func readSource(filePath: String) -> String {
        var source = ""
        
        do {
            let code = try String(contentsOfFile:filePath, encoding: NSUTF8StringEncoding)
            source = code
        
        } catch let error as NSError {
            print(error)
        }
        
        return source
    }
    
    // MARK: - remove comments
    private func removeComment(source: String) -> String {
        var formatted = ""
        
        let pattern = "[ \t]*//.*"
        let replace = ""
        formatted = source.stringByReplacingOccurrencesOfString(pattern, withString: replace, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        
        return formatted
    }
    
    // MARK: - remove multiline comments
    private func removeMultilinesComment(source: String) -> String {
        var formatted = ""
        
        let pattern = "/\\*.*?\\*/"
        let replace = ""
        formatted = source.stringByReplacingOccurrencesOfString(pattern, withString: replace, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        
        return formatted
    }
    
    // MARK: - get literal
    private func getLiteral(source: String, lineNumber: UInt) -> String {
        var tmpLine = ""
        var literal = ""
        var lineIndex: UInt = 1
        var startBracket = 0
        var endBracket = 0
        
        source.enumerateLines {
            line, stop in
            
            if lineIndex >= lineNumber {
                tmpLine = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                for char in tmpLine.characters {
                    if char == "(" {
                        startBracket += 1
                    }
                    if char == ")" {
                        endBracket += 1
                    }
                }
                if startBracket == endBracket {
                    stop = true
                }
                literal += tmpLine
            }
            lineIndex += 1
        }
        
        return literal
    }
    
    // MARK: - formatt literal
    private func formattLiteral(literal: String) -> String {
        var formatted = ""
        
        let pattern = "(,\\s*)"
        let replace = ", "
        formatted = literal.stringByReplacingOccurrencesOfString(pattern, withString: replace, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        
        return formatted
    }
    
    // MARK: - get line indexes
    private func getIndexes(literal: String) -> Array<Int> {
        var location = 0
        var length = 0
        let pattern = ",(\\s*)[==|!=|>|<|>=|<=|===|!==|~=]+(\\s*),(\\s*)"
        
        var indexes: Array<Int> = [0, 0, 0]
        
        do {
            let regexp: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions())
            
            regexp.enumerateMatchesInString(literal, options: [], range: NSMakeRange(0, literal.characters.count),
                usingBlock: {(result: NSTextCheckingResult?, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if let result = result {
                        location = result.range.location
                        length = result.range.length
                    }
            })
            
            indexes[0] = "=> ".characters.count + "PAssert(".characters.count
            indexes[1] = "=> ".characters.count + location + 1
            indexes[2] = indexes[1] + length - 1 - 2
        
        } catch let error as NSError {
            print(error)
        }
        
        return indexes
    }
    
    // MARK: - get file name
    private func getFilename(filePath: String) -> String {
        var fileName = ""
        
        if let match = filePath.rangeOfString("[^/]*$", options: .RegularExpressionSearch) {
            fileName = filePath.substringWithRange(match)
        }
        
        return fileName
    }
    
    // MARK: - repeat character
    private func repeatCharacter(char: String, length: Int) -> String {
        var chars = ""
        
        if length > 0 {
            for _ in 0..<length {
                chars += char
            }
        }
        
        return chars
    }
    
    // MARK: - print result
    private func output<T>(source source: String?, comparison: Bool, lhs: T, rhs: T, fileName: String, lineNumber: UInt, function: String) -> String {
        
        let title = "=== Assertion Failed ============================================="
        let file = "FILE: \(fileName)"
        
        var out = "\n\n\(title)\n"
        out += "DATE: \(getDateTime())\n"
        out += "\(file)\n"
        out += "LINE: \(lineNumber)\n"
        out += "FUNC: \(function)\n"
        
        if let src = source {
            var literal = getLiteral(src, lineNumber: lineNumber) // return: PAssert(lhs, comparison, rhs)
            
            let indexes = getIndexes(literal)
            
            literal = "=> " + formattLiteral(literal)
            
            out += "\n"
            out += "\(literal)\n"
            
            var lValue = "\(lhs)"
            lValue = (lValue == "") ? "\"\"" : lValue
            lValue = "\(lValue)"
            
            var rValue = "\(rhs)"
            rValue = (rValue == "") ? "\"\"" : rValue
            rValue = "\(rValue)"
            
            let space1 = repeatCharacter(" ", length: indexes[0])
            let space2 = repeatCharacter(" ", length: indexes[1] - indexes[0])
            let space3 = repeatCharacter(" ", length: indexes[2] - indexes[1])
            
            out += "\(space1)|\(space2)|\(space3)|\n"
            out += "\(space1)|\(space2)|\(space3)\(rValue)\n"
            out += "\(space1)|\(space2)|\n"
            out += "\(space1)|\(space2)\(comparison)\n"
            out += "\(space1)|\n"
            out += "\(space1)\(lValue)\n"
        
        } else {
            out += "\n"
            out += "=> PAssert(...    ///// Could not output /////\n"
            out += "\n"
        }
        
        return out
    }
}
