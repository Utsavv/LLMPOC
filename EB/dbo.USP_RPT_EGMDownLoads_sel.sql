/*
2021-02-22  dev/1.0.ExtendedBuckets         Ajay           WI#429423/WI#471735    
Initial Version     
2021-02-25  dev/1.0.ExtendedBuckets         Ajay           WI#429423/WI#473351    
Removed TransactionInitiatorStatus join. It can be null.    
2021-02-28  dev/1.0.ExtendedBuckets         Ajay           WI#429423/WI#473656/WI#472743    
Incomplete data appearing in report     
Code refactoring    
2021-03-22  dev/1.0.ExtendedBuckets         Ajay           WI#429423/WI#473656/WI#477321/#WI474060    
Points download data incorrect, Changed irrelevant join in Bucketview clause.     
2021-04-14  dev/1.0.ExtendedBuckets         Ajay           WI#429423/WI#471735/WI#481338    
Summation on BucketView instead of Buckets     
2021-04-26  Dev/1.0.ExtendedBucket          Shekhar            WI#482644/WI#483354
Removed PointsPerDollar/ValueOfPoint from UC_X_Property
2021-05-07  dev/1.0.ExtendedBuckets         Ajay           WI#429423/WI#471735/TI#487181    
Beginning balance issue.
2021-05-11  Dev/1.0.ExtendedBucket          Shekhar            WI#489056/WI#489057
Numeric Bucket- currency Configuration: In Player Reports , cash equivalent not 
showing the correct currency
2021-05-13  Dev/1.0.ExtendedBucket          Shekhar            WI#489631/WI#489714
CasinoManagementSystemAmount was equivalent to TransactionAmount (Without Multiplier) in 1.4
2021-05-17  Dev/1.0.ExtendedBucket          Ajay             WI#429423/WI#473656/TI#481338
Beginning Balance Duplicate issue.
2021-05-17  Dev/1.0.ExtendedBucket          Ajay             WI#429423/WI#473656/TI#491043
Removing universe check from egm downloads.
2021-05-25  Dev/1.0.ExtendedBucket          Ajay             WI#429423/WI#471735/TI#490976/TI#491904
Casino and Dollar point sign change, Nulls to Zero's, PropertyGroupID change
Multiproperty and PropertyGroupID handling cases
2021-02-22  dev/1.0.ExtendedBuckets         Utsav Verma        WI#491616,429423/WI#492937
Used new function to populate bucket views so that custom bucket views will be part of transaction.
2021-06-23  dev/1.0.ExtendedBuckets         Rajat Garg        WI#488970/WI#476867
Added new column Source 
2021-07-06  dev/1.0.ExtendedBuckets         Rajat Garg        WI#523773/WI#476867
Source column reference changes and transaction not coming in Sequential order so removed group by
2021-10-26  Release/2.0.1000            Deepak Dwij        WI#566547/WI#566548
Re-Write proc for perfomance
2021-11-02  Release/2.0.1000    Himanshu Shekhar       WI#567287/567381
Fixed duplicate Rows for property groups having multiple properties
2021-12-21  Release/2.0.1000            Nikita               WI#572021/WI#572498
Fixed displaying data in case of no transcation within date range
2022-01-16  Release/2.0.1000            Shekhar              WI#566547/WI#574424
Removed unused code and Optimized for better performance
2022-02-01  Release/2.0.1000            Rajat Garg              WI#566547/WI#574424
Before Balance was coming wrong as we are adding balance from diff property.
2022-04-08   Dev/2.0.OL15-0            Rajat Garg           WI#586135/WI#587160
In case of Numeric BucketTypeID, Conversion CurrencyID  should be used.
2022-06-17  Dev/2.0.OL15-0         Pramil Gupta     WI#596965/TI#596966
Fixed unqualified column name and removed temp table not used in proc
2022-11-17  Dev/2.0.OL15-0         Parag     WI#616804/TI#616949
Remove index create script on temp table #MaxPropertyPlayerBalance as 
table was already removed.
*/

CREATE OR ALTER PROCEDURE dbo.USP_RPT_EGMDownLoads_sel
  @BucketViewID nvarchar(MAX) = NULL, @PropertyID nvarchar(MAX) = NULL,
  @UniversalID nvarchar(MAX) = NULL, @FromDate date, @ToDate date,
  @TZ nvarchar(16)
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY

    DECLARE @SQL nvarchar(MAX), @Timezone nvarchar(64),
      @PromoBucketViewID smallint, @BlankMoneyValue money = 0.00,
      @NCEPInTransactionTypeID smallint, @CEPInTransactionTypeID smallint,
      @EGMInterfaceID smallint,@tProperties dbo.tProperties, @tPlayerID dbo.tPlayerID,
      @tBucketViewPrimaryBucketView dbo.tBucketViewPrimaryBucketView,
      @BucketAwardInitiatorID smallint, @PromoOfferInitiatorID SMALLINT,
      @NumericBucketTypeID smallint;

    DECLARE @PropertyList table (PropertyID bigint NOT NULL PRIMARY KEY
                                                            (PropertyID)
                                );
    DECLARE @BucketViewList table
    (
      BucketViewID smallint NOT NULL,
      PrimaryBucketViewID smallint NOT NULL,
      BucketID smallint NOT NULL,
      PrimaryBucketViewDisplayName nvarchar(256) NOT NULL,
      CurrencySymbol nvarchar(3) NULL,
      ConversionCurrencySymbol nvarchar(3) NULL,
      DataPrecision tinyint NULL,
      ConversionRate numeric(11, 5) NULL,
      PRIMARY KEY (BucketViewID, PrimaryBucketViewID, BucketID)
    );
    DECLARE @UniversalPlayerID table (PlayerID bigint PRIMARY KEY);

    DROP TABLE IF EXISTS #FinalMaxPropertyPlayerBalance;
    CREATE TABLE #FinalMaxPropertyPlayerBalance
    (
      PlayerID bigint NOT NULL,
      PrimaryBucketViewID smallint NOT NULL,
      PropertyID bigint NOT NULL,
      PropertyName varchar(50) NOT NULL,
      MaxPropertyBalance money NOT NULL
    );

    DROP TABLE IF EXISTS #FinalOfferAwardBalancesProperty;
    CREATE TABLE #FinalOfferAwardBalancesProperty
    (
      PrimaryBucketViewID smallint NOT NULL,
      PlayerID bigint NOT NULL,
      PropertyID bigint NOT NULL,
      RunningBalance money NULL,
      PRIMARY KEY (PrimaryBucketViewID, PlayerID, PropertyID)
    );

    DROP TABLE IF EXISTS #BalBef;
    CREATE TABLE #BalBef
    (
      BalBefID int IDENTITY(1, 1) PRIMARY KEY,
      BeginningBalance money NULL,
      PlayerID bigint NOT NULL,
      PrimaryBucketViewID smallint NOT NULL
    );

    DROP TABLE IF EXISTS #FilteredTransactions;
    CREATE TABLE #FilteredTransactions
    (
      TransactionID bigint NOT NULL,
      PlayerID bigint NOT NULL,
      TransactionTypeID smallint NOT NULL,
      TransactionPropertyGroupID int NULL
    );

    DECLARE @PropertyGroups AS TABLE
    (
      PropertyGroupID int NOT NULL,
      PropertyID BIGINT PRIMARY KEY (PropertyID, PropertyGroupID)
    );

    SELECT @NumericBucketTypeID = BucketTypeID
    FROM dbo.BucketTypes
    WHERE BucketTypeName = 'Numeric';

    INSERT @BucketViewList
    (
      BucketViewID, PrimaryBucketViewID, BucketID,
      PrimaryBucketViewDisplayName, CurrencySymbol, ConversionCurrencySymbol,
      DataPrecision, ConversionRate
    )
    SELECT UBVFR.BucketViewID, UBVFR.PrimaryBucketViewID, b.BucketID,
      pbv.BucketViewDisplayName, b1.Symbol, b1.ConversionSymbol,
      b1.DataPrecision,
      IIF(ISNULL(b.ConversionRate, 0) = 0, 1, b.ConversionRate) ConversionRate
    FROM dbo.udf_BucketViewsForReports(
                                      @BucketViewID,
                                      'IsFreePlay,IsRedeemableAtEGM'
                                      ) UBVFR
      INNER JOIN dbo.BucketViews BV ON UBVFR.BucketViewID = BV.BucketViewID
      INNER JOIN dbo.BucketViewBuckets bvb ON BV.BucketViewID = bvb.BucketViewID
                                             AND bvb.IsPrimaryEarningBucket = 1
      INNER JOIN dbo.Buckets b ON b.BucketID = bvb.BucketID
      INNER JOIN dbo.BucketViews pbv ON UBVFR.PrimaryBucketViewID = pbv.BucketViewID
      CROSS APPLY
    (
      SELECT bkt.DataPrecision, c.Symbol,
        IIF(bkt.BucketTypeID = @NumericBucketTypeID, Curn.Symbol, c.Symbol) ConversionSymbol
      FROM dbo.Buckets bkt
        INNER JOIN dbo.BucketViewBuckets bvb ON UBVFR.PrimaryBucketViewID = bvb.BucketViewID
                                               AND bvb.IsPrimaryEarningBucket = 1
        LEFT JOIN dbo.Currencies c ON bkt.CurrencyID = c.CurrencyID
        LEFT JOIN dbo.Currencies Curn ON bkt.ConversionCurrencyID = Curn.CurrencyID
      WHERE bkt.BucketID = bvb.BucketID
    ) b1;

    SELECT @NCEPInTransactionTypeID = IIF(Name = 'NCEPIn',
                                      TransactionTypeID,
                                      @NCEPInTransactionTypeID),
      @CEPInTransactionTypeID = IIF(Name = 'CEPIn',
                                TransactionTypeID,
                                @CEPInTransactionTypeID)
    FROM dbo.TransactionTypes
    WHERE Name IN ('NCEPIn', 'CEPIn');

    SELECT @PromoBucketViewID = bvb.BucketViewID
    FROM dbo.Buckets b
      INNER JOIN dbo.BucketViewBuckets bvb on bvb.BucketViewID > 0
                                             AND bvb.BucketID = b.BucketID
      INNER JOIN dbo.BucketViews BV ON BV.BucketViewID = BVB.BucketViewID
      INNER JOIN dbo.BucketSettings bs ON b.BucketID = bs.BucketID
      INNER JOIN dbo.BucketSettingsConfig bsc ON bs.BucketSettingID = bsc.BucketSettingID
    WHERE bsc.SettingKey = 'IsFreePlay'
      AND bs.Value = N'1';

    SELECT @BucketAwardInitiatorID = IIF(Name = 'BucketAwards',
                                     TransactionInitiatorID,
                                     @BucketAwardInitiatorID),
      @PromoOfferInitiatorID = IIF(Name = 'PromoOffer',
                               TransactionInitiatorID,
                               @PromoOfferInitiatorID)
    FROM dbo.TransactionInitiators
    WHERE Name IN ('BucketAwards', 'PromoOffer');

    SELECT @EGMInterfaceID = InterfaceID
    FROM dbo.Interfaces
    WHERE InterfaceName = 'EGM';

    IF @PropertyID IS NULL
    BEGIN
      INSERT @Propertylist (PropertyID)
      SELECT p.PropertyID
      FROM dbo.UC_X_Property p
        INNER JOIN dbo.UC_X_Host h ON p.PropertyID = h.PropertyID
      WHERE p.Active = 1
        AND h.IsUniverse = 0;
    END;
    ELSE
    BEGIN
      INSERT @Propertylist (PropertyID)
      SELECT value FROM STRING_SPLIT(@PropertyID, ',');
    END;

    IF @UniversalID IS NOT NULL
    BEGIN
      INSERT @UniversalPlayerID (PlayerID)
      SELECT DISTINCT P.PlayerID
      FROM STRING_SPLIT(@UniversalID, ',') U
        INNER JOIN dbo.UC_PL_Player P WITH (NOLOCK) ON P.UniversalPlayerID = U.value
      WHERE p.PlayerID > 0;
    END;

    INSERT INTO @PropertyGroups (PropertyGroupID, PropertyID)
    SELECT PG.PropertyGroupID, CONVERT(BIGINT, PG.GroupList)
    FROM dbo.PropertyGroups PG
    WHERE CHARINDEX(',', PG.GroupList) = 0;

    INSERT #FilteredTransactions (TransactionID, PlayerID, TransactionTypeID,
                                 TransactionPropertyGroupID
                                 )
    SELECT DISTINCT t.TransactionID, t.PlayerID, t.TransactionTypeID,
      PGL2.PropertyGroupID
    FROM EB.Transactions t WITH (NOLOCK)
      INNER JOIN dbo.PropertyGroupList pgl ON t.PropertyGroupID = pgl.PropertyGroupID
                                             AND IIF(t.PropertyGroupID = 0,
                                                 T.TransactionPropertyID,
                                                 pgl.PropertyID) = T.TransactionPropertyID
      INNER JOIN dbo.UC_X_Property p ON IIF(t.PropertyGroupID = 0,
                                        t.TransactionPropertyID,
                                        pgl.PropertyID) = p.PropertyID
      INNER JOIN @PropertyGroups PGL2 ON PGL2.PropertyID = T.TransactionPropertyID
      INNER JOIN @PropertyList PRL ON PRL.PropertyID = p.PropertyID
      INNER JOIN @BucketViewList bvl ON bvl.BucketViewID = t.BucketViewID
      LEFT JOIN @UniversalPlayerID up ON up.PlayerID = t.PlayerID
    WHERE t.GamingDate >= @FromDate
      AND t.GamingDate <= @ToDate
      AND (@UniversalID IS NULL OR up.PlayerID IS NOT NULL)
    OPTION (RECOMPILE);

    SET @SQL = 'CREATE CLUSTERED INDEX ' + 'nc_FilteredTransactions_'
               + CAST(REPLACE(NEWID(), '-', '_') AS varchar(64))
               + ' 
    ON #FilteredTransactions(TransactionID,PlayerID, TransactionTypeID)';
    EXECUTE sys.sp_executesql @Stmt = @SQL;
    SET @SQL = NULL;

    SELECT @Timezone = UXT.StandardName
    FROM dbo.UC_X_Timezones AS UXT
    WHERE UXT.StandardAbbreviation = @TZ
      OR UXT.DaylightAbbreviation = @TZ;

    IF @Timezone IS NULL
    BEGIN
      SELECT @Timezone = uxp.TimeZone
      FROM dbo.UC_X_Property AS uxp
        INNER JOIN dbo.UC_X_Host uxh ON uxp.PropertyID = uxh.PropertyID
                                       AND uxh.IsUniverse = 1;
    END;

    INSERT @tBucketViewPrimaryBucketView (BucketViewID, PrimaryBucketViewID)
    SELECT BucketViewID, PrimaryBucketViewID FROM @BucketViewList;

    INSERT @tProperties (PropertyID)
    SELECT DISTINCT PropertyID FROM @PropertyList
    UNION ALL
    SELECT uxp.PropertyID
    FROM dbo.UC_X_Property AS uxp
      INNER JOIN dbo.UC_X_Host uxh ON uxp.PropertyID = uxh.PropertyID
                                     AND uxh.IsUniverse = 1;

    INSERT @tPlayerID (PlayerID)
    SELECT DISTINCT t.PlayerID
    FROM
    (
      SELECT DISTINCT PlayerID
      FROM #FilteredTransactions
      UNION ALL
      SELECT PlayerID
      FROM @UniversalPlayerID
    ) t;

    IF EXISTS (SELECT 1 FROM @tPlayerID)
    BEGIN
      EXEC dbo.isp_RunningBalancePropertyWithPlayer_sel @BucketViewList = @tBucketViewPrimaryBucketView,
        @PropertyList = @tProperties, @PlayerIDs = @tPlayerID,
        @FromDate = @FromDate, @UniversalID = -1,
        @BucketAwardInitiatorID = @BucketAwardInitiatorID,
        @PromoOfferInitiatorID = @PromoOfferInitiatorID;

      EXEC dbo.isp_RunningBalanceAwardOffer_sel @BucketViewList = @tBucketViewPrimaryBucketView,
        @PropertyList = @tProperties, @PlayerIDs = @tPlayerID,
        @TillDate = @FromDate, @UniversalID = -1,
        @BucketAwardInitiatorID = @BucketAwardInitiatorID,
        @PromoOfferInitiatorID = @PromoOfferInitiatorID;
    END;

    SET @SQL = 'CREATE NONCLUSTERED INDEX '
               + 'nc_FinalMaxPropertyPlayerBalance_'
               + CAST(REPLACE(NEWID(), '-', '_') AS varchar(64))
               + '
    ON #FinalMaxPropertyPlayerBalance(PlayerID,PrimaryBucketViewID,PropertyID) INCLUDE (MaxPropertyBalance)';
    EXECUTE sys.sp_executesql @Stmt = @SQL;
    SET @SQL = NULL;

    SET @SQL = 'CREATE NONCLUSTERED INDEX '
               + 'nc_FinalOfferAwardBalancesProperty_'
               + CAST(REPLACE(NEWID(), '-', '_') AS varchar(64))
               + '
    ON #FinalOfferAwardBalancesProperty(PlayerID,PrimaryBucketViewID,PropertyID) INCLUDE (RunningBalance)';
    EXECUTE sys.sp_executesql @Stmt = @SQL;

    INSERT #BalBef (PlayerID, PrimaryBucketViewID, BeginningBalance)
    SELECT PlayerID, PrimaryBucketViewID, SUM(MaxPropertyBalance)
    FROM #FinalMaxPropertyPlayerBalance
    GROUP BY PlayerID, PrimaryBucketViewID;

    SELECT final.Property, P.UniversalPlayerID, P.FirstName, P.LastName,
      final.TransactionDateTime, final.BucketName, final.EGMID,
      final.BalanceBefore, final.FactoredLoyaltyPoints, final.BalanceAfter,
      final.DollarAmountofPoints, final.CasinoManagementSystemAmount,
      @BlankMoneyValue PromoBefore, @BlankMoneyValue CurrentPromoBalance,
      @BlankMoneyValue PromoAfter, final.SequenceNumber, final.DataPrecision,
      final.Symbol, final.ConversionSymbol, final.[Source],
      IIF(final.FactoredLoyaltyPoints < 0, final.FactoredLoyaltyPoints, 0) TotalIn,
      IIF(final.FactoredLoyaltyPoints > 0, final.FactoredLoyaltyPoints, 0) TotalOut
    FROM
    (
      SELECT egm2.Property,
        CONVERT(datetime2, egm2.TransactionDTO AT TIME ZONE @TimeZone) TransactionDateTime,
        egm2.BucketName, egm2.EGMID,
        ISNULL(FOA.RunningBalance, @BlankMoneyValue)
        + ISNULL(bb.BeginningBalance, @BlankMoneyValue)
        + ISNULL(
                  SUM(egm2.BucketAmount) OVER (PARTITION BY egm2.PlayerID,
                                                egm2.PrimaryBucketViewID
                                              ORDER BY egm2.TransactionDTO
                                              ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                                             ),
                  @BlankMoneyValue
                ) BalanceBefore, egm2.FactoredLoyaltyPoints,
        ISNULL(FOA.RunningBalance, @BlankMoneyValue)
        + ISNULL(bb.BeginningBalance, @BlankMoneyValue)
        + ISNULL(
                  SUM(egm2.BucketAmount) OVER (PARTITION BY egm2.PlayerID,
                                                egm2.PrimaryBucketViewID
                                              ORDER BY egm2.TransactionDTO
                                              ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                                             ),
                  @BlankMoneyValue
                ) + egm2.BucketAmount BalanceAfter, egm2.DollarAmountofPoints,
        egm2.CasinoManagementSystemAmount, egm2.SequenceNumber,
        egm2.DataPrecision, egm2.Symbol, egm2.ConversionSymbol, egm2.[Source],
        egm2.PlayerID, egm2.TransactionTypeID, egm2.InterfaceID
      FROM
      (
        SELECT egm.Property, egm.TransactionDTO, egm.BucketName, egm.EGMID,
          egm.PlayerID, egm.EarnedPropertyID,
          SUM(egm.BucketAmount) BucketAmount, egm.PrimaryBucketViewID,
          ISNULL(SUM(egm.BucketAmount), @BlankMoneyValue) FactoredLoyaltyPoints,
          SUM(egm.BucketAmount) * egm.ConversionRate * (-1) DollarAmountofPoints,
          SUM(egm.TransactionBucketAmount) * (-1) CasinoManagementSystemAmount,
          egm.SequenceNumber, egm.DataPrecision, egm.Symbol,
          egm.ConversionSymbol, egm.[Source], egm.InterfaceID,
          egm.TransactionTypeID
        FROM
        (
          SELECT t.BucketViewID, p.PropertyName Property,
            p.PropertyID EarnedPropertyID, t.InterfaceID, t.TransactionTypeID,
            bv.PrimaryBucketViewDisplayName BucketName, t.MachineID EGMID,
            ISNULL(
                    IIF(
                      ISNULL(lu.BucketAmount, @BlankMoneyValue) = @BlankMoneyValue,
                      ls.BucketAmount,
                      lu.BucketAmount),
                    @BlankMoneyValue
                  ) BucketAmount,
            ISNULL(
                    IIF(
                      ISNULL(lu.BucketAmount, @BlankMoneyValue) = @BlankMoneyValue,
                      ls.TransactionAmount,
                      lu.TransactionAmount),
                    @BlankMoneyValue
                  ) TransactionBucketAmount, bv.ConversionRate,
            t.TransactionDTO, t.TransactionID SequenceNumber,
            bv.CurrencySymbol Symbol,
            bv.ConversionCurrencySymbol ConversionSymbol, bv.DataPrecision,
            t.PlayerID, bv.PrimaryBucketViewID,
            IIF(tisource.DisplayName IN ('Awards', 'Offers'),
              tisource.DisplayName,
              'Bucket') AS [Source],
            ROW_NUMBER() OVER (PARTITION BY t.TransactionID,
                                 ISNULL(
                                       lu.TransactionLedgerID,
                                       ls.TransactionLedgerID
                                       )
                               ORDER BY IIF(
                                          ISNULL(
                                                lu.PropertyGroupID,
                                                t.PropertyGroupID
                                                ) = ft.TransactionPropertyGroupID,
                                          1,
                                          2)
                              ) RNumLedger
          FROM EB.Transactions t WITH (NOLOCK)
            INNER JOIN #FilteredTransactions ft ON ft.TransactionID = t.TransactionID
            INNER JOIN dbo.UC_X_Property p ON t.TransactionPropertyID = p.PropertyID
            INNER JOIN @BucketViewList bv ON bv.BucketViewID = t.BucketViewID
            LEFT JOIN EB.TransactionLedger ls WITH (NOLOCK) ON t.TransactionID = ls.SourceTransactionID
                                                              AND ls.UsageTransactionID IS NULL
            LEFT JOIN EB.TransactionLedger lu WITH (NOLOCK) ON t.TransactionID = lu.UsageTransactionID
            LEFT JOIN dbo.TransactionInitiators tisource ON lu.TransactionInitiatorID = tisource.TransactionInitiatorID
          WHERE t.BucketViewID <> @PromoBucketViewID
        ) egm
        WHERE egm.RNumLedger = 1
        GROUP BY egm.Property, egm.BucketName, egm.EGMID, egm.TransactionDTO,
          egm.InterfaceID, egm.TransactionTypeID, egm.PlayerID,
          egm.PrimaryBucketViewID, egm.SequenceNumber, egm.DataPrecision,
          egm.Symbol, egm.ConversionSymbol, egm.[Source], egm.ConversionRate,
          egm.EarnedPropertyID
      ) egm2
        LEFT JOIN #BalBef bb ON bb.BalBefID > 0
                               AND egm2.PlayerID = bb.PlayerID
                               AND egm2.PrimaryBucketViewID = bb.PrimaryBucketViewID
        LEFT JOIN #FinalOfferAwardBalancesProperty FOA ON FOA.PlayerID = egm2.PlayerID
                                                         AND FOA.PrimaryBucketViewID = egm2.PrimaryBucketViewID
                                                         AND FOA.PropertyID = egm2.EarnedPropertyID
      WHERE egm2.BucketAmount <> @BlankMoneyValue
    ) final
      INNER JOIN dbo.UC_PL_Player P ON P.PlayerID = final.PlayerID
    WHERE final.InterfaceID = @EGMInterfaceID
      AND final.TransactionTypeID IN (@NCEPInTransactionTypeID,
                                     @CEPInTransactionTypeID
                                     )
    UNION ALL

    -- Promo
    SELECT final.Property, P.UniversalPlayerID, P.FirstName, P.LastName,
      final.TransactionDateTime, final.BucketName, final.EGMID,
      @BlankMoneyValue BalanceBefore, @BlankMoneyValue FactoredLoyaltyPoints,
      @BlankMoneyValue BalanceAfter, @BlankMoneyValue DollarAmountofPoints,
      @BlankMoneyValue CasinoManagementSystemAmount, final.PromoBefore,
      final.BucketAmount CurrentPromoBalance, final.PromoAfter,
      final.SequenceNumber, final.DataPrecision, final.Symbol,
      final.ConversionSymbol, final.[Source],
      IIF(final.BucketAmount < 0, final.BucketAmount, 0) TotalIn,
      IIF(final.BucketAmount > 0, final.BucketAmount, 0) TotalIn
    FROM
    (
      SELECT egm2.Property,
        CONVERT(datetime2, egm2.TransactionDTO AT TIME ZONE @TimeZone) TransactionDateTime,
        egm2.BucketName, egm2.EGMID, egm2.SequenceNumber, egm2.DataPrecision,
        egm2.Symbol, egm2.ConversionSymbol, egm2.[Source], egm2.BucketAmount,
        ISNULL(FOA.RunningBalance, @BlankMoneyValue)
        + ISNULL(f.MaxPropertyBalance, @BlankMoneyValue)
        + ISNULL(
                  SUM(IIF(
                        egm2.PropertyGroupID = 0
                           AND egm2.PBTPromoMethod = 'U',
                        egm2.BucketAmount,
                        @BlankMoneyValue)
                     ) OVER (PARTITION BY egm2.PlayerID,
                               egm2.PrimaryBucketViewID
                             ORDER BY egm2.TransactionDTO
                             ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                            ),
                  @BlankMoneyValue
                )
        + ISNULL(
                  SUM(IIF(egm2.PropertyGroupID <> 0,
                     egm2.BucketAmount,
                     @BlankMoneyValue)
                     ) OVER (PARTITION BY egm2.PlayerID,
                               egm2.PrimaryBucketViewID
                             ORDER BY egm2.TransactionDTO
                             ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                            ),
                  @BlankMoneyValue
                ) PromoBefore,
        ISNULL(FOA.RunningBalance, @BlankMoneyValue)
        + ISNULL(f.MaxPropertyBalance, @BlankMoneyValue)
        + ISNULL(
                  SUM(IIF(
                        egm2.PropertyGroupID = 0
                           AND egm2.PBTPromoMethod = 'U',
                        egm2.BucketAmount,
                        @BlankMoneyValue)
                     ) OVER (PARTITION BY egm2.PlayerID,
                               egm2.PrimaryBucketViewID
                             ORDER BY egm2.TransactionDTO
                             ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                            ),
                  @BlankMoneyValue
                )
        + ISNULL(
                  SUM(IIF(egm2.PropertyGroupID <> 0,
                     egm2.BucketAmount,
                     @BlankMoneyValue)
                     ) OVER (PARTITION BY egm2.PlayerID,
                               egm2.PrimaryBucketViewID
                             ORDER BY egm2.TransactionDTO
                             ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                            ),
                  @BlankMoneyValue
                ) + egm2.BucketAmount PromoAfter, egm2.PlayerID,
        egm2.InterfaceID, egm2.TransactionTypeID
      FROM
      (
        SELECT egm.Property, egm.TransactionDTO, egm.BucketName, egm.EGMID,
          egm.PlayerID, egm.EarnedPropertyID,
          ISNULL(SUM(egm.BucketAmount), @BlankMoneyValue) BucketAmount,
          egm.PrimaryBucketViewID, egm.SequenceNumber, egm.DataPrecision,
          egm.Symbol, egm.ConversionSymbol, egm.[Source], egm.PBTPromoMethod,
          egm.PropertyGroupID, egm.InterfaceID, egm.TransactionTypeID
        FROM
        (
          SELECT p.PropertyName Property, p.PropertyID EarnedPropertyID,
            t.InterfaceID, t.TransactionTypeID,
            bv.PrimaryBucketViewDisplayName BucketName, t.MachineID EGMID,
            ISNULL(
                    IIF(
                      ISNULL(lu.BucketAmount, @BlankMoneyValue) = @BlankMoneyValue,
                      ls.BucketAmount,
                      lu.BucketAmount),
                    @BlankMoneyValue
                  ) BucketAmount, bv.ConversionRate, t.TransactionDTO,
            t.TransactionID SequenceNumber, bv.CurrencySymbol Symbol,
            bv.ConversionCurrencySymbol ConversionSymbol, bv.DataPrecision,
            t.PlayerID, bv.PrimaryBucketViewID, p.PBTPromoMethod,
            ISNULL(lu.PropertyGroupID, t.PropertyGroupID) PropertyGroupID,
            IIF(tisource.DisplayName IN ('Awards', 'Offers'),
              tisource.DisplayName,
              'Bucket') AS [Source],
            ROW_NUMBER() OVER (PARTITION BY t.TransactionID,
                                 ISNULL(
                                       lu.TransactionLedgerID,
                                       ls.TransactionLedgerID
                                       )
                               ORDER BY IIF(
                                          ISNULL(
                                                lu.PropertyGroupID,
                                                t.PropertyGroupID
                                                ) = ft.TransactionPropertyGroupID,
                                          1,
                                          2)
                              ) RNumLedger -- calculated to eliminate duplicate rows from usage's source propertygroup property
          FROM EB.Transactions t WITH (NOLOCK)
            INNER JOIN #FilteredTransactions ft ON ft.TransactionID = t.TransactionID
            INNER JOIN dbo.UC_X_Property p ON t.TransactionPropertyID = p.PropertyID
            INNER JOIN @BucketViewList bv ON bv.BucketViewID = t.BucketViewID
            LEFT JOIN EB.TransactionLedger ls WITH (NOLOCK) ON t.TransactionID = ls.SourceTransactionID
                                                              AND ls.UsageTransactionID IS NULL
            LEFT JOIN EB.TransactionLedger lu WITH (NOLOCK) ON t.TransactionID = lu.UsageTransactionID
            LEFT JOIN dbo.TransactionInitiators tisource ON lu.TransactionInitiatorID = tisource.TransactionInitiatorID
          WHERE t.BucketViewID = @PromoBucketViewID
        ) egm
        WHERE egm.RNumLedger = 1
        GROUP BY egm.Property, egm.BucketName, egm.EGMID, egm.TransactionDTO,
          egm.PBTPromoMethod, egm.InterfaceID, egm.TransactionTypeID,
          egm.PropertyGroupID, egm.PlayerID, egm.PrimaryBucketViewID,
          egm.SequenceNumber, egm.DataPrecision, egm.Symbol,
          egm.ConversionSymbol, egm.[Source], egm.EarnedPropertyID
      ) egm2
        LEFT JOIN #FinalMaxPropertyPlayerBalance F ON F.PlayerID = egm2.PlayerId
                                                     AND F.PrimaryBucketViewID = egm2.PrimaryBucketViewID
                                                     AND F.PropertyID = egm2.EarnedPropertyID
        LEFT JOIN #FinalOfferAwardBalancesProperty FOA ON FOA.PlayerID = egm2.PlayerID
                                                         AND FOA.PrimaryBucketViewID = egm2.PrimaryBucketViewID
                                                         AND FOA.PropertyID = egm2.EarnedPropertyID
      WHERE egm2.BucketAmount <> @BlankMoneyValue
    ) final
      INNER JOIN dbo.UC_PL_Player P ON P.PlayerID = final.PlayerID
    WHERE final.InterfaceID = @EGMInterfaceID
      AND final.TransactionTypeID IN (@NCEPInTransactionTypeID,
                                     @CEPInTransactionTypeID
                                     )
    UNION ALL
    SELECT NULL Property, pl.UniversalPlayerID, pl.FirstName, pl.LastName,
      NULL TransactionDateTime, bv.PrimaryBucketViewDisplayName BucketName,
      NULL EGMID, ISNULL(SUM(bbal.MaxPropertyBalance), 0) BalanceBefore,
      0 FactoredLoyaltyPoints,
      ISNULL(SUM(bbal.MaxPropertyBalance), 0) BalanceAfter,
      0 DollarAmountofPoints, 0 CasinoManagementSystemAmount,
      ISNULL(
              IIF(bv.PrimaryBucketViewID = @PromoBucketViewID,
                SUM(bbal.MaxPropertyBalance),
                0),
              0
            ) PromoBefore, 0 CurrentPromoBalance,
      ISNULL(
              IIF(bv.PrimaryBucketViewID = @PromoBucketViewID,
                SUM(bbal.MaxPropertyBalance),
                0),
              0
            ) PromoAfter, NULL SequenceNumber, bv.DataPrecision,
      bv.CurrencySymbol Symbol, bv.ConversionCurrencySymbol ConversionSymbol,
      NULL [Source], 0 TotalIn, 0 TotalOut
    FROM @UniversalPlayerID up
      INNER JOIN dbo.UC_PL_Player pl WITH (NOLOCK) ON pl.PlayerID = up.PlayerID
      LEFT JOIN dbo.UC_PL_DomProp dp WITH (NOLOCK) ON dp.PlayerID = up.PlayerID
      LEFT JOIN dbo.UC_X_Property dprop ON dp.DominantProperty = dprop.PropertyID
      CROSS APPLY
    (
      SELECT DISTINCT PrimaryBucketViewID, PrimaryBucketViewDisplayName,
        CurrencySymbol, ConversionCurrencySymbol, DataPrecision
      FROM @BucketViewList
    ) bv
      LEFT JOIN #FilteredTransactions ft ON ft.PlayerID = up.PlayerID
                                           AND ft.TransactionTypeID IN (
                                                                       @NCEPInTransactionTypeID,
                                                                       @CEPInTransactionTypeID
                                                                       )
      LEFT JOIN #FinalMaxPropertyPlayerBalance bbal ON up.PlayerID = bbal.PlayerID
                                                      AND bbal.PrimaryBucketViewID = bv.PrimaryBucketViewID
                                                      AND bbal.PropertyID = dp.DominantProperty
    WHERE ft.PlayerID IS NULL
    GROUP BY pl.UniversalPlayerID, pl.LastName, pl.FirstName,
      bv.PrimaryBucketViewDisplayName, bv.CurrencySymbol,
      bv.ConversionCurrencySymbol, dprop.PropertyName, bv.DataPrecision,
      bv.PrimaryBucketViewID
    OPTION (RECOMPILE);

  END TRY
  BEGIN CATCH
    THROW;
  END CATCH;
END;
GO