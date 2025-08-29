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
    public partial class GenreForm : Form
    {
        //initialize here for use in load and click
        private string genreName;
        private string connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=spotifydata;Integrated Security=True";
        public GenreForm(string name)
        {
            InitializeComponent();
            //set genre name to name input in main form
            genreName = name;
            //auto populate genre text box with genre name from main form
            txtGenreName.Text = genreName;
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    //use insert genre protocal to insert genre to data base
                    using (SqlCommand cmd = new SqlCommand("insertGenre", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@genre_name", genreName);
                        cmd.Parameters.AddWithValue("@subgenre_name", txtSubgenreName.Text);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                        //show message box that genre insertion was successful
                        MessageBox.Show("Genre inserted successfully!", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
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
