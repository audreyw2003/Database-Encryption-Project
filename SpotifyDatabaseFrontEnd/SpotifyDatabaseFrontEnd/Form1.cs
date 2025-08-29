using SpotifyDatabaseFrontEnd.spotifydataDataSetTableAdapters;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Net.NetworkInformation;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SpotifyDatabaseFrontEnd
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=spotifydata;Integrated Security=True";

        private void LoadDataGridView()
        {
            //get type selection if none it defaults to track
            string selectedType = cmdSearchType.SelectedItem?.ToString() ?? "Track";
            //initialize query string
            string query = "";

            //use switch to determine which data to show based on selected type
            //sets query to applicable procedure to view that data types table
            switch (selectedType)
            {
                case "Track":
                    query = "exec decryptTrack";
                    break;
                case "Artist":
                    query = "exec decryptArtist";
                    break;
                case "Album":
                    query = "exec decryptAlbum";
                    break;
                case "Playlist":
                    query = "exec decryptPlaylist";
                    break;
                case "Genre":
                    query = "exec decryptGenre";
                    break;
                case "Features":
                    query = "exec viewFeatures";
                    break;
                case "TrackArtists":
                    query = "exec gettrackartists";
                    break;
            }

            //if query doesnt get updated by one of the cases for some reason gives error
            if (string.IsNullOrWhiteSpace(query))
            {
                MessageBox.Show("Error: Query is not initialized!", "SQL Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            try
            {
                //initialize connection to database
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    //initialize command
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        SqlDataReader reader = cmd.ExecuteReader();
                        DataTable dataTable = new DataTable();
                        dataTable.Load(reader);
                        //had issues with grid showing values and this fixed it
                        dataGridViewTracks.AutoGenerateColumns = true;
                        dataGridViewTracks.DataSource = dataTable;
                        //same as setting auto generate columns
                        dataGridViewTracks.Refresh();
                        //check that there were no issues with retrieving data give error message box if so
                        if (dataTable.Rows.Count == 0)
                        {
                            MessageBox.Show("No data returned from query!", "Debugging", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        }
                    }
                }
            }
            //catch any sql errors and use message box to show user what the error was
            catch (SqlException ex)
            {
                MessageBox.Show($"Database Error: {ex.Message}", "SQL Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            //same as above but for other errors not related to sql
            catch (Exception e)
            {
                MessageBox.Show($"Unexpected Error: {e.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnInsert_Click(object sender, EventArgs e)
        {
            //get type of data user wants to insert from dropdown
            string selectedType = cmdSearchType.SelectedItem.ToString();
            //get name of data from text box
            string enteredName = txtData.Text;

            //if user doesnt input a name then gives them a warning
            if (string.IsNullOrWhiteSpace(enteredName))
            {
                MessageBox.Show("Enter track name.", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            //initialize form to null - will be updated based on type
            Form inputForm = null;

            //switch to determine which insertion form to open based on selected type
            //if none is selected error is raised
            switch (selectedType)
            {
                case "Track":
                    inputForm = new TrackForm(enteredName);
                    break;
                case "Artist":
                    inputForm = new ArtistForm(enteredName);
                    break;
                case "Album":
                    inputForm = new AlbumForm(enteredName);
                    break;
                case "Playlist":
                    inputForm = new PlaylistForm(enteredName);
                    break;
                case "Genre":
                    inputForm = new GenreForm(enteredName);
                    break;
                default:
                    MessageBox.Show("Invalid selection.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
            }
            //load form determined from switch
            inputForm.ShowDialog();
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                //initialize connection to database
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    //initialize query - uses delete record procedure
                    using (SqlCommand cmd = new SqlCommand("deleteRecord", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        //set to lower because i had some issues with it not matching procedure making the string lowercase made it easier to fix
                        cmd.Parameters.AddWithValue("@selectedType", cmdSearchType.SelectedItem.ToString().ToLower());
                        //record name from name in text box
                        cmd.Parameters.AddWithValue("@recordName", txtData.Text);
                        //run query
                        cmd.ExecuteNonQuery();
                    }
                    //reload gridview
                    LoadDataGridView();
                    //give message box to user to know deletion was successful
                    MessageBox.Show("Deletion successful!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
            //catch sql errors and raise error through message box to show user
            catch (SqlException ex)
            {
                MessageBox.Show($"Database Error: {ex.Message}", "SQL Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            //catch any other errors and raise error through message box to show user
            catch (Exception b)
            {
                MessageBox.Show($"Unexpected Error: {b.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            //keep datagrid view from loading twice because index is 'changed' so it is set to track by default
            cmdSearchType.SelectedIndexChanged -= cmdSearchType_SelectedIndexChanged;
            //set type index to track as default
            cmdSearchType.SelectedIndex = 0;
            //load data with track data since track is default for initial view on load
            LoadDataGridView();
            //add back index changed method so that grid view will update when it is changed
            cmdSearchType.SelectedIndexChanged += cmdSearchType_SelectedIndexChanged;
        }

        private void cmdSearchType_SelectedIndexChanged(object sender, EventArgs e)
        {
            //reload grid view when search type index is changed
            LoadDataGridView();
        }
    }
}
