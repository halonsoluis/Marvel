//
//  HTTPClient.swift
//  CharactersAPI
//
//  Created by Hugo Alonso on 17/11/2020.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}
