using System;
using MIWebService.DataLayer;

namespace MIWebService.Infrastructure
{
    /// <summary>
    /// A crude version of a service locator. In a production version of this code I'd favor 
    /// DI with a DI container. Something like Unity, Ninject and IoC.Ninject or another similar framework.
    /// </summary>
    public static class ServiceLocator
    {
        private static IRepository _repository;

        public static void RegisterRepository(IRepository repository)
        {
            if (_repository != null)
            {
                throw new InvalidOperationException("A repository was already registered.");
            }

            _repository = repository;
        }

        public static IRepository  GetRepository()
        {
            if (_repository == null)
            {
                throw new InvalidOperationException("Attempt to access the repository before it was set.");
            }

            return _repository;
        }
    }
}
