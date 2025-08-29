--main database tables after encrypting and troubleshooting everything to work properly
--copied from visual studio table code because i forgot to save the queries where i modified them as i worked through everything

CREATE TABLE [dbo].[album] (
    [album_id]           VARCHAR (50)    NOT NULL,
    [album_release_date] DATE            NOT NULL,
    [total_tracks]       INT             NULL,
    [album_name_encrypt] VARBINARY (MAX) NULL,
    PRIMARY KEY CLUSTERED ([album_id] ASC)
);

CREATE TABLE [dbo].[artist] (
    [artist_id]           INT             NOT NULL,
    [artist_name_encrypt] VARBINARY (MAX) NULL,
    PRIMARY KEY CLUSTERED ([artist_id] ASC)
);

CREATE TABLE [dbo].[features] (
    [feature_id]       INT          NOT NULL,
    [track_id]         VARCHAR (50) NOT NULL,
    [energy]           FLOAT (53)   NULL,
    [tempo]            FLOAT (53)   NULL,
    [dancebility]      FLOAT (53)   NULL,
    [acousticness]     FLOAT (53)   NULL,
    [instrumentalness] FLOAT (53)   NULL,
    [mode]             INT          NULL,
    [song_key]         INT          NULL,
    [liveness]         FLOAT (53)   NULL,
    [loudness]         FLOAT (53)   NULL,
    PRIMARY KEY CLUSTERED ([feature_id] ASC, [track_id] ASC),
    FOREIGN KEY ([track_id]) REFERENCES [dbo].[track] ([track_id])
);

CREATE TABLE [dbo].[genre] (
    [genre_id]              INT             NOT NULL,
    [genre_name_encrypt]    VARBINARY (MAX) NULL,
    [subgenre_name_encrypt] VARBINARY (MAX) NULL,
    PRIMARY KEY CLUSTERED ([genre_id] ASC)
);

CREATE TABLE [dbo].[playlist] (
    [playlist_id]           VARCHAR (50)    NOT NULL,
    [genre_id]              INT             NULL,
    [playlist_name_encrypt] VARBINARY (MAX) NULL,
    PRIMARY KEY CLUSTERED ([playlist_id] ASC),
    FOREIGN KEY ([genre_id]) REFERENCES [dbo].[genre] ([genre_id])
);

CREATE TABLE [dbo].[track] (
    [track_id]           VARCHAR (50)    NOT NULL,
    [energy]             FLOAT (53)      NULL,
    [tempo]              FLOAT (53)      NULL,
    [danceability]       FLOAT (53)      NULL,
    [loudness]           FLOAT (53)      NULL,
    [liveness]           FLOAT (53)      NULL,
    [valence]            FLOAT (53)      NULL,
    [speechiness]        FLOAT (53)      NULL,
    [instrumentalness]   FLOAT (53)      NULL,
    [mode]               INT             NULL,
    [song_key]           INT             NULL,
    [duration_ms]        INT             NULL,
    [acousticness]       FLOAT (53)      NULL,
    [track_popularity]   INT             NULL,
    [album_id]           VARCHAR (50)    CONSTRAINT [df_album_id] DEFAULT (newid()) NULL,
    [playlist_id]        VARCHAR (50)    CONSTRAINT [df_playlist_id] DEFAULT (newid()) NULL,
    [track_name_encrypt] VARBINARY (MAX) NULL,
    PRIMARY KEY CLUSTERED ([track_id] ASC),
    FOREIGN KEY ([album_id]) REFERENCES [dbo].[album] ([album_id]),
    FOREIGN KEY ([playlist_id]) REFERENCES [dbo].[playlist] ([playlist_id])
);

CREATE TABLE [dbo].[trackartist] (
    [track_id]  VARCHAR (50) NOT NULL,
    [artist_id] INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([track_id] ASC, [artist_id] ASC),
    FOREIGN KEY ([track_id]) REFERENCES [dbo].[track] ([track_id]),
    FOREIGN KEY ([artist_id]) REFERENCES [dbo].[artist] ([artist_id])
);


--final index and mapping tables
--also taken from visual studio table code the originals of these are in my encrpt data sql file
--they are the same but thought id put all tables in one file

--mapping tables

CREATE TABLE [dbo].[acousticnessLookup] (
    [min_value]   FLOAT (53)    NULL,
    [max_value]   FLOAT (53)    NULL,
    [description] VARCHAR (255) NULL
);

CREATE TABLE [dbo].[instrumentalnessLookup] (
    [min_value]   FLOAT (53)    NULL,
    [max_value]   FLOAT (53)    NULL,
    [description] VARCHAR (255) NULL
);

CREATE TABLE [dbo].[modeLookup] (
    [modeIndex]   INT           NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([modeIndex] ASC)
);

CREATE TABLE [dbo].[tempoLookup] (
    [tempoIndex]  INT           NOT NULL,
    [description] VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([tempoIndex] ASC)
);

CREATE TABLE [dbo].[popularityLookup] (
    [popularityIndex] INT           NOT NULL,
    [description]     VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([popularityIndex] ASC)
);

--indexing tables

CREATE TABLE [dbo].[albumIndex] (
    [album_id]        VARCHAR (50) NOT NULL,
    [releasedate]     INT          NULL,
    [trackcountindex] INT          NULL,
    PRIMARY KEY CLUSTERED ([album_id] ASC)
);

CREATE TABLE [dbo].[artistIndex] (
    [artist_id] INT            NOT NULL,
    [nameHash]  VARBINARY (64) NULL,
    PRIMARY KEY CLUSTERED ([artist_id] ASC)
);

CREATE TABLE [dbo].[featuresIndex] (
    [feature_id]         INT NOT NULL,
    [acousticBucket]     INT NULL,
    [instrumentalBucket] INT NULL,
    PRIMARY KEY CLUSTERED ([feature_id] ASC)
);

CREATE TABLE [dbo].[genreIndex] (
    [genre_id]           INT NOT NULL,
    [genrecategoryindex] INT NULL,
    PRIMARY KEY CLUSTERED ([genre_id] ASC)
);

CREATE TABLE [dbo].[playlistIndex] (
    [playlist_id]        VARCHAR (50) NOT NULL,
    [genrecategoryindex] INT          NULL,
    PRIMARY KEY CLUSTERED ([playlist_id] ASC)
);

CREATE TABLE [dbo].[trackartistIndex] (
    [track_id]  VARCHAR (50) NOT NULL,
    [artist_id] INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([track_id] ASC, [artist_id] ASC)
);

CREATE TABLE [dbo].[trackIndex] (
    [track_id]         VARCHAR (50) NOT NULL,
    [popularityBucket] INT          NULL,
    [modeIndex]        INT          NULL,
    [tempoIndex]       INT          NULL,
    PRIMARY KEY CLUSTERED ([track_id] ASC)
);