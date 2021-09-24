INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_événement', 'Evénement', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_événement', 'Evénement', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_événement', 'Evénement', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('event','Organisateur-événement')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('event',0,'recruit','Stagiaire',20,'{}','{}'),
	('event',1,'boss','Patron',100,'{}','{}')
;