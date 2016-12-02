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
    var backgroundColor: UIColor {
        return .black
    }
    
    
    struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .segmentedControl
        }
        var height: CGFloat {
            return 30
        }
        var backgroundColor: UIColor {
            return .black
        }
        var selectedBackgroundColor: UIColor {
            return .black
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemSong(), MenuItemArtist(), MenuItemAlbum()]
        }
        var focusMode: MenuFocusMode {
            return .underline(height: 1.5, color: .green, horizontalPadding: 0, verticalPadding: 0)
        }
    }

    struct MenuItemSong: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
                        let title = MenuItemText(text: "Song", color: .lightGray, selectedColor: .green, font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    struct MenuItemArtist: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Artist", color: .lightGray, selectedColor: .green, font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    struct MenuItemAlbum: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Album", color: .lightGray, selectedColor: .green, font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
}
