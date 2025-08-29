namespace SpotifyDatabaseFrontEnd
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.btnInsert = new System.Windows.Forms.Button();
            this.txtData = new System.Windows.Forms.TextBox();
            this.btnDelete = new System.Windows.Forms.Button();
            this.dataGridViewTracks = new System.Windows.Forms.DataGridView();
            this.spotifydataDataSetBindingSource = new System.Windows.Forms.BindingSource(this.components);
            this.spotifydataDataSet = new SpotifyDatabaseFrontEnd.spotifydataDataSet();
            this.cmdSearchType = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewTracks)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.spotifydataDataSetBindingSource)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.spotifydataDataSet)).BeginInit();
            this.SuspendLayout();
            // 
            // btnInsert
            // 
            this.btnInsert.Location = new System.Drawing.Point(27, 706);
            this.btnInsert.Name = "btnInsert";
            this.btnInsert.Size = new System.Drawing.Size(502, 66);
            this.btnInsert.TabIndex = 0;
            this.btnInsert.Text = "insert record";
            this.btnInsert.UseVisualStyleBackColor = true;
            this.btnInsert.Click += new System.EventHandler(this.btnInsert_Click);
            // 
            // txtData
            // 
            this.txtData.Location = new System.Drawing.Point(526, 612);
            this.txtData.Name = "txtData";
            this.txtData.Size = new System.Drawing.Size(587, 26);
            this.txtData.TabIndex = 1;
            // 
            // btnDelete
            // 
            this.btnDelete.Location = new System.Drawing.Point(594, 708);
            this.btnDelete.Name = "btnDelete";
            this.btnDelete.Size = new System.Drawing.Size(519, 64);
            this.btnDelete.TabIndex = 2;
            this.btnDelete.Text = "delete record";
            this.btnDelete.UseVisualStyleBackColor = true;
            this.btnDelete.Click += new System.EventHandler(this.btnDelete_Click);
            // 
            // dataGridViewTracks
            // 
            this.dataGridViewTracks.AutoGenerateColumns = false;
            this.dataGridViewTracks.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridViewTracks.DataSource = this.spotifydataDataSetBindingSource;
            this.dataGridViewTracks.Location = new System.Drawing.Point(27, 12);
            this.dataGridViewTracks.Name = "dataGridViewTracks";
            this.dataGridViewTracks.RowHeadersWidth = 62;
            this.dataGridViewTracks.RowTemplate.Height = 28;
            this.dataGridViewTracks.Size = new System.Drawing.Size(1086, 570);
            this.dataGridViewTracks.TabIndex = 4;
            // 
            // spotifydataDataSetBindingSource
            // 
            this.spotifydataDataSetBindingSource.DataSource = this.spotifydataDataSet;
            this.spotifydataDataSetBindingSource.Position = 0;
            // 
            // spotifydataDataSet
            // 
            this.spotifydataDataSet.DataSetName = "spotifydataDataSet";
            this.spotifydataDataSet.SchemaSerializationMode = System.Data.SchemaSerializationMode.IncludeSchema;
            // 
            // cmdSearchType
            // 
            this.cmdSearchType.FormattingEnabled = true;
            this.cmdSearchType.Items.AddRange(new object[] {
            "Track",
            "Artist",
            "Album",
            "Playlist",
            "Genre",
            "Features",
            "TrackArtists"});
            this.cmdSearchType.Location = new System.Drawing.Point(526, 653);
            this.cmdSearchType.Name = "cmdSearchType";
            this.cmdSearchType.Size = new System.Drawing.Size(121, 28);
            this.cmdSearchType.TabIndex = 8;
            this.cmdSearchType.SelectedIndexChanged += new System.EventHandler(this.cmdSearchType_SelectedIndexChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(23, 615);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(459, 20);
            this.label1.TabIndex = 9;
            this.label1.Text = "Insert name of data to insert: (i.e. track name, album name, etc.)";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(23, 656);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(255, 20);
            this.label2.TabIndex = 10;
            this.label2.Text = "Choose Data Type to Insert/Delete";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1145, 802);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.cmdSearchType);
            this.Controls.Add(this.dataGridViewTracks);
            this.Controls.Add(this.btnDelete);
            this.Controls.Add(this.txtData);
            this.Controls.Add(this.btnInsert);
            this.Name = "Form1";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridViewTracks)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.spotifydataDataSetBindingSource)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.spotifydataDataSet)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnInsert;
        private System.Windows.Forms.TextBox txtData;
        private System.Windows.Forms.Button btnDelete;
        private System.Windows.Forms.DataGridView dataGridViewTracks;
        private System.Windows.Forms.BindingSource spotifydataDataSetBindingSource;
        private spotifydataDataSet spotifydataDataSet;
        private System.Windows.Forms.ComboBox cmdSearchType;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
    }
}

