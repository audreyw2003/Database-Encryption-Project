using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SpotifyDatabaseFrontEnd
{
    public partial class TrackForm : Form
    {
        //use class wide variable for track name so that form load and confirm button click methods can use it
        private string trackName;
        string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=spotifydata;Integrated Security=True";

        public TrackForm(string name)
        {
            InitializeComponent();
            trackName = name;
            //auto populate track name text box with track name from main form since a name must be inserted there
            //user can still modify it though
            txtTrackName.Text = trackName;
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                //generate connection
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    //generate command - use procedure insert track with parameters inserted in form
                    using (SqlCommand cmd = new SqlCommand("insertTrack", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@track_name", trackName);
                        cmd.Parameters.AddWithValue("@energy", float.Parse(txtenergy.Text));
                        cmd.Parameters.AddWithValue("@tempo", float.Parse(txttempo.Text));
                        cmd.Parameters.AddWithValue("@danceability", float.Parse(txtDanceability.Text));
                        cmd.Parameters.AddWithValue("@loudness", float.Parse(txtLoudness.Text));
                        cmd.Parameters.AddWithValue("@liveness", float.Parse(txtLiveness.Text));
                        cmd.Parameters.AddWithValue("@valence", float.Parse(txtValence.Text));
                        cmd.Parameters.AddWithValue("@speechiness", float.Parse(txtSpeechiness.Text));
                        cmd.Parameters.AddWithValue("@instrumentalness", float.Parse(txtInstrumentalness.Text));
                        cmd.Parameters.AddWithValue("@mode", int.Parse(txtMode.Text));
                        cmd.Parameters.AddWithValue("@song_key", int.Parse(txtKey.Text));
                        cmd.Parameters.AddWithValue("@duration_ms", int.Parse(txtDuration.Text));
                        cmd.Parameters.AddWithValue("@acousticness", float.Parse(txtAcousticness.Text));
                        cmd.Parameters.AddWithValue("@track_popularity", int.Parse(txtPopularity.Text));
                        //doesnt allow for entering in album and playlist id manually because too many issues getting procedure to work with it
                        //was only able to get procedure to work by having them null
                        cmd.Parameters.AddWithValue("@album_id", DBNull.Value);
                        cmd.Parameters.AddWithValue("@playlist_id", DBNull.Value);

                        conn.Open();
                        //save number of rows affected by executing the query to verify success
                        int rowsAffected = cmd.ExecuteNonQuery();
                        //if any rows changed means track was inserted so give success message box
                        if (rowsAffected > 0)
                        {
                            MessageBox.Show("Track inserted successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                        //if no rows were affected data was not inserted so gives error
                        else
                        {
                            MessageBox.Show("Failed to insert track.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                        //close form after executing query
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
