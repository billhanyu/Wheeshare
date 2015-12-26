//
//  AppKeys.swift
//  Need&Give
//
//  Created by Bill Yu on 12/26/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import Foundation

struct AppKeys {
    
    struct PF {
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    struct User {
        static let email = "email"
        static let profilePic = "profilePic"
        static let facebookID = "FBID"
        static let telephone = "telNum"
    }
    
    struct ItemProperties {
        static let name = "Name"
        static let description = "detail"
        static let condition = "condition"
        static let category = "category"
        static let image = "image"
    }
    
    struct CellIdentifiers {
        static let loadingCell = "LoadingCell"
        static let noResultsCell = "NoResultsCell"
        static let listedCell = "ListedCell"
    }
    
    struct SegueIdentifiers {
        static let lendItem = "Given"
        static let detailReveal = "DetailReveal"
        static let showShare = "ShowShare"
    }
    
    struct ItemRelationship {
        static let requester = "requester"
        static let requestedLender = "requestedLender"
        static let owner = "giver"
        static let connected = "connected"
    }
}