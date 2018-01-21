# Working Hours Tracker

[![Sponsored](https://img.shields.io/badge/chilicorn-sponsored-brightgreen.svg?logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAA4AAAAPCAMAAADjyg5GAAABqlBMVEUAAAAzmTM3pEn%2FSTGhVSY4ZD43STdOXk5lSGAyhz41iz8xkz2HUCWFFhTFFRUzZDvbIB00Zzoyfj9zlHY0ZzmMfY0ydT0zjj92l3qjeR3dNSkoZp4ykEAzjT8ylUBlgj0yiT0ymECkwKjWqAyjuqcghpUykD%2BUQCKoQyAHb%2BgylkAyl0EynkEzmkA0mUA3mj86oUg7oUo8n0k%2FS%2Bw%2Fo0xBnE5BpU9Br0ZKo1ZLmFZOjEhesGljuzllqW50tH14aS14qm17mX9%2Bx4GAgUCEx02JySqOvpSXvI%2BYvp2orqmpzeGrQh%2Bsr6yssa2ttK6v0bKxMBy01bm4zLu5yry7yb29x77BzMPCxsLEzMXFxsXGx8fI3PLJ08vKysrKy8rL2s3MzczOH8LR0dHW19bX19fZ2dna2trc3Nzd3d3d3t3f39%2FgtZTg4ODi4uLj4%2BPlGxLl5eXm5ubnRzPn5%2Bfo6Ojp6enqfmzq6urr6%2Bvt7e3t7u3uDwvugwbu7u7v6Obv8fDz8%2FP09PT2igP29vb4%2BPj6y376%2Bu%2F7%2Bfv9%2Ff39%2Fv3%2BkAH%2FAwf%2FtwD%2F9wCyh1KfAAAAKXRSTlMABQ4VGykqLjVCTVNgdXuHj5Kaq62vt77ExNPX2%2Bju8vX6%2Bvr7%2FP7%2B%2FiiUMfUAAADTSURBVAjXBcFRTsIwHAfgX%2FtvOyjdYDUsRkFjTIwkPvjiOTyX9%2FAIJt7BF570BopEdHOOstHS%2BX0s439RGwnfuB5gSFOZAgDqjQOBivtGkCc7j%2B2e8XNzefWSu%2BsZUD1QfoTq0y6mZsUSvIkRoGYnHu6Yc63pDCjiSNE2kYLdCUAWVmK4zsxzO%2BQQFxNs5b479NHXopkbWX9U3PAwWAVSY%2FpZf1udQ7rfUpQ1CzurDPpwo16Ff2cMWjuFHX9qCV0Y0Ok4Jvh63IABUNnktl%2B6sgP%2BARIxSrT%2FMhLlAAAAAElFTkSuQmCC)](http://spiceprogram.org/oss-sponsorship)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/olpeh/wht/pulls)
[![license](http://img.shields.io/badge/license-BSD-brightgreen.svg?style=flat)](https://github.com/olpeh/wht/blob/master/LICENSE.md)

An easy to use and simple Working Hours Tracker for SailfishOS

* v. 1.2.3-1 (for phone and tablet) available in Jolla store (06.11.2017)<br />
* Newest version available in [openrepos](https://openrepos.net/content/olpe/working-hours-tracker)
* Newest version also available with direct download [here](https://github.com/olpeh/wht/releases)

## Quick links

[Project page](https://wht.olpe.fi/)<br />
[Changelog](https://github.com/olpeh/wht/blob/master/qml/CHANGELOG.md)<br />
[Current features](#current-features)<br />
[License](https://github.com/olpeh/wht/blob/master/LICENSE.md)<br />
[Roadmap](https://github.com/olpeh/wht/projects/1)<br />
[How to use](#how-to-use)<br />
[Exporting](#exporting)<br />
[Importing](#importing)

![Working Hours Tracker GIF](wht.gif)

## Donate

Donations are welcome :)<br />

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=olpe&url=https%3A%2F%2Fgithub.com%2Folpeh%2Fwht&tags=github&category=software)

Paypal [EUR](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=9HY294XX4EJFW&lc=FI&item_name=Olpe&item_number=Working%20Hours%20Tracker¤cy_code=EUR&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)<br />
Paypal [USD](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=9HY294XX4EJFW&lc=FI&item_name=Olpe&item_number=Working%20Hours%20Tracker¤cy_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)

## Translate

Working Hours Tracker project is in transifex. Please contribute to translations there:

https://www.transifex.com/projects/p/working-hours-tracker/

### Updating resources in transifex

The file `.tx/config` contains the basic config for what needs to be pushed to tx.

`~/.transifexrc`, which stores your Transifex credentials in your home directory. You shouldn’t share this file since it contains your own credentials.

To push a source file, use the -s or --source flag with the push command:

`$ tx push -s`

To pull translations from Transifex, run the following command:

`$ tx pull -a`

## Current features:

* Adding hours
* Timer - saves starting time to database
* Viewing hours in different categories
* Deleting
* Editing
* Resetting database in settings
* Cover actions for timer and adding new hours
* Cover info for today, week and month
* Changing effort times by adjusting duration
* Adding break possibility
* Settings for default duration and default break
* Setting for timer autostart on app startup
* Break functionality in timer
* Possibility to adjust timer start time
* Support for different projects
* Project coloring
* Shows price for efforts if project hourlyrate is set
* Project view
* Category summary
* Email reports
* Exporting as csv
* Exporting as .sql dump
* Importing database dump
* Translations
* Logging
* Setting for default break in timer
* Tasks within projects
* Autofill last used input
* Rounding to nearest

## License

[See license here](https://github.com/olpeh/wht/blob/master/LICENSE.md)

## How to use

### Adding hours

Working Hours Tracker is quite easy to use. Adding hours can be done in two different ways.

1. You can access the add hours in the pulley menu on the first page. It takes you to the add page.
2. Start the timer when starting to work. You can then close the app if you want to and the timer will stay running. At the end of your work day, stop the timer and it should take you to the add page where you can adjust the details, add description and select the project.

### Adding projects

Projects can be added and edited in the settings. You can select the labelcolor and hourlyrate for a project. You can edit projects by clicking them. When editing a project you can select if you want to make that project the
default project which will be automatically selected when adding hours. If you set the hourlyrate for a project, you will see the price for spent hours in the detailed listing and summaries.

### Using the timer

Timer can be used by pressing the big button on the first page. When started, you will see three buttons for controlling the timer.

On the left you have a break button which is meant to be used if you have a break
during your workday that you don't want to include in the duration. Break works just like the timer: you start it by clicking it and stop it when the break is over.

The button in the middle stops the timer and takes you to the add page where you will be able to adjust the start and endtime and other details for the effort. The hours will be saved only when accepting the dialog.

On the right side you have a button for adjusting the timer start time. It can be used if you forget to start the timer when you start to work.

### Using the cover

Cover actions can be used to quickly add hours or to control the timer. Cover actions include adding hours, starting the timer, starting a break, ending a break and stopping the timer.

When stopping the timer from the cover, it should open up the appwindow in the add view and after closing the dialog it should get minimized back to cover.

### Summaries

On the first page you will see total hours for different categories. If you have more than one projects you should see a attached page that can be accessed by swiping left from the first page. There you can see hours for one project at a time

Clicking a category will take you to the detailed listing view where you can see all entries in that category. You can edit those entries by clicking them.

By swiping left in the detailed view you can see a detailed summary for that category.

### Settings

There are a few settings in the settings page that makes adding hours faster and easier. Default duration and default break duration will be used when manually adding hours. Starts now or Ends now by default means the option to select if you want the start time or the endtime be set to the time now when adding hours manually.

Other settings are explained in the settings page and more will come in the future versions.

### Exporting

In the settings you find different methods for exporting data from Working Hours Tracker.

When selecting to export Hours as CSV the syntax will look like this: <br />
<strong>'uid','date','startTime','endTime',duration,'project','description',breakDuration</strong><br />

Where entries surrounded by ' are strings (LONGVARCHAR or TEXT in the sqlite database) And durations are of type REAL with . as decimal separator. An example line would look like this:

'2015231425401087574','2015-04-20','12:38','18:44',6.1,'20153191429477190454','Code review',0

This is also the syntax which is expected for the .csv importing (Coming later...) Exporting as .csv from Working Hours Tracker will create the data in the right format but if you e.g want to import your existing data into Working Hours Tracker you can create .csv files in the above syntax. <br />
<strong>Please note that uid must be an unique id of type LONGVARCHAR and project should be an id of an existing project in your database.</strong><br />

Project in hours means a project id. <br /><br />
When exporting projects as CSV the syntax will look like this:<br />
<strong>'id','name',hourlyRate,contractRate,budget,hourBudget,'labelColor'</strong><br />

An example project line would look like this:<br />
'20153191429477190454','Project name',0,0,0,0,'#ccb865'

Exporting the whole database creates a sqlite dump of the database.<br />

### Importing

At the moment importing is only possible from a .sql file. The .csv file support will come later.<br />
Don't worry for duplicates when importing because the entries have unique id's and duplicates cannot exist in the database due to unique constraints.<br />

<strong>Please note that importing uses INSERT OR REPLACE so you can update edited entries.</strong>

### Startup commands

Still WIP (but it works)

#### Commands atm:

* `harbour-workinghourstracker --start`
* `harbour-workinghourstracker --stop`
