//
//  Response.swift
//  SoftU2F
//
//  Created by Benjamin P Toews on 2/7/17.
//

import Foundation

enum ResponseError: Error {
    case BadSize
    case BadStatus
    case BadCertificate
    case BadData
}

protocol Response {
    var body: Data { get }
    var trailer: ResponseStatus { get }

    init(body: Data, trailer: ResponseStatus)

    func validateBody() throws
}

// Implement RawConvertible
extension Response {
    public var raw: Data {
        let writer = DataWriter()
        writer.writeData(body)
        writer.write(trailer)

        return writer.buffer
    }

    public init(raw: Data) throws {
        let reader = DataReader(data: raw)
        let body = try reader.readData(reader.remaining - 2)
        let trailer: ResponseStatus = try reader.read()

        self.init(body: body, trailer: trailer)

        try validateBody()
    }

    // For testing with libu2f-host
    public init(raw: Data, bodyOnly: Bool) throws {
        if bodyOnly {
            self.init(body: raw, trailer: .NoError)
        } else {
            try self.init(raw: raw)
        }
    }
}
