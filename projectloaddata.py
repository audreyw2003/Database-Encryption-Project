import pandas as pd

#load in data
dataset = pd.read_csv("high_popularity_spotify_data.csv")

#function to make sure id columns are first to make sure insertion works
def reorder_columns(df, id_column):
    cols = [id_column] + [col for col in df.columns if col != id_column]
    return df[cols]

#makes sure release date format is correct for all the albums
#some only had the year so this makes sure that even if the date is not complete it is formatted correctly for insertion into album table
def fix_album_date(date_value):
    #uses try statement to attempt to convert date to correct datetime format using pandas
    try:
        #attempt to convert with pandas to correct format
        #error=coerce -- returns not a time if conversion fails
        date = pd.to_datetime(date_value, errors='coerce')  

        #if the date converts successfully it gets formatted into YYYY-MM-DD (correct format for sql)
        #if not since all the dates that were wrong just had the year it defaults to january first and keeps the year
        return date.strftime("%Y-%m-%d") if pd.notna(date) else f"{date_value}-01-01"

    #just in case there are any unexpected errors to keep program from crashing
    except:
        return None  

#create artists dataset for artists table

#get unique artists (drop_duplicates) from dataset and reset index
artists = dataset[['track_artist']].drop_duplicates().reset_index(drop=True)

#since there is more than one artist for some tracks and in the dataset they are seperated by a comma
#transform them into a list to allow for seperation into individual artists using (str.split)
artists['track_artist'] = artists['track_artist'].str.split(', ')

#use (explode) to split the rows with multiple artists into multiple rows so that each artist has a seperate row
#since an artist can be on more than one track and could share more than one track with different artists
#remove duplicates again to account for it and reset the index again to simplify adding ids later
artists = artists.explode('track_artist').drop_duplicates().reset_index(drop=True)

#assigns unique id for each artist sequentially starting from 1
#essentially how using identity(1,1) would work in sql but had issues doing that and using bulk insert
#so set ids in this code instead
artists['artist_id'] = range(1, len(artists) + 1)

#creating dataset for multivalued trackartist table representation

#get unique tracks and artist using (drop_duplicates) to remove repeats
#reset index
track_artists = dataset[['track_id', 'track_artist']].drop_duplicates().reset_index(drop=True)

#same as with artists could be more than one artist on the track which is why I used trackartists table to
#show that relationship and represent the multivalued artist attribute
#split on ',' because thats how they are split in original dataset and add them to list
track_artists['track_artist'] = track_artists['track_artist'].str.split(', ')

#use (explode) to split list into individual artists and give each their own row
#reset index again
#dont need to remove duplicates again because this table is for multivalued attribute track to artist
#so track can repeat with different artists
track_artists = track_artists.explode('track_artist').reset_index(drop=True)

#use merge to join track_artists with artists on track_artist
#use left join to make sure that all track_artists stay and have their artist id added to track_artists
#([['track_id, 'artist_id']]) makes sure that only those two columns are kept because they are what is needed
#for the trackartist table in the database
track_artists = track_artists.merge(artists, on='track_artist', how='left')[['track_id', 'artist_id']]

#create genre dataset for genre table

#get genre, subgenre combinations from dataset and remove exact duplicate combos and reset index
genres = dataset[['playlist_genre', 'playlist_subgenre']].drop_duplicates().reset_index(drop=True)

#double checks that any genre subgenre combos are only in the dataset once
#keeps the first apperence of the combo
genres = genres.drop_duplicates(subset=['playlist_genre', 'playlist_subgenre'], keep='first')

#assigns genre_ids same as above starts from 1 and continues similar to identity (1,1) in sql
genres['genre_id'] = range(1, len(genres) + 1)

#sorts the genres in ascending order by their id
genres = genres.sort_values(by=['genre_id'])

#create playlists dataset for playlist table

#get playlist id, name, and genre/subgenre from original dataset
#remove duplicates and reset index
playlists = dataset[['playlist_id', 'playlist_name', 'playlist_genre', 'playlist_subgenre']].drop_duplicates().reset_index(drop=True)

#use left join to merge playlist with genre/subgenre pair to get genre id for it from genre table/dataset
#only keeps playlist_id, name, and genre_id columns necessary for insertion in the playlist dataset
playlists = playlists.merge(genres, on=['playlist_genre', 'playlist_subgenre'], how='left')[['playlist_id', 'playlist_name', 'genre_id']]

#double checks for any duplicates and keeps first occurence of them if there are any
playlists = playlists.drop_duplicates(subset=['playlist_id'], keep='first')

#create track dataset for track table

#get track info from original dataset
#remove duplicates and reset index
tracks = dataset[['track_id', 'track_name', 'energy', 'tempo', 'danceability', 'loudness', 'liveness', 'valence', 
                  'speechiness', 'instrumentalness', 'mode', 'key', 'duration_ms', 'acousticness', 'track_popularity', 
                  'track_album_id', 'playlist_id']].drop_duplicates().reset_index(drop=True)

#double checks for duplicate track_ids (added because i had issues with track_ids being repeated)
tracks = tracks.drop_duplicates(subset=['track_id'])

#create albums dataset for album table

#get album info from original dataset
#remove duplicates and reset index
albums = dataset[['track_album_id','track_album_name', 'track_album_release_date']].drop_duplicates().reset_index(drop=True)

#get track counts for albums

#group tracks in the original dataset by album name and count how many tracks are in each one
#rest index of new album_track_counts dataframe
album_track_counts = dataset.groupby('track_album_name')['track_id'].count().reset_index()

#rename track_id to track_count for clarity and because track_id is now track_count
album_track_counts.rename(columns={'track_id': 'total_tracks'}, inplace=True)

#merge albums and album_track_counts dataframe together on a left join so that even if an album has no tracks it stays in the dataset
#adds track_counts to albums dataframe
albums = albums.merge(album_track_counts, on='track_album_name', how='left')

#had a lot of issues using bulk insert and data types/formatting making it read the csvs wrong so added in extra data cleaning and formatting
#dont really need them now because the issue was with albums having commas in the title but left it in just in case

#converts release date to string and uses fix_album_date function defined above to ensure the date is correctly formatted
albums['track_album_release_date'] = albums['track_album_release_date'].astype(str).apply(fix_album_date)

#if album has no track count sets it to 0 and converts all values in total tracks to integers
#should already be integers but had insertion problems so added this anyways
albums['total_tracks'] = albums['total_tracks'].fillna(0).astype(int)

#additional conversion using built-in pandas function to ensure that date is formatted correctly using same method as fix_album_date does
albums['track_album_release_date'] = pd.to_datetime(albums['track_album_release_date'], errors='coerce').dt.strftime('%Y-%m-%d')

#makes sure any unnecessary spaces in dates are removed if any
albums['track_album_release_date'] = albums['track_album_release_date'].str.strip() 

#renamed columns to match tables but again not necessary because the issue was with the commas not the column names
albums.rename(columns={
    'track_album_name': 'album_name',
    'track_album_release_date': 'album_release_date'
}, inplace=True)

#use reorder_column function defined above to make sure id comes first for insertion
albums = reorder_columns(albums, 'track_album_id')

#create features dataset for features table

#get features from original dataset and make sure there are no duplicates and reset index for if there are
features = dataset[['track_id', 'energy', 'tempo', 'danceability', 'acousticness', 'instrumentalness', 'mode', 'key',
                    'liveness', 'loudness']].drop_duplicates().reset_index(drop=True)

#create ids for features starting from one and increasing with each feature set having unique id
features['feature_id'] = range(1, len(features) + 1)

#set feature_id to first column for insertion into features table
features = reorder_columns(features, 'feature_id')

#set artist_id to first column for insertion into artist table
artists = reorder_columns(artists, 'artist_id')

#make genre_id first column for insertion into genre table
genres = reorder_columns(genres, 'genre_id')

#make playlist_id first column for insertion into playlist table
playlists = reorder_columns(playlists, 'playlist_id')

#make album_id first column for insertion into album table
albums = reorder_columns(albums, 'track_album_id')

#set track_id to first column for insertion into track table
tracks = reorder_columns(tracks, 'track_id')

#make sure track_id and artist_id are in correct order for insertion into trackartist table
track_artists = track_artists[['track_id', 'artist_id']]  # IDs must be first

#save all datasets to their own csvs based on tables in database for bulk insertion into database

artists.to_csv("artists.csv", index=False)
genres.to_csv("genres.csv", index=False)
playlists.to_csv("playlists.csv", index=False)

#had to add in encoding, seperator arguments due to misreading of the csv during bulk insertion due to commas in track names
tracks.to_csv("tracks.csv", index=False, encoding='utf-8', sep='\t')
track_artists.to_csv("track_artists.csv", index=False)

#issues during bulk insertion so explicitly set encoding which fixed it
features.to_csv("features.csv", index=False, encoding='utf-8')

#same as above and had to change seperator because of commas in album names
albums.to_csv("albums.csv", index=False, encoding='utf-8', sep='\t')

print("data split successfully")

