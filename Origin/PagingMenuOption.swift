//
//  PagingMenuOption.swift
//  Origin
//
//  Created by Gen on 2016/12/02.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import PagingMenuController


struct MenuItemSong: MenuItemViewCustomizable {}
struct MenuItemArtist: MenuItemViewCustomizable {}
struct MenuItemAlbum: MenuItemViewCustomizable {}

struct PagingMenuOption: PagingMenuControllerCustomizable {
    let songViewController = SongViewController.instantiateFromStoryboard()
    let artistViewController = ArtistViewController.instantiateFromStoryboard()
    let albumViewController = AlbumViewController.instantiateFromStoryboard()
    
    var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: [songViewController, artistViewController, albumViewController])
    }
    var menuControllerSet: MenuControllerSet {
        return .single
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .segmentedControl
        }
        var height: CGFloat {
            return 30
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemSong(), MenuItemArtist(), MenuItemAlbum()]
        }
    }
    
    struct MenuItemSong: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Song")
            return .text(title: title)
        }
    }
    struct MenuItemArtist: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Artist")
            return .text(title: title)
        }
    }
    struct MenuItemAlbum: MenuItemViewCustomizable {
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Album")
            return .text(title: title)
        }
    }
}
