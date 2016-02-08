using System;

namespace MIModels.Utilities
{
    public static class ModelHelpers
    {
        public static bool IsSameDate(this DateTime? dt1, DateTime? dt2)
        {
            if (dt1 == null && dt2 == null)
            {
                return true;
            }

            if (dt1 == null || dt2 == null)
            {
                return false;
            }

            return dt1.Value.ToUniversalTime() == dt2.Value.ToUniversalTime();
        }
    }
}
