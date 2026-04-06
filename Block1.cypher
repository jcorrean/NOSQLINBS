:param {
  file_path_root: 'file:///',
  file_0: 'speed_dating.csv'
};

CREATE CONSTRAINT `participant_id_unique` IF NOT EXISTS
  FOR (p:Participant) REQUIRE p.Part_num IS UNIQUE;

CREATE CONSTRAINT `date_rating_id_unique` IF NOT EXISTS
  FOR (d:DateRating) REQUIRE d.date_rating_id IS UNIQUE;

CREATE INDEX `followup_lookup` IF NOT EXISTS
  FOR (f:FollowUp) ON (f.follow_id);