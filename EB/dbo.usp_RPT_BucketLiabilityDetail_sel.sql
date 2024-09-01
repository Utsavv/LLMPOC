/*  
DATE        VERSION                     NAME                    REFERENCE 
2021-03-04  Dev/1.0.ExtendedBuckets      Praveen         WI#429421/WI#474471 
Initial Version
2021-03-11  Dev/1.0.ExtendedBuckets      Praveen         WI#475294/WI#475348
Added CepIn
2021-03-19  Dev/1.0.ExtendedBuckets      Praveen         WI#476819/WI#477287
EB to DBO 
2021-05-06  Dev/1.0.ExtendedBuckets      Praveen         WI#487181/WI#487905
Added Logic for PrimaryBucketViewID
2021-05-13  Dev/1.0.ExtendedBuckets      Praveen         WI#487181/WI#487905
improved logic to get bucketviews based on consolidated bucketview
2021-05-13  Dev/1.0.ExtendedBuckets  Rajat Garg          WI#487356/WI#489728
Adjustment Property is displaying incorrect value, 
Earlier PropertyGroupList join is not used.
2021-05-20  Dev/1.0.ExtendedBuckets      Praveen         WI#429421/WI#489585 
Performance Improvement
2021-05-25  Dev/1.0.ExtendedBuckets  Rajat Garg             WI#491888/WI#490839
Data not coming in case of universal Promo,
New case added for PropertyGroupID =0
2021-05-26  Dev/1.0.ExtendedBuckets      Rajan Kumar     WI#483286/WI#492037
Change for considering Tier Bonus inside EarnedAwarded field
2021-05-27  Dev/1.0.ExtendedBuckets      Praveen Negi     WI#483286/WI#492037/WI#491108
2.0 | Liabilities are calculated incorrectly in case awards are getting expired.
2021-06-04  Dev/1.0.ExtendedBuckets      ArshdeepSingh     WI#425156/WI#491348
Performance Improvement
2021-06-30  Dev/1.0.ExtendedBuckets      Shekhar           WI#489724/WI#523520
Used Outlet in Case of NonComp Transactions
2021-07-22  Dev/1.0.ExtendedBuckets      Shekhar           WI#523431/WI#546390
Remove Awards and Offers from Liability Reports
2021-08-03  Dev/1.0.ExtendedBuckets  Rajat Garg             WI#549737/WI#550325
Summary is not coming correct
2021-08-26  Dev/1.0.ExtendedBuckets     Nikita Kapoor   WI#491616/WI#554003
Change for @BucketViewList Table
2021-10-08  Release/2.0.1000            Shiva               WI#548822/WI#564023
Performance Fix, Beginning balance fix and more logical fixes
2021-10-25  Release/2.0.1000            Shiva               WI#548822/WI#564023
Fixed universal balance in running balance w.r.t. its usage
2021-11-30  Release/2.0.1000            Nikita               WI#569293/WI#570760
Fixed voided and EarnedAward column
2021-12-03  Release/2.0.1000            Nikita               WI#569293/WI#571280
Fixed Sequence issue
2021-12-06  Release/2.0.1000            Nikita               WI#569293/WI#570760
Reverted Void changes.
2021-12-21  Release/2.0.1000            Nikita               WI#572021/WI#572498
Fixed displaying data in case of no transcation within date range
2022-02-04  Release/2.0.1000            Parag               WI#578243/WI#578413
Return the procedure with norow when only Summary part is selected in the report.
2022-04-21    Dev/2.0.OL15-0       Pramil Gupta     WI#584952/TI#589484
Added INSERT with column list
2022-10-10    Dev/2.0.OL15-0       Niharika     WI#601466/TI#611430
Added Mobility Interface and sanitized code
2023-01-30  Dev/2.0.OL15-0              Shekhar             WI#627175/WI#628070
Corrected Foreign Redemption case in case of Balance used from the same property where it was issued
*/
CREATE OR ALTER PROCEDURE dbo.usp_RPT_BucketLiabilityDetail_sel
(
  @BucketViewID nvarchar(MAX), @PropertyID nvarchar(MAX) = NULL,
  @UniversalID nvarchar(MAX) = NULL, @FromDate date, @ToDate date,
  @TZ nvarchar(8), @ReportType nvarchar(7) = 'Detail'
)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    DECLARE @TimeZone nvarchar(64), @EGMInterfaceID smallint,
      @BucketAwardInitiatorID smallint, @PromoOfferInitiatorID smallint,
      @EarningTransactionTypeID smallint, @RedeemTransactionTypeID smallint,
      @CEPInTransactionTypeID smallint, @NCEPInTransactionTypeID smallint,
      @AdjustmentTransactionTypeID smallint, @CEPOutTransactionTypeID smallint,
      @NCEPOutTransactionTypeID smallint, @ExpiredTransactionTypeID smallint,
      @DepositTransactionTypeID smallint, @RewardTransactionTypeID smallint,
      @TierBonusInitiatorID smallint, @SpeedMediaInterfaceID smallint,
      @OneLinkInterfaceID smallint, @KioskInterfaceID smallint,
      @MobilityInterfaceID smallint,
      @SQL nvarchar(MAX),
      @tBucketViewPrimaryBucketView AS dbo.tBucketViewPrimaryBucketView,
      @tProperties AS dbo.tProperties, @tPlayerID AS dbo.tPlayerID,
      @PromoBucketViewID smallint;

    DECLARE @PropertyList table (PropertyID bigint PRIMARY KEY);
    DECLARE @UniversalIDList TABLE (UniversalID nvarchar(12) PRIMARY KEY NOT NULL, PlayerID bigint NOT NULL);
    DECLARE @BucketViewList TABLE
    (
      BucketViewID bigint NOT NULL PRIMARY KEY,
      PrimaryBucketViewID bigint NOT NULL,
      CurrencySymbol nvarchar(3) NULL,
      DataPrecision tinyint NULL,
      BucketViewDisplayName nvarchar(256) NOT NULL
    );

    DROP TABLE IF EXISTS #MaxPropertyPlayerBalance;
    CREATE TABLE #MaxPropertyPlayerBalance
    (
      PrimaryBucketViewID bigint NOT NULL,
      PlayerID bigint NOT NULL,
      PropertyID bigint NOT NULL,
      MaxPropertyBalance money NOT NULL
    );
    /*To avoid Static Code Anlaysis error*/
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

    DROP TABLE IF EXISTS #ResultSet;
    CREATE TABLE #ResultSet
    (
      EarnedProperty varchar(50) NULL,
      UniversalID char(12) NULL,
      LastName varchar(50) NULL,
      FirstName varchar(50) NULL,
      LastPlayedDate datetime NULL,
      TierName varchar(50) NULL,
      ForeigRedemptionRegion varchar(100) NULL,
      ForeignProperty varchar(50) NULL,
      ForeignRedemptionDateTime datetime2 NULL,
      ForeignRedemptionOutletEGMRedeemed varchar(50) NULL,
      CompName varchar(50) NULL,
      BeginningBalance money NULL,
      EarnedAwarded money NULL,
      RedemptionOnEarnedLocation money NULL,
      ForeignRedemption money NULL,
      EgmDownloads money NULL,
      ForeignEgmDownloads money NULL,
      NcepOut money NULL,
      ForeignNcepOut money NULL,
      Adjustment money NULL,
      ExternalRewards money NULL,
      Expirations money NULL,
      ChangeInLiability money NULL,
      EndingBalance money NULL,
      Voided money NULL,
      CurrencySymbol nvarchar(3) NULL,
      DataPrecision tinyint NULL
    );

    IF @ReportType = 'Summary'
    BEGIN
      SELECT EarnedProperty, UniversalID, LastName, FirstName, LastPlayedDate,
        TierName, ForeigRedemptionRegion, ForeignProperty,
        ForeignRedemptionDateTime, ForeignRedemptionOutletEGMRedeemed,
        CompName, BeginningBalance, EarnedAwarded, RedemptionOnEarnedLocation,
        ForeignRedemption, EgmDownloads, ForeignEgmDownloads, NcepOut,
        ForeignNcepOut, Adjustment, ExternalRewards, Expirations,
        ChangeInLiability, EndingBalance, Voided, CurrencySymbol, DataPrecision
      FROM #ResultSet;
      RETURN;
    END;


    SELECT @PromoBucketViewID = BV.BucketViewID
    FROM dbo.BucketSettings BS
      INNER JOIN dbo.BucketSettingsConfig BSC ON BSC.BucketSettingID = BS.BucketSettingID
      INNER JOIN dbo.BucketViewBuckets BVB ON BVB.BucketID = BS.BucketID
      INNER JOIN dbo.BucketViews BV ON BV.BucketViewID = BVB.BucketViewID
    WHERE BSC.SettingKey = 'IsFreePlay'
      AND BS.Value = 1;

    IF @PropertyID IS NULL
    BEGIN
      INSERT @PropertyList (PropertyID)
      SELECT p.PropertyID
      FROM dbo.UC_X_Property p
        INNER JOIN dbo.UC_X_Host h ON (p.PropertyID = h.PropertyID)
      WHERE p.Active = 1
        AND h.IsUniverse = 0;
    END;
    ELSE
    BEGIN
      INSERT INTO @PropertyList (PropertyID)
      SELECT value FROM STRING_SPLIT(@PropertyID, ',');
    END;

    INSERT INTO @UniversalIDList (UniversalID, PlayerID)
    SELECT U.value, P.PlayerID
    FROM STRING_SPLIT(@UniversalID, ',') U
      INNER JOIN dbo.UC_PL_Player P ON P.UniversalPlayerID = U.value;

    INSERT INTO @BucketViewList
    (
      BucketViewID, PrimaryBucketViewID, CurrencySymbol, DataPrecision,
      BucketViewDisplayName
    )
    SELECT UBVFR.BucketViewID, UBVFR.PrimaryBucketViewID, b1.Symbol,
      b1.DataPrecision, bv.BucketViewDisplayName
    FROM dbo.udf_BucketViewsForReports(
                                        @BucketViewID,
                                        'CompItems,IsTierPoints,IsFreePlay,DiscretionaryComp,IsRedeemableAtEGM'
                                      ) AS UBVFR
      INNER JOIN dbo.BucketViewBuckets bvb ON UBVFR.PrimaryBucketViewID = bvb.BucketViewID
                                             AND bvb.IsPrimaryEarningBucket = 1
      INNER JOIN dbo.BucketViews bv ON bvb.BucketViewID = bv.BucketViewID
      INNER JOIN dbo.Buckets b ON b.BucketID = bvb.BucketID
      CROSS APPLY
    (
      SELECT bkt.DataPrecision, c.Symbol
      FROM dbo.Buckets bkt
        INNER JOIN dbo.BucketViewBuckets bvb ON UBVFR.PrimaryBucketViewID = bvb.BucketViewID
                                               AND bvb.IsPrimaryEarningBucket = 1
        LEFT JOIN dbo.Currencies c ON bkt.CurrencyID = c.CurrencyID
      WHERE bkt.BucketID = bvb.BucketID
    ) b1;

    SELECT @BucketAwardInitiatorID = IIF(Name = 'BucketAwards',
                                     TransactionInitiatorID,
                                     @BucketAwardInitiatorID),
      @PromoOfferInitiatorID = IIF(Name = 'PromoOffer',
                               TransactionInitiatorID,
                               @PromoOfferInitiatorID),
      @TierBonusInitiatorID = IIF(Name = 'TierBonus',
                              TransactionInitiatorID,
                              @TierBonusInitiatorID)
    FROM dbo.TransactionInitiators
    WHERE Name IN ('BucketAwards', 'PromoOffer', 'TierBonus');

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
      @MobilityInterfaceID = IIF(InterfaceName = 'Mobility',
                          InterfaceID,
                          @MobilityInterfaceID)
    FROM dbo.Interfaces
    WHERE InterfaceName IN ('SpeedMedia', 'EGM', 'OneLink', 'Kiosk', 'Mobility');

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

    INSERT INTO @tBucketViewPrimaryBucketView (BucketViewID,
                                              PrimaryBucketViewID
                                              )
    SELECT BucketViewID, PrimaryBucketViewID FROM @BucketViewList;

    INSERT INTO @tProperties (PropertyID)
    SELECT PropertyID FROM @PropertyList
    UNION ALL
    SELECT H.PropertyID
    FROM dbo.UC_X_Property P
      INNER JOIN dbo.UC_X_Host H ON H.PropertyID = P.PropertyID
    where H.IsUniverse = 1;

    INSERT INTO @tPlayerID (PlayerID) SELECT PlayerID FROM @UniversalIDList;

    SELECT @TimeZone = UXT.StandardName
    FROM dbo.UC_X_Timezones AS UXT
    WHERE UXT.StandardAbbreviation = @TZ
      OR UXT.DaylightAbbreviation = @TZ;

    IF @TimeZone IS NULL
      SELECT @TimeZone = UXP.TimeZone
      FROM dbo.UC_X_Property AS UXP
        INNER JOIN dbo.UC_X_Host h ON UXP.PropertyID = h.PropertyID
      WHERE h.IsUniverse = 1;

    EXEC dbo.isp_RunningBalancePropertyWithPlayer_sel @BucketViewList = @tBucketViewPrimaryBucketView,
      @PropertyList = @tProperties, @PlayerIDs = @tPlayerID,
      @FromDate = @FromDate, @UniversalID = @UniversalID,
      @BucketAwardInitiatorID = @BucketAwardInitiatorID,
      @PromoOfferInitiatorID = @PromoOfferInitiatorID;

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
        EarnedProperty, UniversalID, LastName, FirstName, LastPlayedDate,
        TierName, ForeigRedemptionRegion, ForeignProperty,
        ForeignRedemptionDateTime, ForeignRedemptionOutletEGMRedeemed,
        CompName, BeginningBalance, EarnedAwarded, RedemptionOnEarnedLocation,
        ForeignRedemption, EgmDownloads, ForeignEgmDownloads, NcepOut,
        ForeignNcepOut, Adjustment, ExternalRewards, Expirations,
        ChangeInLiability, EndingBalance, Voided, CurrencySymbol, DataPrecision
      )
      SELECT a.EarnedProperty, a.UniversalID, a.LastName, a.FirstName,
        a.LastPlayedDate, a.TierName, a.ForeigRedemptionRegion,
        a.ForeignProperty, a.ForeignRedemptionDateTime,
        a.ForeignRedemptionOutletEGMRedeemed, a.CompName, a.BeginningBalance,
        a.EarnedAwarded, a.RedemptionOnEarnedLocation, a.ForeignRedemption,
        a.EgmDownloads, a.ForeignEgmDownloads, a.NcepOut, a.ForeignNcepOut,
        a.Adjustment, a.ExternalRewards, a.Expirations,
        (a.EarnedAwarded + a.RedemptionOnEarnedLocation + a.ForeignRedemption
         + a.EgmDownloads + a.ForeignEgmDownloads + a.NcepOut
         + a.ForeignNcepOut + a.Adjustment + a.ExternalRewards + a.Expirations
         + a.Voided
        ) AS ChangeInLiability,
        (a.BeginningBalance + a.EarnedAwarded + a.RedemptionOnEarnedLocation
         + a.ForeignRedemption + a.EgmDownloads + a.ForeignEgmDownloads
         + a.NcepOut + a.ForeignNcepOut + a.Adjustment + a.ExternalRewards
         + a.Expirations + a.Voided
        ) EndingBalance, a.Voided, a.CurrencySymbol,
        a.DataPrecision
      FROM
      (
        SELECT t.EarnedProperty, t.UniversalPlayerID UniversalID, t.LastName,
          t.FirstName, t.LastPlayedDate, t.TierName, t.ForeigRedemptionRegion,
          t.ForeignProperty, t.PrimaryBucketViewID,
          t.ForeignRedemptionDateTime, t.ForeignRedemptionOutletEGMRedeemed,
          t.CompName, ISNULL(t.PromoRunningBalance, 0) AS BeginningBalance,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @EarningTransactionTypeID
                       OR
                       (
                         t.TransactionInitiatorID = @TierBonusInitiatorID
                         AND t.TransactionTypeID <> @ExpiredTransactionTypeID
                       ),
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS EarnedAwarded,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @RedeemTransactionTypeID
                       AND t.EarnedPropertyID = t.UsagePropertyID,
                    t.UsageBucketAmount,
                    0),
                  0.0
                ) AS RedemptionOnEarnedLocation,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @RedeemTransactionTypeID
                       AND t.EarnedPropertyID <> t.UsagePropertyID,
                    t.UsageBucketAmount,
                    0),
                  0.0
                ) AS ForeignRedemption,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @NCEPInTransactionTypeID
                       AND t.IsVoid = 0
                       AND t.UsagePropertyID = t.EarnedPropertyID,
                    t.UsageBucketAmount,
                    0),
                  0.0
                ) AS EgmDownloads,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @NCEPInTransactionTypeID
                       AND t.IsVoid = 0
                       AND t.UsagePropertyID <> t.EarnedPropertyID,
                    t.UsageBucketAmount,
                    0.0),
                  0.0
                ) AS ForeignEgmDownloads,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @NCEPOutTransactionTypeID
                       AND (t.EarnedPropertyID = t.UsagePropertyID OR t.UsagePropertyID IS NULL),
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS NcepOut,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @NCEPOutTransactionTypeID
                       AND t.EarnedPropertyID <> t.UsagePropertyID,
                    t.UsageBucketAmount,
                    0),
                  0.0
                ) AS ForeignNcepOut,
          ISNULL(
                  IIF(t.TransactionTypeID = @AdjustmentTransactionTypeID,
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS Adjustment,
          ISNULL(
                  IIF(
                    t.TransactionTypeID IN (@DepositTransactionTypeID,
                                           @RewardTransactionTypeID
                                           )
                       AND t.InterfaceID IN (@SpeedMediaInterfaceID,
                                            @OneLinkInterfaceID,
                                            @KioskInterfaceID,
                                            @MobilityInterfaceID),
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS ExternalRewards,
          ISNULL(
                  IIF(t.TransactionTypeID = @ExpiredTransactionTypeID,
                  t.UsageBucketAmount,
                  0),
                  0.0
                ) AS Expirations,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @NCEPInTransactionTypeID
                       AND t.IsVoid = 1,
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS Voided, t.CurrencySymbol, t.DataPrecision
        FROM
        (
          SELECT t.EarnedProperty, pl.UniversalPlayerID, pl.LastName,
            pl.FirstName, ppl.LastPlayedDate, tx.TierName,
            t.PrimaryBucketViewID, t.TransactionTypeID,
            t.TransactionInitiatorID, t.EarnedPropertyID, t.UsagePropertyID,
            t.IsVoid, t.InterfaceID, t.UsageBucketAmount, t.SourceBucketAmount,
            ISNULL(bb.MaxPropertyBalance, 0.00)
            + ISNULL(
                      SUM(IIF(
                            ISNULL(t.SourcePropertyGroupID, t.PropertyGroupID) = 0
                               AND t.PBTPromoMethod = 'U',
                            IIF(t.UsageBucketAmount = 0.00,
                            t.SourceBucketAmount,
                            t.UsageBucketAmount),
                            0.00)
                         ) OVER (PARTITION BY t.PlayerID, T.PrimaryBucketViewID
                                 ORDER BY T.TransactionDTO, t.TransactionID
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                                ),
                      0.0
                    )
            + ISNULL(
                      SUM(IIF(
                            ISNULL(t.SourcePropertyGroupID, t.PropertyGroupID) <> 0,
                            IIF(t.UsageBucketAmount = 0.00,
                            t.SourceBucketAmount,
                            t.UsageBucketAmount),
                            0.00)
                         ) OVER (PARTITION BY t.PlayerID,
                                   T.PrimaryBucketViewID,
                                   t.EarnedPropertyID
                                 ORDER BY T.TransactionDTO,
                                   t.TransactionID
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                                ),
                      0.0
                    ) AS PromoRunningBalance, t.CurrencySymbol,
            t.DataPrecision, pru.PropertyName ForeignProperty,
            ru.RegionName ForeigRedemptionRegion, c.CompName, t.Bucket,
            t.PlayerID,
            CONVERT(
                     datetime2,
                     CONVERT(datetimeoffset(7), t.TransactionDTO)AT TIME ZONE @TimeZone
                   ) AS ForeignRedemptionDateTime,
            IIF(t.InterfaceID = @EGMInterfaceID,
              CAST(t.MachineID AS varchar(64)),
              IIF(tc.CompItemID IS NOT NULL, uo.OutletName, uon.OutletName)) AS ForeignRedemptionOutletEGMRedeemed
          FROM
          (
            SELECT ISNULL(uxp.PropertyName,t.PropertyName) EarnedProperty, tr.PlayerID,
              t.PrimaryBucketViewID, tr.TransactionTypeID,
              tr.TransactionInitiatorID, ISNULL(tu.TransactionPropertyID,t.EarnedPropertyID) AS EarnedPropertyID,
              tr.TransactionPropertyID UsagePropertyID, tr.IsVoid,
              tr.InterfaceID, t.PropertyGroupID,
              SUM(
                 ISNULL(
                       IIF(tu.TransactionID IS NOT NULL, lu.BucketAmount, NULL),
                       0.00
                       )
                 ) UsageBucketAmount,
              SUM(ISNULL(ls.BucketAmount, 0.0)) SourceBucketAmount,
              t.CurrencySymbol, t.DataPrecision, TR.TransactionDTO,
              TR.MachineID, t.BucketViewDisplayName AS Bucket,
              t.ParentTransactionID, Tu.PropertyGroupID SourcePropertyGroupID,
              t.PBTPromoMethod, t.TransactionID
            FROM
            (
              SELECT t.TransactionID, t.PlayerID, p.PropertyName,
                pgl.PropertyGroupID, bvl.PrimaryBucketViewID, t.GamingDate,
                p.propertyid EarnedPropertyID, bvl.CurrencySymbol,
                bvl.DataPrecision,
                ISNULL(t.ParentTransactionID, t.TransactionID) ParentTransactionID,
                bvl.BucketViewDisplayName, P.PBTPromoMethod
              FROM EB.Transactions t WITH (NOLOCK)
                INNER JOIN dbo.PropertyGroupList pgl ON t.PropertyGroupID = pgl.PropertyGroupID
                INNER JOIN dbo.UC_X_Property p ON IIF(t.PropertyGroupID = 0,
                                                  t.TransactionPropertyID,
                                                  pgl.PropertyID) = p.PropertyID
                INNER JOIN @bucketviewList bvl ON t.BucketViewID = bvl.BucketViewID
                INNER JOIN @PropertyList PRL ON PRL.PropertyID = p.PropertyID
                LEFT JOIN @UniversalIDList ul ON ul.PlayerID = t.PlayerID
              WHERE (t.GamingDate >= @FromDate AND t.GamingDate <= @ToDate)
                AND (@UniversalID IS NULL OR ul.PlayerID IS NOT NULL)
                AND t.TransactionInitiatorID NOT IN (@PromoOfferInitiatorID,
                                                    @BucketAwardInitiatorID
                                                    )
            ) t
              INNER JOIN EB.Transactions TR WITH (NOLOCK) ON TR.TransactionID = t.TransactionID
              LEFT JOIN EB.TransactionLedger ls WITH (NOLOCK) ON t.TransactionID = ls.SourceTransactionID
                                                                AND ls.UsageTransactionID IS NULL
              LEFT JOIN eb.TransactionLedger lu WITH (NOLOCK) ON t.TransactionID = lu.UsageTransactionID
              LEFT JOIN eb.Transactions tu WITH (NOLOCK) ON lu.SourceTransactionID = tu.TransactionID
                                                           AND tu.TransactionInitiatorID NOT IN (
                                                                                                @PromoOfferInitiatorID,
                                                                                                @BucketAwardInitiatorID
                                                                                                )
              LEFT JOIN dbo.PropertyGroupList pglu ON tu.PropertyGroupID = pglu.PropertyGroupID
              LEFT JOIN dbo.UC_X_Property AS uxp ON tu.TransactionPropertyID = uxp.PropertyID
            GROUP BY t.PropertyName, tr.PlayerID, t.PrimaryBucketViewID,
              tr.TransactionTypeID, tr.TransactionInitiatorID,
              t.EarnedPropertyID, tu.TransactionPropertyID, tr.IsVoid,
              tr.InterfaceID, t.PropertyGroupID, t.CurrencySymbol,
              t.DataPrecision, tr.TransactionDTO, t.BucketViewDisplayName,
              t.ParentTransactionID, TR.MachineID, tu.PropertyGroupID,
              t.PBTPromoMethod, t.TransactionID,uxp.PropertyName,TR.TransactionPropertyID
          ) t
            INNER JOIN dbo.UC_PL_Player pl ON T.PlayerID = pl.PlayerID
            INNER JOIN dbo.UC_PL_Tier pt WITH (NOLOCK) ON pl.PlayerID = pt.PlayerID
            INNER JOIN dbo.UC_X_Tier tx ON pt.TierID = tx.TierID
            OUTER APPLY
          (
            SELECT MAX(ppl.LastPlayedDate) LastPlayedDate
            FROM dbo.UC_PL_PropPlay ppl WITH (NOLOCK)
            WHERE PPL.PlayerID = t.PlayerID
              AND PPL.PropertyID = T.EarnedPropertyID
          ) ppl
            LEFT JOIN EB.TransactionCompReferences tc WITH (NOLOCK) ON tc.TransactionID = t.ParentTransactionID
            LEFT JOIN EB.TransactionNonCompReferences tnc WITH (NOLOCK) ON tnc.TransactionID = t.ParentTransactionID
            LEFT JOIN dbo.UC_X_CompItem c ON tc.CompItemID = c.CompItemID
            LEFT JOIN dbo.UC_X_Outlet uo ON uo.OutletID = c.OutletID
            LEFT JOIN dbo.UC_X_Outlet uon ON uon.OutletID = tnc.OutletID
            LEFT JOIN dbo.UC_X_Property pru ON t.UsagePropertyID = pru.PropertyID
            LEFT JOIN dbo.UC_X_Region ru ON pru.RegionID = ru.RegionID
            LEFT JOIN #FinalMaxPropertyPlayerBalance bb ON t.PlayerID = bb.PlayerID
                                                          AND t.EarnedPropertyID = bb.PropertyID
                                                          AND t.PrimaryBucketViewID = bb.PrimaryBucketViewID
          WHERE IIF(t.UsageBucketAmount = 0.00,
                t.SourceBucketAmount,
                t.UsageBucketAmount) <> 0
        ) t
      ) a
      OPTION (RECOMPILE);
    END;
    ELSE
    BEGIN

      DROP TABLE IF EXISTS #BalBef;
      CREATE TABLE #BalBef
      (
        BalBefID int IDENTITY(1, 1) PRIMARY KEY,
        BeginningBalance money NULL,
        PlayerID bigint NOT NULL,
        PrimaryBucketViewID smallint NOT NULL
      );

      INSERT INTO #BalBef (PlayerID, PrimaryBucketViewID, BeginningBalance)
      SELECT PlayerID, PrimaryBucketViewID, SUM(MaxPropertyBalance)
      FROM #FinalMaxPropertyPlayerBalance
      GROUP BY PlayerID, PrimaryBucketViewID;

      INSERT INTO #ResultSet
      (
        EarnedProperty, UniversalID, LastName, FirstName, LastPlayedDate,
        TierName, ForeigRedemptionRegion, ForeignProperty,
        ForeignRedemptionDateTime, ForeignRedemptionOutletEGMRedeemed,
        CompName, BeginningBalance, EarnedAwarded, RedemptionOnEarnedLocation,
        ForeignRedemption, EgmDownloads, ForeignEgmDownloads, NcepOut,
        ForeignNcepOut, Adjustment, ExternalRewards, Expirations,
        ChangeInLiability, EndingBalance, Voided, CurrencySymbol, DataPrecision
      )
      SELECT a.EarnedProperty, a.UniversalID, a.LastName, a.FirstName,
        a.LastPlayedDate, a.TierName, a.ForeigRedemptionRegion,
        a.ForeignProperty, a.ForeignRedemptionDateTime,
        a.ForeignRedemptionOutletEGMRedeemed, a.CompName, a.BeginningBalance,
        a.EarnedAwarded, a.RedemptionOnEarnedLocation, a.ForeignRedemption,
        a.EgmDownloads, a.ForeignEgmDownloads, 0.00 AS NcepOut,
        0.00 AS ForeignNcepOut, a.Adjustment, a.ExternalRewards, a.Expirations,
        (a.EarnedAwarded + a.RedemptionOnEarnedLocation + a.ForeignRedemption
         + a.EgmDownloads + a.ForeignEgmDownloads + a.Adjustment
         + a.ExternalRewards + a.Expirations + a.Voided
        ) AS ChangeInLiability,
        (a.BeginningBalance + a.EarnedAwarded + a.RedemptionOnEarnedLocation
         + a.ForeignRedemption + a.EgmDownloads + a.ForeignEgmDownloads
         + a.Adjustment + a.ExternalRewards + a.Expirations + a.Voided
        ) EndingBalance,
        a.Voided, a.CurrencySymbol, a.DataPrecision
      FROM
      (
        SELECT t.EarnedProperty, t.UniversalPlayerID UniversalID, t.LastName,
          t.FirstName, t.LastPlayedDate, t.TierName, t.ForeigRedemptionRegion,
          t.ForeignProperty, t.PrimaryBucketViewID,
          t.ForeignRedemptionDateTime, t.ForeignRedemptionOutletEGMRedeemed,
          t.CompName,
          ISNULL(t.OtherBucketsRunningBalance, 0) AS BeginningBalance,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @EarningTransactionTypeID
                       OR
                       (
                         t.TransactionInitiatorID = @TierBonusInitiatorID
                         AND t.TransactionTypeID <> @ExpiredTransactionTypeID
                       ),
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS EarnedAwarded,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @RedeemTransactionTypeID
                       AND t.EarnedPropertyID = t.UsagePropertyID,
                    t.UsageBucketAmount,
                    0),
                  0.0
                ) AS RedemptionOnEarnedLocation,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @RedeemTransactionTypeID
                       AND t.EarnedPropertyID <> t.UsagePropertyID,
                    t.UsageBucketAmount,
                    0),
                  0.0
                ) AS ForeignRedemption,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @CEPInTransactionTypeID
                       AND t.IsVoid = 0
                       AND t.UsagePropertyID = t.EarnedPropertyID,
                    t.UsageBucketAmount,
                    0),
                  0.0
                ) AS EgmDownloads,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @CEPInTransactionTypeID
                       AND t.IsVoid = 0
                       AND t.UsagePropertyID <> t.EarnedPropertyID,
                    t.UsageBucketAmount,
                    0.0),
                  0.0
                ) AS ForeignEgmDownloads,
          ISNULL(
                  IIF(t.TransactionTypeID = @AdjustmentTransactionTypeID,
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS Adjustment,
          ISNULL(
                  IIF(
                    t.TransactionTypeID IN (@DepositTransactionTypeID,
                                           @RewardTransactionTypeID
                                           )
                       AND t.InterfaceID IN (@SpeedMediaInterfaceID,
                                            @OneLinkInterfaceID,
                                            @KioskInterfaceID,
                                            @MobilityInterfaceID),
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS ExternalRewards,
          ISNULL(
                  IIF(t.TransactionTypeID = @ExpiredTransactionTypeID,
                  t.UsageBucketAmount,
                  0),
                  0.0
                ) AS Expirations,
          ISNULL(
                  IIF(
                    t.TransactionTypeID = @CEPInTransactionTypeID
                       AND t.IsVoid = 1,
                    IIF(t.UsageBucketAmount = 0.00,
                    t.SourceBucketAmount,
                    t.UsageBucketAmount),
                    0),
                  0.0
                ) AS Voided, t.CurrencySymbol, t.DataPrecision
        FROM
        (
          SELECT t.EarnedProperty, pl.UniversalPlayerID, pl.LastName,
            pl.FirstName, ppl.LastPlayedDate, tx.TierName,
            t.PrimaryBucketViewID, t.TransactionTypeID,
            t.TransactionInitiatorID, t.EarnedPropertyID, t.UsagePropertyID,
            t.IsVoid, t.InterfaceID, t.SourceBucketAmount, t.UsageBucketAmount,
            t.CurrencySymbol, t.DataPrecision,
            ISNULL(bb.BeginningBalance, 0.00)
            + ISNULL(
                      SUM(IIF(t.UsageBucketAmount = 0.00,
                         t.SourceBucketAmount,
                         t.UsageBucketAmount)
                         ) OVER (PARTITION BY t.PlayerID,
                                   T.PrimaryBucketViewID
                                 ORDER BY T.TransactionDTO,
                                   t.TransactionID
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                                ),
                      0.0
                    ) AS OtherBucketsRunningBalance,
            pru.PropertyName ForeignProperty,
            ru.RegionName ForeigRedemptionRegion,
            CONVERT(
                     datetime2,
                     CONVERT(datetimeoffset(7), t.TransactionDTO)AT TIME ZONE @TimeZone
                   ) AS ForeignRedemptionDateTime,
            IIF(t.InterfaceID = @EGMInterfaceID,
              CAST(t.MachineID AS varchar(64)),
              IIF(tc.CompItemID IS NOT NULL, uo.OutletName, uon.OutletName)) AS ForeignRedemptionOutletEGMRedeemed,
            c.CompName, t.Bucket, t.PlayerID
          FROM
          (
            SELECT ISNULL(uxp.PropertyName,t.PropertyName) EarnedProperty, tr.PlayerID,
              t.PrimaryBucketViewID, tr.TransactionTypeID,
              tr.TransactionInitiatorID, ISNULL(tu.TransactionPropertyID,t.EarnedPropertyID) AS EarnedPropertyID,
              tr.TransactionPropertyID UsagePropertyID, tr.IsVoid,
              tr.InterfaceID, t.PropertyGroupID,
              SUM(
                 ISNULL(
                       IIF(tu.TransactionID IS NOT NULL, lu.BucketAmount, NULL),
                       0.00
                       )
                 ) UsageBucketAmount,
              SUM(ISNULL(ls.BucketAmount, 0.0)) SourceBucketAmount,
              t.CurrencySymbol, t.DataPrecision, TR.TransactionDTO,
              t.BucketViewDisplayName AS Bucket, t.ParentTransactionID,
              TR.MachineID, t.TransactionID
            FROM
            (
              SELECT t.TransactionID, t.PlayerID, p.PropertyName,
                pgl.PropertyGroupID, bvl.PrimaryBucketViewID, t.GamingDate,
                p.propertyid EarnedPropertyID, bvl.CurrencySymbol,
                bvl.DataPrecision,
                ISNULL(t.ParentTransactionID, t.TransactionID) ParentTransactionID,
                bvl.BucketViewDisplayName
              FROM EB.Transactions t WITH (NOLOCK)
                INNER JOIN dbo.PropertyGroupList pgl ON t.PropertyGroupID = pgl.PropertyGroupID
                INNER JOIN dbo.UC_X_Property p ON pgl.PropertyID = p.PropertyID
                INNER JOIN @bucketviewList bvl ON t.BucketViewID = bvl.BucketViewID
                INNER JOIN @PropertyList PRL ON PRL.PropertyID = p.PropertyID
                LEFT JOIN @UniversalIDList ul ON ul.PlayerID = t.PlayerID
              WHERE (t.GamingDate >= @FromDate AND t.GamingDate <= @ToDate)
                AND (@UniversalID IS NULL OR ul.PlayerID IS NOT NULL)
                AND t.TransactionInitiatorID NOT IN (@PromoOfferInitiatorID,
                                                    @BucketAwardInitiatorID
                                                    )
            ) t
              INNER JOIN EB.Transactions TR WITH (NOLOCK) ON TR.TransactionID = t.TransactionID
              LEFT JOIN EB.TransactionLedger ls WITH (NOLOCK) ON t.TransactionID = ls.SourceTransactionID
                                                                AND ls.UsageTransactionID IS NULL
              LEFT JOIN eb.TransactionLedger lu WITH (NOLOCK) ON t.TransactionID = lu.UsageTransactionID
              LEFT JOIN eb.Transactions tu WITH (NOLOCK) ON lu.SourceTransactionID = tu.TransactionID
                                                           AND tu.TransactionInitiatorID NOT IN (
                                                                                                @PromoOfferInitiatorID,
                                                                                                @BucketAwardInitiatorID
                                                                                                )
              LEFT JOIN dbo.PropertyGroupList pglu ON tu.PropertyGroupID = pglu.PropertyGroupID
              LEFT JOIN dbo.UC_X_Property AS uxp ON tu.TransactionPropertyID = uxp.PropertyID
            GROUP BY tr.InterfaceID, tr.TransactionID, t.PropertyName,
              tr.PlayerID, t.PrimaryBucketViewID, tr.TransactionTypeID,
              tr.TransactionInitiatorID, t.EarnedPropertyID,
              tu.TransactionPropertyID, tr.IsVoid, t.PropertyGroupID,
              t.CurrencySymbol, t.DataPrecision, tr.TransactionDTO,
              t.BucketViewDisplayName, t.ParentTransactionID, TR.MachineID,
              t.TransactionID,tr.TransactionPropertyID,uxp.PropertyName
          ) t
            INNER JOIN dbo.UC_PL_Player pl ON T.PlayerID = pl.PlayerID
            INNER JOIN dbo.UC_PL_Tier pt WITH (NOLOCK) ON pl.PlayerID = pt.PlayerID
            INNER JOIN dbo.UC_X_Tier tx ON pt.TierID = tx.TierID
            OUTER APPLY
          (
            SELECT MAX(ppl.LastPlayedDate) LastPlayedDate
            FROM dbo.UC_PL_PropPlay ppl WITH (NOLOCK)
            WHERE PPL.PlayerID = t.PlayerID
              AND PPL.PropertyID = T.EarnedPropertyID
          ) ppl
            LEFT JOIN EB.TransactionCompReferences tc WITH (NOLOCK) ON tc.TransactionID = t.ParentTransactionID
            LEFT JOIN EB.TransactionNonCompReferences tnc WITH (NOLOCK) ON tnc.TransactionID = t.ParentTransactionID
            LEFT JOIN dbo.UC_X_CompItem c ON tc.CompItemID = c.CompItemID
            LEFT JOIN dbo.UC_X_Outlet uo ON uo.OutletID = c.OutletID
            LEFT JOIN dbo.UC_X_Outlet uon ON uon.OutletID = tnc.OutletID
            LEFT JOIN dbo.UC_X_Property pru ON t.UsagePropertyID = pru.PropertyID
            LEFT JOIN dbo.UC_X_Region ru ON pru.RegionID = ru.RegionID
            LEFT JOIN #BalBef bb ON t.PlayerID = bb.PlayerID
                                   AND t.PrimaryBucketViewID = bb.PrimaryBucketViewID
          WHERE IIF(t.UsageBucketAmount = 0.00,
                t.SourceBucketAmount,
                t.UsageBucketAmount) <> 0
        ) t
      ) a
      OPTION (RECOMPILE);
    END;

    IF EXISTS (SELECT 1 FROM #ResultSet)
    BEGIN
      SELECT EarnedProperty, UniversalID, LastName, FirstName, LastPlayedDate,
        TierName, ForeigRedemptionRegion, ForeignProperty,
        ForeignRedemptionDateTime, ForeignRedemptionOutletEGMRedeemed,
        CompName, BeginningBalance, EarnedAwarded, RedemptionOnEarnedLocation,
        ForeignRedemption, EgmDownloads, ForeignEgmDownloads, NcepOut,
        ForeignNcepOut, Adjustment, ExternalRewards, Expirations,
        ChangeInLiability, EndingBalance, Voided, CurrencySymbol, DataPrecision
      FROM #ResultSet;
    END;
    ELSE
    BEGIN
      SELECT DISTINCT NULL EarnedProperty, P.UniversalPlayerID UniversalID,
        P.LastName, P.FirstName, NULL LastPlayedDate, NULL TierName,
        NULL ForeigRedemptionRegion, NULL ForeignProperty,
        NULL ForeignRedemptionDateTime,
        NULL ForeignRedemptionOutletEGMRedeemed, NULL CompName,
        ISNULL(bbal.MaxPropertyBalance, 0) BeginningBalance, 0 EarnedAwarded,
        0 RedemptionOnEarnedLocation, 0 ForeignRedemption, 0 EgmDownloads,
        0 ForeignEgmDownloads, 0 NcepOut, 0 ForeignNcepOut, 0 Adjustment,
        0 ExternalRewards, 0 Expirations, 0 ChangeInLiability,
        ISNULL(bbal.MaxPropertyBalance, 0) EndingBalance, 0 Voided,
        bv.CurrencySymbol, bv.DataPrecision
      FROM @UniversalIDList up
        INNER JOIN dbo.UC_PL_Player P WITH (NOLOCK) ON up.PlayerID = P.PlayerID
        LEFT JOIN dbo.UC_PL_DomProp dp WITH (NOLOCK) ON dp.PlayerID = P.PlayerID
        LEFT JOIN dbo.UC_X_Property dprop ON dp.DominantProperty = dprop.PropertyID
        CROSS APPLY
      (
        SELECT DISTINCT PrimaryBucketViewID, BucketViewDisplayName,
          CurrencySymbol, DataPrecision
        FROM @BucketViewList
      ) bv
        LEFT JOIN #FinalMaxPropertyPlayerBalance bbal ON P.PlayerID = bbal.PlayerID
                                                        AND bbal.PrimaryBucketViewID = bv.PrimaryBucketViewID
                                                        AND bbal.PropertyID = dp.DominantProperty;
    END;

  END TRY
  BEGIN CATCH
    THROW;
  END CATCH;
END;
GO