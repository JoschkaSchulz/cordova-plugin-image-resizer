using Newtonsoft.Json.Linq;
using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Storage;
using Windows.Storage.Streams;
using Windows.UI.Xaml.Media.Imaging;

namespace ImageResizerNative
{
    public sealed class ImageResizer
    {
        private const int ARGUMENT_NUMBER = 1;
        private static Config config;

        public static string Resize(Config args)
        {
            config = args;
            Task<string> t = ResizeAsync();
            t.Wait();
            if (t.IsFaulted)
            {
                Debug.WriteLine("Windows Image Resizer Error");
                Debug.WriteLine(t.Exception.InnerException.Message);
                Debug.WriteLine(t.Exception.InnerException.StackTrace);
                throw t.Exception.InnerException;
            }

            return t.Result;
        }

        private async static Task<string> ResizeAsync()
        {
            WriteableBitmap resized = await ResizedImage(await StorageFile.GetFileFromPathAsync(config.Uri), config.Width, config.Height);

            string filePath = await saveFile(resized);

            return filePath;
        }

        private static async Task<string> saveFile(WriteableBitmap resized)
        {
            StorageFolder localFolder = ApplicationData.Current.TemporaryFolder;
            StorageFile thumb = await localFolder.CreateFileAsync(Guid.NewGuid().ToString() + ".jpg");
            using (IRandomAccessStream fileStream = await thumb.OpenAsync(FileAccessMode.ReadWrite))
            {
                await resized.ToStreamAsJpeg(fileStream);
                await fileStream.FlushAsync();
            }
            return thumb.Path;
        }



        private static async Task<WriteableBitmap> ResizedImage(StorageFile imageFile, int maxWidth, int maxHeight)
        {
            var picInfo = await imageFile.Properties.GetImagePropertiesAsync();
            WriteableBitmap source = new WriteableBitmap(Convert.ToInt32(picInfo.Width), Convert.ToInt32(picInfo.Height));
            await source.SetSourceAsync(await imageFile.OpenAsync(FileAccessMode.Read));
            return source.Resize(maxWidth, maxHeight, WriteableBitmapExtensions.Interpolation.Bilinear);
        }

    }

    public sealed class Config
    {
        public string Uri { get; set; }
        public string FolderName { get; set; }
        public string FileName { get; set; }
        public int Quality { get; set; }
        public int Width { get; set; }
        public int Height { get; set; }
    }
}
