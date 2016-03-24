IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
BEGIN
	PRINT N'Creating Master Key...';

	CREATE MASTER KEY ENCRYPTION BY PASSWORD= N'5F18E937-6F17-4EED-8265-D2CBC9FEA553';
END
GO
IF EXISTS(SELECT 1 FROM sys.certificates where name = 'Mediachase_ECF50_MDP' and expiry_date < GETUTCDATE())
BEGIN
	DROP CERTIFICATE Mediachase_ECF50_MDP
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates where name = 'Mediachase_ECF50_MDP') 										
BEGIN
	PRINT N'Creating CERTIFICATE...';

	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'CREATE CERTIFICATE [Mediachase_ECF50_MDP] WITH SUBJECT = ''Mediachase Certificate'', START_DATE = N''' + CONVERT(VARCHAR, GETUTCDATE(), 120) + ''', EXPIRY_DATE = N''' + CONVERT(VARCHAR, DATEADD(year, 1, GETUTCDATE()), 120) + '''';
	exec sp_executesql @sql
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys where name = 'Mediachase_ECF50_MDP_Key')
BEGIN
	PRINT N'Creating [Mediachase_ECF50_MDP_Key]...';
	CREATE SYMMETRIC KEY [Mediachase_ECF50_MDP_Key]
		WITH ALGORITHM = AES_128
		ENCRYPTION BY CERTIFICATE [Mediachase_ECF50_MDP];
END
GO



PRINT N'Updating [mdpsp_sys_OpenSymmetricKey]...';
GO

ALTER PROCEDURE [dbo].[mdpsp_sys_OpenSymmetricKey] AS
	OPEN SYMMETRIC KEY Mediachase_ECF50_MDP_Key DECRYPTION BY CERTIFICATE Mediachase_ECF50_MDP
GO

PRINT N'Updating [mdpsp_sys_CloseSymmetricKey]...';
GO

ALTER PROCEDURE [dbo].[mdpsp_sys_CloseSymmetricKey] AS
	CLOSE SYMMETRIC KEY Mediachase_ECF50_MDP_Key
GO

PRINT N'Updating [mdpfn_sys_EncryptDecryptString2]...';
GO

ALTER FUNCTION [dbo].[mdpfn_sys_EncryptDecryptString2]
(
	
	@input varbinary(4000), 
	@encrypt bit
)
RETURNS varbinary(4000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @RetVal varbinary(4000)

	IF(@input IS NULL)
		RETURN @input

	IF(@encrypt = 1) 
		SELECT @RetVal = EncryptByKey(Key_GUID('Mediachase_ECF50_MDP_Key'), @input) 
	ELSE
		SELECT @RetVal = DecryptByKey(@input)

	RETURN @RetVal;
END
GO

PRINT N'Updating [mdpfn_sys_EncryptDecryptString]...';
GO

ALTER FUNCTION [dbo].[mdpfn_sys_EncryptDecryptString]
(
	@input nvarchar(4000),
	@encrypt bit
)
RETURNS nvarchar(4000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @RetVal nvarchar(4000)

	IF(@input = '' OR @input IS NULL)
		RETURN @input

	IF(@encrypt = 1)
		SELECT @RetVal = CONVERT(nvarchar(4000), EncryptByKey(Key_GUID('Mediachase_ECF50_MDP_Key'), @input) )
	ELSE
		SELECT @RetVal = CONVERT(nvarchar(4000), DecryptByKey(@input))

	RETURN @RetVal;

END
GO

PRINT N'Updating [mdpsp_sys_RotateEncryptionKeys]...';
GO

ALTER PROCEDURE [dbo].[mdpsp_sys_RotateEncryptionKeys] AS
DECLARE @Query_tmp  nvarchar(max)

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION

DECLARE @MetaClassTable NVARCHAR(256), @MetaFieldName NVARCHAR(256), @MultiLanguageValue BIT
DECLARE @sqlQuery NVARCHAR(4000)
DECLARE classall_cursor CURSOR FOR
	SELECT MF.Name, MF.MultiLanguageValue, MC.TableName FROM MetaField MF
		INNER JOIN MetaClassMetaFieldRelation MCFR ON MCFR.MetaFieldId = MF.MetaFieldId
		INNER JOIN MetaClass MC ON MC.MetaClassId = MCFR.MetaClassId
		WHERE MF.IsEncrypted = 1 AND MC.IsSystem = 0

--Open symmetric key
exec mdpsp_sys_OpenSymmetricKey

OPEN classall_cursor
	FETCH NEXT FROM classall_cursor INTO @MetaFieldName, @MultiLanguageValue, @MetaClassTable

--Decrypt meta values
WHILE(@@FETCH_STATUS = 0)
BEGIN

	IF @MultiLanguageValue = 0
		SET @Query_tmp = '
			UPDATE '+@MetaClassTable+'
				SET ['+@MetaFieldName+'] = dbo.mdpfn_sys_EncryptDecryptString(['+@MetaFieldName+'], 0)
				WHERE NOT [' + @MetaFieldName + '] IS NULL'
	ELSE
		SET @Query_tmp = '
			UPDATE '+@MetaClassTable+'_Localization
				SET ['+@MetaFieldName+'] = dbo.mdpfn_sys_EncryptDecryptString(['+@MetaFieldName+'], 0)
				WHERE NOT [' + @MetaFieldName + '] IS NULL'

	EXEC(@Query_tmp)

	IF @@ERROR <> 0 GOTO ERR

	FETCH NEXT FROM classall_cursor INTO @MetaFieldName, @MultiLanguageValue, @MetaClassTable
END

CLOSE classall_cursor

--Decrypt credit cards
SET @sqlQuery = 'UPDATE dbo.cls_CreditCard
SET [CreditCardNumber] = CCD.CardNumber_string,
[SecurityCode] = CCD.SecurityCode_string
FROM (SELECT CONVERT(VARCHAR(max), DecryptByKey(cast(N'''' AS XML).value(''xs:base64Binary(sql:column("CC.CreditCardNumber"))'', ''varbinary(max)''))) AS [CardNumber_string],
    CONVERT(VARCHAR(max), DecryptByKey(cast(N'''' AS XML).value(''xs:base64Binary(sql:column("CC.SecurityCode"))'',''varbinary(max)''))) AS [SecurityCode_string],
    CreditCardId
FROM cls_CreditCard CC WHERE CC.CreditCardNumber is not NULL) CCD WHERE CCD.CreditCardId = cls_CreditCard.CreditCardId'

EXECUTE sp_executesql @sqlQuery

--Close symmetric key
exec mdpsp_sys_CloseSymmetricKey

--Recreate symmetric key
SET @sqlQuery = ' 
DROP SYMMETRIC KEY Mediachase_ECF50_MDP_Key
CREATE SYMMETRIC KEY Mediachase_ECF50_MDP_Key
WITH ALGORITHM = AES_128 ENCRYPTION BY CERTIFICATE Mediachase_ECF50_MDP'
EXECUTE sp_executesql @sqlQuery

--Open new symmetric key
exec mdpsp_sys_OpenSymmetricKey

OPEN classall_cursor
	FETCH NEXT FROM classall_cursor INTO @MetaFieldName, @MultiLanguageValue, @MetaClassTable

--Encrypt meta values
WHILE(@@FETCH_STATUS = 0)
BEGIN

	IF @MultiLanguageValue = 0
		SET @Query_tmp = '
			UPDATE '+@MetaClassTable+'
				SET ['+@MetaFieldName+'] = dbo.mdpfn_sys_EncryptDecryptString(['+@MetaFieldName+'], 1)
				WHERE NOT [' + @MetaFieldName + '] IS NULL'
	ELSE
		SET @Query_tmp = '
			UPDATE '+@MetaClassTable+'_Localization
				SET ['+@MetaFieldName+'] = dbo.mdpfn_sys_EncryptDecryptString(['+@MetaFieldName+'], 1)
				WHERE NOT [' + @MetaFieldName + '] IS NULL'

	EXEC(@Query_tmp)

	FETCH NEXT FROM classall_cursor INTO @MetaFieldName, @MultiLanguageValue, @MetaClassTable
END

CLOSE classall_cursor
DEALLOCATE classall_cursor

--Encrypt credit cards
SET @sqlQuery = 'UPDATE  cls_CreditCard
SET CreditCardNumber = CONVERT(nvarchar(512), CAST(N'''' AS xml).value(''xs:base64Binary(sql:column("CC.CreditCardNumber_string"))'', ''varchar(4000)'') ) ,
    SecurityCode = CONVERT(nvarchar(255), CAST(N'''' AS xml).value(''xs:base64Binary(sql:column("CC.SecurityCode_string"))'', ''varchar(4000)'') ) 
FROM
    ( SELECT EncryptByKey(Key_GUID(''Mediachase_ECF50_MDP_Key''), (CONVERT(varchar(4000), CreditCardNumber)))  CreditCardNumber_string
        , EncryptByKey(Key_GUID(''Mediachase_ECF50_MDP_Key''), (CONVERT(varchar(4000), SecurityCode)))  SecurityCode_string
        , CreditCardId FROM [cls_CreditCard]) CC WHERE cls_CreditCard.CreditCardId = CC.CreditCardId'
EXECUTE sp_executesql @sqlQuery

--Close new symmetric key
exec mdpsp_sys_CloseSymmetricKey

COMMIT TRAN
RETURN

ERR:
ROLLBACK TRAN
RETURN
GO

PRINT N'Updating AzureCompatible table, to flag the DB as not compatible for Azure...';
GO

IF NOT EXISTS (SELECT * FROM dbo.AzureCompatible)
	INSERT INTO dbo.AzureCompatible VALUES (0)
ELSE
	UPDATE dbo.AzureCompatible SET AzureCompatible = 0