//
//  PAssert.swift
//  PAssert
//
//  Created by keygx on 2015/03/20.
//  Copyright (c) 2015年 keygx. All rights reserved.
//

import Foundation

public class PAssert {

    /**
        Setting at Xcode :
        ---------------------------------------
        Build Settings
            > Swift Compiler - Custom Flags
                > Other Swift Flags
                    > Debug    -D DEBUG

        Usage :
        ---------------------------------------
        #if DEBUG
            // Only Debugging
        #endif
    */


    // MARK: - assert
    public class func assert<T>(lhs: T, _ comparison: (T, T) -> Bool, _ rhs: T,
                filePath: String = __FILE__, lineNumber: Int = __LINE__, function: String = __FUNCTION__) {
        #if DEBUG

            let result = comparison(lhs, rhs)

            if !result {
                var source = readSource(filePath)

                if source != "" {
                    source = removeComment(source)
                    source = removeMultilinesComment(source)
                    output(source: source, comparison: result, lhs: lhs, rhs: rhs, fileName: getFilename(filePath), lineNumber: lineNumber, function: function)

                } else {
                    return
                }

            } else {
                println("[\(getDateTime()) \(getFilename(filePath)):\(lineNumber) \(function)] \(lhs)")
            }

        #endif
    }

    // MARK: - get datetime
    private class func getDateTime() -> String {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        let localeIdentifier = NSLocale.currentLocale().localeIdentifier
        dateFormatter.locale = NSLocale(localeIdentifier: localeIdentifier)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return dateFormatter.stringFromDate(now)
    }

    // MARK: - read source file
    private class func readSource(filePath: String) -> String {
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
    private class func removeComment(source: String) -> String {
        var formatted = ""

        let pattern = "[ \t]*//.*"
        let replace = ""
        formatted = source.stringByReplacingOccurrencesOfString(pattern, withString: replace, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)

        return formatted
    }

    // MARK: - remove multiline comments
    private class func removeMultilinesComment(source: String) -> String {
        var formatted = ""

        let pattern = "/\\*.*?\\*/"
        let replace = ""
        formatted = source.stringByReplacingOccurrencesOfString(pattern, withString: replace, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)

        return formatted
    }

    // MARK: - get literal
    private class func getLiteral(source: String, lineNumber: Int) -> String {
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
                    if char == "," {
                        ++comma
                    }
                }
                if comma == 2 && (startBracket == endBracket) {
                    stop = true
                }
                literal += tmpLine
            }
            lineIndex += 1
        }

        return literal
    }

    // MARK: - formatt literal
    private class func formattLiteral(literal: String) -> String {
        var formatted = ""

        let pattern = "(,\\s*)"
        let replace = ", "
        formatted = literal.stringByReplacingOccurrencesOfString(pattern, withString: replace, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)

        return formatted
    }

    // MARK: - get comma indexes
    private class func getIndexes(literal: String) -> Array<Int> {
        var indexes: Array<Int> = []
        var i = 0

        for char in literal {
            if char == "(" {
                if indexes.count == 0 {
                    indexes.append(i)
                }
            } else if char == "," {
                indexes.append(i)
            }
            ++i
        }

        return indexes
    }

    // MARK: - get file name
    private class func getFilename(filePath: String) -> String {
        var fileName = ""

        if let match = filePath.rangeOfString("[^/]*$", options: .RegularExpressionSearch) {
            fileName = filePath.substringWithRange(match)
        }

        return fileName
    }

    // MARK: - repeat character
    private class func repeatCharacter(char: String, length: Int) -> String {
        var chars = ""

        if length > 0 {
            for i in 0..<length {
                chars += char
            }
        }

        return chars
    }

    // MARK: - print result
    private class func output<T>(#source: String?, comparison: Bool, lhs: T, rhs: T, fileName: String, lineNumber: Int, function: String) {

        var literal = ""
        if var src = source {
            literal = getLiteral(src, lineNumber: lineNumber)
        }
        literal = "=> " + formattLiteral(literal)

        let indexes = getIndexes(literal)

        let file = "FILE: \(fileName)"
        let title = "=== Assertion Failed ==========================================================="

        println("\(title)")
        println("DATE: \(getDateTime())")
        println(file)
        println("LINE: \(lineNumber)")
        println("FUNC: \(function)")

        if indexes.count == 3 {
            println("")
            println(literal)

            var lValue = "\(lhs)"
            lValue = (lValue == "") ? "\"\"" : lValue

            var rValue = "\(rhs)"
            rValue = (rValue == "") ? "\"\"" : rValue

            var space1 = repeatCharacter(" ", length: indexes[0] + 1)
            var space2 = repeatCharacter(" ", length: indexes[1] - indexes[0])
            var space3 = repeatCharacter(" ", length: indexes[2] - indexes[1] - 1)

            println("\(space1)|\(space2)|\(space3)|")

            println("\(space1)|\(space2)|\(space3)\(rValue)")

            println("\(space1)|\(space2)|")

            println("\(space1)|\(space2)\(comparison)")

            println("\(space1)|")

            println("\(space1)\(lValue)")

            println("")

            //abort()

        } else {
            println("")
            println("=> pa.assert(... \n///// Could not output /////")
            println("")
        }
    }
}
