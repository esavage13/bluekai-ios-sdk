## v1.5.0 (05.05.2014)
-----
Major internal code updates and enhancements.

### Bug fixes
- All third party classes are now BlueKai namespaced ([bug #4](https://github.com/BlueKai/bluekai-ios-sdk/issues/4))

### Enhancements
- General code clean up, bringing SDK to use ARC and updated deprecated syntax
- BlueKai SDK `NSLog`s can now be turned on/off via the `devMode` boolean
- All global variables are namespaced with `BlueKai_` prefix
- Upgrade `Reachability` class to the v3.5 (latest as of this release)
- More verbose inline documentation
- Update `README` documentation

### Deprecated
- The `setPreference` method was ambigiously and named and will be deprecated in favor of `setOptInPreference` method; no functionality change
- The `InitWithArgs` method is deprecated in favor of `InitWithSiteId:withAppVersion:withView:withDevMode`


## v1.0.1 (12.31.2013)
-----
No change should be required from v1.0.0 implementations.

### Enhancements
- Code cleanup
- When using the settings screen don't require ViewController
- Host static resource through GitHub
- New mobile proxy through GitHub


## v1.0.0 (08.20.2013)
-----
Initial SDK release.

- Initial release
- Pass individual hints or collections
