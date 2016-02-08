using System.IO;
using System.Net.Http;
using System.Net.Http.Formatting;

namespace MIWebService.Tests.Utilities
{
    /// <summary>
    /// A helper class containing methods related to serialization and deserialization.
    /// </summary>
    public static class SerializerHelper
    {
        public static T DeserializeFromXml<T>(string xmlString) where T : class
        {
            return SerializerHelper.Deserialize<T>(new XmlMediaTypeFormatter(), xmlString);
        }

        public static string SerializeToXml<T>(T value) where T : class
        {
            return SerializerHelper.Serialize<T>(new XmlMediaTypeFormatter(), value);
        }

        private static string Serialize<T>(MediaTypeFormatter formatter, T value) where T : class
        {
            using (Stream stream = new MemoryStream())
            {
                using (var content = new StreamContent(stream))
                {
                    formatter.WriteToStreamAsync(typeof (T), value, stream, content, null).Wait();
                    stream.Position = 0;
                    return content.ReadAsStringAsync().Result;
                }
            }
        }

        private static T Deserialize<T>(MediaTypeFormatter formatter, string str) where T : class
        {
            using (Stream stream = new MemoryStream())
            {
                using (StreamWriter writer = new StreamWriter(stream))
                {
                    writer.Write(str);
                    writer.Flush();
                    stream.Position = 0;
                    return formatter.ReadFromStreamAsync(typeof (T), stream, null, null).Result as T;
                }
            }
        }
    }
}
