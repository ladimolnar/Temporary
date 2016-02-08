using System.Runtime.Serialization;

namespace MIModels
{
    [DataContract]
    public enum CauseOfLoss
    {
        [EnumMember]
        Collision,

        [EnumMember]
        Explosion,

        [EnumMember]
        Fire,

        [EnumMember]
        Hail,

        [EnumMember(Value = "Mechanical Breakdown")]
        MechanicalBreakdown,

        [EnumMember]
        Other,
    }
}