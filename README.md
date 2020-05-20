# oeci_scraper

`oeci_scraper` scrapes case information from the Oregon eCourt Case Information (OECI) system.

![oei_scraper demo](https://oeci.s3-us-west-2.amazonaws.com/demo.gif)

## Table of Contents

- Overview
- Installation
- Use
- About
- Disclaimer
- License

## Overview

Oregon eCourt Case Information (OECI) provides electronic access to state trial court records. OECI does not have a public API. Programatic access to state court files is therefore extremely limited. `oeci_scraper` demonstrates one way to scrape this data.

## Installation

``

`oeci_scraper` requires a OECI username and password. Credentials are stored in environment variables.

For more information about OECI signup and fees:

- Signup https://www.courts.oregon.gov/services/online/Pages/ojcin-signup.aspx
- Fees https://www.courts.oregon.gov/forms/Documents/OJCINFeeSchedule.pdf

## Use

`oeci_scraper` runs from the console using Ruby. After installing the relevant files and ensuring all dependencies are installed (see below) run `ruby scraper.rb` from the script's directory.

## About

`oeci_scraper` uses open source software to scrape OECI and spit out data in a useful JSON format. Please consider that this is meant to be a toy script, not a production app or comprehensive software package. I work full-time and this is just a hobby project I wanted to share publicly. If you are itching to contribute features, bug fixes, etc., please contact me or submit a PR.

`oeci_scraper` runs primarily in the terminal and is limited for the time being to very rudimentary functionality. It is easy enough to expand and modify the code for use elsewhere. Please don't expect `oeci_scraper` to be ready for many use cases - it probably is not. Likewise, you will probably encounter bugs while using `oeci_scraper`.

`oeci_scaper` uses a Ruby-based automated testing library called Watir http://watir.com/. Watir uses another software called Selenium that drives a web browser (Firefox in this case[1]), which, in turn, navigates to the necessary places on OECI to quickly access data. Then, another open source software called Nokogiri[2] extracts the data and organizes it into a useful format (JSON, in this example). From here, you can do with the data what you wish.

## Disclaimer

This code is __only__ meant to demonstrate a rough sketch of how one might use a computer to gather case file information. In reading the code, it is easy to imagine how one might alter it to expand temporal scope, run at set times, work in various frameworks (e.g., Ruby on Rails, Django, Node), etc.


## License

The Beer-Ware License (Revision 42 from Poul-Henning Kamp https://people.freebsd.org/~phk/):
 <joel@worklaw.io> wrote the code in this repo.  As long as you retain this notice you can do whatever you want with this stuff. If we meet some day, and you think this stuff is worth it, you can buy me a beer in return. -Joel Christiansen
