//
//  JSONEncoder+Network.swift
//  ALTENNetwork
//
//  Created by Rafael FERNANDEZ on 11/9/24.
//
import Foundation

public extension JSONEncoder {
    convenience init(outputFormatting: JSONEncoder.OutputFormatting) {
        self.init()
        self.outputFormatting = outputFormatting
    }
}
