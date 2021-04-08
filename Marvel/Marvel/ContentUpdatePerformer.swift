//
//  ContentUpdatePerformer.swift
//  Marvel
//
//  Created by Hugo Alonso on 08/04/2021.
//

import Foundation

protocol ContentUpdatePerformer {
    var onItemsChangeCallback: (() -> Void)? { get set }
}
