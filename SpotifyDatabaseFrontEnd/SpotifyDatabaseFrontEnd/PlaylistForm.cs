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
    public partial class PlaylistForm : Form
    {
        //initialize name here to be used in load and click
        private string playlistName;
        private string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=spotifydata;Integrated Security=True";

        public PlaylistForm(string name)
        {
            InitializeComponent();
            //set playlist name to name in main form text box
            playlistName = name;
            //auto populate name text box with name input in main form
            txtPlaylistName.Text = playlistName;
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    //use insert playlist procedure to insert playlist into database
                    using (SqlCommand cmd = new SqlCommand("insertPlaylist", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@playlist_name", playlistName);
                        //cast text from genre id text box to int to match for insertion
                        cmd.Parameters.AddWithValue("@genre_id", int.Parse(txtGenreID.Text));

                        conn.Open();
                        cmd.ExecuteNonQuery();
                        //show user in message box that playlist insertion was successful
                        MessageBox.Show("Playlist inserted successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
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
