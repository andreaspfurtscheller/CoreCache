# CorePromises
CorePromises brings Promises to Swift and enables beautiful multi-thread and typesafe Swift code. CorePromises makes heavy use of generics, asynchronous networking and asynchronous programming in general is greatly facilitated. The framework is particularly useful when working with Apple's [Dispatch](https://developer.apple.com/documentation/dispatch), [Alamofire](https://github.com/Alamofire/Alamofire) or [WebParsing](https://github.com/borchero/WebParsing).

Since version 1.0.0, CorePromises is a fully thread-safe framework.

## Usage
CorePromises can be used with CocoaPods: simply add `CorePromises` to your podfile. It might, however, be advisable to copy the files into your project (especially if you encounter any problems regarding performance) to make use of generic specialization (that is currently not enabled for external frameworks). This may speed up your program significantly.

## Documentation
CorePromises is thoroughly documented:

- All symbols are documented using Swift Doc which has been converted to HTML documentation using [jazzy](https://github.com/realm/jazzy). This documentation is available on [GithubPages](https://borchero.github.io/CorePromises/). Also consider downloading [Dash](https://kapeli.com/dash) which provides searchable documentation for all CocoaPods projects, including CorePromises.
- A more general documentation will be added in the near future.

Feel free to file bug reports if you feel that something is not documented thoroughly enough.

## About the Current Version
CorePromises 1.0.0 is the first fully documented and tested release of CorePromises.
The framework is fully up to date for Swift 4 as of Xcode 9 Beta 6.

Tests have been added to guarantee basic functionality. Although the framework has successfully been tested and used in practice, do not hesitate filing bug reports if you encounter any errors or unexpected behavior that is documented nowhere.

This is particularly important as testing in a multi-threaded environment poses a major challenge.
