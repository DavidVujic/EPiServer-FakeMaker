Remove Common Framework

Introduction
============

From version 8, EPiServer Commerce no longer requires EPiServer Common Framework. This folder contains tools
to remove any Common Framework related config (including NHibernate) and database schema/data.

Alternatively, take a dependency to the EPiServer.CommonFramework and EPiServer.Common.Gadgets nuget packages
to continue using the Common Framework features. Depending on what features of Commerce 7 your site
uses, you may also have to replace classes that were removed in Commerce 8.

For more information, see the Breaking Changes document for EPiServer Commerce 8 on EPiServer World.

Usage
=====

1. Execute the RemoveCommonFramework.sql script in the database specified by the EPiServerCommon connection string
in your site (most likely the same as the CMS database).
Warning! This removes the schema as well as all the data of the Common Framework tables! It is recommended to back
up the affected database first.

2. Execute the powershell script RemoveCommonFrameworkConfig.ps1 with a reference to your site's path. Example:
PS> .\RemoveCommonFrameworkConfig C:\EPiServer\MyCommerceSite\wwwroot