*****DATA CLEANING STARTS**********

*Delete out the IDs that have no data

DATASET ACTIVATE DataSet1.
FILTER OFF.
USE ALL.
SELECT IF (Part_num  ~=  '-999').
EXECUTE.

*Standardizing the various ways people entered the follow-up variable
*Make sure to add placeholders for the "0" values by hand

RECODE Follow ('1'='1') ('1.'='1') ('10'='10') ('10.'='10') ('2'='2') ('2.'='2') ('3'='3') ('3.'='3') ('4'='4') 
    ('4.'='4') ('5'='5') ('5.'='5') ('6'='6') ('6.'='6') ('7'='7') ('7.'='7') ('8'='8') ('8.'='8') ('9'='9') ('9.'='9') 
    ('folllow 1'='1') ('folllow 2'='2') ('folllow 3'='3') ('folllow 4'='4') ('folllow 5'='5') ('folllow 6'='6') 
    ('folllow 7'='7') ('folllow 8'='8') ('folllow 9'='9') ('folllow 10'='10') ('follow 1'='1') ('follow 2'='2') 
    ('follow 3'='3') ('follow 4'='4') ('follow 5'='5') ('follow 6'='6') ('follow 7'='7') ('follow 8'='8') 
    ('follow 9'='9') ('follow 10'='10') ('Follow 1'='1') ('Follow 2'='2') ('Follow 3'='3') ('Follow 4'='4') 
    ('Follow 5'='5') ('Follow 6'='6') ('Follow 7'='7') ('Follow 8'='8') ('Follow 9'='9') ('Follow 10'='10') 
    ('followup 1'='1') ('followup 2'='2') ('followup 3'='3') ('followup 4'='4') ('followup 5'='5') ('followup '+
    '6'='6') ('followup 7'='7') ('followup 8'='8') ('followup 9'='9') ('followup 10'='10') ('-999.'='1') 
    ('Z1'='1') ('V1'='1') ('M1'='1') ('K1'='1') ('J1'='1') ('C1'='1') ('D1'='1') ('84.'='4') ('0'='0') (ELSE =COPY) INTO 
    Follow_clean.
EXECUTE.

*Delete Rows if they have no match ID "-999s"

FILTER OFF.
USE ALL.
SELECT IF (MatchID  ~= '-999').
EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (MatchID  ~= '-999.').
EXECUTE.

* Identify Duplicate Cases.
SORT CASES BY Part_num(A) MatchID_clean(A) Follow_clean(A).
MATCH FILES
  /FILE=*
  /BY Part_num MatchID_clean Follow_clean
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryLast InDupGrp MatchSequence.
VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary'.
VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
VARIABLE LEVEL  PrimaryFirst (ORDINAL).
FREQUENCIES VARIABLES=PrimaryFirst.
EXECUTE.

*Delete out the duplicates

FILTER OFF.
USE ALL.
SELECT IF (PrimaryFirst = 1).
EXECUTE.

*******Fixing Out-of-Range Data entry Errors*********

*Standardize missing value code

RECODE FUEnjoyContact (-99=-999) (ELSE=COPY).
EXECUTE.

*Assume that 66 was supposed to be "6"

RECODE IRSayYes (66=6) (ELSE=COPY).
EXECUTE.

*Assume that 10 was supposed to be 9 (based on "Ambitious" item for same person/match)

RECODE IRThinkCareer (10=9) (ELSE=COPY).
EXECUTE.

*Assume that 10 was supposed to be 5 (based on "Career" item for same person/match)

RECODE IRThinkAmbitious (10=9) (ELSE=COPY).
EXECUTE.

*Replace out-of-range values based on "Hot" item for same person/match)

RECODE IRThinkPhys (11=7) (30=5) (50=6) (85=8) (ELSE=COPY).
EXECUTE.

*Replace out-of-range values based on "Friendly" item for same person/match)

RECODE IRThinkFun (0=7) (10=8) (ELSE=COPY).
EXECUTE.

*Standardize missing value code

RECODE IRThinkDependable (-9999=-999) (ELSE=COPY).
EXECUTE.

*Replace out-of-range values based on "Fun" item for same person/match)

RECODE IRThinkFriendly (10=7) (ELSE=COPY).
EXECUTE.


********CALCULATING SCALE TOTALS****************

*Calculating Scale Totals

COMPUTE IRpatt=MEAN(IRThinkPhys,IRThinkHot).
EXECUTE.

COMPUTE IRepro=MEAN(IRThinkCareer,IRThinkAmbitious).
EXECUTE.

COMPUTE IRpers=MEAN(IRThinkFun,IRThinkResponsive,IRThinkDependable,IRThinkFriendly).
EXECUTE.

COMPUTE IRrdes=MEAN(IRLikedPartner,IRSayYes,IRSexAttract).
EXECUTE.

COMPUTE IRchem=MEAN(IRCommon,IRPersonality,IRConnection).
EXECUTE.

COMPUTE FUpasn=MEAN(FUSexDesire,FUSoulMate,FURomInterest,FUOnlyWith,FUMind).
EXECUTE.

COMPUTE FUpatt=MEAN(FUExtentPhys,FUExtentHot).
EXECUTE.

COMPUTE FUepro=MEAN(FUExtentCareer,FUExtentAmbitious).
EXECUTE.

COMPUTE FUpers=MEAN(FUExtentFun,FUExtentRespons,FUExtentFriendly).
EXECUTE.

RECODE IRpatt IRepro IRpers IRrdes IRchem FUpasn FUpatt FUepro FUpers (SYSMIS=-999) (ELSE=COPY).
EXECUTE.

*Recoding dichotomous variables so 1 = Yes and 0 = No
*Contrast coding for Sex

RECODE yessing (1=1) (2=0) (-999=-999).
EXECUTE.

RECODE mutmatch (1=1) (2=0) (-999=-999).
EXECUTE.

RECODE FUEager (1=1) (2=0) (-999=-999).
EXECUTE.

RECODE FUPhysContact (1=1) (2=0) (-999=-999).
EXECUTE.

RECODE sex_M1_F2 (1=-0.5) (2=0.5) (-999=-999).
EXECUTE.





*Saving a smaller datafile for Mplus (3-level)
*Missing followup dependable/trustworthy variable because it wasn't measured accidentally

SAVE OUTFILE='C:\Users\Sean Mackinnon\Desktop\speed.dating.3lev.small.july23.2014.sav'
  /KEEP=Part_num MatchID_clean Follow_clean IRLikedPartner IRSayYes IRSexAttract 
IRThinkCareer IRThinkAmbitious IRThinkPhys IRThinkHot 
IRThinkFun IRThinkResponsive IRThinkDependable IRThinkFriendly
IRCommon IRPersonality IRConnection
yessing
mutmatch
PMexcited PMselfinit PMMatchinit
FUEager FUInitiate FUEnjoy 
FUSexDesire FUSoulMate FURomInterest FUOnlyWith FUMind
FUOneNight FUCasual FUSerious FUCommitted 
FUExtentPhys FUExtentCareer FUExtentAmbitious
FUExtentPhys FUExtentHot
FUExtentFun FUExtentRespons FUExtentFriendly 
DemAge DemEthn
FUPhysContact FUInitiatePhys FUEnjoyContact FUContactBad
IRpatt IRepro IRpers IRrdes IRchem FUpasn FUpatt FUepro FUpers
FUStatus sex_M1_F2.


*Cutting out all but one followup for the two-level dataset

DATASET ACTIVATE DataSet2.
FILTER OFF.
USE ALL.
SELECT IF (Follow_clean = 1).
EXECUTE.

*Delete out all the write-ins

FILTER OFF.
USE ALL.
SELECT IF (MatchID_clean <= 10000).
EXECUTE.

*Turning all the missing values to -999s

RECODE Part_num MatchID_clean Follow_clean IRLikedPartner IRSayYes IRSexAttract IRThinkCareer 
    IRThinkAmbitious IRThinkPhys IRThinkHot IRThinkFun IRThinkResponsive IRThinkDependable 
    IRThinkFriendly IRCommon IRPersonality IRConnection yessing mutmatch PMexcited PMSelfinit 
    PMMatchinit FUEager FUInitiate FUEnjoy FUSexDesire FUSoulMate FURomInterest FUOnlyWith FUMind 
    FUOneNight FUCasual FUSerious FUCommitted FUExtentPhys FUExtentCareer FUExtentAmbitious FUExtentHot 
    FUExtentFun FUExtentRespons FUExtentFriendly DemAge DemEthn FUPhysContact FUInitiatePhys 
    FUEnjoyContact FUContactBad IRpatt IRepro IRpers IRrdes IRchem FUpasn FUpatt FUepro FUpers FUStatus sex_M1_F2
    (SYSMIS=-999) (ELSE=COPY).
EXECUTE.

*Formatting widths for Mplus

ALTER TYPE Part_num MatchID_clean Follow_clean IRLikedPartner IRSayYes IRSexAttract IRThinkCareer 
    IRThinkAmbitious IRThinkPhys IRThinkHot IRThinkFun IRThinkResponsive IRThinkDependable 
    IRThinkFriendly IRCommon IRPersonality IRConnection yessing mutmatch PMexcited PMSelfinit 
    PMMatchinit FUEager FUInitiate FUEnjoy FUSexDesire FUSoulMate FURomInterest FUOnlyWith FUMind 
    FUOneNight FUCasual FUSerious FUCommitted FUExtentPhys FUExtentCareer FUExtentAmbitious FUExtentHot 
    FUExtentFun FUExtentRespons FUExtentFriendly DemAge DemEthn FUPhysContact FUInitiatePhys 
    FUEnjoyContact FUContactBad IRpatt IRepro IRpers IRrdes IRchem FUpasn FUpatt FUepro FUpers FUStatus  sex_M1_F2 (f12.0).
EXECUTE.

******OTHER STATISTICS********

*Saving Aggregate Variables to a separate file to calculate level 3 reliabilities


DATASET ACTIVATE DataSet1.
DATASET DECLARE aggr1.
SORT CASES BY Part_num.
AGGREGATE
  /OUTFILE='aggr1'
  /PRESORTED
  /BREAK=Part_num
  /FUEager_mean=MEAN(FUEager) 
  /FUInitiate_mean=MEAN(FUInitiate) 
  /FUEnjoy_mean=MEAN(FUEnjoy) 
  /FUSexDesire_mean=MEAN(FUSexDesire) 
  /FUSoulMate_mean=MEAN(FUSoulMate) 
  /FURomInterest_mean=MEAN(FURomInterest) 
  /FUOnlyWith_mean=MEAN(FUOnlyWith) 
  /FUMind_mean=MEAN(FUMind) 
  /FUOneNight_mean=MEAN(FUOneNight) 
  /FUCasual_mean=MEAN(FUCasual) 
  /FUSerious_mean=MEAN(FUSerious) 
  /FUCommitted_mean=MEAN(FUCommitted) 
  /FUExtentPhys_mean=MEAN(FUExtentPhys) 
  /FUExtentCareer_mean=MEAN(FUExtentCareer) 
  /FUExtentAmbitious_mean=MEAN(FUExtentAmbitious) 
  /FUExtentHot_mean=MEAN(FUExtentHot) 
  /FUExtentFun_mean=MEAN(FUExtentFun) 
  /FUExtentRespons_mean=MEAN(FUExtentRespons) 
  /FUExtentFriendly_mean=MEAN(FUExtentFriendly) 
  /FUPhysContact_mean=MEAN(FUPhysContact) 
  /FUInitiatePhys_mean=MEAN(FUInitiatePhys) 
  /FUEnjoyContact_mean=MEAN(FUEnjoyContact) 
  /FUContactBad_mean=MEAN(FUContactBad).

*Calculating Reliabiliy in New Dataset

*Personable Alpha Reliability

DATASET ACTIVATE aggr1.
RELIABILITY
  /VARIABLES=FUExtentRespons_mean FUExtentFriendly_mean FUExtentFun_mean
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL.

*Passion alpha reliability

RELIABILITY
  /VARIABLES=FUSexDesire_mean FUSoulMate_mean FURomInterest_mean FUOnlyWith_mean FUMind_mean
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL.

*Reliability physical attractiveness and earning prospects

CORRELATIONS
  /VARIABLES=FUExtentPhys_mean FUExtentHot_mean FUExtentCareer_mean FUExtentAmbitious_mean
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

*Calculating Demographics for Participants Section

DATASET ACTIVATE DataSet2.
DATASET DECLARE demographics.
AGGREGATE
  /OUTFILE='demographics'
  /BREAK=
  /DemAge_mean=MEAN(DemAge) 
  /DemEthn_mean=MEAN(DemEthn) 
  /sex_M1_F2_mean=MEAN(sex_M1_F2)
  /N_BREAK=N.

DATASET ACTIVATE DataSet4.
FREQUENCIES VARIABLES=DemAge_mean DemEthn_mean sex_M1_F2_mean PM_cluster
  /STATISTICS=STDDEV MEAN MEDIAN
  /ORDER=ANALYSIS.
