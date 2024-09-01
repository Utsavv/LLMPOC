/**************************************************************************                
DATE           VERSION                 NAME                    REFERENCE            
2021-03-05    Dev/1.0.ExtendedBuckets   Amit Sisodiya           WI#446709/WI#476870          
Initial Version        
2021-03-23  Dev/1.0.ExtendedBuckets   Dinesh                    WI#446709/WI#476870         
Changed in Proc for beginning balance and closing balance        
2021-03-30  Dev/1.0.ExtendedBuckets   Dinesh                    WI#446709/WI#476870/#WI479191/#WI479197         
QA observations related to Bucketviewid and data points        
2021-04-05  Dev/1.0.ExtendedBuckets   Dinesh                   WI#479925/WI#479197,WI#480118      
Added TimeZone Parameter and Changed logic for beginning balance and closing balance      
2021-04-05  Dev/1.0.ExtendedBuckets   Amit                   WI#479968/WI#446709       
Added code to implement partial and full redeem case in the code      
2021-04-12  Dev/1.0.ExtendedBuckets   Amit                   WI#446709/WI#480371       
multipe Bug fixes.  
2021-04-12  Dev/1.0.ExtendedBuckets   Amit                   WI#446709/WI#480371       
multipe Bug fixes.  
2021-04-13  Dev/1.0.ExtendedBuckets   Amit                   WI#481633/WI#480371       
Removed Bucket and SubBucket merging in the code  
2021-04-22  Dev/1.0.ExtendedBuckets   Amit                   WI#481633/WI#480371,481373           
Handled opening balance case when two subsequent transactions can have same DTO.
2021-04-26  Dev/1.0.ExtendedBuckets   Amit                   WI#481633/WI#480371
BucketView added in partition by clause.
2021-05-26   Dev/1.0.ExtendedBuckets  Dinesh                 WI#489794/WI#492065
Removed COndition AND IIF(ts.StatusDescription IS NULL,'',ts.StatusDescription)!='Issue' to get the exact redeemed amount.
2021-06-12   Dev/1.0.ExtendedBuckets  Rajan Kumar            WI#494508/WI#496631
Considering TierBonus in Earned column instead of Redeemed.
2021-06-12   Dev/1.0.ExtendedBuckets  Rishi            WI#515327/WI#515327
Show transaction displayname for Source 
2021-06-30   Dev/1.0.ExtendedBuckets  Nikita            WI#523376/WI#497900
Added NCEPOut column
2021-07-05   Dev/1.0.ExtendedBuckets  Nikita            WI#534448/WI#518855
Updated source column for issued and redeemed transactions
2021-08-16   Dev/1.0.ExtendedBuckets  Shekhar           WI#551496/WI#552539
Bucket Awards must nt come in External Source Rewards
2021-08-26  Dev/1.0.ExtendedBuckets     Nikita Kapoor   WI#491616/WI#554003
Change for @BucketViewList Table
2021-09-03  Dev/1.0.ExtendedBuckets     Shekhar         WI#551725/WI#556893
Performance Issue : Report is taking more than 10 min to fetch the data for one month
2021-09-04   Releases/2.0.1000     Nikita         WI#534324/TI#557573
player beginning and ending balance while selecting future date
2021-09-07   Releases/2.0.1000  Nikita           WI#534324/WI#557580
Added previous change comment
2021-10-11  Releases/2.0.1000     Nikita         WI#563233/TI#563803
Added data in bucket column for selected future date
2021-11-01  Releases/2.0.1000     Shekhar        WI#548822/WI#567168
Optimization for better result
2021-11-01  Releases/2.0.1000     Nikita         WI#563233/TI#567179 
Fixed Future date selected issue
2021-11-10  Releases/2.0.1000     Shekhar        WI#567955/WI#568254 
Fixed Future date selected issue - Corrected Logic
2021-11-22  Releases/2.0.1000     Parag    WI#568031/WI#569814
Fixed the currency symbol displayed and sequence of running balance.
2021-11-24 Releases/2.0.1000     Parag    WI#570018/WI#570069
Fixed "Transaction Date Time" issue.
2021-11-25 Releases/2.0.1000   Himanshu Shekhar    WI#570211/WI#570273
Tier Bonus should be considered as earning for non promo buckets
2021-11-26 Releases/2.0.1000   Parag               WI#569002/WI#570016
Replaces the Null values from 0 causing issue in report.
2021-12-06 Releases/2.0.1000        Nikita               WI#570398/WI#571458
Fixed Beginning balace.
2021-12-06 Releases/2.0.1000   Parag               WI#570248/WI#570466
Fixed Partial Redemption issue for  Column Redeemed.
2021-12-15 Releases/2.0.1000   Himanshu Shekhar    WI#572148/WI#572712
Show "Multiple" in source column when many sources are used in any transaction
2021-12-21  Release/2.0.1000            Nikita               WI#572021/WI#572498
Fixed displaying data in case of no transcation within date range
2021-12-28  Release/2.0.1000            Parag               WI#573235/WI#573764
Fixed for the Redeemed transcation.
2021-01-03  Release/2.0.1000            Nikita               WI#572021/WI#574159
Property Name should be NA for no transaction section.
2022-01-13  Release/2.0.1000            Parag               WI#573235/WI#575629
Fixed In the Ending balances for Redeemed transcation in case of Points.
2022-01-18  Release/2.0.1000            Pramil              WI#569486/TI#575950
RNumLedger instead of Rnump in promo transactions
2022-01-24  Release/2.0.1000            Nikita              WI#576831/TI#576876
Fixed Source column for 'Multiple' and 'Bucket' value.
2022-01-25  Release/2.0.1000            Nikita              WI#577042/TI#577185
Fixed incorrect Source as "Bucket" instead of "Bucket Award"
2022-01-27  Release/2.0.1000            Nikita              WI#577017/TI#577307
Fixed multi property issue by joining UC_X_Property with PropertyGroupList
2022-01-28  Release/2.0.1000            Nikita              WI#577360/TI#577584
Fixed Source column for multiple usage with multiple InitiatorID
2022-02-17  Release/2.0.1000            Shekhar             WI#580334/WI#580341
Corrected Beginning Balance for the Transactions which consumed more than one Sources In Reports
Fixed additional Scenarios
2022-04-21    Dev/2.0.OL15-0       Pramil Gupta     WI#584952/TI#589484
Added INSERT with column list
2022-06-17  Dev/2.0.OL15-0         Pramil Gupta     WI#596965/TI#596966
Fixed unqualified column name
2022-10-10    Dev/2.0.OL15-0       Niharika     WI#601466/TI#611430
Added Mobility Interface and santized code
**************************************************************************/
CREATE OR ALTER PROCEDURE dbo.usp_UC_RPT_PlayerTransactionBalanceReport_sel
(
  @BucketViewID nvarchar(MAX) = NULL, @PropertyID nvarchar(MAX) = NULL,
  @UniversalID nvarchar(MAX) = NULL, @FromDate date, @ToDate date,
  @TZ nvarchar(7)
)
AS
BEGIN
  BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @RedeemTransactionTypeID smallint, @Timezone nvarchar(64),
      @tBucketViewPrimaryBucketView AS dbo.tBucketViewPrimaryBucketView,
      @tProperties AS dbo.tProperties, @tPlayerID AS dbo.tPlayerID,
      @PromoBucketViewID smallint, @BucketAwardInitiatorID smallint,
      @PromoOfferInitiatorID smallint, @CompItemInitiatorID smallint,
      @NonCompItemInitiatorID smallint, @SQL nvarchar(MAX),
      @AvailableTransactionInitiatorStatusID tinyint,
      @IssueTransactionInitiatorStatusID tinyint,
      @VoidTransactionInitiatorStatusID tinyint, 
      @ExpiredTransactionTypeID smallint, @EarningTransactionTypeID smallint,
      @CEPInTransactionTypeID smallint, @NCEPInTransactionTypeID smallint,
      @AdjustmentTransactionTypeID smallint, @CEPOutTransactionTypeID smallint,
      @NCEPOutTransactionTypeID smallint, @DepositTransactionTypeID smallint,
      @RewardTransactionTypeID smallint, @TierBonusInitiatorID smallint,
      @SpeedMediaInterfaceID smallint, @MassImporterInterfaceID smallint,
      @EGMInterfaceID smallint, @OneLinkInterfaceID smallint,
      @KioskInterfaceID smallint, @EventBlockInitiatorID smallint,
      @RedeemTransactionInitiatorStatusID smallint,
      @MobilityInterfaceID smallint;

    DECLARE @PropertyList TABLE (PropertyID bigint PRIMARY KEY);
    DECLARE @UniversalIDList TABLE (UniversalID varchar(12) PRIMARY KEY, PlayerID bigint NOT NULL);
    DECLARE @BucketViewList table
    (
      BucketViewID bigint NOT NULL PRIMARY KEY,
      PrimaryBucketViewID bigint NULL,
      CurrencySymbol nvarchar(3) NULL,
      DataPrecision tinyint NULL,
      BucketViewDisplayName nvarchar(256) NOT NULL,
      PrimaryBucketViewDisplayName nvarchar(256) NOT NULL,
      BucketName nvarchar(256) NOT NULL,
      IsDefaultBucketView bit NOT NULL
    );
    CREATE TABLE #ResultSet
    (
      Bucket nvarchar(256) NULL,
      Property varchar(50) NULL,
      UniversalID char(12) NULL,
      FirstName varchar(50) NULL,
      LastName varchar(50) NULL,
      GamingDate date NULL,
      TransactionDateTime datetime2(7) NULL,
      BeginningBalance decimal(38, 4) NULL,
      Earned money NULL,
      Voided money NULL,
      EGMDownloaded money NULL,
      Adjustments money NULL,
      Expired money NULL,
      ExternalRewards money NULL,
      Prize money NULL,
      Eventtickets money NULL,
      BucketAward money NULL,
      Redeemed money NULL,
      Issued money NULL,
      Promooffers money NULL,
      NCEPOut money NULL,
      SOURCE varchar(12) NULL,
      CurrencySymbol nvarchar(3) NULL,
      DataPrecision tinyint NULL,
      IsIgnoreEB int NULL,
      PartialRedeemAmount money NULL,
      TransactionID bigint NULL
    );

    IF @PropertyID IS NULL
    BEGIN
      INSERT INTO @PropertyList
      SELECT p.PropertyID FROM dbo.UC_X_Property p WHERE p.Active = 1;
    END;
    ELSE
    BEGIN
      INSERT INTO @PropertyList SELECT value FROM STRING_SPLIT(@PropertyID, ',');
    END;

    INSERT INTO @tProperties (PropertyID)
    SELECT PropertyID FROM @PropertyList
    UNION ALL
    SELECT H.PropertyID
    FROM dbo.UC_X_Property P
      INNER JOIN dbo.UC_X_Host H ON H.PropertyID = P.PropertyID
    WHERE H.IsUniverse = 1;

    INSERT INTO @BucketViewList
    (
      Bucketviewid, PrimaryBucketViewID, CurrencySymbol, DataPrecision,
      BucketViewDisplayName, PrimaryBucketViewDisplayName, BucketName,
      IsDefaultBucketView
    )
    SELECT UBVFR.BucketViewID, UBVFR.PrimaryBucketViewID, b1.Symbol,
      b1.DataPrecision, BVP.BucketViewDisplayName,
      pbv.BucketViewDisplayName PrimaryBucketViewDisplayName, b.BucketName,
      bv.IsDefaultBucketView
    FROM dbo.udf_BucketViewsForReports(
                                        @BucketViewID,
                                        'BalanceUsage,CompItems,ConsolidatedBucket,IsTierPoints,IsFreePlay,DiscretionaryComp,ExclusiveBucket,
      IsRedeemableAtEGM,FunctionalAuthorization,IsNegativeBalanceAllowed,VisibleToPlayers'
                                      ) AS UBVFR
      INNER JOIN dbo.BucketViewBuckets bvb ON UBVFR.BucketViewID = bvb.BucketViewID
                                             AND bvb.IsPrimaryEarningBucket = 1
      INNER JOIN dbo.BucketViews bv ON bvb.BucketViewID = bv.BucketViewID
      INNER JOIN dbo.BucketViews bvp ON bvp.BucketViewID = UBVFR.PrimaryBucketViewID
      INNER JOIN dbo.Buckets b ON b.BucketID = bvb.BucketID
      INNER JOIN dbo.BucketViews pbv ON UBVFR.PrimaryBucketViewID = pbv.BucketViewID
      CROSS APPLY
    (
      SELECT bkt.DataPrecision, c.Symbol
      FROM dbo.Buckets bkt
        INNER JOIN dbo.BucketViewBuckets bvb ON UBVFR.PrimaryBucketViewID = bvb.BucketViewID
                                               AND bvb.IsPrimaryEarningBucket = 1
        LEFT JOIN dbo.Currencies c ON bkt.CurrencyID = c.CurrencyID
      WHERE bkt.BucketID = bvb.BucketID
    ) b1;

    INSERT INTO @tBucketViewPrimaryBucketView (BucketViewID,
                                              PrimaryBucketViewID
                                              )
    SELECT BucketViewID, PrimaryBucketViewID FROM @BucketViewList;

    SELECT @BucketAwardInitiatorID = IIF(Name = 'BucketAwards',
                                     TransactionInitiatorID,
                                     @BucketAwardInitiatorID),
      @PromoOfferInitiatorID = IIF(Name = 'PromoOffer',
                               TransactionInitiatorID,
                               @PromoOfferInitiatorID),
      @TierBonusInitiatorID = IIF(Name = 'TierBonus',
                              TransactionInitiatorID,
                              @TierBonusInitiatorID),
      @EventBlockInitiatorID = IIF(Name = 'EventBlock',
                               TransactionInitiatorID,
                               @EventBlockInitiatorID),
      @CompItemInitiatorID = IIF(Name = 'CompItem',
                             TransactionInitiatorID,
                             @CompItemInitiatorID),
      @NonCompItemInitiatorID = IIF(Name = 'NonCompItem',
                                TransactionInitiatorID,
                                @NonCompItemInitiatorID)
    FROM dbo.TransactionInitiators
    WHERE Name IN ('BucketAwards', 'PromoOffer', 'TierBonus', 'EventBlock',
                    'CompItem', 'NonCompItem'
                  );

    SELECT @SpeedMediaInterfaceID = IIF(InterfaceName = 'SpeedMedia',
                                    InterfaceID,
                                    @SpeedMediaInterfaceID),
      @EGMInterfaceID = IIF(InterfaceName = 'EGM', InterfaceID, @EGMInterfaceID),
      @OneLinkInterfaceID = IIF(InterfaceName = 'OneLink',
                            InterfaceID,
                            @OneLinkInterfaceID),
      @KioskInterfaceID = IIF(InterfaceName = 'Kiosk',
                          InterfaceID,
                          @KioskInterfaceID),
      @MassImporterInterfaceID = IIF(InterfaceName = 'Mass Import',
                                 InterfaceID,
                                 @MassImporterInterfaceID),
      @MobilityInterfaceID = IIF(InterfaceName = 'Mobility',
                          InterfaceID,
                          @MobilityInterfaceID)
    FROM dbo.Interfaces
    WHERE InterfaceName IN ('SpeedMedia', 'OneLink', 'Kiosk', 'EGM',
                           'Mass Import','Mobility'
                           );

    SELECT @EarningTransactionTypeID = IIF(Name = 'Earning',
                                       TransactionTypeID,
                                       @EarningTransactionTypeID),
      @AdjustmentTransactionTypeID = IIF(Name = 'Adjustment',
                                     TransactionTypeID,
                                     @AdjustmentTransactionTypeID),
      @RedeemTransactionTypeID = IIF(Name = 'Redeem',
                                 TransactionTypeID,
                                 @RedeemTransactionTypeID),
      @ExpiredTransactionTypeID = IIF(Name = 'Expired',
                                  TransactionTypeID,
                                  @ExpiredTransactionTypeID),
      @CEPInTransactionTypeID = IIF(Name = 'CEPIn',
                                TransactionTypeID,
                                @CEPInTransactionTypeID),
      @CEPOutTransactionTypeID = IIF(Name = 'CEPOut',
                                 TransactionTypeID,
                                 @CepOutTransactionTypeID),
      @NCEPInTransactionTypeID = IIF(Name = 'NCEPIn',
                                 TransactionTypeID,
                                 @NCEPInTransactionTypeID),
      @NCEPOutTransactionTypeID = IIF(Name = 'NCEPOut',
                                  TransactionTypeID,
                                  @NCEPOutTransactionTypeID),
      @DepositTransactionTypeID = IIF(Name = 'Deposit',
                                  TransactionTypeID,
                                  @DepositTransactionTypeID),
      @RewardTransactionTypeID = IIF(Name = 'Reward',
                                 TransactionTypeID,
                                 @RewardTransactionTypeID)
    FROM dbo.TransactionTypes
    WHERE Name IN ('Earning', 'Adjustment', 'Redeem', 'Expired', 'CEPIn',
                    'CEPOut', 'NCEPIn', 'NCEPOut', 'Deposit', 'Reward'
                  );

    SELECT @IssueTransactionInitiatorStatusID = IIF(StatusDescription = 'Issue',
                                                  TransactionInitiatorStatusID,
                                                  @IssueTransactionInitiatorStatusID),
      @RedeemTransactionInitiatorStatusID = IIF(StatusDescription = 'Redeem',
                                              TransactionInitiatorStatusID,
                                              @RedeemTransactionInitiatorStatusID),
      @VoidTransactionInitiatorStatusID = IIF(StatusDescription = 'Void',
                                            TransactionInitiatorStatusID,
                                            @VoidTransactionInitiatorStatusID),
      @AvailableTransactionInitiatorStatusID = IIF(
                                                 StatusDescription = 'Available',
                                                 TransactionInitiatorStatusID,
                                                 @AvailableTransactionInitiatorStatusID)
    FROM dbo.TransactionInitiatorStatus
    WHERE StatusDescription IN ('Issue', 'Redeem', 'Available', 'Void');

    IF @UniversalID IS NOT NULL
    BEGIN
      INSERT INTO @UniversalIDList
      SELECT a.value, upp.PlayerID
      FROM STRING_SPLIT(@UniversalID, ',') a
        INNER JOIN dbo.UC_PL_Player upp WITH (NOLOCK) ON a.value = upp.UniversalPlayerID;

      INSERT INTO @tPlayerID (PlayerID) SELECT PlayerID FROM @UniversalIDList;
    END;
    ELSE
    BEGIN
      INSERT INTO @tPlayerID
      SELECT DISTINCT T.PlayerID
      FROM EB.Transactions T WITH (NOLOCK)
        INNER JOIN @BucketViewList BVL ON BVL.BucketViewID = T.BucketViewID
        INNER JOIN @PropertyList PL ON PL.PropertyID = T.TransactionPropertyID
        LEFT JOIN @UniversalIDList UIL ON UIL.PlayerID = T.PlayerID
      WHERE T.GamingDate BETWEEN @FromDate AND @ToDate
        AND (@UniversalID IS NULL OR UIL.PlayerID = T.PlayerID);
    END;

    DROP TABLE IF EXISTS #MaxPropertyPlayerBalance;
    CREATE TABLE #MaxPropertyPlayerBalance
    (
      PrimaryBucketViewID bigint NOT NULL,
      PlayerID bigint NOT NULL,
      PropertyID bigint NOT NULL,
      MaxPropertyBalance money NOT NULL
    );
  
  /* Avoiding static code analysis error*/
    UPDATE #MaxPropertyPlayerBalance
    SET PropertyID = 100001

    DROP TABLE IF EXISTS #FinalMaxPropertyPlayerBalance;
    CREATE TABLE #FinalMaxPropertyPlayerBalance
    (
      PrimaryBucketViewID bigint NOT NULL,
      PlayerID bigint NOT NULL,
      PropertyID bigint NOT NULL,
      PropertyName varchar(50) NOT NULL,
      MaxPropertyBalance money NOT NULL
    );

    DROP TABLE IF EXISTS #FinalOfferAwardBalancesProperty;
    CREATE TABLE #FinalOfferAwardBalancesProperty
    (
      PrimaryBucketViewID int NOT NULL,
      PlayerID bigint NOT NULL,
      PropertyID bigint NOT NULL,
      RunningBalance money NULL PRIMARY KEY
                                (PrimaryBucketViewID, PlayerID, PropertyID)
    );

    SELECT @TimeZone = UXT.StandardName
    FROM dbo.UC_X_Timezones AS UXT
    WHERE UXT.StandardAbbreviation = @TZ
      OR UXT.DaylightAbbreviation = @TZ;

    SELECT @PromoBucketViewID = BV.BucketViewID
    FROM dbo.BucketSettings BS
      INNER JOIN dbo.BucketSettingsConfig BSC ON BSC.BucketSettingID = BS.BucketSettingID
      INNER JOIN dbo.BucketViewBuckets BVB ON BVB.BucketID = BS.BucketID
      INNER JOIN dbo.BucketViews BV ON BV.BucketViewID = BVB.BucketViewID
    WHERE BSC.SettingKey = 'IsFreePlay'
      AND BS.Value = 1;

    IF @TimeZone IS NULL
      SELECT @TimeZone = UXP.TimeZone
      FROM dbo.UC_X_Property AS UXP
        INNER JOIN dbo.UC_X_Host h ON uxp.PropertyID = h.PropertyID
      WHERE h.IsUniverse = 1;

    IF EXISTS (SELECT 1 FROM @tPlayerID)
    BEGIN
      EXEC dbo.isp_RunningBalancePropertyWithPlayer_sel @BucketViewList = @tBucketViewPrimaryBucketView,
        @PropertyList = @tProperties, @PlayerIDs = @tPlayerID,
        @FromDate = @FromDate, @UniversalID = -1,
        @BucketAwardInitiatorID = @BucketAwardInitiatorID,
        @PromoOfferInitiatorID = @PromoOfferInitiatorID;

      EXEC dbo.isp_RunningBalanceAwardOffer_sel @BucketViewList = @tBucketViewPrimaryBucketView,
        @BucketAwardInitiatorID = @BucketAwardInitiatorID,
        @PromoOfferInitiatorID = @PromoOfferInitiatorID,
        @PropertyList = @tProperties, @PlayerIDs = @tPlayerID,
        @TillDate = @FromDate, @UniversalID = -1;
    END;

    SET @SQL = 'CREATE NONCLUSTERED INDEX '
               + 'nc_FinalMaxPropertyPlayerBalance_'
               + CAST(REPLACE(NEWID(), '-', '_') AS varchar(64))
               + ' 
  ON #FinalMaxPropertyPlayerBalance(PlayerID,PrimaryBucketViewID,PropertyID) INCLUDE (MaxPropertyBalance)';

    EXECUTE sys.sp_executesql @Stmt = @SQL;
    SET @SQL = NULL;

    IF EXISTS (SELECT 1 FROM @BucketViewList WHERE BucketViewID = @PromoBucketViewID)
    BEGIN
      INSERT INTO #ResultSet
      (
        Bucket, Property, UniversalID, FirstName, LastName, GamingDate,
        TransactionDateTime, BeginningBalance, Earned, Voided, EGMDownloaded,
        Adjustments, Expired, ExternalRewards, Prize, Eventtickets,
        BucketAward, Redeemed, Issued, Promooffers, NCEPOut, SOURCE,
        CurrencySymbol, DataPrecision, IsIgnoreEB, PartialRedeemAmount,
        TransactionID
      )
      SELECT T.Bucket, T.Property, T.UniversalPlayerID UniversalID,
        T.FirstName, T.LastName, T.GamingDate, T.TransactionDateTime,
        T.BeginningBalance,
        IIF(
          (
            T.TransactionInitiatorID = @TierBonusInitiatorID
            AND T.TransactionDerivedTypeID = @DepositTransactionTypeID
          ),
          T.AmountofTransaction,
          0) AS Earned,
        IIF(T.TransactionDerivedTypeID = -10, T.AmountofTransaction, 0) AS Voided,
        IIF(
          T.TransactionDerivedTypeID IN (@NCEPInTransactionTypeID,
                                        @CEPInTransactionTypeID
                                        ),
          T.AmountofTransaction,
          0) AS EGMDownloaded,
        IIF(
          T.TransactionDerivedTypeID = @AdjustmentTransactionTypeID
             AND T.InterfaceID NOT IN (@SpeedMediaInterfaceID,
                                      @KioskInterfaceID, @OneLinkInterfaceID,
                                      @MobilityInterfaceID
                                      )
             AND ISNULL(T.TransactionInitiatorID, 0) <> @EventBlockInitiatorID,
          T.AmountofTransaction,
          0) AS Adjustments,
        IIF(T.TransactionDerivedTypeID = @ExpiredTransactionTypeID,
          T.AmountofTransaction,
          0) AS Expired,
        IIF(
          T.TransactionDerivedTypeID IN (@DepositTransactionTypeID,
                                        @RewardTransactionTypeID
                                        )
             AND T.InterfaceID IN (@SpeedMediaInterfaceID, @KioskInterfaceID,
                                  @OneLinkInterfaceID, @MobilityInterfaceID
                                  )
             AND T.TransactionInitiatorID <> @TierBonusInitiatorID
             AND T.TransactionDerivedTypeID <> -10
             AND T.SOURCE = 'Bucket',
          T.AmountofTransaction,
          0) AS ExternalRewards,
        IIF(
          EXISTS
    (
      SELECT 1
      FROM AWA.UC_PL_PrizeRedemptionDetail
      WHERE t.SequenceNumber = RedeemedTransactionID
    )
             AND T.TransactionDerivedTypeID <> -10,
          T.AmountofTransaction,
          0) AS Prize,
        IIF(
          BlockEvents.Eventtickets IS NOT NULL
             AND T.TransactionInitiatorID = @EventBlockInitiatorID
             AND T.TransactionDerivedTypeID <> -10,
          T.AmountofTransaction,
          0) AS Eventtickets,
        IIF(
          T.SOURCE = 'Bucket Award'
             AND T.TransactionInitiatorStatusID = @AvailableTransactionInitiatorStatusID,
          T.AmountofTransaction,
          0) AS BucketAward,
        CASE
          WHEN T.TransactionInitiatorID = @CompItemInitiatorID
            AND T.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID
            AND T.TransactionDerivedTypeID <> -10
            AND T.ParentTransactionID IS NOT NULL THEN T.AmountofTransaction
          WHEN T.TransactionDerivedTypeID IN (@RedeemTransactionTypeID,
                                               @DepositTransactionTypeID,
                                               @NCEPInTransactionTypeID,
                                               @CEPInTransactionTypeID
                                             )
            AND T.TransactionDerivedTypeID <> -10
            AND T.TransactionInitiatorID NOT IN (@PromoOfferInitiatorID,
                                                @EventBlockInitiatorID,
                                                @TierBonusInitiatorID
                                                )
            AND T.InterfaceID NOT IN (@EGMInterfaceID)
            AND NOT EXISTS
    (
      SELECT 1
      FROM AWA.UC_PL_PrizeRedemptionDetail
      WHERE t.SequenceNumber = RedeemedTransactionID
    )
            AND T.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID THEN
            T.AmountofTransaction
          ELSE 0
        END AS Redeemed,
        IIF(
          T.TransactionInitiatorStatusID = @IssueTransactionInitiatorStatusID
             AND T.TransactionInitiatorID IN (@CompItemInitiatorID,
                                             @NonCompItemInitiatorID
                                             )
             AND T.TransactionDerivedTypeID NOT IN (@DepositTransactionTypeID,
                                                     @NCEPInTransactionTypeID,
                                                     @CEPInTransactionTypeID,
                                                     @EventBlockInitiatorID,
                                                     -10
                                                   )
             AND NOT EXISTS
    (
      SELECT 1
      FROM AWA.UC_PL_PrizeRedemptionDetail
      WHERE t.SequenceNumber = RedeemedTransactionID
    )   ,
          T.AmountofTransaction,
          0) AS Issued,
        IIF(
          T.TransactionInitiatorID = @PromoOfferInitiatorID
             AND T.TransactionDerivedTypeID <> -10,
          T.AmountofTransaction,
          0) AS Promooffers,
        IIF(T.TransactionDerivedTypeID = @NCEPOutTransactionTypeID,
          T.AmountofTransaction,
          0) AS NCEPOut, T.SOURCE, T.CurrencySymbol, T.DataPrecision,
        CASE
          WHEN T.TransactionInitiatorID = @CompItemInitiatorID
            AND T.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID
            AND T.TransactionDerivedTypeID <> -10
            AND T.ParentTransactionID IS NOT NULL
            AND T.AmountofTransaction = 0 THEN 1
          ELSE 0
        END AS IsIgnoreEB,
        CASE
          WHEN T.TransactionInitiatorID = @CompItemInitiatorID
            AND T.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID
            AND T.TransactionDerivedTypeID <> -10
            AND T.ParentTransactionID IS NOT NULL
            AND T.AmountofTransaction IS NOT NULL THEN T.AmountofTransaction
          ELSE 0
        END AS PartialRedeemAmount, T.SequenceNumber AS TransactionID
      FROM
      (
        SELECT T.Bucket, T.Property, T.UniversalPlayerID, T.FirstName,
          T.LastName, t.playerID, T.TransactionDateTime,
          ISNULL(FOA.RunningBalance, 0.00) + ISNULL(F.MaxPropertyBalance, 0.00)
          + ISNULL(T.PromoRunningBalance, 0.0)
          + ISNULL(T.BeginningBalanceAward, 0.0) BeginningBalance,
          SUM(T.BucketAmount) OVER (PARTITION BY T.SequenceNumber, T.RNumLedger ORDER BY T.SequenceNumber) AmountofTransaction,
          T.ParentTransactionID, T.RNumLedger, T.SequenceNumber,
          T.CurrencySymbol, T.DataPrecision, T.TransactionDerivedTypeID,
          T.EarnedPropertyID,
          IIF(
            LEAD(T.SequenceNumber, 1) OVER (ORDER BY T.RNumLedger) = T.SequenceNumber
               AND LEAD(T.SOURCE, 1) OVER (ORDER BY T.RNumLedger) <> T.SOURCE,
            'Multiple',
            T.SOURCE) SOURCE, T.TransactionInitiatorID, T.InterfaceID,
          T.TransactionInitiatorStatusID, T.GamingDate,
          ROW_NUMBER() OVER (PARTITION BY T.SequenceNumber, T.RNumLedger
ORDER BY T.RNumLedger, T.LedgerID
                            ) RNum
        FROM
        (
          SELECT t.BucketViewDisplayName AS Bucket, pr.PropertyName Property,
            p.UniversalPlayerID, p.FirstName, p.LastName, t.GamingDate,
            CONVERT(datetime2, tr.TransactionDTO AT TIME ZONE @TimeZone) TransactionDateTime,
            t.TransactionID AS SequenceNumber, t.CurrencySymbol,
            t.DataPrecision, t.TransactionDerivedTypeID,
            CASE
              WHEN ISNULL(lu.TransactionInitiatorID, ls.TransactionInitiatorID) = @BucketAwardInitiatorID then
                'Bucket Award'
              WHEN ISNULL(lu.TransactionInitiatorID, ls.TransactionInitiatorID) = @PromoOfferInitiatorID then
                'Promo Offer'
              ELSE 'Bucket'
            END AS SOURCE, TR.TransactionInitiatorID,
            ISNULL(
                    SUM(IIF(
                          ISNULL(PGLU.PropertyGroupID, PGL.PropertyGroupID) = 0
                             AND pr.PBTPromoMethod = 'U'
                             AND ISNULL(
                                       TU.TransactionInitiatorID,
                                       TR.TransactionInitiatorID
                                       ) NOT IN (@BucketAwardInitiatorID,
                                                @PromoOfferInitiatorID
                                                ),
                          ISNULL(lu.BucketAmount, ls.BucketAmount),
                          0.0)
                       ) OVER (PARTITION BY TR.PlayerID, t.PrimaryBucketViewID
                               ORDER BY TR.TransactionDTO, TR.TransactionID
                               ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                              ),
                    0.0
                  )
            + ISNULL(
                      SUM(IIF(
                            ISNULL(PGLU.PropertyGroupID, PGL.PropertyGroupID) <> 0
                               AND ISNULL(
                                         TU.TransactionInitiatorID,
                                         TR.TransactionInitiatorID
                                         ) NOT IN (@BucketAwardInitiatorID,
                                                  @PromoOfferInitiatorID
                                                  ),
                            ISNULL(lu.BucketAmount, ls.BucketAmount),
                            0.0)
                         ) OVER (PARTITION BY tr.PlayerID,
                                   t.PrimaryBucketViewID, t.EarnedPropertyID
                                 ORDER BY ISNULL(
                                                lu.TransactionLedgerID,
                                                ls.TransactionLedgerID
                                                ), TR.TransactionDTO,
                                   TR.TransactionID
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                                ),
                      0.0
                    ) AS PromoRunningBalance,
            SUM(IIF(
                  ISNULL(TU.TransactionInitiatorID, TR.TransactionInitiatorID) IN (
                                                                                  @BucketAwardInitiatorID,
                                                                                  @PromoOfferInitiatorID
                                                                                  ),
                  ISNULL(lu.BucketAmount, ls.BucketAmount),
                  0.00)
               ) OVER (PARTITION BY TR.PlayerID, t.PrimaryBucketViewID,
                         IIF(
                           ISNULL(
                                         TU.TransactionInitiatorID,
                                         TR.TransactionInitiatorID
                                         ) IN (@BucketAwardInitiatorID,
                                              @PromoOfferInitiatorID
                                              ),
                           ISNULL(PGLU.PropertyID, PGL.PropertyID),
                           TR.TransactionPropertyID)
                       ORDER BY ISNULL(
                                              lu.TransactionLedgerID,
                                              ls.TransactionLedgerID
                                              ), TR.TransactionDTO,
                         TR.TransactionID
                       ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                      ) BeginningBalanceAward,
            ROW_NUMBER() OVER (PARTITION BY TR.TransactionID,
                                 ISNULL(
                                       lu.TransactionLedgerID,
                                       ls.TransactionLedgerID
                                       )
                               ORDER BY IIF(
                                        ISNULL(PGLU.PropertyID, PGL.PropertyID) = TR.TransactionPropertyID,
                                        1,
                                        2)
                              ) RNumLedger,
            ISNULL(ISNULL(lu.BucketAmount, ls.BucketAmount), 0.0) BucketAmount,
            TR.InterfaceID, TR.TransactionInitiatorStatusID, p.PlayerID,
            t.PrimaryBucketViewID, t.EarnedPropertyID, TR.ParentTransactionID,
            ISNULL(lu.TransactionLedgerID, ls.TransactionLedgerID) LedgerID
          FROM
          (
            SELECT t.TransactionID, bvl.PrimaryBucketViewID, t.GamingDate,
              t.TransactionPropertyID EarnedPropertyID, bvl.CurrencySymbol,
              bvl.DataPrecision, bvl.BucketViewDisplayName,
              IIF(
                t.TransactionInitiatorStatusID = @VoidTransactionInitiatorStatusID,
                -10,
                t.TransactionTypeID) TransactionDerivedTypeID
            FROM EB.Transactions t WITH (NOLOCK)
              INNER JOIN @BucketViewList bvl ON t.BucketViewID = bvl.BucketViewID
              INNER JOIN @tPlayerID ul ON ul.PlayerID = t.PlayerID
            WHERE (t.GamingDate >= @FromDate AND t.GamingDate <= @ToDate)
          ) t
            INNER JOIN EB.Transactions TR WITH (NOLOCK) ON TR.TransactionID = t.TransactionID
            INNER JOIN dbo.PropertyGroupList PGL ON PGL.PropertyGroupID = TR.PropertyGroupID
            INNER JOIN dbo.UC_X_Property pr ON IIF(tr.PropertyGroupID = 0,
                                               tr.TransactionPropertyID,
                                               pgl.PropertyID) = pr.PropertyID
            INNER JOIN dbo.UC_PL_Player p ON TR.PlayerID = p.PlayerID
            LEFT JOIN EB.Transactions tp WITH (NOLOCK) ON tp.TransactionID = tr.ParentTransactionID
            LEFT JOIN EB.TransactionLedger ls WITH (NOLOCK) ON t.TransactionID = ls.SourceTransactionID
                                                              AND ls.UsageTransactionID IS NULL
            LEFT JOIN eb.TransactionLedger lu WITH (NOLOCK) ON t.TransactionID = lu.UsageTransactionID
            LEFT JOIN EB.Transactions TU WITH (NOLOCK) ON lu.SourceTransactionID = tu.TransactionID
            LEFT JOIN dbo.PropertyGroupList PGLU ON PGLU.PropertyGroupID = TU.PropertyGroupID
                                                   AND TR.TransactionTypeID <> @ExpiredTransactionTypeID
            LEFT JOIN EB.TransactionOfferReferences tor WITH (NOLOCK) ON t.transactionid = tor.TransactionID
                                                                        AND tor.TransactionID > 0
        ) T
          INNER JOIN @PropertyList PRL ON PRL.PropertyID = T.EarnedPropertyID
          LEFT JOIN #FinalMaxPropertyPlayerBalance F ON F.PlayerID = T.PlayerId
                                                       AND F.PrimaryBucketViewID = t.PrimaryBucketViewID
                                                       AND F.PropertyID = T.EarnedPropertyID
          LEFT JOIN #FinalOfferAwardBalancesProperty FOA ON FOA.PlayerID = T.PlayerID
                                                           AND FOA.PrimaryBucketViewID = t.PrimaryBucketViewID
                                                           AND FOA.PropertyID = T.EarnedPropertyID
        WHERE T.RNumLedger = 1
      ) T
        OUTER APPLY
      (
        SELECT SUM(ESB.CostToPlayer * ISNULL(BA.AllocationCount, 0)) AS Eventtickets
        FROM EVT.UC_X_EventScheduleBlock AS ESB WITH (NOLOCK)
          INNER JOIN EVT.UC_X_EventSchedule AS ES WITH (NOLOCK) ON ESB.EventScheduleID = ES.EventScheduleID
          INNER JOIN EVT.UC_PL_BlockAllocation AS BA WITH (NOLOCK) ON BA.EventScheduleBlockID = ESB.EventScheduleBlockID
          INNER JOIN EVT.UC_X_AllocationStatus AS EAS WITH (NOLOCK) ON EAS.AllocationStatusID = BA.AllocationStatusID
        WHERE BA.PlayerID = T.PlayerID
      ) AS BlockEvents
      WHERE T.RNum = 1
      OPTION (RECOMPILE);
    END;
    ELSE
    BEGIN
      DROP TABLE IF EXISTS #BalBef;
      CREATE TABLE #BalBef
      (
        BalBefID int IDENTITY(1, 1) PRIMARY KEY,
        MaxPropertyBalance money NULL,
        PlayerID bigint NOT NULL,
        PrimaryBucketViewID smallint NOT NULL
      );

      INSERT INTO #BalBef (PlayerID, PrimaryBucketViewID, MaxPropertyBalance)
      SELECT PlayerID, PrimaryBucketViewID, SUM(MaxPropertyBalance)
      FROM #FinalMaxPropertyPlayerBalance
      GROUP BY PlayerID, PrimaryBucketViewID;

      INSERT INTO #ResultSet
      (
        Bucket, Property, UniversalID, FirstName, LastName, GamingDate,
        TransactionDateTime, BeginningBalance, Earned, Voided, EGMDownloaded,
        Adjustments, Expired, ExternalRewards, Prize, Eventtickets,
        BucketAward, Redeemed, Issued, Promooffers, NCEPOut, SOURCE,
        CurrencySymbol, DataPrecision, IsIgnoreEB, PartialRedeemAmount,
        TransactionID
      )
      SELECT T.Bucket, T.Property, T.UniversalPlayerID UniversalID,
        T.FirstName, T.LastName, T.GamingDate, T.TransactionDateTime,
        T.BeginningBalance,
        IIF(
          T.TransactionDerivedTypeID = @EarningTransactionTypeID
             OR
             (
               t.TransactionDerivedTypeID = @DepositTransactionTypeID
               AND t.TransactionInitiatorID = @TierBonusInitiatorID
             ),
          T.AmountofTransaction,
          0) AS Earned,
        IIF(T.TransactionDerivedTypeID = -10, T.AmountofTransaction, 0) AS Voided,
        IIF(
          T.TransactionDerivedTypeID IN (@NCEPInTransactionTypeID,
                                        @CEPInTransactionTypeID
                                        ),
          T.AmountofTransaction,
          0) AS EGMDownloaded,
        IIF(
          T.TransactionDerivedTypeID = @AdjustmentTransactionTypeID
             AND T.InterfaceID NOT IN (@SpeedMediaInterfaceID,
                                      @KioskInterfaceID, @OneLinkInterfaceID,
                                      @MobilityInterfaceID
                                      )
             AND ISNULL(T.TransactionInitiatorID, 0) <> @EventBlockInitiatorID,
          T.AmountofTransaction,
          0) AS Adjustments,
        IIF(T.TransactionDerivedTypeID = @ExpiredTransactionTypeID,
          T.AmountofTransaction,
          0) AS Expired,
        IIF(
          T.TransactionDerivedTypeID IN (@DepositTransactionTypeID,
                                        @RewardTransactionTypeID
                                        )
             AND T.InterfaceID IN (@SpeedMediaInterfaceID, @KioskInterfaceID,
                                  @OneLinkInterfaceID, @MobilityInterfaceID
                                  )
             AND T.TransactionInitiatorID <> @TierBonusInitiatorID
             AND T.TransactionDerivedTypeID <> -10
             AND T.SOURCE = 'Bucket',
          T.AmountofTransaction,
          0) AS ExternalRewards,
        IIF(
          EXISTS
    (
      SELECT 1
      FROM AWA.UC_PL_PrizeRedemptionDetail
      WHERE t.SequenceNumber = RedeemedTransactionID
    )
             AND T.TransactionDerivedTypeID <> -10,
          T.AmountofTransaction,
          0) AS Prize,
        IIF(
          BlockEvents.Eventtickets IS NOT NULL
             AND T.TransactionInitiatorID = @EventBlockInitiatorID
             AND T.TransactionDerivedTypeID <> -10,
          T.AmountofTransaction,
          0) AS Eventtickets,
        IIF(
          T.SOURCE = 'Bucket Award'
             AND T.TransactionInitiatorStatusID = @AvailableTransactionInitiatorStatusID,
          T.AmountofTransaction,
          0) AS BucketAward,
        CASE
          WHEN T.TransactionInitiatorID IN (@CompItemInitiatorID,
                                           @NonCompItemInitiatorID
                                           )
            AND T.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID
            AND T.TransactionDerivedTypeID <> -10
            AND T.ParentTransactionID IS NOT NULL THEN
            ISNULL(T.AmountofTransaction, 0.0)
            + IIF(
                T.Rnump = 1
                   and ISNULL(T.AmountofTransaction, 0.0) >= 0,
                ISNULL(T.AmountIssued, 0),
                0.0)
          WHEN T.TransactionDerivedTypeID IN (@RedeemTransactionTypeID,
                                               @DepositTransactionTypeID,
                                               @NCEPInTransactionTypeID,
                                               @CEPInTransactionTypeID
                                             )
            AND T.TransactionDerivedTypeID <> -10
            AND T.TransactionInitiatorID NOT IN (@PromoOfferInitiatorID,
                                                @EventBlockInitiatorID,
                                                @TierBonusInitiatorID
                                                )
            AND T.InterfaceID NOT IN (@EGMInterfaceID)
            AND NOT EXISTS
    (
      SELECT 1
      FROM AWA.UC_PL_PrizeRedemptionDetail
      WHERE t.SequenceNumber = RedeemedTransactionID
    )
            AND T.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID THEN
            T.AmountofTransaction
          ELSE 0
        END AS Redeemed,
        IIF(
          T.TransactionInitiatorStatusID = @IssueTransactionInitiatorStatusID
             AND T.TransactionInitiatorID IN (@CompItemInitiatorID,
                                             @NonCompItemInitiatorID
                                             )
             AND T.TransactionDerivedTypeID NOT IN (@DepositTransactionTypeID,
                                                     @NCEPInTransactionTypeID,
                                                     @CEPInTransactionTypeID,
                                                     @EventBlockInitiatorID,
                                                     -10
                                                   )
             AND NOT EXISTS
    (
      SELECT 1
      FROM AWA.UC_PL_PrizeRedemptionDetail
      WHERE t.SequenceNumber = RedeemedTransactionID
    )   ,
          T.AmountofTransaction,
          0) AS Issued,
        IIF(
          T.TransactionInitiatorID = @PromoOfferInitiatorID
             AND T.TransactionDerivedTypeID <> -10,
          T.AmountofTransaction,
          0) AS Promooffers,
        IIF(T.TransactionDerivedTypeID = @NCEPOutTransactionTypeID,
          T.AmountofTransaction,
          0) AS NCEPOut, T.SOURCE, T.CurrencySymbol, T.DataPrecision,
        CASE
          WHEN T.TransactionInitiatorID IN (@CompItemInitiatorID,
                                           @NonCompItemInitiatorID
                                           )
            AND T.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID
            AND T.TransactionDerivedTypeID <> -10
            AND T.ParentTransactionID IS NOT NULL
            AND T.AmountofTransaction = 0 THEN 1
          ELSE 0
        END AS IsIgnoreEB,
        CASE
          WHEN T.TransactionInitiatorID IN (@CompItemInitiatorID,
                                           @NonCompItemInitiatorID
                                           )
            AND T.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID
            AND T.TransactionDerivedTypeID <> -10
            AND T.ParentTransactionID IS NOT NULL
            AND T.AmountofTransaction IS NOT NULL THEN T.AmountofTransaction
          ELSE 0
        END AS PartialRedeemAmount, T.SequenceNumber AS TransactionID
      FROM
      (
        SELECT T.Bucket, T.Property, T.UniversalPlayerID, T.FirstName,
          T.LastName, t.playerID, t.TransactionDateTime,
          ISNULL(FOA.RunningBalance, 0.00) + ISNULL(F.MaxPropertyBalance, 0.00)
          + ISNULL(T.BeginningBalanceBucket, 0.0)
          + ISNULL(T.BeginningBalanceAward, 0.0) BeginningBalance,
          SUM(T.BucketAmount) OVER (PARTITION BY T.SequenceNumber, T.RNumLedger ORDER BY T.SequenceNumber) AmountofTransaction,
          T.ParentTransactionID, T.SequenceNumber, T.CurrencySymbol,
          T.DataPrecision, T.TransactionDerivedTypeID, T.EarnedPropertyID,
          IIF(
            LEAD(T.SequenceNumber, 1) OVER (ORDER BY T.Rnump) = T.SequenceNumber
               AND LEAD(T.SOURCE, 1) OVER (ORDER BY T.Rnump) <> T.SOURCE,
            'Multiple',
            T.SOURCE) SOURCE, T.TransactionInitiatorID, T.InterfaceID,
          T.TransactionInitiatorStatusID, T.GamingDate,
          ROW_NUMBER() OVER (PARTITION BY T.SequenceNumber, T.RNumLedger
ORDER BY T.RNumLedger, T.LedgerID
                            ) Rnum, T.AmountIssued, T.Rnump
        FROM
        (
          SELECT t.BucketViewDisplayName AS Bucket, pr.PropertyName Property,
            p.UniversalPlayerID, p.FirstName, p.LastName, t.GamingDate,
            CONVERT(datetime2, tr.TransactionDTO AT TIME ZONE @TimeZone) TransactionDateTime,
            t.TransactionID AS SequenceNumber, t.CurrencySymbol,
            t.DataPrecision, t.TransactionDerivedTypeID,
            CASE
              WHEN ISNULL(lu.TransactionInitiatorID, ls.TransactionInitiatorID) = @BucketAwardInitiatorID then
                'Bucket Award'
              WHEN ISNULL(lu.TransactionInitiatorID, ls.TransactionInitiatorID) = @PromoOfferInitiatorID then
                'Promo Offer'
              ELSE 'Bucket'
            END AS SOURCE, TR.TransactionInitiatorID,
            SUM(IIF(
                  ISNULL(TU.TransactionInitiatorID, TR.TransactionInitiatorID) <> @BucketAwardInitiatorID,
                  ISNULL(lu.BucketAmount, ls.BucketAmount),
                  0.00)
               ) OVER (PARTITION BY TR.PlayerID, t.PrimaryBucketViewID
                       ORDER BY ISNULL(
                                              lu.TransactionLedgerID,
                                              ls.TransactionLedgerID
                                              ), TR.TransactionDTO,
                         TR.TransactionID
                       ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                      ) BeginningBalanceBucket,
            SUM(IIF(
                  ISNULL(TU.TransactionInitiatorID, TR.TransactionInitiatorID) IN (
                                                                                  @BucketAwardInitiatorID,
                                                                                  @PromoOfferInitiatorID
                                                                                  ),
                  ISNULL(lu.BucketAmount, ls.BucketAmount),
                  0.00)
               ) OVER (PARTITION BY TR.PlayerID, t.PrimaryBucketViewID,
                         IIF(
                           ISNULL(
                                         TU.TransactionInitiatorID,
                                         TR.TransactionInitiatorID
                                         ) IN (@BucketAwardInitiatorID,
                                              @PromoOfferInitiatorID
                                              ),
                           ISNULL(PGLU.PropertyID, PGL.PropertyID),
                           TR.TransactionPropertyID)
                       ORDER BY ISNULL(
                                              lu.TransactionLedgerID,
                                              ls.TransactionLedgerID
                                              ), TR.TransactionDTO,
                         TR.TransactionID
                       ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                      ) BeginningBalanceAward,
            ROW_NUMBER() OVER (PARTITION BY TR.TransactionID,
                                 ISNULL(
                                       lu.TransactionLedgerID,
                                       ls.TransactionLedgerID
                                       )
                               ORDER BY IIF(
                                        ISNULL(PGLU.PropertyID, PGL.PropertyID) = TR.TransactionPropertyID,
                                        1,
                                        2)
                              ) RNumLedger,
            (ISNULL(lu.BucketAmount, 0) + ISNULL(ls.BucketAmount, 0)) BucketAmount,
            TR.InterfaceID, TR.TransactionInitiatorStatusID, p.PlayerID,
            t.PrimaryBucketViewID, t.EarnedPropertyID, TR.ParentTransactionID,
            IIF(tp.Amount IS NULL, 0, tp.Amount) AmountIssued,
            ROW_NUMBER() OVER (PARTITION BY TR.PlayerID,
                                 IIF(
                                   TR.TransactionInitiatorStatusID = @RedeemTransactionInitiatorStatusID,
                                   TR.ParentTransactionID,
                                   0)
                               ORDER BY tr.TransactionDTO, TR.TransactionID
                              ) Rnump,
            ISNULL(lu.TransactionLedgerID, ls.TransactionLedgerID) LedgerID
          FROM
          (
            SELECT t.TransactionID, bvl.PrimaryBucketViewID, t.GamingDate,
              t.TransactionPropertyID EarnedPropertyID, bvl.CurrencySymbol,
              bvl.DataPrecision, bvl.BucketViewDisplayName,
              IIF(
                t.TransactionInitiatorStatusID = @VoidTransactionInitiatorStatusID,
                -10,
                t.TransactionTypeID) TransactionDerivedTypeID
            FROM EB.Transactions t WITH (NOLOCK)
              INNER JOIN @BucketViewList bvl ON t.BucketViewID = bvl.BucketViewID
              INNER JOIN @tPlayerID ul ON ul.PlayerID = t.PlayerID
            WHERE (t.GamingDate >= @FromDate AND t.GamingDate <= @ToDate)
          ) t
            INNER JOIN EB.Transactions TR WITH (NOLOCK) ON TR.TransactionID = t.TransactionID
            INNER JOIN dbo.PropertyGroupList PGL ON PGL.PropertyGroupID = TR.PropertyGroupID
            INNER JOIN dbo.UC_X_Property pr ON IIF(tr.PropertyGroupID = 0,
                                               tr.TransactionPropertyID,
                                               pgl.PropertyID) = pr.PropertyID
            INNER JOIN dbo.UC_PL_Player p ON TR.PlayerID = p.PlayerID
            LEFT JOIN EB.Transactions tp WITH (NOLOCK) ON tp.TransactionID = tr.ParentTransactionID
            LEFT JOIN EB.TransactionLedger ls WITH (NOLOCK) ON t.TransactionID = ls.SourceTransactionID
                                                              AND ls.UsageTransactionID IS NULL
            LEFT JOIN eb.TransactionLedger lu WITH (NOLOCK) ON t.TransactionID = lu.UsageTransactionID
            LEFT JOIN EB.Transactions TU WITH (NOLOCK) ON lu.SourceTransactionID = tu.TransactionID
            LEFT JOIN dbo.PropertyGroupList PGLU ON PGLU.PropertyGroupID = TU.PropertyGroupID
                                                   AND TR.TransactionTypeID <> @ExpiredTransactionTypeID
            LEFT JOIN EB.TransactionOfferReferences tor WITH (NOLOCK) ON t.transactionid = tor.TransactionID
                                                                        AND tor.TransactionID > 0
        ) T
          INNER JOIN @PropertyList PRL ON PRL.PropertyID = T.EarnedPropertyID
          LEFT JOIN #BalBef F ON F.PlayerID = T.PlayerId
                                AND F.PrimaryBucketViewID = t.PrimaryBucketViewID
          LEFT JOIN #FinalOfferAwardBalancesProperty FOA ON FOA.PlayerID = T.PlayerID
                                                           AND FOA.PrimaryBucketViewID = t.PrimaryBucketViewID
                                                           AND FOA.PropertyID = T.EarnedPropertyID
        WHERE T.RNumLedger = 1
      ) T
        OUTER APPLY
      (
        SELECT SUM(ESB.CostToPlayer * ISNULL(BA.AllocationCount, 0)) AS Eventtickets
        FROM EVT.UC_X_EventScheduleBlock AS ESB WITH (NOLOCK)
          INNER JOIN EVT.UC_X_EventSchedule AS ES WITH (NOLOCK) ON ESB.EventScheduleID = ES.EventScheduleID
          INNER JOIN EVT.UC_PL_BlockAllocation AS BA WITH (NOLOCK) ON BA.EventScheduleBlockID = ESB.EventScheduleBlockID
          INNER JOIN EVT.UC_X_AllocationStatus AS EAS WITH (NOLOCK) ON EAS.AllocationStatusID = BA.AllocationStatusID
        WHERE BA.PlayerID = T.PlayerID
      ) AS BlockEvents
      WHERE T.RNum = 1
      OPTION (RECOMPILE);
    END;

    IF EXISTS (SELECT 1 FROM #ResultSet)
    BEGIN
      SELECT Bucket, Property, UniversalID, FirstName, LastName, GamingDate,
        TransactionDateTime, BeginningBalance, Earned, Voided, EGMDownloaded,
        Adjustments, Expired, ExternalRewards, Prize, Eventtickets,
        BucketAward, Redeemed, Issued, Promooffers, NCEPOut, SOURCE,
        CurrencySymbol, DataPrecision, IsIgnoreEB, PartialRedeemAmount,
        TransactionID
      FROM #ResultSet;
    END;
    ELSE
    BEGIN
      SELECT DISTINCT bv.PrimaryBucketViewDisplayName AS Bucket,
        NULL AS Property, P.UniversalPlayerID AS UniversalID, P.FirstName,
        P.LastName, NULL AS GamingDate, NULL AS TransactionDateTime,
        (ISNULL(bbal.MaxPropertyBalance, 0) + ISNULL(FOA.RunningBalance, 0)) BeginningBalance,
        0.00 AS Earned, 0.00 AS Voided, 0.00 AS EGMDownloaded,
        0.00 AS Adjustments, 0.00 AS Expired, 0.00 AS ExternalRewards,
        0.00 AS Prize, 0.00 AS Eventtickets, 0.00 AS BucketAward,
        0.00 AS Redeemed, 0.00 AS Issued, 0.00 AS Promooffers, 0.00 AS NCEPOut,
        NULL AS SOURCE, bv.CurrencySymbol, bv.DataPrecision,
        NULL AS IsIgnoreEB, 0.00 AS PartialRedeemAmount, NULL AS TransactionID
      FROM @UniversalIDList up
        INNER JOIN dbo.UC_PL_Player P WITH (NOLOCK) ON up.PlayerID = P.PlayerID
        LEFT JOIN dbo.UC_PL_DomProp dp WITH (NOLOCK) ON dp.PlayerID = P.PlayerID
        LEFT JOIN dbo.UC_X_Property dprop ON dp.DominantProperty = dprop.PropertyID
        CROSS APPLY
      (
        SELECT DISTINCT PrimaryBucketViewID, PrimaryBucketViewDisplayName,
          CurrencySymbol, DataPrecision
        FROM @BucketViewList
      ) bv
        LEFT JOIN #FinalMaxPropertyPlayerBalance bbal ON P.PlayerID = bbal.PlayerID
                                                        AND bbal.PrimaryBucketViewID = bv.PrimaryBucketViewID
                                                        AND bbal.PropertyID = dp.DominantProperty
        FULL OUTER JOIN #FinalOfferAwardBalancesProperty FOA ON FOA.PlayerID = bbal.PlayerID
                                                               AND FOA.PrimaryBucketViewID = bbal.PrimaryBucketViewID
                                                               AND FOA.PropertyID = bbal.PropertyID;
    END;
  END TRY
  BEGIN CATCH
    THROW;
  END CATCH;
END;
GO