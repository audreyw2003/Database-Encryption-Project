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
    public partial class ArtistForm : Form
    {
        //initialize here for use in load and click
        private string artistName;
        private string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=spotifydata;Integrated Security=True";

        public ArtistForm(string name)
        {
            InitializeComponent();
            //set artist name to artist name input in main form
            artistName = name;
            //same for text box
            txtArtistName.Text = artistName;
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    //use insert artist procedure to insert artist
                    using (SqlCommand cmd = new SqlCommand("insertArtist", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@artist_name", artistName);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                        //show user insertion was successful
                        MessageBox.Show("Artist inserted successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
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
