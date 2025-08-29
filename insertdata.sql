--used bulk inserts to insert all my data
--csvs are genrated from projectloaddata python program
--had to use extra arguments and modify fieldterminator for album and track because there were commas in some track and album names that caused issues
--data was split incorrectly in them and it made inserts not work

bulk insert artist from "C:\\Users\\audre\\Downloads\\projectloaddata\\projectloaddata\\artists.csv" with (
	fieldterminator = ',',
	rowterminator = '\n',
	firstrow = 2
);

bulk insert album from "C:\\Users\\audre\\Downloads\\projectloaddata\\projectloaddata\\albums.csv" with (
	fieldterminator = '\t',
	rowterminator = '0x0A',
	firstrow = 2,
	codepage = '65001'
);

bulk insert genre from "C:\\Users\\audre\\Downloads\\projectloaddata\\projectloaddata\\genres.csv" with (
	fieldterminator = ',',
	rowterminator = '\n',
	firstrow = 2
);

bulk insert playlist from "C:\\Users\\audre\\Downloads\\projectloaddata\\projectloaddata\\playlists.csv" with (
	fieldterminator = ',',
	rowterminator = '\n',
	firstrow = 2
);

bulk insert track from "C:\\Users\\audre\\Downloads\\projectloaddata\\projectloaddata\\tracks.csv" with (
	fieldterminator = '\t',
	rowterminator = '0x0A',
	firstrow = 2,
	codepage='65001'
);

bulk insert trackartist from "C:\\Users\\audre\\Downloads\\projectloaddata\\projectloaddata\\track_artists.csv" with (
	fieldterminator = ',',
	rowterminator = '\n',
	firstrow = 2
);

bulk insert features from "C:\\Users\\audre\\Downloads\\projectloaddata\\projectloaddata\\features.csv" with (
	fieldterminator = ',',
	rowterminator = '\n',
	firstrow = 2
);

