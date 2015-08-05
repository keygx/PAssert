//
//  XCTest+PAssert.swift
//
//  Created by keygx on 2015/08/01.
//  Copyright (c) 2015年 keygx. All rights reserved.
//

import Foundation
import XCTest

extension XCTest {
    
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
        var error : NSError?
        var source = String(contentsOfFile:filePath, encoding: NSUTF8StringEncoding, error: &error)
        
        if error != nil {
            println("error: \(error)")
        }
        
        if let str = source {
            return str
        } else {
            return ""
        }
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
    private func getLiteral(source: String, lineNumber: Int) -> String {
        var tmpLine = ""
        var literal = ""
        var lineIndex = 1
        var startBracket = 0
        var endBracket = 0
        var comma = 0
        
        source.enumerateLines {
            line, stop in
            
            if lineIndex >= lineNumber {
                tmpLine = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
                for char in tmpLine {
                    if char == "(" {
                        ++startBracket
                    }
                    if char == ")" {
                        ++endBracket
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
        let regexp: NSRegularExpression? = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.allZeros, error: nil)
        
        if let regexp = regexp {
            regexp.enumerateMatchesInString(literal, options: nil, range: NSMakeRange(0, count(literal)),
                usingBlock: {(result: NSTextCheckingResult!, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    location = result.range.location
                    length = result.range.length
            })
        }
        
        var indexes: Array<Int> = [0, 0, 0]
        indexes[0] = count("=> ") + count("PAssert(")
        indexes[1] = count("=> ") + location + 1
        indexes[2] = indexes[1] + length - 1 - 2
        
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
            for i in 0..<length {
                chars += char
            }
        }
        
        return chars
    }
    
    // MARK: - print result
    private func output<T>(#source: String?, comparison: Bool, lhs: T, rhs: T, fileName: String, lineNumber: Int, function: String) -> String {
        
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
            
            var space1 = repeatCharacter(" ", length: indexes[0])
            var space2 = repeatCharacter(" ", length: indexes[1] - indexes[0])
            var space3 = repeatCharacter(" ", length: indexes[2] - indexes[1])
            
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

// MARK: - PAssert
func PAssert<T>(@autoclosure lhs: () -> T, comparison: (T, T) -> Bool, @autoclosure rhs: () -> T,
                filePath: String = __FILE__, lineNumber: Int = __LINE__, function: String = __FUNCTION__) {
    
    let test = XCTest()
    
    let result = comparison(lhs(), rhs())
    
    if !result {
        var source = test.readSource(filePath)
        
        if source != "" {
            source = test.removeComment(source)
            source = test.removeMultilinesComment(source)
            let out = test.output(source: source, comparison: result, lhs: lhs(), rhs: rhs(),
                                  fileName: test.getFilename(filePath), lineNumber: lineNumber, function: function)
            
            XCTFail(out, file: filePath, line:UInt(lineNumber))
        }
    } else {
        println("")
        println("[\(test.getDateTime()) \(test.getFilename(filePath)):\(lineNumber) \(function)] \(lhs())")
        println("")
    }
}
