CREATE DATABASE pak_election; 
USE pak_election; 
 
 
 CREATE TABLE Seat (
    seatnumber VARCHAR(10) PRIMARY KEY
    );


CREATE TABLE Voter ( 
    votercnic  VARCHAR(20) PRIMARY KEY, 
    votername VARCHAR(100), 
    voterage int,
    gender varchar (10),
    voterpassword varchar (20) ,            
    seatnumber VARCHAR(10),
    FOREIGN KEY (seatnumber) REFERENCES Seat(seatnumber)
    
); -- Insert stored procedure 
DELIMITER $$ 
CREATE PROCEDURE InsertVoter( 
    IN p_vcnic VARCHAR(20), 
    IN p_vname VARCHAR(100), 
    IN p_vage int,
    IN p_vseatnumber VARCHAR(20), 
    IN p_vpassword VARCHAR(15), 
    IN p_vgender VARCHAR(100) 
) 
BEGIN 
    INSERT INTO Voter (votercnic, votername,  voterage, gender, voterpassword, seatnumber) 
    VALUES (p_vcnic, p_vname,  p_vage, p_vseatnumber, p_vpassword, p_vgender); 
END$$ 
 
 -- Update stored procedure 
DELIMITER $$ 
CREATE PROCEDURE UpdateVoter( 
    IN p_vcnic VARCHAR(20), 
    IN p_vname VARCHAR(100),
    IN p_vage int,
    IN p_vseatnumber VARCHAR(20), 
    IN p_vpassword VARCHAR(15), 
    IN p_vgender VARCHAR(100)
) 
BEGIN 
    UPDATE Voter 
    SET votername = p_vname, 
        seatnumber = p_vseatnumber, 
         voterpassword = p_vpassword, 
      votername = p_vname  
    WHERE votercnic = p_vcnic; 
END$$ 
 -- Delete stored procedure 
DELIMITER $$

CREATE PROCEDURE DeleteVoter(IN p_vcnic VARCHAR(20))
BEGIN
    -- Step 1: Delete all votes cast by this voter
    DELETE FROM Vote WHERE votercnic = p_vcnic;

    -- Step 2: Now delete the voter
    DELETE FROM Voter WHERE votercnic = p_vcnic;
END$$

DELIMITER ;
-- Select all voters 
DELIMITER $$ 
CREATE PROCEDURE GetAllVoters() 
BEGIN 
    SELECT * FROM Voter; 
END$$


CREATE TABLE voters_with_flag AS
SELECT *, FALSE AS has_voted FROM Voter;

CREATE TABLE voted_cnic (
    cnic VARCHAR(20) PRIMARY KEY
);

DELIMITER //
CREATE PROCEDURE VerifyVoter (
    IN input_cnic VARCHAR(20),
    IN input_password VARCHAR(20)
)
BEGIN
    DECLARE already_voted INT;

    -- Check if the CNIC exists in voted_cnic
    SELECT COUNT(*) INTO already_voted
    FROM voted_cnic
    WHERE votercnic = input_cnic;

    IF already_voted > 0 THEN
        SELECT 'Already Voted';
    ELSE
        IF EXISTS (
            SELECT * FROM Voter
            WHERE votercnic = input_cnic AND voterpassword = input_password
        ) THEN
            SELECT 'Verified';
        ELSE
            SELECT 'Invalid CNIC or Password';
        END IF;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CastVote (
    IN input_cnic VARCHAR(20),
    IN input_party VARCHAR(50)
)
BEGIN
    -- Record the CNIC in voted_cnic
    INSERT INTO voted_cnic (cnic) VALUES (input_cnic);

    -- Increase party vote
    UPDATE party
    SET votes = votes + 1
    WHERE party_name = input_party;
END //
DELIMITER ;



DELIMITER //
CREATE PROCEDURE VerifyVoter(
    IN input_cnic VARCHAR(20),
    IN input_password VARCHAR(50)
)
BEGIN
    DECLARE voter_count INT;
    DECLARE already_voted INT;

    SELECT COUNT(*) INTO voter_count
    FROM voters_with_flag
    WHERE votercnic = input_cnic AND voterpassword = input_password;

    IF voter_count = 0 THEN
        SELECT 'Invalid' AS status;
    ELSE
        SELECT has_voted INTO already_voted
        FROM voters_with_flag
        WHERE votercnic = input_cnic AND voterpassword = input_password;

        IF already_voted = TRUE THEN
            SELECT 'Already Voted' AS status;
        ELSE
            SELECT 'Verified' AS status;
        END IF;
    END IF;
END //
DELIMITER ;

CREATE TABLE ElectionTimer (
    id INT PRIMARY KEY,
    start_time DATETIME,
    end_time DATETIME
);
INSERT INTO ElectionTimer (id, start_time, end_time) VALUES (1, NULL, NULL);


DELIMITER $$

CREATE PROCEDURE CheckIfVoted (
    IN p_cnic VARCHAR(20)
)
BEGIN
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count
    FROM Vote
    WHERE votercnic = p_cnic;

    IF v_count = 0 THEN
        SELECT 'Not Voted' AS status;
    ELSE
        SELECT 'Already Voted' AS status;
    END IF;
END$$

DELIMITER ;


-- PARTY TABLE ----


CREATE TABLE Party (
    partyid INT AUTO_INCREMENT PRIMARY KEY,
    partyname VARCHAR(100) NOT NULL UNIQUE,
    symbol VARCHAR(255),
    leadername VARCHAR(150)
);
 -- Insert stored procedure 
DELIMITER $$ 
CREATE PROCEDURE Insertparty( 
    IN p_pid VARCHAR(20), 
    IN p_pname VARCHAR(100), 
    IN p_psymbol varchar(100),
    IN p_pleadername VARCHAR(100) 
) 
BEGIN 
    INSERT INTO Party (  partyid,  partyname ,  symbol, leadername) 
    VALUES (p_pid , p_pname,  p_psymbol, p_pleadername); 
END$$ 
 
 -- Update stored procedure 
DELIMITER $$ 
CREATE PROCEDURE UpdateParty( 
    IN p_pid VARCHAR(20), 
    IN p_pname VARCHAR(100), 
    IN p_psymbol int,
    IN p_pleadername VARCHAR(100) 
) 
BEGIN 
    UPDATE Party
    SET name = p_pname, 
        symbol = p_psymbol, 
         voterpassword = p_vpassword, 
    leadername = p_pleadername  
    WHERE partyid = p_pid; 
END$$ 
 -- Delete stored procedure 
DELIMITER $$ 
CREATE PROCEDURE DeleteParty(IN p_pid VARCHAR(20)) 
BEGIN 
    DELETE FROM Party WHERE partyid = p_pid; 
END$$ -- Select all parties 
DELIMITER $$ 
CREATE PROCEDURE GetAllParties() 
BEGIN 
    SELECT * FROM Party; 
END$$



-- CANDIDATE TABLE ------



CREATE TABLE Candidate (
    candidatecnic VARCHAR(15) PRIMARY KEY,
    candidatename VARCHAR(150) NOT NULL,
    partyid INT NULL,
    seatnumber VARCHAR(10) NOT NULL,
    FOREIGN KEY (partyid) REFERENCES Party(partyid),
    FOREIGN KEY (seatnumber) REFERENCES Seat(seatnumber)
); 
-- Insert stored procedure 
DELIMITER $$ 
CREATE PROCEDURE InsertCandidate( 
    IN p_ccnic VARCHAR(20), 
    IN p_cname VARCHAR(100), 
    IN p_cpid VARCHAR(15), 
    IN p_cseatnumber VARCHAR(100) 
) 
BEGIN 
    INSERT INTO Candidate ( candidatecnic, candidatename, partyid,  seatnumber) 
    VALUES ( p_ccnic, p_cname, p_cpid , p_cseatnumber); 
END$$ 
 
 -- Update stored procedure 
DELIMITER $$ 
CREATE PROCEDURE UpdateCandidate( 
    IN p_ccnic VARCHAR(20), 
    IN p_cname VARCHAR(100), 
    IN p_cpid VARCHAR(15), 
    IN p_cseatnumber VARCHAR(100) 
) 
BEGIN 
    UPDATE Candidate 
    SET candidatename = p_cname, 
        seatnumber = p_cseatnumber, 
         partyid = p_cpid
    WHERE candidatecnic= p_ccnic; 
END$$ 
 -- Delete stored procedure 
DELIMITER $$ 
CREATE PROCEDURE DeleteCandidate(IN p_ccnic VARCHAR(20)) 
BEGIN 
    DELETE FROM Candidate  WHERE candidatecnic= p_ccnic; 
END$$ -- Select all Candidates
DELIMITER $$ 
CREATE PROCEDURE GetAllCandidate() 
BEGIN 
    SELECT * FROM Candidate ; 
END$$

create table if not exists constituency ( 
constituency_no varchar(20) primary key, 
region varchar(100) not null, 
assembly varchar(20) not null 
);

create table if not exists vote ( 
votercnic varchar(15) not null, 
candidatecnic varchar(15) not null, 
seatnumber varchar(20) not null, 
date_time date not null, 
primary key (votercnic, seatnumber), 
foreign key (votercnic) references Voter(votercnic), 
foreign key (candidatecnic) references Candidate(candidatecnic), 
foreign key (seatnumber) references Seat(seatnumber) 
);

DELIMITER $$

CREATE PROCEDURE InsertVote (
    IN votercnic VARCHAR(20),
    IN candidatecnic VARCHAR(20),
    IN seatnumber VARCHAR(20),
    IN votedate DATE
)
BEGIN
    INSERT INTO vote (votercnic, candidatecnic, seatnumber, date_time)
    VALUES (votercnic, candidatecnic, seatnumber, votedate);
END $$

DELIMITER ;


create table if not exists electionresult ( 
election_id int primary key auto_increment, 
year int not null unique, 
candidatecnic varchar(15) not null, 
total_votes int default 0, 
status enum('winner', 'loser') not null, 
foreign key (candidatecnic) references Candidate(candidatecnic) 
);