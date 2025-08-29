--create database master key (dmk) to use in encryption using user-defined password
--used randomly genreated secure password
create master key encryption by password = 'IZ_nYPz4h7H$W[B';

--create certificate for use in key creation
--subject clause just describes certificate
create certificate encryptcert with subject = 'Spotify Database Encryption';

--create symmetric key using AES-256 encyption algorithm that is encrypted by the certificate
create symmetric key symkey with algorithm = AES_256 encryption by certificate encryptcert;

--due to encrypting after table creation alter tables to include column to hold
--encrypted names data
--use varbinary max becuase the names have varying lengths and some are relatively long
--this way all names can be encrypted regardless of length

--adds encrypted names column to artist table for encrypted artist names
alter table artist add artist_name_encrypt varbinary(MAX);

--adds encrypted names column to albums table for encrypted album names
alter table album add album_name_encrypt varbinary(MAX);

--adds encrypted names column to genre table to hold encrypted genre and subgenre names 
alter table genre add genre_name_encrypt varbinary(MAX), subgenre_name_encrypt varbinary(max);

--adds encrypted names column to playlist table to hold encrypted playlist names
alter table playlist add playlist_name_encrypt varbinary(MAX);

--adds encrypted names column to track to hold encrypted track names
alter table track add track_name_encrypt varbinary(MAX);

--did not need to add columns for all tables becuase it is most important in most situations
--to encrypt name data so stuck to that to model how a database with more sensitive information
--might be encrypted

--data was inserted before encryption so any data already in the tables is encrypted here
--open symmetric key so that it is used to encrypt data
open symmetric key symkey decryption by certificate encryptcert;

--each update statement uses encryptbykey function using the unique identifier or (guid)
--of the symmetric key used to set up encryption in this project 'symkey'
--to encrypt relavent name data in each table

--encrypts artist names and stores the encrypted names in new encrypted names column
update artist set artist_name_encrypt = encryptbykey(key_guid('symkey'), artist_name);

--encrypts album names and stores the encrypted names in new encrypted names column
update album set album_name_encrypt = encryptbykey(key_guid('symkey'), album_name);

--encrypts names of genre and subgenre and stores them into new encrypted names column
update genre set genre_name_encrypt = encryptbykey(key_guid('symkey'), genre_name),
	subgenre_name_encrypt = encryptbykey(key_guid('symkey'), subgenre_name);

--encrypts playlist names and stores them into new encrypted playlist names column
update playlist set playlist_name_encrypt = encryptbykey(key_guid('symkey'), playlist_name);

--encrypts track names and stores them into new encrypted track name column
update track set track_name_encrypt = encryptbykey(key_guid('symkey'), track_name);

--after tables are updated close key to maintain security
close symmetric key symkey;

--create tables to hold indeces of encrypted data
--allows for data to be queried and searched without having to pull entire table
--indexing enables decryption using only relavent rows for the queries or searches

--create index table for artist
--keep artist id for identification
--hash name to allow for fast searches without needing decryption
create table artistIndex (
	artist_id int primary key,
	nameHash varbinary(64)
);

--create index table for album
--use album id for identification
--could improve security by tokenizing the id
--store releasedate as int with just the year to prevent unecessary encryption
--categorize albums into buckets based on track count to make searching more effiecient
create table albumIndex (
	album_id varchar(50) primary key,
	releasedate int,
	trackcountindex int
);

--create index table for genre
--use genre id for identification
--create bucket categories for genre by assigning each a number to make queries perform better
create table genreIndex (
	genre_id int primary key,
	genrecategoryindex int
);

--create index for playlist
--use playlist id for identification
--could also be improved by tokenizing the ids for better security
--create bucket categories for playlist same as genre where they are assigned numerical categories based on their genre
create table playlistIndex (
	playlist_id varchar(50) primary key,
	genrecategoryindex int
);

--create index for track
--use track id for identification
--create buckets for popularity, mode, and tempo
create table trackIndex (
	track_id varchar(50) primary key,
	popularityBucket int,
	modeIndex int,
	tempoIndex int
);

--create index for trackartist relationship table
--use indexed ids to link track and artist together
--allows for queries to reference artist tracks using indexed ids instead of names
create table trackartistIndex (
	track_id varchar(50),
	artist_id int,
	primary key (track_id, artist_id)
);

--create features index
--creates buckets for certain features
--allows for filtering quickly based on certain features
--could add more buckets to allow for more sorting and filtering methods
create table featuresIndex (
	feature_id int primary key,
	acousticBucket int,
	instrumentalBucket int
);

--insert data into indexes
--for artists use hashes (hashbytes) function with algortihm SHA2_256 to encrypt names
--using hashing allows for fast searching without storing plaintext names
insert into artistIndex (artist_id, nameHash) select artist_id, hashbytes('SHA2_256', artist_name) from artist;

--gets the year from album release date and divides albums into 5 groups(ntile(5)) based on track count
--inserts those values including album id into index table
insert into albumIndex (album_id, releasedate, trackcountindex) 
select album_id, year(album_release_date) as releasedate,
	ntile(5) over (order by total_tracks) as trackcountindex from album;

--splits genre into 10 groups (ntile(10)) and inserts genres into genre index
--using those groups as genre category index with the genre id
insert into genreIndex (genre_id, genrecategoryindex)
select genre_id, ntile(10) over (order by genre_name) as genrecategoryindex from genre;

--uses join to combine playlist with the indexed genres so that genre calculations
--do not get repeated when querying playlists
insert into playlistIndex (playlist_id, genrecategoryindex)
select playlist_id, g.genrecategoryindex from playlist p
join genreIndex g on p.genre_id = g.genre_id;

--seperates tracks into 5 groups (ntile(5)) based on popularity for popularity buckets
--sets mode to 1 if major and 0 if minor for insertion into modeindex
--seperates tracks into 5 groups based on tempo for tempo index
--inserts track id and bucket info into track index
insert into trackIndex (track_id, popularityBucket, modeIndex, tempoIndex)
select track_id,
	ntile(5) over (order by track_popularity) as popularityBucket,
	case when mode = 1 then 1 else 0 end as modeIndex,
	ntile(5) over (order by tempo) as tempoIndex from track;

--insert ids into track artist index this may be redundant
insert into trackartistIndex (track_id, artist_id) select track_id, artist_id from trackartist;

--seperate features into 5 groups each for acousticness and instrumentalness
--inserts bucket numbers and ids of each feature into feature index
insert into featuresIndex (feature_id, acousticBucket, instrumentalBucket)
select feature_id,
	ntile(5) over (order by acousticness) as acousticBucket,
	ntile(5) over (order by instrumentalness) as instrumentalBucket from features;

--create mapping tables to catgeorize buckets from index tables
--improves data interpretation and makes searches more effiecient

--mapping table for popularity index
--uses popularity index as key
--description to hold readable interpretation of popularity
create table popularityLookup (
    popularityIndex int primary key,
    description varchar(255)
);

--five groups so descriptions given on scale of 1-5
--inserts set description of popularity based on index with 1 being least popular and 5 most popular
insert into popularityLookup values 
(1, 'Rarely Played'), 
(2, 'Slightly Popular'), 
(3, 'Moderately Popular'), 
(4, 'Highly Popular'), 
(5, 'Extreme Hit');

--mapping table for mode
--use mode index for primary key
--description attribute to hold calssification (major or minor)
create table modeLookup (
    modeIndex int primary key,
    description varchar(255)
);

--two cases for mode (major and minor) so insert classification for both
insert into modeLookup values (0, 'Minor Key'), (1, 'Major Key');

--mapping table for tempo
--tempo index is primary key
--description attribute to hold tempo description based on index
create table tempoLookup (
    tempoIndex int primary key,
    description varchar(255)
);

--five groups so tempos range from 1 to 5
--set tempo scale from slow-fast based on those 5 groups and insert index and description into mapping table
insert into tempoLookup values 
(1, 'Slow'), 
(2, 'Moderate-Slow'), 
(3, 'Moderate'), 
(4, 'Fast'), 
(5, 'Very Fast');


--mapping table for acousticness
--min and max acousticness levels for each group
--description attribute to hold readable interpretation of index
create table acousticnessLookup (
    min_value float,
    max_value float,
    description varchar(255)
);

--define ranges for not acoustic to extremely acoustic
--dataset ranges from 0.0 - 1.0 so base ranges on that
--tried to use groups but had issues
--technically this should work with group numbers 1-5 instead of having to use ranges
insert into acousticnessLookup values 
(0.00, 0.20, 'Not Acoustic'), 
(0.21, 0.40, 'Slightly Acoustic'), 
(0.41, 0.60, 'Moderately Acoustic'), 
(0.61, 0.80, 'Highly Acoustic'), 
(0.81, 1.00, 'Extremely Acoustic');

--mapping table for instrumentalness
--min and max attributes for ranges based on groups
--description attribute to hold readable representation of what each group is
create table instrumentalnessLookup (
    min_value float,
    max_value float,
    description varchar(255)
);

--define ranges from not instrumental to extremely instrumental
--same as above with how the dataset values range
--also same as above as technically should be able to use groups 1-5 as defined in index table
--but had similar issue so created ranges instead for use
insert into instrumentalnessLookup values 
(0.00, 0.20, 'Not Instrumental'), 
(0.21, 0.40, 'Slightly Instrumental'), 
(0.41, 0.60, 'Moderately Instrumental'), 
(0.61, 0.80, 'Highly Instrumental'), 
(0.81, 1.00, 'Purely Instrumental');

--procedures to encrypt data for insertion

--procedure to insert encrypted artist name into artist table 
go
create procedure insertArtist
    --takes parameter artist name
    @artist_name varchar(50)
as
begin
    --open key to use for encryption
    open symmetric key symkey decryption by certificate encryptcert;

    --use key to encrypt artist name and store it into encrypted_name
    declare @encrypted_name varbinary(255) = encryptbykey(key_guid('symkey'), @artist_name);
    
    --insert encrypted name into artist table
    insert into artist (artist_id, artist_name_encrypt) 

    --create id for artist because they are not autogenerated in tables
    --coalece(max(artist_id),0) finds highest artist id in table and if its empty its set to 0
    --then increments by 1 to get next id this ensures that if table is empty it starts at 1
    values ((select coalesce(max(artist_id), 0) + 1 from artist), @encrypted_name);

    --close key
    close symmetric key symkey;
end;

--procedure to insert album into database and encrypt the album name for insertion
go
create procedure insertAlbum
    --takes 3 parameters name, release date, and total tracks
    @album_name varchar(255),
    @album_release_date date,
    @total_tracks int
as
begin
    --open key for use for encryption of album name
    open symmetric key symkey decryption by certificate encryptcert;

    --initialize encrypted name variable to encrypted album name
    declare @encrypted_name varbinary(255) = encryptbykey(key_guid('symkey'), @album_name);

    --insert album id, encrypted album name, release date, and total tracks into database
    --generates a new uuid using newid() to make sure the new albums id is unique
    insert into album (album_id, album_name_encrypt, album_release_date, total_tracks) 
    values (newid(), @encrypted_name, @album_release_date, @total_tracks);

    --close key
    close symmetric key symkey;
end;

--procedure to insert tracks into database and encrypt the track name for insertion
go
alter procedure insertTrack
    --takes track name, all track feautures, album id, and playlist id
    --album id and playlist id are default null to make insertion simpler for if 
    --ids are unknown or not yet in the database
    --could allow duplicates to be inserted but had a lot of problems getting procedure to work
    --when it allowed for them to be inputted by user 
    @track_name varchar(255),
    @energy float,
    @tempo float,
    @danceability float,
    @loudness float,
    @liveness float,
    @valence float,
    @speechiness float,
    @instrumentalness float,
    @mode int,
    @song_key int,
    @duration_ms int,
    @acousticness float,
    @track_popularity int,
    @album_id varchar(50) = null,
    @playlist_id varchar(50) = null
as
begin
    --open key
    open symmetric key symkey decryption by certificate encryptcert;

    --album id handling
    --checks if album id is null
    --will always be null because in my form album id insertion is not an option
    --track album id is always set to null
    if @album_id is null
    begin
        --retrieves most recent album row based on release date
        select @album_id = album_id from album order by album_release_date desc offset 0 rows fetch next 1 row only;
        
        --if there are no albums in the database to fetch a new one is created
        if @album_id is null
        begin
            --generates new uuid
            set @album_id = newid();

            --encrypts album name and uses the current date (getdate()) for the release date
            insert into album (album_id, album_name_encrypt, album_release_date, total_tracks) 
            values (@album_id, encryptbykey(key_guid('symkey'), @track_name), getdate(), 1);
        end
    end

    --playlist id handling - similar to album
    --checks if playlist id is provided if not it creates one using the last existing playlist
    --if there are no playlists in the database it inserts one using encrypted track name
    if @playlist_id is null
    begin
        select @playlist_id = playlist_id from playlist order by playlist_id desc offset 0 rows fetch next 1 row only;
        if @playlist_id is null
        begin
            set @playlist_id = newid();
            insert into playlist (playlist_id, playlist_name_encrypt) 
            values (@playlist_id, encryptbykey(key_guid('symkey'), @track_name));
        end
    end

    --encrypts track name using key and stores it in variable encrypted_name
    declare @encrypted_name varbinary(255) = encryptbykey(key_guid('symkey'), @track_name);
    
    --inserts new track into database using a newly generated id (newid()) the track name
    --all track features and the album id and playlist id found or generated in the if statements
    insert into track (track_id, track_name_encrypt, energy, tempo, danceability, loudness, liveness, 
                       valence, speechiness, instrumentalness, mode, song_key, duration_ms, acousticness, 
                       track_popularity, album_id, playlist_id) 
    values (newid(), @encrypted_name, @energy, @tempo, @danceability, @loudness, @liveness, @valence, 
            @speechiness, @instrumentalness, @mode, @song_key, @duration_ms, @acousticness, 
            @track_popularity, @album_id, @playlist_id);

    --close key
    close symmetric key symkey;
end;

--procedure to encrypt genre and subgenre name and insert new genre into database
go
create procedure insertGenre
    --takes genre and subgenre names as parameters
    @genre_name varchar(100),
    @subgenre_name varchar(100)
as
begin
    --open key for use in encryption
    open symmetric key symkey decryption by certificate encryptcert;

    --use key to encrypt genre and subgenre names and store them in their respective variables
    declare @encrypted_genre varbinary(255) = encryptbykey(key_guid('symkey'), @genre_name);
    declare @encrypted_subgenre varbinary(255) = encryptbykey(key_guid('symkey'), @subgenre_name);

    --generate new id for the genre subgenre combo using same method as in artist
    --use numeric generation for genre and artist because that is how they are in tables
    --insert new id and encrypted genre and subgenre names into database
    insert into genre (genre_id, genre_name_encrypt, subgenre_name_encrypt) 
    values ((select coalesce(max(genre_id), 0) + 1 from genre), @encrypted_genre, @encrypted_subgenre);

    --close key
    close symmetric key symkey;
end;

--procedure to insert playlist with encrypted playlist name into playlist table
go
create procedure insertPlaylist
    --two parameters playlist name and genre id
    @playlist_name varchar(255),
    @genre_id int
as
begin
    --open key for use in encrypting playlist name
    open symmetric key symkey decryption by certificate encryptcert;

    --set encrypted name variable to encrypted playlist name using the key to encrypt it
    declare @encrypted_name varbinary(255) = encryptbykey(key_guid('symkey'), @playlist_name);
    
    --insert the encrypted playlist name into database using provided genre id and newly generated playlist id
    insert into playlist (playlist_id, playlist_name_encrypt, genre_id) 
    values (newid(), @encrypted_name, @genre_id);

    --close key
    close symmetric key symkey;
end;

--triggers to handle deletion of objects in database

--trigger for artist deletion
--will execute instead of default deletion behavior when query is executed to delete artist
go
create trigger artistDelete on artist
instead of delete
as
begin
    --use temporary table deleted to check if any artist in artist index matches artist about to be deleted and delete the record if so
    delete from artistIndex where exists (select 1 from deleted where artistIndex.artist_id = deleted.artist_id);
    --after index is deleted artist can be deleted
    delete from artist where exists (select 1 from deleted where artist.artist_id = deleted.artist_id);
    --use exists in both to verify that the artist index and artist with given id exist to prevent errors
    --stops execution when it doesnt exist
end;

--trigger to delete album
--follows same logic as artistDelete except also checks track to implement cascading deletion
--then continuees with checking for albumIndex and deleting it followed by deleting the album last
go
create trigger albumDelete on album
instead of delete
as
begin
    delete from track where exists (select 1 from deleted where track.album_id = deleted.album_id);
    delete from albumIndex where exists (select 1 from deleted where albumIndex.album_id = deleted.album_id);
    delete from album where exists (select 1 from deleted where album.album_id = deleted.album_id);
end;

--trigger to delete track
--same logic as artist and album delete triggers
--checks track index and deletes record there if necessary before checking for track and deleting it
go
create trigger trackDelete on track
instead of delete
as
begin
    delete from trackIndex where exists (select 1 from deleted where trackIndex.track_id = deleted.track_id);
    delete from track where exists (select 1 from deleted where track.track_id = deleted.track_id);
end;

--trigger to delete genre
--same logic as other delete triggers
--checks genre index for that genre and deletes it if necessary before deleting the genre from main table
go
create trigger genreDelete on genre
instead of delete
as
begin
    delete from genreIndex where exists (select 1 from deleted where genreIndex.genre_id = deleted.genre_id);
    delete from genre where exists (select 1 from deleted where genre.genre_id = deleted.genre_id);
end;

--trigger to delete playlist
--same logic as album delete trigger
--checks for track first to enable cascading deletion and deletes any tracks on that playlist from database
--then checks playlist index and finally deletes playlist from main table
go
create trigger playlistDelete on playlist
instead of delete
as
begin
    delete from track where exists (select 1 from deleted where track.playlist_id = deleted.playlist_id);
    delete from playlistIndex where exists (select 1 from deleted where playlistIndex.playlist_id = deleted.playlist_id);
    delete from playlist where exists (select 1 from deleted where playlist.playlist_id = deleted.playlist_id);
end;

--general procedure to handle decryption and deletion of a record in the database
go
alter procedure deleteRecord
    --takes parameters type and record name
    --type is which table is being deleted from
    --recordname is name of whatever is being deleted i.e. track name, album name, etc.
    @selectedType varchar(50),
    @recordName varchar(255)
as
begin
    --open key to allow for decryption
    open symmetric key symkey decryption by certificate encryptcert;

    --initialize recordid to hold the id of whatever is going to be deleted
    declare @recordId varchar(50);

    --depending on type find decrypted record name in table correlating to the type
    --compare name given to decrypted names from whichever table is specified based on type
    --set record id to matching id found if any
    if @selectedType = 'track'
        select @recordId = track_id 
        from track 
        where convert(varchar, decryptbykey(track_name_encrypt)) = @recordName;
    else if @selectedType = 'artist'
        select @recordId = artist_id 
        from artist 
        where convert(varchar, decryptbykey(artist_name_encrypt)) = @recordName;
    else if @selectedType = 'album'
        select @recordId = album_id 
        from album 
        where convert(varchar, decryptbykey(album_name_encrypt)) = @recordName;
    else if @selectedType = 'playlist'
        select @recordId = playlist_id 
        from playlist 
        where convert(varchar, decryptbykey(playlist_name_encrypt)) = @recordName;
    else if @selectedType = 'genre'
        select @recordId = genre_id 
        from genre 
        where convert(varchar, decryptbykey(genre_name_encrypt)) = @recordName;
    else
        --if type given is invalid will raise error
        begin
            raiserror('Invalid selection.', 16, 1);
            return;
        end
    --if record id is not found (will be null because select statement is used to find it)
    if @recordId is null
    begin
        --error will be raised that item cant be found because id wasnt found
        raiserror('Item not found.', 16, 1);
        return;
    end

    --use id to delete record based on type selection
    --if record id matches id of something in table will get deleted
    if @selectedType = 'track'
        delete from track where track_id = @recordId;
    else if @selectedType = 'artist'
        delete from artist where artist_id = @recordId;
    else if @selectedType = 'album'
        delete from album where album_id = @recordId;
    else if @selectedType = 'playlist'
        delete from playlist where playlist_id = @recordId;
    else if @selectedType = 'genre'
        delete from genre where genre_id = @recordId;
    --close key
    close symmetric key symkey;
end;

--procedure to show track artist relation
--shows tracks and all their artists
--retrieves and decrypts track names along with any artists they are assciated with
--puts artists in list
go
alter procedure gettrackartists
as
begin
    --open key to use for decryption
    open symmetric key symkey decryption by certificate encryptcert;

    select 
        --decrypt the encrypted track name from track and convert it to readable string
        convert(varchar(255), decryptbykey(t.track_name_encrypt)) as track_name,
        --for tracks with multiple artists use (agg) to combine the artists into single string seperated by comma
        string_agg(convert(varchar(255), decryptbykey(a.artist_name_encrypt)), ', ') as artists
    from track t
    --join track and trackartist table to find matching id records
    --as well as artist and trackartist to get artist names
    join trackartist ta on t.track_id = ta.track_id
    join artist a on ta.artist_id = a.artist_id
    --group reseults by encrypted track name in case there are duplicates and to allow proper aggregation of multiple artists
    group by t.track_name_encrypt;

    --close key
    close symmetric key symkey;
end;

--procedure to get features using indeces and show track names and descriptions of index buckets
go
alter procedure viewFeatures 
as
begin
    --open key
    open symmetric key symkey decryption by certificate encryptcert;

    select 
        --decrypts track name and converts it to string
        convert(varchar(255), decryptbykey(t.track_name_encrypt)) as track_name, 
        --get track features
        f.energy, 
        f.tempo, 
        f.dancebility, 
        --round acousticness and instrumentallness to 2 decimal places for simpler use with mapping tables
        round(f.acousticness, 2) as acousticness, 
        round(f.instrumentalness, 2) as instrumentalness,  
        --rest of track features
        f.mode, 
        f.song_key, 
        f.liveness, 
        f.loudness, 
        --join mapping tables to get descriptions of indeces
        al.description as acousticness_level, 
        il.description as instrumentalness_level
    --join feature table and feature index table
    from features f
    join featuresIndex fi on f.feature_id = fi.feature_id
    --join with track on track id to get names for decryption
    left join track t on f.track_id = t.track_id
    --use between to match mapping table values to categories of feautures
    left join acousticnessLookup al 
        ON f.acousticness BETWEEN al.min_value AND al.max_value
    left join instrumentalnessLookup il 
        ON f.instrumentalness BETWEEN il.min_value AND il.max_value;

    --close key
    close symmetric key symkey;
end;

--procedures for views in front end
--decrypt track table
go
alter procedure decryptTrack 
as
begin
    --open key for decryption of track name
    open symmetric key symkey decryption by certificate encryptcert;
    
    select 
           --decrypt track name to string
           convert(varchar(255), decryptbykey(t.track_name_encrypt)) as track_name, 
           --get descriptions of indeces for track
           pl.description as popularity_level, 
           ml.description as mode, 
           tl.description as tempo_category
    --join track and trackindex together for bucket data
    from track t 
    join trackindex ti on t.track_id = ti.track_id
    --match popularity mode and tempo to descriptions
    --use left join to make sure there are results even when some categories dont match
    left join popularityLookup pl 
        on ti.popularityBucket = pl.popularityIndex
    left join modeLookup ml 
        on ti.modeIndex = ml.modeIndex
    left join tempoLookup tl 
        on ti.tempoIndex = tl.tempoIndex;
    --close key
    close symmetric key symkey;
end;

--decrypt artist table for front end
go
alter procedure decryptArtist
as
begin
    --open key for deryption of artist name
    open symmetric key symkey decryption by certificate encryptcert;

    select 
        --decrypt artist name and convert oit to string
        convert(varchar(255), decryptbykey(a.artist_name_encrypt)) as artist_name
    --join artist with artist index for more effiecient lookup of names
    from artist a
    join artistIndex ai on a.artist_id = ai.artist_id;
    --close key
    close symmetric key symkey;
end;

--decrypt album table for front end
go
alter procedure decryptAlbum 
as
begin
    --open key for decryption of album name
    open symmetric key symkey decryption by certificate encryptcert;
    
    select 
           --decrypt album name and convert it to string get release date and track count from index
           convert(varchar(255), decryptbykey(a.album_name_encrypt)) as album_name, 
           ai.releasedate, 
           ai.trackcountindex 
    --join album and album index to allow for efficient retrieval using index
    from album a 
    join albumindex ai on a.album_id = ai.album_id;
    
    --close key
    close symmetric key symkey;
end;

--decrypt genre table for front end
go
alter procedure decryptGenre 
as
begin
    --open key to decrypt genre name and subgenre name
    open symmetric key symkey decryption by certificate encryptcert;
    
    --decrypt genre and subgenre name and convert them to strings
    --get categories of genre from genre index
    select 
           convert(varchar(100), decryptbykey(g.genre_name_encrypt)) as genre_name, 
           convert(varchar(100), decryptbykey(g.subgenre_name_encrypt)) as subgenre_name, 
           gi.genrecategoryindex 
    --join genre and genre index for efficient retrieval and to get category
    from genre g 
    join genreindex gi on g.genre_id = gi.genre_id;
    
    --close key
    close symmetric key symkey;
end;

go
alter procedure decryptPlaylist 
as
begin
    --open key for decryption of playlist name
    open symmetric key symkey decryption by certificate encryptcert;
    
    --decrypt playlist name and convert it to string get genre category of playlist
    select 
           convert(varchar(255), decryptbykey(p.playlist_name_encrypt)) as playlist_name, 
           pi.genrecategoryindex 
    --join playlist and playlist index for efficient retrieval and to get category
    from playlist p 
    join playlistindex pi on p.playlist_id = pi.playlist_id;
    
    --close key
    close symmetric key symkey;
end;