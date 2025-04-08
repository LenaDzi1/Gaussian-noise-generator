namespace Gaussian_Noise
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
            this.run = new System.Windows.Forms.Button();
            this.pictureBoxInput = new System.Windows.Forms.PictureBox();
            this.pictureBoxOutput = new System.Windows.Forms.PictureBox();
            this.load = new System.Windows.Forms.Button();
            this.originalLabel = new System.Windows.Forms.Label();
            this.outputLabel = new System.Windows.Forms.Label();
            this.checkBoxAsm = new System.Windows.Forms.CheckBox();
            this.label1 = new System.Windows.Forms.Label();
            this.threadSelector = new System.Windows.Forms.CheckedListBox();
            this.trackBarNoise = new System.Windows.Forms.TrackBar();
            this.weak = new System.Windows.Forms.Label();
            this.strong = new System.Windows.Forms.Label();
            this.Noise = new System.Windows.Forms.Label();
            this.checkBoxGrayscale = new System.Windows.Forms.CheckBox();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxInput)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxOutput)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarNoise)).BeginInit();
            this.SuspendLayout();
            // 
            // run
            // 
            this.run.BackColor = System.Drawing.Color.Lavender;
            this.run.Font = new System.Drawing.Font("Century Gothic", 7.875F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.run.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.run.Location = new System.Drawing.Point(113, 245);
            this.run.Margin = new System.Windows.Forms.Padding(6, 8, 6, 8);
            this.run.Name = "run";
            this.run.Size = new System.Drawing.Size(138, 56);
            this.run.TabIndex = 0;
            this.run.Text = "Run";
            this.run.UseVisualStyleBackColor = false;
            this.run.Click += new System.EventHandler(this.btnProcess_Click);
            // 
            // pictureBoxOriginal
            // 
            this.pictureBoxInput.BackColor = System.Drawing.SystemColors.ControlLight;
            this.pictureBoxInput.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pictureBoxInput.Location = new System.Drawing.Point(354, 160);
            this.pictureBoxInput.Margin = new System.Windows.Forms.Padding(6, 8, 6, 8);
            this.pictureBoxInput.Name = "pictureBoxOriginal";
            this.pictureBoxInput.Size = new System.Drawing.Size(896, 606);
            this.pictureBoxInput.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBoxInput.TabIndex = 1;
            this.pictureBoxInput.TabStop = false;
            // 
            // pictureBoxOutput
            // 
            this.pictureBoxOutput.BackColor = System.Drawing.SystemColors.ControlLight;
            this.pictureBoxOutput.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pictureBoxOutput.Location = new System.Drawing.Point(1338, 160);
            this.pictureBoxOutput.Margin = new System.Windows.Forms.Padding(6, 8, 6, 8);
            this.pictureBoxOutput.Name = "pictureBoxOutput";
            this.pictureBoxOutput.Size = new System.Drawing.Size(896, 606);
            this.pictureBoxOutput.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBoxOutput.TabIndex = 2;
            this.pictureBoxOutput.TabStop = false;
            // 
            // load
            // 
            this.load.BackColor = System.Drawing.Color.Lavender;
            this.load.Font = new System.Drawing.Font("Century Gothic", 7.875F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.load.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.load.Location = new System.Drawing.Point(113, 160);
            this.load.Margin = new System.Windows.Forms.Padding(6, 8, 6, 8);
            this.load.Name = "load";
            this.load.Size = new System.Drawing.Size(138, 56);
            this.load.TabIndex = 3;
            this.load.Text = "Load";
            this.load.UseVisualStyleBackColor = false;
            this.load.Click += new System.EventHandler(this.btnLoadImage_Click);
            // 
            // originalLabel
            // 
            this.originalLabel.AutoSize = true;
            this.originalLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(192)))), ((int)(((byte)(255)))));
            this.originalLabel.Font = new System.Drawing.Font("Cascadia Code", 12F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.originalLabel.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.originalLabel.Location = new System.Drawing.Point(650, 85);
            this.originalLabel.Margin = new System.Windows.Forms.Padding(6, 0, 6, 0);
            this.originalLabel.Name = "originalLabel";
            this.originalLabel.Size = new System.Drawing.Size(266, 43);
            this.originalLabel.TabIndex = 4;
            this.originalLabel.Text = "Original file";
            this.originalLabel.Click += new System.EventHandler(this.labelInput_Click);
            // 
            // outputLabel
            // 
            this.outputLabel.AutoSize = true;
            this.outputLabel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(192)))), ((int)(((byte)(255)))));
            this.outputLabel.Font = new System.Drawing.Font("Cascadia Code", 12F, System.Drawing.FontStyle.Italic, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.outputLabel.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.outputLabel.Location = new System.Drawing.Point(1764, 85);
            this.outputLabel.Margin = new System.Windows.Forms.Padding(6, 0, 6, 0);
            this.outputLabel.Name = "outputLabel";
            this.outputLabel.Size = new System.Drawing.Size(133, 43);
            this.outputLabel.TabIndex = 5;
            this.outputLabel.Text = "Result";
            this.outputLabel.Click += new System.EventHandler(this.labelOutput_Click);
            // 
            // checkBox1
            // 
            this.checkBoxAsm.AutoSize = true;
            this.checkBoxAsm.Font = new System.Drawing.Font("Century Gothic", 7.875F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.checkBoxAsm.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.checkBoxAsm.Location = new System.Drawing.Point(113, 783);
            this.checkBoxAsm.Margin = new System.Windows.Forms.Padding(6, 8, 6, 8);
            this.checkBoxAsm.Name = "checkBox1";
            this.checkBoxAsm.Size = new System.Drawing.Size(126, 28);
            this.checkBoxAsm.TabIndex = 6;
            this.checkBoxAsm.Text = "ASM x64";
            this.checkBoxAsm.UseVisualStyleBackColor = true;
            this.checkBoxAsm.CheckedChanged += new System.EventHandler(this.checkBoxAsm_CheckedChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.label1.Font = new System.Drawing.Font("Century Gothic", 7.875F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.label1.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.label1.Location = new System.Drawing.Point(90, 364);
            this.label1.Margin = new System.Windows.Forms.Padding(6, 0, 6, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(208, 24);
            this.label1.TabIndex = 8;
            this.label1.Text = "Number of threads:";
            //this.label1.Click += new System.EventHandler(this.label1_Click);
            // 
            // checkedListBox1
            // 
            this.threadSelector.BackColor = System.Drawing.Color.Lavender;
            this.threadSelector.Font = new System.Drawing.Font("Century Gothic", 7.875F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.threadSelector.FormattingEnabled = true;
            this.threadSelector.Items.AddRange(new object[] {
            "x1",
            "x2",
            "x4",
            "x8",
            "x16",
            "x32",
            "x64"});
            this.threadSelector.Location = new System.Drawing.Point(74, 423);
            this.threadSelector.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.threadSelector.Name = "checkedListBox1";
            this.threadSelector.Size = new System.Drawing.Size(214, 154);
            this.threadSelector.TabIndex = 9;
            this.threadSelector.ItemCheck += new System.Windows.Forms.ItemCheckEventHandler(this.threadSelector_ItemCheck);
            // 
            // trackBar1
            // 
            this.trackBarNoise.Location = new System.Drawing.Point(74, 637);
            this.trackBarNoise.Name = "trackBar1";
            this.trackBarNoise.Size = new System.Drawing.Size(206, 90);
            this.trackBarNoise.TabIndex = 10;
            this.trackBarNoise.Scroll += new System.EventHandler(this.trackBarNoise_Scroll);
            // 
            // weak
            // 
            this.weak.AutoSize = true;
            this.weak.Font = new System.Drawing.Font("Century Gothic", 7.875F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.weak.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.weak.Location = new System.Drawing.Point(70, 703);
            this.weak.Name = "weak";
            this.weak.Size = new System.Drawing.Size(67, 24);
            this.weak.TabIndex = 11;
            this.weak.Text = "weak";
            //this.weak.Click += new System.EventHandler(this.label2_Click);
            // 
            // strong
            // 
            this.strong.AutoSize = true;
            this.strong.Font = new System.Drawing.Font("Century Gothic", 7.875F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.strong.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.strong.Location = new System.Drawing.Point(226, 702);
            this.strong.Name = "strong";
            this.strong.Size = new System.Drawing.Size(72, 24);
            this.strong.TabIndex = 12;
            this.strong.Text = "strong";
            // 
            // Noise
            // 
            this.Noise.AutoSize = true;
            this.Noise.ForeColor = System.Drawing.SystemColors.ActiveCaption;
            this.Noise.Location = new System.Drawing.Point(121, 599);
            this.Noise.Name = "Noise";
            this.Noise.Size = new System.Drawing.Size(124, 25);
            this.Noise.TabIndex = 13;
            this.Noise.Text = "Noise level:";
            this.Noise.Click += new System.EventHandler(this.labelNoiseLevel_Click);
            // 
            // checkBox2
            // 
            this.checkBoxGrayscale.AutoSize = true;
            this.checkBoxGrayscale.Font = new System.Drawing.Font("Century Gothic", 7.875F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(238)));
            this.checkBoxGrayscale.ForeColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.checkBoxGrayscale.Location = new System.Drawing.Point(113, 743);
            this.checkBoxGrayscale.Name = "checkBox2";
            this.checkBoxGrayscale.Size = new System.Drawing.Size(149, 29);
            this.checkBoxGrayscale.TabIndex = 14;
            this.checkBoxGrayscale.Text = "Grayscale";
            this.checkBoxGrayscale.UseVisualStyleBackColor = true;
            this.checkBoxGrayscale.CheckedChanged += new System.EventHandler(this.checkBoxGrayscale_CheckedChanged);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(12F, 25F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.BackColor = System.Drawing.SystemColors.ButtonHighlight;
            this.ClientSize = new System.Drawing.Size(2282, 887);
            this.Controls.Add(this.checkBoxGrayscale);
            this.Controls.Add(this.Noise);
            this.Controls.Add(this.strong);
            this.Controls.Add(this.weak);
            this.Controls.Add(this.trackBarNoise);
            this.Controls.Add(this.threadSelector);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.checkBoxAsm);
            this.Controls.Add(this.outputLabel);
            this.Controls.Add(this.originalLabel);
            this.Controls.Add(this.load);
            this.Controls.Add(this.pictureBoxOutput);
            this.Controls.Add(this.pictureBoxInput);
            this.Controls.Add(this.run);
            this.Margin = new System.Windows.Forms.Padding(6, 8, 6, 8);
            this.Name = "Form1";
            this.Text = "Gaussian noise";
            this.Load += new System.EventHandler(this.MainForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxInput)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxOutput)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarNoise)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button run;
        private System.Windows.Forms.PictureBox pictureBoxInput;
        private System.Windows.Forms.PictureBox pictureBoxOutput;
        private System.Windows.Forms.Button load;
        private System.Windows.Forms.Label originalLabel;
        private System.Windows.Forms.Label outputLabel;
        private System.Windows.Forms.CheckBox checkBoxAsm;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckedListBox threadSelector;
        private System.Windows.Forms.TrackBar trackBarNoise;
        private System.Windows.Forms.Label weak;
        private System.Windows.Forms.Label strong;
        private System.Windows.Forms.Label Noise;
        private System.Windows.Forms.CheckBox checkBoxGrayscale;
    }
}

