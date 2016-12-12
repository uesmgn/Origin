//
//  D_PagingMenuOption.swift
//  Origin
//
//  Created by Gen on 2016/12/10.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import PagingMenuController

struct MenuItemAll: MenuItemViewCustomizable {}
struct MenuItemPop: MenuItemViewCustomizable {}
struct MenuItemAnime: MenuItemViewCustomizable {}
struct MenuItemDance: MenuItemViewCustomizable {}
struct MenuItemHipHop: MenuItemViewCustomizable {}
struct MenuItemRock: MenuItemViewCustomizable {}
struct MenuItemJPop: MenuItemViewCustomizable {}
struct MenuItemOther: MenuItemViewCustomizable {}

struct D_PagingMenuOption: PagingMenuControllerCustomizable {
    
    let allViewController = AllViewController.instantiateFromStoryboard()
    let popViewController = PopViewController.instantiateFromStoryboard()
    let aniViewController = AnimeViewController.instantiateFromStoryboard()
    let danViewController = DanceViewController.instantiateFromStoryboard()
    let hipViewController = HipHopViewController.instantiateFromStoryboard()
    let rocViewController = RockViewController.instantiateFromStoryboard()
    let jpoViewController = JPopViewController.instantiateFromStoryboard()
    let otherViewController = OtherViewController.instantiateFromStoryboard()
    
    var componentType: ComponentType {
        return .all(menuOptions: MenuOptions(), pagingControllers: [allViewController, jpoViewController, rocViewController, popViewController, aniViewController,danViewController, hipViewController, otherViewController])
    }
    
    var lazyLoadingPage: LazyLoadingPage {
        return .three
    }
    
    var backgroundColor: UIColor {
        return .black
    }
    
    struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .standard(widthMode: .fixed(width: 50), centerItem: false, scrollingMode: .scrollEnabled)
        }
        //.standard(widthMode: .flexible, centerItem: true, scrollingMode: .pagingEnabled)
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
            return [MenuItemAll(), MenuItemJPop(), MenuItemRock(), MenuItemPop(), MenuItemAnime(), MenuItemDance(), MenuItemHipHop(),MenuItemOther(),]
        }
        var focusMode: MenuFocusMode {
            return .underline(height: 1.5, color: UIColor(hex: "4caf50"), horizontalPadding: 0, verticalPadding: 0)
        }
    }
    
    struct MenuItemAll: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "All", color: .lightGray, selectedColor: UIColor(hex: "4caf50"), font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    struct MenuItemPop: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Pop", color: .lightGray, selectedColor: UIColor(hex: "4caf50"), font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    struct MenuItemAnime: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Anime", color: .lightGray, selectedColor: UIColor(hex: "4caf50"), font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    struct MenuItemDance: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Dance", color: .lightGray, selectedColor: UIColor(hex: "4caf50"), font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    struct MenuItemHipHop: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "HipHop/Rap", color: .lightGray, selectedColor: UIColor(hex: "4caf50"), font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    struct MenuItemRock: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Rock", color: .lightGray, selectedColor: UIColor(hex: "4caf50"), font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    struct MenuItemJPop: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "JPop", color: .lightGray, selectedColor: UIColor(hex: "4caf50"), font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    
    struct MenuItemOther: MenuItemViewCustomizable {
        let font = UIFont(name: "HelveticaNeue", size: 12)
        let selectedfont = UIFont(name: "HelveticaNeue-Bold", size: 12)
        var displayMode: MenuItemDisplayMode {
            let title = MenuItemText(text: "Other", color: .lightGray, selectedColor: UIColor(hex: "4caf50"), font: font!, selectedFont: selectedfont!)
            return .text(title: title)
        }
    }
    
}
