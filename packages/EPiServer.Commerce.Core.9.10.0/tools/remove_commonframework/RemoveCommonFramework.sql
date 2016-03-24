--beginvalidatingquery
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME like 'tblEPiServerCommon%') 
		SELECT 1, 'Removing EPiServer Common database'
ELSE 
    select 0, 'Already remove EPiServer Common database' 
--endvalidatingquery

GO

-- remove FOREIGN KEY 
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEventCounterEventDay_tblEPiServerCommonCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventDay]'))
ALTER TABLE [dbo].[tblEPiServerCommonEventCounterEventDay] DROP [FK_tblEPiServerCommonEventCounterEventDay_tblEPiServerCommonCategory] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEventCounterEventDay_tblEPiServerCommonEventGroup]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventDay]'))
ALTER TABLE [dbo].[tblEPiServerCommonEventCounterEventDay]  DROP [FK_tblEPiServerCommonEventCounterEventDay_tblEPiServerCommonEventGroup] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEventCounterEventHour_tblEPiServerCommonCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventHour]'))
ALTER TABLE [dbo].[tblEPiServerCommonEventCounterEventHour] DROP [FK_tblEPiServerCommonEventCounterEventHour_tblEPiServerCommonCategory] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEventCounterEventHour_tblEPiServerCommonEventGroup]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventHour]'))
ALTER TABLE [dbo].[tblEPiServerCommonEventCounterEventHour]  DROP [FK_tblEPiServerCommonEventCounterEventHour_tblEPiServerCommonEventGroup]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEventCounterEventLog_tblEPiServerCommonCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventLog]'))
ALTER TABLE [dbo].[tblEPiServerCommonEventCounterEventLog] DROP [FK_tblEPiServerCommonEventCounterEventLog_tblEPiServerCommonCategory] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEventCounterEventLog_tblEPiServerCommonEventGroup]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventLog]'))
ALTER TABLE [dbo].[tblEPiServerCommonEventCounterEventLog]  DROP [FK_tblEPiServerCommonEventCounterEventLog_tblEPiServerCommonEventGroup] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEventCounterEventMonth_tblEPiServerCommonCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventMonth]'))
ALTER TABLE [dbo].[tblEPiServerCommonEventCounterEventMonth] DROP [FK_tblEPiServerCommonEventCounterEventMonth_tblEPiServerCommonCategory] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEventCounterEventMonth_tblEPiServerCommonEventGroup]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventMonth]'))
ALTER TABLE [dbo].[tblEPiServerCommonEventCounterEventMonth]  DROP [FK_tblEPiServerCommonEventCounterEventMonth_tblEPiServerCommonEventGroup]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonRatableItem_tblEntityType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonRatableItem]'))
ALTER TABLE [dbo].[tblEPiServerCommonRatableItem] DROP [FK_tblEPiServerCommonRatableItem_tblEntityType]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonCategory_tblEPiServerCommonCategory_Parent]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonCategory]'))
ALTER TABLE [dbo].[tblEPiServerCommonCategory] DROP [FK_tblEPiServerCommonCategory_tblEPiServerCommonCategory_Parent] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItem_tblEPiServerCommonAuthor]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItem]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItem]  DROP [FK_tblEPiServerCommonTagItem_tblEPiServerCommonAuthor] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItem_tblEntityType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItem]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItem]  DROP [FK_tblEPiServerCommonTagItem_tblEntityType]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItem_tblEPiServerCommonCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItem]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItem]  DROP [FK_tblEPiServerCommonTagItem_tblEPiServerCommonCategory] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItem_tblTag]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItem]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItem]  DROP [FK_tblEPiServerCommonTagItem_tblTag] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonAttributeValueFloat_tblEPiServerCommonAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueFloat]'))
ALTER TABLE [dbo].[tblEPiServerCommonAttributeValueFloat]  DROP [FK_tblEPiServerCommonAttributeValueFloat_tblEPiServerCommonAttribute] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonAttributeValueString_tblEPiServerCommonAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueString]'))
ALTER TABLE [dbo].[tblEPiServerCommonAttributeValueString]  DROP [FK_tblEPiServerCommonAttributeValueString_tblEPiServerCommonAttribute] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagPredefinedTag_tblEPiServerCommonAuthor]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagPredefinedTag]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagPredefinedTag]  DROP [FK_tblEPiServerCommonTagPredefinedTag_tblEPiServerCommonAuthor] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagPredefinedTag_tblEntityType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagPredefinedTag]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagPredefinedTag]  DROP [FK_tblEPiServerCommonTagPredefinedTag_tblEntityType]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagPredefinedTag_tblTag]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagPredefinedTag]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagPredefinedTag]  DROP [FK_tblEPiServerCommonTagPredefinedTag_tblTag] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItemCount_tblEPiServerCommonAuthor]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItemCount]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItemCount]  DROP [FK_tblEPiServerCommonTagItemCount_tblEPiServerCommonAuthor] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItemCount_tblEntityType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItemCount]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItemCount]  DROP [FK_tblEPiServerCommonTagItemCount_tblEntityType] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItemCount_tblEPiServerCommonCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItemCount]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItemCount]  DROP [FK_tblEPiServerCommonTagItemCount_tblEPiServerCommonCategory] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItemCount_tblTag]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItemCount]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItemCount]  DROP [FK_tblEPiServerCommonTagItemCount_tblTag] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonAttributeValueDateTime_tblEPiServerCommonAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueDateTime]'))
ALTER TABLE [dbo].[tblEPiServerCommonAttributeValueDateTime]  DROP [FK_tblEPiServerCommonAttributeValueDateTime_tblEPiServerCommonAttribute]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonAttributeValueInteger_tblEPiServerCommonAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueInteger]'))
ALTER TABLE [dbo].[tblEPiServerCommonAttributeValueInteger]  DROP [FK_tblEPiServerCommonAttributeValueInteger_tblEPiServerCommonAttribute] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonUserAdministrativeAccessRight_tblEPiServerCommonAccessRightSection]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonUserAdministrativeAccessRight]'))
ALTER TABLE [dbo].[tblEPiServerCommonUserAdministrativeAccessRight]  DROP [FK_tblEPiServerCommonUserAdministrativeAccessRight_tblEPiServerCommonAccessRightSection] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonGroupAdministrativeAccessRight_tblEPiServerCommonAccessRightSection]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonGroupAdministrativeAccessRight]'))
ALTER TABLE [dbo].[tblEPiServerCommonGroupAdministrativeAccessRight]  DROP [FK_tblEPiServerCommonGroupAdministrativeAccessRight_tblEPiServerCommonAccessRightSection] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonGroupUser_tblEPiServerCommonGroup]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonGroupUser]'))
ALTER TABLE [dbo].[tblEPiServerCommonGroupUser]  DROP [FK_tblEPiServerCommonGroupUser_tblEPiServerCommonGroup] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonGroupUser_tblEPiServerCommonUser]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonGroupUser]'))
ALTER TABLE [dbo].[tblEPiServerCommonGroupUser]  DROP [FK_tblEPiServerCommonGroupUser_tblEPiServerCommonUser] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonAttributeValueChoiceInteger_tblEPiServerCommonAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueChoiceInteger]'))
ALTER TABLE [dbo].[tblEPiServerCommonAttributeValueChoiceInteger]  DROP [FK_tblEPiServerCommonAttributeValueChoiceInteger_tblEPiServerCommonAttribute] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonAttributeValueChoiceString_tblEPiServerCommonAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueChoiceString]'))
ALTER TABLE [dbo].[tblEPiServerCommonAttributeValueChoiceString]  DROP [FK_tblEPiServerCommonAttributeValueChoiceString_tblEPiServerCommonAttribute] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonAttributeValueChoiceDateTime_tblEPiServerCommonAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueChoiceDateTime]'))
ALTER TABLE [dbo].[tblEPiServerCommonAttributeValueChoiceDateTime]  DROP [FK_tblEPiServerCommonAttributeValueChoiceDateTime_tblEPiServerCommonAttribute] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonAttributeValueChoiceFloat_tblEPiServerCommonAttribute]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueChoiceFloat]'))
ALTER TABLE [dbo].[tblEPiServerCommonAttributeValueChoiceFloat]  DROP [FK_tblEPiServerCommonAttributeValueChoiceFloat_tblEPiServerCommonAttribute] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonCategoryItem_tblEPiServerCommonCategory]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonCategoryItem]'))
ALTER TABLE [dbo].[tblEPiServerCommonCategoryItem]  DROP [FK_tblEPiServerCommonCategoryItem_tblEPiServerCommonCategory] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonCategoryItem_tblEntityType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonCategoryItem]'))
ALTER TABLE [dbo].[tblEPiServerCommonCategoryItem]  DROP [FK_tblEPiServerCommonCategoryItem_tblEntityType] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonTagItemCountArchive_tblEPiServerCommonTagItemCount]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItemCountArchive]'))
ALTER TABLE [dbo].[tblEPiServerCommonTagItemCountArchive]  DROP [FK_tblEPiServerCommonTagItemCountArchive_tblEPiServerCommonTagItemCount]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonReport_tblEPiServerCommonReportMatter]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonReport]'))
ALTER TABLE [dbo].[tblEPiServerCommonReport]  DROP [FK_tblEPiServerCommonReport_tblEPiServerCommonReportMatter] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonRatableItem_tblEPiServerCommonRatingLog]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonRatingLog]'))
ALTER TABLE [dbo].[tblEPiServerCommonRatingLog]  DROP [FK_tblEPiServerCommonRatableItem_tblEPiServerCommonRatingLog]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonVisitLog_tblEPiServerCommonVisitableItem]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonVisitLog]'))
ALTER TABLE [dbo].[tblEPiServerCommonVisitLog]  DROP [FK_tblEPiServerCommonVisitLog_tblEPiServerCommonVisitableItem] 
GO

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwEPiServerCommonAuthor]'))
	DROP VIEW [dbo].[vwEPiServerCommonAuthor]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonOwnership_tblEntityType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonOwnership]'))
ALTER TABLE [dbo].[tblEPiServerCommonOwnership]  DROP [FK_tblEPiServerCommonOwnership_tblEntityType] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonOwnership_tblEntityType1]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonOwnership]'))
ALTER TABLE [dbo].[tblEPiServerCommonOwnership]  DROP [FK_tblEPiServerCommonOwnership_tblEntityType1] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonOwnership_tblEPiServerCommonOwnerContext]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonOwnership]'))
ALTER TABLE [dbo].[tblEPiServerCommonOwnership]  DROP [FK_tblEPiServerCommonOwnership_tblEPiServerCommonOwnerContext] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEntityGroupAccessRights_tblEPiServerCommonGroup]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEntityGroupAccessRights]'))
ALTER TABLE [dbo].[tblEPiServerCommonEntityGroupAccessRights]  DROP [FK_tblEPiServerCommonEntityGroupAccessRights_tblEPiServerCommonGroup] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEntityGroupAccessRights_tblEntityType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEntityGroupAccessRights]'))
ALTER TABLE [dbo].[tblEPiServerCommonEntityGroupAccessRights]  DROP [FK_tblEPiServerCommonEntityGroupAccessRights_tblEntityType] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEntityUserAccessRights_tblEntityType]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEntityUserAccessRights]'))
ALTER TABLE [dbo].[tblEPiServerCommonEntityUserAccessRights]  DROP [FK_tblEPiServerCommonEntityUserAccessRights_tblEntityType]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonUserOpenID]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonUserOpenID]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonOwnerContext]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonOwnerContext]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEntityGroupAccessRights]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEntityGroupAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEntityUserAccessRights]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEntityUserAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonOwnership]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonOwnership]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonSetting]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonSetting]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonUserModuleAccessRight]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonUserModuleAccessRight]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonSite]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonSite]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonSiteRemoveObjectReferences]'))
	DROP TRIGGER [dbo].[trEPiServerCommonSiteRemoveObjectReferences]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAccessRightSection]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAccessRightSection]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonPasswordProvider]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonPasswordProvider]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonGroup]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonGroup]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonGroupRemoveObjectReferences]'))
	DROP TRIGGER [dbo].[trEPiServerCommonGroupRemoveObjectReferences]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonUser]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonUser]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonUserRemoveObjectReferences]'))
	DROP TRIGGER [dbo].[trEPiServerCommonUserRemoveObjectReferences]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonUserOnPermanentRemoval]'))
	DROP TRIGGER [dbo].[trEPiServerCommonUserOnPermanentRemoval]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonUserOnSoftRemoval]'))
	DROP TRIGGER [dbo].[trEPiServerCommonUserOnSoftRemoval]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonGroupChildren]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonGroupChildren]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttribute]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttribute]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTag]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonTag]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonActivityLog]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonActivityLog]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonGroupModuleAccessRight]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonGroupModuleAccessRight]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonVisitableItem]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonVisitableItem]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonScheduledTaskStarter]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonScheduledTaskStarter]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonRatableItem]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonRatableItem]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonCategory]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonCategory]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItem]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonTagItem]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonTagRemoveTagItemAuthor]'))
	DROP TRIGGER [dbo].[trEPiServerCommonTagRemoveTagItemAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonReportCase]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonReportCase]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueFloat]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttributeValueFloat]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueString]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttributeValueString]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagPredefinedTag]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonTagPredefinedTag]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonTagRemoveTagPredefinedTagAuthor]'))
	DROP TRIGGER [dbo].[trEPiServerCommonTagRemoveTagPredefinedTagAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItemCount]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonTagItemCount]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonTagRemoveTagItemCountAuthor]'))
	DROP TRIGGER [dbo].[trEPiServerCommonTagRemoveTagItemCountAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueDateTime]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttributeValueDateTime]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueInteger]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttributeValueInteger]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonUserAdministrativeAccessRight]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonUserAdministrativeAccessRight]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonGroupAdministrativeAccessRight]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonGroupAdministrativeAccessRight]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonGroupUser]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonGroupUser]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAuthor]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueChoiceInteger]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttributeValueChoiceInteger]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueChoiceString]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttributeValueChoiceString]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueChoiceDateTime]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttributeValueChoiceDateTime]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonAttributeValueChoiceFloat]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonAttributeValueChoiceFloat]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonCategoryItem]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonCategoryItem]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonTagItemCountArchive]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonTagItemCountArchive]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonReport]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonReport]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonReportCaseDecreaseReportCaseCounter]'))
	DROP TRIGGER [dbo].[trEPiServerCommonReportCaseDecreaseReportCaseCounter]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonReportCaseIncreaseReportCaseCounter]'))
	DROP TRIGGER [dbo].[trEPiServerCommonReportCaseIncreaseReportCaseCounter]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonRatingLog]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonRatingLog]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonRatingRemoveRatingAuthor]'))
	DROP TRIGGER [dbo].[trEPiServerCommonRatingRemoveRatingAuthor]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trOnDeleteRecalculateValuesOnRatableItem]'))
	DROP TRIGGER [dbo].[trOnDeleteRecalculateValuesOnRatableItem]
GO


IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trOnInsertRecalculateValuesOnRatableItem]'))
	DROP TRIGGER [dbo].[trOnInsertRecalculateValuesOnRatableItem]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonVisitLog]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonVisitLog]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonOnDeleteRecalculateValuesOnVisitableItem]'))
	DROP TRIGGER [dbo].[trEPiServerCommonOnDeleteRecalculateValuesOnVisitableItem]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonOnInsertRecalculateValuesOnVisitableItem]'))
	DROP TRIGGER [dbo].[trEPiServerCommonOnInsertRecalculateValuesOnVisitableItem]
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[trEPiServerCommonRemoveVisitAuthor]'))
	DROP TRIGGER [dbo].[trEPiServerCommonRemoveVisitAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonComment]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonComment]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[trEPiServerCommonRemoveCommentAuthor]') AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
	DROP TRIGGER [dbo].[trEPiServerCommonRemoveCommentAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonOpenIDUserRealm]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonOpenIDUserRealm]
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonEntityUserAccessRights_tblEPiServerCommonUser]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEntityUserAccessRights]'))
ALTER TABLE [dbo].[tblEPiServerCommonEntityUserAccessRights]  DROP [FK_tblEPiServerCommonEntityUserAccessRights_tblEPiServerCommonUser] 
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_tblEPiServerCommonUserOpenID_tblEPiServerCommonUser]') AND parent_object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonUserOpenID]'))
ALTER TABLE [dbo].[tblEPiServerCommonUserOpenID]  DROP [FK_tblEPiServerCommonUserOpenID_tblEPiServerCommonUser] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventLog]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEventCounterEventLog]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventHour]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEventCounterEventHour]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventDay]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEventCounterEventDay]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventName]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEventCounterEventName]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterJobLog]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEventCounterJobLog]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventCounterEventMonth]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEventCounterEventMonth]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblEPiServerCommonEventGroup]') AND type in (N'U'))
	DROP TABLE [dbo].[tblEPiServerCommonEventGroup]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUserCount]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUserCount]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUserByUserName]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUserByUserName]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveAllAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveAllAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveUser]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveUser]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonSetAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUserExist]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUserExist]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAccessOwnersForObject]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAccessOwnersForObject]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetUserReportStatsByUser]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingGetUserReportStatsByUser] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetUserReportStatsOnUser]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingGetUserReportStatsOnUser] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetReportingUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingGetReportingUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetReportedUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingGetReportedUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUsersRatedItems]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUsersRatedItems]	
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetReports]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingGetReports]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetReportCases]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingGetReportCases]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnEPiServerCommonCalculatePopularity]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[fnEPiServerCommonCalculatePopularity]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetCategorizedItems]') AND type in (N'P', N'PC'))
	DROP PROCEDURE  [dbo].[spEPiServerCommonGetCategorizedItems]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetRatings]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetRatings]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAttributeValues]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAttributeValues]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetRatedItems]') AND type in (N'P', N'PC'))
	DROP PROCEDURE  [dbo].[spEPiServerCommonGetRatedItems]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAttributeValueChoices]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAttributeValueChoices]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonClearAttributeValueChoices]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonClearAttributeValueChoices]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonClearAttributeValues]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonClearAttributeValues]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAttributeStartOfValueSequence]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAttributeStartOfValueSequence]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsGetVisits]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsGetVisits] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsCleanUserVisits]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsCleanUserVisits] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsRemoveAllVisits]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsRemoveAllVisits]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsGetNumVisits]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsGetNumVisits] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsGetNumVisitsDateInterval]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsGetNumVisitsDateInterval] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsGetUniqueNumVisits]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsGetUniqueNumVisits] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetSiteList]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetSiteList]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsGetVisitedItems]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsGetVisitedItems] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnEPiServerCommonVisitsGetNumVisitsDateInterval]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[fnEPiServerCommonVisitsGetNumVisitsDateInterval]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsGetVisit]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsGetVisit] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsAddVisit]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsAddVisit]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnEPiServerCommonVisitsGetUniqueNumVisits]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[fnEPiServerCommonVisitsGetUniqueNumVisits]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsRemoveVisit]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsRemoveVisit]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveUserModuleAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveUserModuleAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetUserModuleAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonSetUserModuleAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetModuleUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetModuleUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUserModuleAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUserModuleAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetPasswordProviders]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetPasswordProviders]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddUser]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddUser]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddPasswordProvider]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddPasswordProvider]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUpdateUser]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonUpdateUser]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetChildGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetChildGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetGroup]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetGroup]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddGroup]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddGroup]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonFindGroup]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonFindGroup]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUpdateGroup]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonUpdateGroup]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetParentGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetParentGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetGroupByName]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetGroupByName]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAdministrativeAccessRightGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAdministrativeAccessRightGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUserGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUserGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetModuleGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetModuleGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveGroup]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveGroup]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetGroupUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetGroupUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAdministrativeAccessRightUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAdministrativeAccessRightUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetLatestActivatedUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetLatestActivatedUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUsersByAlias]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUsersByAlias]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonFindUser]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonFindUser]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUserByEMail]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUserByEMail]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUser]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUser]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveChildGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveChildGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveParentGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveParentGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddChildGroup]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddChildGroup]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUserAdministrativeAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetUserAdministrativeAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveUserAdministrativeAccessRightSection]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveUserAdministrativeAccessRightSection]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetUserAdministrativeAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonSetUserAdministrativeAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetGroupAdministrativeAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetGroupAdministrativeAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetGroupAdministrativeAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonSetGroupAdministrativeAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveGroupAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveGroupAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveGroupAdministrativeAccessRightSection]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveGroupAdministrativeAccessRightSection]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddGroupUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddGroupUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveGroupUsers]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveGroupUsers]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveUserGroups]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveUserGroups]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveAttribute]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveAttribute]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttribute]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttribute] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUpdateAttribute]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonUpdateAttribute] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAttributesByObjectType]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAttributesByObjectType]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAttribute]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAttribute]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetRelatedTags]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetRelatedTags]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetTagCloud]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetTagCloud]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRatingUpdateRatingItemStatus]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRatingUpdateRatingItemStatus] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsUpdateVisitsItemStatus]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsUpdateVisitsItemStatus] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagUpdateTagItemsCount]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagUpdateTagItemsCount] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetMostPopularTags]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetMostPopularTags] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagAddTag]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagAddTag] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagRemoveTag]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagRemoveTag] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetEntityTagsCount]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetEntityTagsCount] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetTaggedItems]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetTaggedItems]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetPredefinedTags]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetPredefinedTags] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetPredefinedTagById]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetPredefinedTagById] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetEntityTag]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetEntityTag] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetTagByID]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetTagByID] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagRemovePredefinedTag]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagRemovePredefinedTag] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetTagByName]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetTagByName] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetEntityTags]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetEntityTags]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetMostRatedItems]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetMostRatedItems]	
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonLoggingGetLogEntries]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonLoggingGetLogEntries]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonLoggingGetActivityLog]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonLoggingGetActivityLog]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetRating]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetRating] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetReportCase]') AND type in (N'P', N'PC'))
	DROP  PROCEDURE [dbo].[spEPiServerCommonReportingGetReportCase] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetRatingByAuthor]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetRatingByAuthor] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagGetTags]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagGetTags] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonLoggingAddActivityLog]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonLoggingAddActivityLog]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueChoiceFloat]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueChoiceFloat]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueDateTime]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueDateTime] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueChoiceDateTime]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueChoiceDateTime]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueChoiceInteger]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueChoiceInteger]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueChoiceBoolean]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueChoiceBoolean]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueInteger]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueInteger] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueBoolean]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueBoolean]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueChoiceString]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueChoiceString]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueFloat]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueFloat]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAttributeValueString]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAttributeValueString] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagRemoveTaggedEntityTagsInternal]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagRemoveTaggedEntityTagsInternal] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetCategoriesByEntity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetCategoriesByEntity]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetCategories]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetCategories]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddCategory]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddCategory] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetCategoryByName]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetCategoryByName] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetCategory]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetCategory] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUpdateCategory]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonUpdateCategory] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveCategory]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveCategory] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetChildCategories]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetChildCategories]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingIsReportedEntity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingIsReportedEntity]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingAddReport]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingAddReport]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingUpdateReportCase]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingUpdateReportCase]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingRemoveReportCase]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingRemoveReportCase]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUpdateRatableEntity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonUpdateRatableEntity] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetRatableEntityValues]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetRatableEntityValues]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRate]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRate]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAuthorsByEntityID]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAuthorsByEntityID]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetAuthor]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveAuthor]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUpdateAuthor]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonUpdateAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddAuthor]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddAuthor]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveCategoryEntityItem]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveCategoryEntityItem] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonAddCategoryEntityItem]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonAddCategoryEntityItem] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveCategoryEntityItems]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveCategoryEntityItems] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetReport]') AND type in (N'P', N'PC'))
	DROP  PROCEDURE [dbo].[spEPiServerCommonReportingGetReport] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingUpdateReport]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingUpdateReport]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingRemoveReport]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingRemoveReport]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveGroupModuleAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveGroupModuleAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetGroupModuleAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetGroupModuleAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetGroupModuleAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonSetGroupModuleAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetSetting]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonSetSetting]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveSetting]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveSetting]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetSetting]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetSetting]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnEPiServerCommonVisitsGetNumVisits]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[fnEPiServerCommonVisitsGetNumVisits]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonVisitsGetLastVisitID]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonVisitsGetLastVisitID] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveScheduledTaskStarter]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveScheduledTaskStarter]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetScheduledTaskStarter]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonSetScheduledTaskStarter]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetScheduledTaskStarter]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetScheduledTaskStarter]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveObjectReferences]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveObjectReferences] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonRemoveObjectAttributeReferences]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonRemoveObjectAttributeReferences] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagAddTagItem]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagAddTagItem] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagAddPredefinedTag]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagAddPredefinedTag]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonTagRemoveTagItem]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonTagRemoveTagItem] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonCommentsAddComment]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonCommentsAddComment]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonCommentsGetComment]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonCommentsGetComment] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonCommentsGetComments]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonCommentsGetComments] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonCommentsGetNumComments]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonCommentsGetNumComments]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonCommentsRemoveComment]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonCommentsRemoveComment]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonCommentsUpdateComment]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonCommentsUpdateComment]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonReportingGetUserReportsCleanup]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonReportingGetUserReportsCleanup]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetOwnerContextID]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetOwnerContextID] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetOwnership]') AND type in (N'P', N'PC'))
	DROP PROCEDURE spEPiServerCommonSetOwnership 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetOwnership]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetOwnership]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetObjectsByOwner]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonGetObjectsByOwner]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonSetEntityGuid]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonSetEntityGuid]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecurityGetUserAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecurityGetUserAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecuritySetUserAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecuritySetUserAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecurityRemoveUserAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecurityRemoveUserAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecurityRemoveAllAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecurityRemoveAllAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecurityGetAccessOwnerUsersForObject]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecurityGetAccessOwnerUsersForObject]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecurityGetAccessOwnerGroupsForObject]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecurityGetAccessOwnerGroupsForObject]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecurityRemoveGroupAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecurityRemoveGroupAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecuritySetGroupAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecuritySetGroupAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEntitySecurityGetGroupAccessRights]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEntitySecurityGetGroupAccessRights]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUserRemoveUserOpenID]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonUserRemoveUserOpenID]	
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUserAddOpenID]') AND type in (N'P', N'PC'))
	DROP PROCEDURE spEPiServerCommonUserAddOpenID
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonUserGetUserByOpenIDClaimedIdent]') AND type in (N'P', N'PC'))
	DROP PROCEDURE spEPiServerCommonUserGetUserByOpenIDClaimedIdent
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonGetUserOpenIDs]') AND type in (N'P', N'PC'))
	DROP PROCEDURE spEPiServerCommonGetUserOpenIDs
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonOpenIDAddUserRealm]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonOpenIDAddUserRealm]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonOpenIDGetUserRealm]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonOpenIDGetUserRealm]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonOpenIDGetUserRealmByRealm]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonOpenIDGetUserRealmByRealm]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonOpenIDRemoveUserRealm]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonOpenIDRemoveUserRealm]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEventCounterRemoveLogs]') AND type in (N'P', N'PC'))
	DROP  PROCEDURE [dbo].[spEPiServerCommonEventCounterRemoveLogs]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEventCounterAddEventLog]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEventCounterAddEventLog] 
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEventCounterGetResults]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEventCounterGetResults]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEventCounterAddJobLog]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEventCounterAddJobLog]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEventCounterAddEventHour]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEventCounterAddEventHour]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEventCounterAddEventDay]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEventCounterAddEventDay]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEventCounterAddEventMonth]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEventCounterAddEventMonth]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spEPiServerCommonEventCounterRunJobs]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spEPiServerCommonEventCounterRunJobs]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnEPiServerCommonGetDayStart]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[fnEPiServerCommonGetDayStart]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnEPiServerCommonGetQuarter]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[fnEPiServerCommonGetQuarter]
GO

