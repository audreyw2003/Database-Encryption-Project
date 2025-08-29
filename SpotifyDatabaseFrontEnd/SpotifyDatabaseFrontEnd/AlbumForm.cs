using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SpotifyDatabaseFrontEnd
{
    public partial class AlbumForm : Form
    {
        //make album name available throughout form class to allow form load and button click to use it
        private string albumName;
        private string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=spotifydata;Integrated Security=True";
        public AlbumForm(string name)
        {
            InitializeComponent();
            //set name to name passed from main form that user entered
            albumName = name;
            //auto populate text box for album name to the one inputted in main form
            //user can still change if needed but this way they dont have to enter it again
            txtAlbumName.Text = albumName;
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                //initialize connection
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    //run command query on connection
                    //runs insert Album procedure
                    using (SqlCommand cmd = new SqlCommand("insertAlbum", conn))
                    {
                        //date variable to hold release date
                        DateTime releaseDate;

                        //attempt to cast text in release date box to date
                        if (!DateTime.TryParse(txtReleaseDate.Text, out releaseDate))
                        {
                            //if it fails then show user there was an error with the date using a message box
                            MessageBox.Show("Invalid date format. Please enter a valid date.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@album_name", albumName);
                        cmd.Parameters.AddWithValue("@album_release_date", releaseDate);
                        //cast track number to int
                        cmd.Parameters.AddWithValue("@total_tracks", int.Parse(txtTotalTracks.Text));

                        conn.Open();
                        cmd.ExecuteNonQuery();
                        //tell user album was inserted successfully in message box
                        MessageBox.Show("Album inserted successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        //close form
                        this.Close();
                    }
                }
            }
            //catch any sql errors and use message box to show user what the error was
            catch (SqlException ex)
            {
                MessageBox.Show($"Database Error: {ex.Message}", "SQL Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            //same as above but for other errors not related to sql
            catch (Exception a)
            {
                MessageBox.Show($"Unexpected Error: {a.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
