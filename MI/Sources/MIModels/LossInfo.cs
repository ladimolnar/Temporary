using System;
using System.Runtime.Serialization;
using MIModels.Utilities;

namespace MIModels
{
    /// <summary>
    /// Contains details about a loss referenced in a claim.
    /// Model class: this class is used to serialized and deserialize information exchanged via the MIWebService.
    /// </summary>
    [DataContract(Namespace = "http://www.mitchell.com/examples/claim")]
    public class LossInfo
    {
        [DataMember(Order = 1, EmitDefaultValue = false)]
        public CauseOfLoss? CauseOfLoss { get; set; }

        [DataMember(Order = 2, EmitDefaultValue = false)]
        public DateTime? ReportedDate { get; set; }

        [DataMember(Order = 3, EmitDefaultValue = false)]
        public string LossDescription { get; set; }

        public override int GetHashCode()
        {
            // Unless we find a really good reason to implement GetHashCode we will throw NotSupportedException.
            // Typically, GetHashCode is implemented so that instances of a class can be used as keys in 
            // some form of a hash table or dictionary. This class being mutable should never be used 
            // in that way. Throwing will consistently break any such usage which is better than allowing 
            // obscure and unpredictable bugs to be generated.
            throw new NotSupportedException("Do not use GetHashCode. LossInfo is a mutable class");

            // This is how the GetHashCode could be implemented
            //int hash = 17;
            //hash = hash * 31 + CauseOfLoss.GetHashCode();
            //hash = hash * 31 + ReportedDate.GetHashCode();
            //hash = hash * 31 + LossDescription.GetHashCode();
            //return hash;
        }

        public override bool Equals(object obj)
        {
            LossInfo lossInfo = obj as LossInfo;
            if ((object)lossInfo == null) return false;

            return this == lossInfo;
        }

        public static bool operator ==(LossInfo li1, LossInfo li2)
        {
            // If both are null or both are same instance then return true.
            if (System.Object.ReferenceEquals(li1, li2)) return true;

            // If one is null then return false.
            if ((object)li1 == null || (object)li2 == null) return false;

            return
                li1.CauseOfLoss == li2.CauseOfLoss &&
                li1.ReportedDate.IsSameDate(li2.ReportedDate) &&
                li1.LossDescription == li2.LossDescription;
        }

        public static bool operator !=(LossInfo li1, LossInfo li2)
        {
            return !(li1 == li2);
        }

        public LossInfo DeepClone()
        {
            LossInfo newLossInfo = new LossInfo()
            {
                CauseOfLoss = this.CauseOfLoss,
                ReportedDate = this.ReportedDate,
                LossDescription = this.LossDescription,
            };

            return newLossInfo;
        }

        public void Update(LossInfo updater)
        {
            this.CauseOfLoss = updater.CauseOfLoss ?? this.CauseOfLoss;
            this.ReportedDate = updater.ReportedDate ?? this.ReportedDate;
            this.LossDescription = updater.LossDescription ?? this.LossDescription;
        }

        /// <summary>
        /// Determines if all required fields were set.
        /// </summary>
        /// <returns>
        /// True    - all required fields were set.
        /// False   - one or more required fields were NOT set.
        /// </returns>
        public bool ValidateRequiredFields()
        {
            // At this point there are no required fields. All fields are optional.
            // We still implement this method for consistency.
            return true;
        }
    }
}
