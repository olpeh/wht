## [1.4.0-1] - 2021-02-20

### Fixed

- Fix color contrast issue in first page #81
- Fix previously used description selection when switching between projects or tasks #67

## [1.3.11-1] - 2019-09-13

### Fixed

- Fix sums not working #76 (thanks krzyc)

## [1.3.10-1] - 2019-09-10

### Fixed

- Fix removing break from a row – setting break to 0 does not remove it #75
- Fix a couple of warnings and deprecation errors

## [1.3.9-1] - 2019-09-09

### Fixed

- Fix CSV exporter #72 (thanks krzyc)
- Fix tasks on hours list #71 (thanks krzyc)

## [1.3.8-1] - 2019-08-25

### Fixed

- Generate UUID for new Projects #68 (thanks krzyc)
- Project/task not selected when editing entry #69 (thanks krzyc)

### Updated

- Updated translations

## [1.3.7-1] - 2018-02-11

### Fixed

- Display the correct duration in timer, with breaks deducted
- Fix task related issue caused by refactoring #65

## [1.3.6-1] - 2018-02-03

### Fixed

- Do not select all when focusing on description text field #63
- Update the view after editing a row #64

## [1.3.5-1] - 2018-02-03

### Fixed

- Fix the fix for broken rows in the database
- Remove dateless rows
- Add break when saving from command line if settings allow

### Updated

- Updated translations

## [1.3.4-1] - 2018-01-28

### Fixed

- Fix broken rows in the database
- Fix stopping from command line, issue #57

## [1.3.3-1] - 2018-01-20

### Fixed

- Refactor date handlings to fix most of the date related issues

### Added

- Add end date picker in order to be able to add longer hours or hours for night shifts etc.

# Changelog

## [1.2.5-1] - 2018-01-07

### Added

- Add timestamps to log entries for better debuggability (visible if logs are exported)

## [1.2.4-1] - 2017-11-07

### Fixed

- DB creation fails for new users #58

## [1.2.3-1] - 2017-11-05

### Added

- Better cover layout

## [1.2.2-1] - 2017-11-04

### Added

- Sort projects alphabetically

## [1.2.1-1] - 2016-06-23

### Fixed

- Bugfix for issue #51

### Updated

- Updated translations

## [1.2.0-1] - 2016-02-29

### Fixed

- Workaround for issue #39

### Added

- Possibility to use rounding (still experimental, untested)
- See settings -> Round to nearest

## [1.1.5-1] - 2016-01-26

### Fixed

- Fixed summary page layout
- Fixed first page layout when using the pulldown menu
- Decreased banner text size

## [1.1.4-5] - 2016-01-24

### Added

- Added version numbering to about page
- Added what's new dialog after updating

## [1.1.3-1] - 2016-01-23

### Fixed

- Scaling fixes for tablet version
- Fix annoying bug with the description text

## [1.1.2-1] - 2015-10-18

### Fixed

- More device agnostig item sizing and scaling
- Fix for remorse popup in landscape orientiation

### Added

- Appicons in different sizes

## [1.1.1-2] - 2015-10-10

### Fixed

- Bugfix: #36 unable to send email report

## [1.1.1-1] - 2015-08-18

- Added command line option for stopping and starting the timer

## [1.1.0-1] - 2015-08-12

### Changed

- Improved performance by using workerscript

### Fixed

- Bugfix: unable to save hours

## [1.0.9-2] - 2015-07-20

### Fixed

- Fixed norwegian translation was not working

## [1.0.9-1] - 2015-07-18

### Changed

- Some code refactoring

### Fixed

- Fixed a bug when adding hours from cover

### Added

- Automatically select last used input when adding hours
- BusyIndicator when loading hours from DB

## [1.0.8-1] - 2015-07-15

- Updated translations
- Updated contactinfo
- Added flattr link to about

## [1.0.7-1]

- Fixed task selection bug
- More flexible layout
- Enabled landscape mode
- Added new languages and updated translations

## [1.0.6-2]

- Added tasks selection
- Tasks can be added and edited in settings

## [1.0.5-1]

- Setting to use default break also in timer
- Fixed error with empty emails
- Use of haptics
- Fixed rounding bug in email reports

## [1.0.4-3]

- Updated translations
- Prepare for harbour update

## [1.0.3-1]

- Fixed issue with banner
- Added logging
- Added saving log file
- Added sending log file
- Small improvements

## [1.0.2-1]

- Fix the bug #23 (thx ttln)
- Added notification banner
- Added email reports sending
- Added exporting as CSV
- Added exporting as .sql
- Added importing .sql
- More input validation

## [1.0.1-1]

- Bugfixes: #10, #13 and #6
- Added translations for ca, zh_CN, nl_NL, fi, de, es

## [1.0.0-1]

- Initial harbour release
- Updated about page
- Added howto page
- Fixed two bugs

## [0.9.2-2]

- Added category summary view
- Added project view
- Changed to hh:mm format
- Added option to select currency string
- 2 bugfixes

## [0.8.9-2]

- Removed unused project properties
- Moved settings to first page pulley
- Added remorse timers to 2 settings
- Bugfix for #8 project was resetted to default

## [0.8.8-4]

- Support for different projects
- Project coloring
- Category view renewed layout

## [0.8.7-2]

- Added setting to autostart timer on app startup
- Added break functionality to the timer
- Fixed an issue when timer used from cover
- Simplified parts of the code
- Small bugfixes

## [0.8.6-1]

- redesigned the firstpage
- moved timer to firstpage
- fixed a few issues

## [0.8.4-1]

- Fix for settings (now gets saved)
- Small bugfix for values shown in firstpage

## [0.8.3-3]

- Modified cover text color
- Changed desktop name
- Added toggles to adding hours
- Added settings for default duration and break
- Fixed bug in deleting items
- Added donation links

## [0.8.2-1]

- Added validator for adding hours
- Added today to cover
- Added stop timer button to timer page
- Appwindow gets now deactivated when adding hours from the cover
- Two bugfixes

## [0.8.1-1]

- Fixed a bug in database creation

## [0.8.0-1]

- Added break possibility
- Minor bugfixes

## [0.7.0-2]

- Added new cover action
- Added cover info
- Adjusted colors
- Added possibility to change duration when adding

## [0.6.5-1]

- Added placeholder text
- Added category to pageheader
- Small bugfixes

## [0.6.4-1]

- Bugfix for adding

## [0.6.3-1]

- Added about info
- Created icons
- added settings page
- Fixed database resetting bug

## [0.6.2-1]

- Fixed sorting order
- Updating detailed view after edit
- added license

## [0.6.1-1]

- Added edition possibility
- Deletion possible
- Some bugfixes
