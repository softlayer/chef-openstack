---
layout: page
title: Release Notes
slug: release-notes
lead: "A terse summary of recent changes, enhancements and fixes"
baseurl: "../"
---

# Release Overview

A new release for the {{ site.project }} is now available on GitHub. It includes new features and enhancements, as well as fixes for open issues. Browse the sections below to read more about what's available.

## Compatibility

Perform any updates before applying this update. This is necessary to ensure compatibility.

## Prerequisites

Upgrades should only be applied to systems with Grizzly or greater already installed. If you update it on a system prior to Grizzly, our APIs compatibility layer will no longer be compatible with OpenStack and Chef.

# Features and Enhancements

All new features, enhancements, and updates are listed below.

- In accordance with the USPS Rate Event, 6 new Express Mail rates were added.
- USPS Zip Zone table was updated to support the May 15th USPS changes.
- The USPS list of restricted APO & FPO locations for USPS Delivery Confirmation was updated.

# Issues Fixed

The following is a list of all fixes we have available in this release. 

* G2 prompted for USPS Delivery Confirmation details for UPS Ground RTS (Request-to-Send) records created using WebView. G2 would also throw a “Run-time error 13” message for FedEx RTS records created using WebView.
* While running Identical Pieces using “Next Account”, the IS/IM Series mailing system printed a different amount after switching to the next account. However, the rate on G2’s screen doesn't change.
* The package sequence numbers (e.g. “1 of 2”) were overlapping other text on UPS shipment labels.
* A meter strip tape would print out with postage applied to it when a Business Reply Mail job was being performed.
* The piece counts on Presort Reports were not always accurate, although they were accurate with Meter (Reconciliation) Reports and Meter Audit Reports.

### Known Issues

All known open issues are listed on [our GitHub public repo](https://github.com/softlayer/softlayer-api-python-client/issues?milestone=1&page=1&state=open).

### Other Updates

The eSS app was not updated for this release.

# Quick Install

Before running any install, it is recommended that you save and backup any work beforehand.

1. Download the installers from here.
2. Save the .ZIP file anywhere on the computer that iMCM G2 will be installed on. Extract the .EXE from it.
3. Double-click the .EXE file to start the installation.
4. Follow the on-screen instructions. The installation program will then install all the necessary components.

Our [Getting Started](../getting-started) guide or [Technical Documents](../technical-documents) go into more detail.

# Upgrade Notes

TBD 