# Encrypted Database System with Front-End Integration

This project demonstrates a complete workflow for building a secure, encrypted relational database system with a graphical front end. It includes data preprocessing, SQL-based encryption and decryption, and a C# Windows Forms interface for interacting with the encrypted data.

##  Workflow Overview

1. **Data Preprocessing**
   - Use `projectloaddata.py` to split raw data into normalized CSVs for each table.

2. **Database Initialization**
   - Run `createtables.sql` to define the structure of unencrypted tables.

3. **Data Insertion**
   - Use `insertdata.sql` to populate the database with raw data.

4. **Encryption**
   - Execute `encryption.sql` to encrypt sensitive fields using symmetric keys and certificates.

## Front-End Features

The front end is built using **C# Windows Forms**, providing a graphical interface to interact with the encrypted database. Each form corresponds to a specific table in the database and supports viewing, inserting, and deleting encrypted data.

### Components

- **Form1** — Main dashboard and navigation hub
- **AlbumForm** — Interface for album data
- **ArtistForm** — Interface for artist details
- **GenreForm** — Interface for genre and subgenre classification
- **PlaylistForm** — Interface for playlist viewing
- **TrackForm** — Interface for track-level audio data

### Data Binding

- Uses a typed dataset (`spotifydataDataSet`) to bind encrypted data to UI elements
- Decryption is handled via stored procedures that return plaintext values for display
- No plaintext is stored persistently—decryption occurs only at runtime

### Technologies Used

- C# (.NET Framework)
- Windows Forms Designer
- SQL Server stored procedures

### Example Integration Flow

1. User opens a form (e.g., `GenreForm`)
2. Form calls a stored procedure that:
   - Opens the symmetric key
   - Decrypts the relevant columns
   - Returns plaintext values to the form
3. Form displays the decrypted data in a grid field

### Notes

- GUI is modular and expandable
- Designed for testing encryption visibility and usability
- Not optimized for deployment or public release
