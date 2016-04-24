//
//  PlaceholderViewControllerSpec.swift
//  IVGRouter
//
//  Created by Douglas Sjoquist on 4/24/16.
//  Copyright © 2016 Ivy Gulch LLC. All rights reserved.
//

import UIKit
import Quick
import Nimble
import IVGRouter

extension PlaceholderViewController {
    var originalTabBarItem: UITabBarItem! {
        return super.tabBarItem
    }
    var originalNavigationItem: UINavigationItem {
        return super.navigationItem
    }
}

class PlaceholderViewControllerSpec: QuickSpec {

    override func spec() {

        describe("PlaceholderViewController") {

            context("when initiated with a child view controller") {

                let testTitle = "test title"
                var placeholderViewController: PlaceholderViewController!
                var childViewController: UIViewController!

                beforeEach {
                    childViewController = UIViewController()
                    childViewController.tabBarItem = UITabBarItem(title: testTitle, image: nil, selectedImage: nil)
                    childViewController.navigationItem.title = testTitle
                    placeholderViewController = PlaceholderViewController(childViewController: childViewController)
                }

                it("should automatically have a value for childViewController") {
                    expect(placeholderViewController.childViewController).to(equal(childViewController))
                }

                it("should only have one childViewController") {
                    expect(placeholderViewController.childViewControllers).to(haveCount(1))
                }

                it("should use child's tabBarItem") {
                    expect(placeholderViewController.tabBarItem).to(equal(childViewController.tabBarItem))
                    expect(placeholderViewController.originalTabBarItem).toNot(equal(childViewController.tabBarItem))
                }

                it("should use child's navigationItem") {
                    expect(placeholderViewController.navigationItem).to(equal(childViewController.navigationItem))
                    expect(placeholderViewController.originalNavigationItem).toNot(equal(childViewController.navigationItem))
                }

                it("should keep child view frame in sync") {
                    expect(placeholderViewController.view.bounds).to(equal(childViewController.view.frame))
                    placeholderViewController.view.frame = CGRect(x: 20, y: 20, width: 200, height: 200)
                    expect(placeholderViewController.view.bounds).to(equal(childViewController.view.frame))
                    placeholderViewController.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    expect(placeholderViewController.view.bounds).to(equal(childViewController.view.frame))
                }

            }


            context("when initiated with a lazy loader") {

                let testTitle = "test title"
                var placeholderViewController: PlaceholderViewController!
                var childViewController: UIViewController!

                beforeEach {
                    childViewController = UIViewController()
                    childViewController.tabBarItem = UITabBarItem(title: testTitle, image: nil, selectedImage: nil)
                    childViewController.navigationItem.title = testTitle
                    placeholderViewController = PlaceholderViewController(lazyLoader: {
                        Void -> UIViewController in
                        return childViewController
                    })
                }

                it("should not automatically have a value for childViewController") {
                    expect(placeholderViewController.childViewController).to(beNil())
                }

                it("should only have no childViewControllers") {
                    expect(placeholderViewController.childViewControllers).to(beEmpty())
                }

                it("should not have tabBarItem title") {
                    expect(placeholderViewController.tabBarItem.title).to(beNil())
                }

                it("should not have navigationItem title") {
                    expect(placeholderViewController.navigationItem.title).to(beNil())
                }


                context("but after loading") {

                    beforeEach {
                        placeholderViewController.loadViewIfNeeded()
                    }

                    it("should automatically have a value for childViewController") {
                        expect(placeholderViewController.childViewController).to(equal(childViewController))
                    }

                    it("should only have one childViewController") {
                        expect(placeholderViewController.childViewControllers).to(haveCount(1))
                    }

                    it("should use child's tabBarItem") {
                        expect(placeholderViewController.tabBarItem).to(equal(childViewController.tabBarItem))
                        expect(placeholderViewController.originalTabBarItem).toNot(equal(childViewController.tabBarItem))
                    }

                    it("should use child's navigationItem") {
                        expect(placeholderViewController.navigationItem).to(equal(childViewController.navigationItem))
                        expect(placeholderViewController.originalNavigationItem).toNot(equal(childViewController.navigationItem))
                    }

                    it("should keep child view frame in sync") {
                        expect(placeholderViewController.view.bounds).to(equal(childViewController.view.frame))
                        placeholderViewController.view.frame = CGRect(x: 20, y: 20, width: 200, height: 200)
                        expect(placeholderViewController.view.bounds).to(equal(childViewController.view.frame))
                        placeholderViewController.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        expect(placeholderViewController.view.bounds).to(equal(childViewController.view.frame))
                    }
                    
                }
                
            }
            
        }
        
    }
    
}
