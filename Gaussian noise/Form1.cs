using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;


/////////////////////////////////////////////////////////////////////////////////////////////
// Autor: Lena Dziurska
// 
// Rok/Semestr: 2024/25, semestr 5, Języki Asemblerowe
//
// Temat: Dodawanie szumu gausowaskiego do obrazu 
// Opis algorytmu : Dodawanie szumu do obrazu z wykorzystaniem transformaci Box - Mullera.
// Generowane są dwie liczby z zakresu(0, 1), które nasepnie przekształcane
// są zgodnie ze wzorami z transformacji.
// Zgodnie z wyborem użytkownika kolor obrazu może zostać zamieniony także na skalę szarości.
//
// Wersja: 1.0
//
////////////////////////////////////////////////////////////////////////////////////////////


namespace Gaussian_Noise
{
    public partial class Form1 : Form
    {
        [DllImport(@"..\..\..\JAproj\x64\Release\CLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "Grayscale_ConversionCpp")]
        public static extern void Grayscale_ConversionCpp(IntPtr bmpPtr, int width, int height, int numThreads);

        [DllImport(@"..\..\..\JAproj\x64\Release\CLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "AddGaussianNoiseCpp")]
        public static extern void AddGaussianNoiseCpp(IntPtr bmpPtr, int width, int height, int numThreads, float trackValue);

        [DllImport(@"..\..\..\JAproj\x64\Release\AsmLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "Grayscale_Conversion")]
        public static extern void Grayscale_Conversion(IntPtr bmpPtr, int width, int height_min, int height_max);

        [DllImport(@"..\..\..\JAproj\x64\Release\AsmLib.dll", CallingConvention = CallingConvention.Cdecl, EntryPoint = "AddGaussianNoise")]
        public static extern void AddGaussianNoise(IntPtr bmpPtr, int width, int height_min, int height_max, double trackValue);

        private bool useAsmLibrary = false;
        private bool applyGrayscale = false;

        public Form1()
        {
            InitializeComponent();
            trackBarNoise.Minimum = 10;
            trackBarNoise.Maximum = 50;
            trackBarNoise.TickFrequency = 5;
            trackBarNoise.Value = 30;
        }

        private int GetSelectedThreadCount()
        {
            int selectedThreads = 1;
            foreach (var item in threadSelector.CheckedItems)
            {
                string selectedItem = item.ToString();
                string threadValue = selectedItem.Substring(1);
                int.TryParse(threadValue, out selectedThreads);
                return selectedThreads;
            }
            return selectedThreads;
        }

        private void btnProcess_Click(object sender, EventArgs e)
        {
            if (pictureBoxInput.Image == null)
            {
                MessageBox.Show("No image loaded.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            Stopwatch timer = new Stopwatch();
            timer.Start();

            Bitmap inputImage = new Bitmap(pictureBoxInput.Image);
            int threadCount = GetSelectedThreadCount();
            float noiseValue = trackBarNoise.Value;
            double noiseValueDouble = trackBarNoise.Value;

            try
            {
                Rectangle imgRect = new Rectangle(0, 0, inputImage.Width, inputImage.Height);
                BitmapData imageData = inputImage.LockBits(imgRect, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);

                if (useAsmLibrary)
                {
                    int imgHeight = inputImage.Height;
                    int imgWidth = inputImage.Width;
                    int segmentHeight = imgHeight / threadCount;
                    Thread[] workerThreads = new Thread[threadCount];

                    if (applyGrayscale)
                    {
                        for (int i = 0; i < threadCount; i++)
                        {
                            int startY = i * segmentHeight;
                            int endY = (i == threadCount - 1) ? imgHeight : startY + segmentHeight;

                            workerThreads[i] = new Thread(() =>
                            {
                                Grayscale_Conversion(imageData.Scan0, imgWidth, startY, endY);
                            });
                            workerThreads[i].Start();
                        }

                        foreach (var thread in workerThreads) thread.Join();
                    }

                    workerThreads = new Thread[threadCount];
                    for (int i = 0; i < threadCount; i++)
                    {
                        int startY = i * segmentHeight;
                        int endY = (i == threadCount - 1) ? imgHeight : startY + segmentHeight;

                        workerThreads[i] = new Thread(() =>
                        {
                            AddGaussianNoise(imageData.Scan0, imgWidth, startY, endY, noiseValueDouble);
                        });
                        workerThreads[i].Start();
                    }

                    foreach (var thread in workerThreads) thread.Join();
                }
                else
                {
                    if (applyGrayscale)
                        Grayscale_ConversionCpp(imageData.Scan0, inputImage.Width, inputImage.Height, threadCount);

                    AddGaussianNoiseCpp(imageData.Scan0, inputImage.Width, inputImage.Height, threadCount, noiseValue);
                }

                inputImage.UnlockBits(imageData);
                pictureBoxOutput.Image = inputImage;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                timer.Stop();
                MessageBox.Show($"Czas wykonania operacji: {timer.ElapsedMilliseconds} ms", "Czas wykonania", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        private void btnLoadImage_Click(object sender, EventArgs e)
        {
            OpenFileDialog fileDialog = new OpenFileDialog();
            fileDialog.Filter = "Bitmap Files (*.bmp)|*.bmp";

            if (fileDialog.ShowDialog() == DialogResult.OK)
            {
                pictureBoxInput.Image = new Bitmap(fileDialog.FileName);
            }
        }

        private void threadSelector_ItemCheck(object sender, ItemCheckEventArgs e)
        {
            if (e.NewValue == CheckState.Checked)
            {
                for (int i = 0; i < threadSelector.Items.Count; i++)
                {
                    if (i != e.Index)
                    {
                        threadSelector.SetItemChecked(i, false);
                    }
                }
            }
        }

        private void checkBoxAsm_CheckedChanged(object sender, EventArgs e)
        {
            useAsmLibrary = checkBoxAsm.Checked;
        }

        private void checkBoxGrayscale_CheckedChanged(object sender, EventArgs e)
        {
            applyGrayscale = checkBoxGrayscale.Checked;
        }

        private void labelInput_Click(object sender, EventArgs e)
        {
        }

        private void labelOutput_Click(object sender, EventArgs e)
        {
        }

        private void trackBarNoise_Scroll(object sender, EventArgs e)
        {
        }

        private void labelNoiseLevel_Click(object sender, EventArgs e)
        {
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
        }
    }
}
