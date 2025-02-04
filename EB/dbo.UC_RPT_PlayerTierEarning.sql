IF OBJECT_ID('dbo.UC_RPT_PlayerTierEarning') IS NOT NULL
  DROP PROCEDURE dbo.UC_RPT_PlayerTierEarning;
GO
-- ========================================================================================================================================================
-- Version:		13.5.3700
-- Author:		Unknown
-- Create date:	1/1/1900
-- Description: Report for Player Tier Earning - HALoCOREDB
--
-- Tickets:		Last Modified By:		Date of Modification:	Reason for Modification:
-- NONE			Melissa Mendell			11/04/2015				Creation of Comment Block
-- #506			Mohammad Nadeem			08/14/2015				Change Transactiondate to GamingDate
-- #1848		Aries Sace				03/18/2015				Refactor, make ADJ own column
-- #4021		Umesh Singh				04/12/1016				Show Property Name in Report Result
-- #4210		Umakant Yadav			05/11/2016				Migrated from .43 to .44
-- #2861		Nadeem					05/23/2016				Set Default Date if parameters are null
-- #1191		Sean Street				05/26/2016				NGCB Submission Report Requirements: Included PromotionID to inserts
-- #5907		Vic Van Horn			7/11/2016				Added Transaction Type for Driver for Pts Earned
-- ========================================================================================================================================================

/*************************************************************************
DATE        VERSION             NAME                    REFERENCE
2017-09-18  1.0.0               Autogenerated           WI#216104/WI#21702
Initial Version

2018-01-08  Releases/1.0.1020   Abhinay                 WI#239156/WI#242289
Modifying proc to fetch correct data and improve performance

2018-01-08  Releases/1.0.1020   Abhinay                 WI#239156/WI#244198
Incorporating review comments and logic to fetch latest one month data when 
no filter is selected as previous implementation.

2018-06-20  Hotfix/1.0.1020     Kshitij                 WI#272709/WI#278083
Done some formatting stuff. Added one more join condition on overrideLog table.
To get the correct data.

2018-06-29  MRDev\1.0.xxGanymede  Dominic Villasin      WI#279808\277746
Modified to display records from external source (kiosk) as Reward. Added
OPTION(RECOMPILE). Corrected @TransactionFrom and @TransactionTo conversion
then not null and corrected the comparison in the select predicate as it 
was returning incorrect data when dates are used.

2018-10-03  Dev/1.0.3800.Parity   Himanshu            WI#293860/WI#294029
Merging from Q5 to Main(Boyd) to Parity.

2019-06-24    DEV\1.1.OasisLoyalty1.2   Utsav   WI#359795/WI#360727
Brought comments from 3840
2019-06-29    Dev/1.1.OL1.4           Arun G            WI#389228/WI#408450
Updated code to add Tier Bonus in report
**************************************************************************/

IF OBJECT_ID('dbo.UC_RPT_PlayerTierEarning') IS NOT NULL
  DROP PROCEDURE dbo.UC_RPT_PlayerTierEarning;
GO

CREATE PROCEDURE dbo.UC_RPT_PlayerTierEarning
(
  @PropertyID varchar(max) = NULL, @TransactionFrom datetime = NULL,
  @TransactionTo datetime = NULL, @PlayerId char(12) = NULL
)
AS
BEGIN
  SET NOCOUNT ON;

  IF (
       @PropertyID IS NULL
       AND @TransactionFrom IS NULL
       AND @TransactionTo IS NULL
       AND @PlayerId IS NULL
     )
  BEGIN
    SELECT @TransactionFrom = DATEADD(DAY, -30, GETDATE()),
      @TransactionTo = GETDATE();
  END;

  IF @TransactionFrom IS NOT NULL
  BEGIN
    SET @TransactionFrom = DATEADD(dd, DATEDIFF(dd, 0, @TransactionFrom), 0);
  END;

  IF @TransactionTo IS NOT NULL
  BEGIN
    SET @TransactionTo = DATEADD(dd, DATEDIFF(dd, 0, @TransactionTo + 1), 0);
  END;

  SELECT PLA.UniversalPlayerID PlayerID, PLA.FullName PlayerName,
    CASE
      WHEN tpd.ExternalTransaction IS NOT NULL
        OR tpd.CreatedBy IN ('Kiosk', 'OLK Gateway') THEN NULL
      WHEN TPD.TransactionTypeID IN (20028, 20029) THEN 'Tier Bonus'
      ELSE ORR.OverrideReason
    END AdjustmentReason, TPD.TierPoint Earned, TPD.TransactionDate,
    CASE
      WHEN tpd.ExternalTransaction IS NOT NULL
        OR tpd.CreatedBy IN ('Kiosk', 'OLK Gateway') THEN tpd.CreatedBy
      WHEN TPD.TransactionTypeID IN (20028, 20029) THEN 'NA'
      ELSE ORL.LoginUserName
    END UserName,
    CASE
      WHEN tpd.ExternalTransaction IS NOT NULL
        OR tpd.CreatedBy IN ('Kiosk', 'OLK Gateway') THEN tpd.CreatedBy
      WHEN TPD.TransactionTypeID IN (20028, 20029) THEN 'System'
      ELSE ORL.SupervisorLogin
    END Authorizer, PRO.PropertyName,
    CASE
      WHEN tpd.ExternalTransaction IS NOT NULL
        OR tpd.CreatedBy IN ('Kiosk', 'OLK Gateway') THEN 'Reward'
      WHEN TPD.TransactionTypeID IN (20028, 20029) THEN
        transType.TransactionTypeName
      WHEN ORL.TransactionID IS NULL THEN 'EARNED'
      ELSE 'ADJUSTED'
    END ADJ, MIN(TPD.GamingDate) OVER (ORDER BY TPD.GamingDate) AS FromDate,
    MAX(TPD.GamingDate) OVER (ORDER BY TPD.GamingDate) AS ToDate,
    transType.TransactionTypeName AS driverForPtsEarned
  FROM dbo.UC_PL_TierPointDetail TPD WITH (NOLOCK)
    INNER JOIN dbo.UC_X_Property PRO ON PRO.PropertyID = TPD.PropertyID
    INNER JOIN dbo.UC_PL_Player PLA WITH (NOLOCK) ON PLA.PlayerID = TPD.PlayerID
    LEFT OUTER JOIN dbo.ufnSplit(@PropertyID) filteredProps ON PRO.PropertyID = filteredProps.ID
    LEFT JOIN dbo.UC_L_OverrideLog ORL WITH (NOLOCK) ON ORL.TransactionID = TPD.TierPointDetailID
                                                       AND ORL.PlayerId = PLA.PlayerID
    LEFT JOIN dbo.UC_X_OverrideReason ORR ON ORR.ID = ORL.ReasonID
    LEFT JOIN dbo.UC_X_TransactionType transType ON TPD.TransactionTypeID = transType.TransactionTypeID
  WHERE (@TransactionFrom IS NULL OR TPD.GamingDate >= @TransactionFrom)
    AND (@TransactionTo IS NULL OR TPD.GamingDate < @TransactionTo)
    AND
    (
      @PropertyID IS NULL
      OR TPD.PropertyId IN (SELECT ID FROM dbo.ufnSplit(@PropertyID) )
    )
    AND (@PlayerId IS NULL OR @PlayerId = '' OR PLA.UniversalPlayerID = @PlayerId)
  OPTION (RECOMPILE);

END;
GO