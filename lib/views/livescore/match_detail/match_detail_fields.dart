/// LiveScore6 API field name constants (renamed from _F to allow cross-file imports)
class F {
  F._();

  // BasicMatchParser
  static const homeTeam       = 'T1';
  static const awayTeam       = 'T2';
  static const homeScore      = 'Tr1';
  static const awayScore      = 'Tr2';
  static const matchStartDate = 'Esd';
  static const matchEndDate   = 'Edf';
  static const matchStatus    = 'Eps';
  static const matchStatusId  = 'Esid';
  static const matchId        = 'Eid';
  static const overallStatus  = 'Epr';
  static const whichTeamWon   = 'Ewt';
  static const matchInfoProps = 'EO';

  // SoccerBasicMatchParser
  static const halfTimeHome  = 'Trh1';
  static const halfTimeAway  = 'Trh2';
  static const extraTimeHome = 'Tr1ET';
  static const extraTimeAway = 'Tr2ET';
  static const penaltyHome   = 'Trp1';
  static const penaltyAway   = 'Trp2';

  // BasicParticipantParser
  static const participantId = 'ID';
  static const participantNm = 'Nm';
  static const badgeId       = 'Img';
  static const countryName   = 'Cnm';
  static const countryId     = 'CoId';

  // BasicPlayersParser
  static const playerFirstNm  = 'Fn';
  static const playerLastNm   = 'Ln';
  static const playerFullNm   = 'Shnm';
  static const playerNumber   = 'Snu';
  static const playerPos      = 'Pos';
  static const playerActPos   = 'PosA';
  static const playerStatus   = 'Rt';
  static const playerStatusRs = 'Rs';

  // LineupsParser
  static const lineups   = 'Lu';
  static const lineupPs  = 'Ps';
  static const lineupFo  = 'Fo';
  static const lineupSubs = 'Subs';
  static const lineupIS  = 'IS';

  // IncidentParser
  static const incs              = 'Incs';
  static const incidentType      = 'IT';
  static const incidentReason    = 'IR';
  static const minute            = 'Min';
  static const minuteExt         = 'MinEx';
  static const playerNameInc     = 'Pn';
  static const incidentPlayerAid = 'Aid';
  static const incidentNm        = 'Nm';
  static const scores            = 'Sc';

  // HeadToHeadParser
  static const h2hEvents  = 'H2H';
  static const stageGroup = 'Stg';

  // CompetitionStatsParser
  static const playerRank     = 'Rnk';
  static const playerStatName = 'Pnm';
  static const teamId         = 'Tid';
  static const teamName       = 'Tnm';

  // Match stats keys
  static const statPossession   = 'Pss';
  static const statShotsOn      = 'Shon';
  static const statShotsOff     = 'Shof';
  static const statTotalShots   = 'Sht';
  static const statCorners      = 'Cos';
  static const statFouls        = 'Fls';
  static const statYellowCards  = 'Ycs';
  static const statRedCards     = 'YRcs';
  static const statOffsides     = 'Ofs';
  static const statSaves        = 'Svs';
  static const statAttacks      = 'Atk';
  static const statDangerousAtk = 'Dngs';

  // CompetitionParser / StageParser
  static const competitionName = 'CompN';
  static const competitionDesc = 'CompD';
  static const competitionSub  = 'CompST';
  static const competitionId   = 'CompId';
  static const stageName       = 'Snm';
  static const stageCode       = 'Scd';
  static const stageId         = 'Sid';
  static const stageExtId      = 'ExSid';

  // Incident Type IDs
  static const itRegularGoal       = 36;
  static const itPenalty           = 37;
  static const itMissedPenalty     = 38;
  static const itOwnGoal           = 39;
  static const itYellowCard        = 43;
  static const itSecondYellow      = 44;
  static const itRedCard           = 45;
  static const itUnknownCard       = 46;
  static const itExtraTimeGoal     = 47;
  static const itExtraTimeMissed   = 48;
  static const itAssist            = 63;
  static const itSubstitution      = 3;
  static const itSubstitutionOut   = 4;
  static const itSubstitutionIn    = 5;
  static const itTimePeriodFirst   = 10;
  static const itTimePeriodHalf    = 11;
  static const itTimePeriodSecond  = 12;
  static const itTimePeriodFinished = 22;
  static const itFinishedAET       = 23;
  static const itFinishedAP        = 24;
  static const itVarPenalty        = 1046;
  static const itVarGoal           = 1047;
  static const itVarCard           = 1048;

  // Esid numeric status
  static const esidNotStarted = 0;
  static const esidFirstHalf  = 1;
  static const esidHalfTime   = 2;
  static const esidSecondHalf = 3;
  static const esidETFirst    = 4;
  static const esidETHalfTime = 5;
  static const esidETSecond   = 6;
  static const esidPenalties  = 7;
  static const esidFullTime   = 8;
  static const esidPostponed  = -1;
  static const esidCancelled  = -2;
  static const esidAbandoned  = -3;
  static const esidSuspended  = -4;
}