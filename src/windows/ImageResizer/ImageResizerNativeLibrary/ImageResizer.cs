﻿using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.IsolatedStorage;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Graphics.Imaging;
using Windows.Storage;
using Windows.Storage.Streams;
using Windows.UI.Xaml.Media.Imaging;

namespace ImageResizer
{
    public sealed class ImageResizer
    {
        private const int ARGUMENT_NUMBER = 1;
        private static Config config;

        public static IAsyncOperation<string> Resize(object args)
        {
            return ResizeAsync(new JArray(args)).AsAsyncOperation();
        }

        private async static Task<string> ResizeAsync(JArray args)
        {
            if (checkParameters(args))
            {
                throw new Exception("Invalid arguments");
            }
            // get the arguments
            config = args[0].ToObject<Config>();

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

        private static bool checkParameters(JArray args)
        {
            if (args.Count != ARGUMENT_NUMBER)
            {
                return false;
            }
            return true;
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