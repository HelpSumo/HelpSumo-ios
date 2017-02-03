# HelpSumoSDK

[![CI Status](http://img.shields.io/travis/Help Sumo/HelpSumoSDK.svg?style=flat)](https://travis-ci.org/Help Sumo/HelpSumoSDK)
[![Version](https://img.shields.io/cocoapods/v/HelpSumoSDK.svg?style=flat)](http://cocoapods.org/pods/HelpSumoSDK)
[![License](https://img.shields.io/cocoapods/l/HelpSumoSDK.svg?style=flat)](http://cocoapods.org/pods/HelpSumoSDK)
[![Platform](https://img.shields.io/cocoapods/p/HelpSumoSDK.svg?style=flat)](http://cocoapods.org/pods/HelpSumoSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HelpSumoSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "HelpSumoSDK"
```
## Usage

Import the Pod
    import HelpSumoSDK

Set API Key

   	// APIKey = “g9sfosdf8dfosdf7sfsfj3asdgh1m6” 
	HSConfig.setAPIKey(“g9sfosdf8dfosdf7sfsfj3asdgh1m6”)

To Add Ticket module

  	let frameworkBundle = Bundle(for:  TicketHomeController.self)
	let bundleURL = frameworkBundle.resourceURL?.AppendingPathComponent("HelpSumoSDK.bundle")
	let resourceBundle = Bundle(url: bundleURL!)
	let storyboard = UIStoryboard(name: "TicketList", bundle: resourceBundle)
	let controller = storyboard.instantiateViewController(withIdentifier: "ticketsHomeController") as UIViewController       
 	self.present(controller, animated: true, completion: nil)

To Add Faq module

  	let frameworkBundle = Bundle(for:  TicketHomeController.self)
	let bundleURL = frameworkBundle.resourceURL?.AppendingPathComponent( "HelpSumoSDK.bundle")
	let resourceBundle = Bundle(url: bundleURL!)
	let storyboard = UIStoryboard(name: "KnowledgeBase", bundle: resourceBundle)
	let controller = storyboard.instantiateViewController(withIdentifier:"knowledgeBoard") as UIViewController       
            
 	self.present(controller, animated: true, completion: nil)

To Add Article module

	let frameworkBundle = Bundle(for:  TicketHomeController.self)
	let bundleURL = frameworkBundle.resourceURL?.AppendingPathComponent( "HelpSumoSDK.bundle")
	let resourceBundle = Bundle(url: bundleURL!)
	let storyboard = UIStoryboard(name: "Article", bundle: resourceBundle)
	let controller = storyboard.instantiateViewController(withIdentifier: "articleBoard") 									as UIViewController       
	
 	self.present(controller, animated: true, completion: nil)

Permissions Required
	
	Add the following to info.plist file

		<key>NSPhotoLibraryUsageDescription</key>
		    <string>To upload images related to ticket</string>
		    <key>NSAppTransportSecurity</key>
		    <dict>
			<key>NSExceptionDomains</key>
			<dict>
			    <key>helpsumo.com</key>
			    <dict>
				<key>NSIncludesSubdomains</key>
				<true/>
				<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSTemporaryExceptionMinimumTLSVersion</key>
				<string>TLSv1.1</string>
			    </dict>
			</dict>
		    </dict>

## Author

Help Sumo, careysam@ajsquare.net

## License

HelpSumoSDK is available under the MIT license. See the LICENSE file for more info.
