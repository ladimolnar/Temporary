using System.IO;
using System.Net;
using System.Text;

namespace MIWebService.Tests.Utilities
{
    public static class WebServiceHelpers
    {
        public const string BaseUrl = "http://localhost:57732/api/claims";

        public static string GetClaimUrl(string newClaimNumber)
        {
            return BaseUrl + "/" + newClaimNumber;
        }

        public static string GetClaim(string newClaimNumber)
        {
            using (HttpWebResponse httpWebResponse = ExecuteHttpRequest(GetClaimUrl(newClaimNumber), "GET"))
            {
                Encoding enc = System.Text.Encoding.GetEncoding("utf-8");
                using (StreamReader responseStream = new StreamReader(httpWebResponse.GetResponseStream(), enc))
                {
                    return responseStream.ReadToEnd();
                }
            }
        }

        public static HttpWebResponse PostClaim(string requestBody)
        {
            return ExecuteHttpRequest(BaseUrl, "POST", requestBody);
        }

        public static HttpWebResponse PutClaim(string newClaimNumber, string requestBody)
        {
            return ExecuteHttpRequest(GetClaimUrl(newClaimNumber), "PUT", requestBody);
        }

        private static HttpWebResponse ExecuteHttpRequest(string url, string method, string body = null)
        {
            HttpWebRequest webrequest = (HttpWebRequest)WebRequest.Create(url);
            webrequest.Method = method;
            webrequest.Accept = "text/xml";

            if (body != null)
            {
                webrequest.ContentType = "text/xml";
                ASCIIEncoding encoding = new ASCIIEncoding();
                byte[] bodyBuffer = encoding.GetBytes(body);

                webrequest.ContentLength = bodyBuffer.Length;
                using (Stream newStream = webrequest.GetRequestStream())
                {
                    newStream.Write(bodyBuffer, 0, bodyBuffer.Length);
                }
            }

            return (HttpWebResponse)webrequest.GetResponse();
        }

        public static HttpWebResponse DeleteClaim(string newClaimNumber)
        {
            return ExecuteHttpRequest(GetClaimUrl(newClaimNumber), "DELETE");
        }
    }
}
