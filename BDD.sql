DROP user BDDAdmin CASCADE;
DROP user Etudiant CASCADE;
DROP user Enseignant CASCADE;


create user BDDAdmin IDENTIFIED BY TPAdmin;
GRANT ALL PRIVILEGES TO BDDAdmin;
GRANT create session to BDDAdmin;

disc;

conn BDDAdmin/TPAdmin;

create table Etudiant
(
    matricule_etu  number(8),
    nom_etu        varchar2(10),
    prenom_etu     varchar2(10),
    date_naissance date,
    constraint PK_Etudiant primary key(matricule_etu)
);
create table Enseignant
(
    matricule_ens  number(8), 
    nom_ens        varchar2(20),
    prenom_ens     varchar2(20),
    age            varchar2(20),
    constraint PK_Enseignant primary key(matricule_ens)
);
create table Unite
(
    code_unite  varchar2(20),
    libelle varchar2(20),
    nbr_heures  varchar2(20),
    matricule_ens number(8),
    constraint PK_Unite primary key(code_unite)
);
create table EtudiantUnite
(
    matricule_etu number(8),
    code_unite varchar2(20),
    note_CC INTEGER,
    note_TP INTEGER,
    note_ex   INTEGER,
    constraint PK_ETU primary key(code_unite, matricule_etu),
    constraint FK_ETU foreign key(matricule_etu)
    references Etudiant (matricule_etu),
    constraint FK_ETU2 foreign key(code_unite)
    references Unite (code_unite)
);
/*UNE TABLE "USERS" CONTIENT TOUS LES UTILISATEURS UTILISEES DANS NOTRE BDD*/ 
CREATE TABLE Users (
    id Varchar2(50) PRIMARY KEY,
    pswd Varchar2(255),
    typeDeCompte Varchar2(2)
);
/*Etudiant*/
Create user Etudiant IDENTIFIED BY TPEtudiant;
GRANT create session to Etudiant;
GRANT SELECT ON BDDAdmin.Etudiant TO Etudiant;
/*Enseignant*/
create user Enseignant IDENTIFIED BY TPEnseignant;
GRANT create session to Enseignant;
GRANT INSERT ON Enseignant TO Enseignant;
GRANT SELECT ON Enseignant TO Enseignant;


INSERT INTO Users values('bddadmin','TPAdmin','AD');
INSERT INTO Users values('etudiant','TPEtudiant','ET');
INSERT INTO Users values('enseignant','TPEnseignant','EN'); 

alter table Etudiant add(Adresse Varchar2(100));
alter table Enseignant drop(age);
alter table Etudiant add constraint check_MatE check(matricule_etu>'20190000' and matricule_etu <'20199999');
alter table Etudiant modify(prenom_etu varchar2(25));

INSERT INTO Etudiant VALUES (20190001, 'BOUSSAI', 'MOHAMED', TO_DATE('12-01-2000', 'DD-MM-YYYY'), 'Alger');
INSERT INTO Etudiant VALUES (20190002, 'CHAID', 'LAMIA', TO_DATE('01-10-1999', 'DD-MM-YYYY'), 'Batna');
INSERT INTO Etudiant VALUES (20190003, 'BRAHIMI', 'SOUAD', TO_DATE('18-11-2000', 'DD-MM-YYYY'), 'Setif');
INSERT INTO Etudiant VALUES (20190004, 'LAMA', 'SAID', TO_DATE('23-05-1999', 'DD-MM-YYYY'), 'Oran');


INSERT INTO Enseignant values(20000001,'HAROUNI', 'AMINE');
INSERT INTO Enseignant values(19990011,'FATHI','OMAR');
INSERT INTO Enseignant values(19980078,'BOUZIDANE','FARAH');
INSERT INTO Enseignant values(20170015,'ARABI','ZOUBIDA');
 
INSERT INTO Unite values('FEI0001', 'POO', 6, 20000001);
INSERT INTO Unite values('FEI0002','BDD',6,19990011);
INSERT INTO Unite values('FEI0003','RESEAU', 3 ,20170015);
INSERT INTO Unite values('FEI0004','SYSTEME', 6 ,19980078);

INSERT INTO EtudiantUnite values(20190001,'FEI0001', 10, 15, 9);
INSERT INTO EtudiantUnite values(20190002,'FEI0001',20,13,10);
INSERT INTO EtudiantUnite values(20190004,'FEI0001',13, 17, 16);
INSERT INTO EtudiantUnite values(20190002,'FEI0002',10, 16, 17);
INSERT INTO EtudiantUnite values(20190003,'FEI0002',9, 8, 15);
INSERT INTO EtudiantUnite values(20190004,'FEI0002',15, 9, 20);
INSERT INTO EtudiantUnite values(20190002,'FEI0004',12, 18, 14);
INSERT INTO EtudiantUnite values(20190003,'FEI0004',17, 12, 15);
INSERT INTO EtudiantUnite values(20190004,'FEI0004',12, 13, 20);


commit;
 
 
UPDATE EtudiantUnite SET note_ex = 0 where code_unite in ( SELECT code_unite from unite   where libelle='SYSTEME');
UPDATE etudiantunite SET note_TP = note_TP + 2 where  matricule_etu IN (SELECT matricule_etu FROM etudiant WHERE nom_etu LIKE 'B%');


-- /*UPDATE*/
/*Afficher les noms et prénoms des étudiants ayant obtenus des notes d'examens égales à 20.*/
SELECT
    NOM_ETU,
    PRENOM_ETU
FROM
    ETUDIANT
WHERE
    MATRICULE_ETU IN (
        SELECT
            MATRICULE_ETU
        FROM
            ETUDIANTUNITE
        WHERE
            NOTE_EX = 20
    );

/*Afficher les noms et prénoms des étudiants qui ne sont pas inscrits dans l'unité « POO ».*/
SELECT
    NOM_ETU,
    PRENOM_ETU
FROM
    ETUDIANT MINUS
    SELECT
        NOM_ETU,
        PRENOM_ETU
    FROM
        ETUDIANT
    WHERE
        MATRICULE_ETU IN (
            SELECT
                MATRICULE_ETU
            FROM
                ETUDIANTUNITE
            WHERE
                CODE_UNITE IN (
                    SELECT
                        CODE_UNITE
                    FROM
                        UNITE
                    WHERE
                        LIBELLE = 'POO'
                )
        );

/*Afficher les libellés des unités d'enseignement dont aucun étudiant n'est inscrit.*/
SELECT
    LIBELLE
FROM
    UNITE
WHERE
    CODE_UNITE NOT IN (
        SELECT
            CODE_UNITE
        FROM
            ETUDIANTUNITE
    );

/*Afficher pour chaque étudiant, son nom, son prénom sa moyenne par unité d'enseignement ainsi que le libellé de l'unité.*/
SELECT
    E.NOM_ETU,
    E.PRENOM_ETU,
    U.LIBELLE,
    AVG((EU.NOTE_CC + EU.NOTE_TP + EU.NOTE_EX) / 3)
FROM
    ETUDIANT      E,
    ETUDIANTUNITE EU,
    UNITE         U
WHERE
    E.MATRICULE_ETU = EU.MATRICULE_ETU
    AND EU.CODE_UNITE = U.CODE_UNITE
GROUP BY
    E.MATRICULE_ETU,
    E.NOM_ETU,
    E.PRENOM_ETU,
    U.LIBELLE;


