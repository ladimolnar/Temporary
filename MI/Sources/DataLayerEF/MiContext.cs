using System.Data.Entity;
using MIModels;

namespace DataLayerEF
{
    public class MiContext : DbContext
    {
        public DbSet<MitchellClaim> Claims { get; set; }
        public DbSet<LossInfo> LossInfo { get; set; }
        public DbSet<VehicleDetails> VehicleDetails { get; set; }
    }
}
