using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Routing;
using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;

//[assembly: PreApplicationStartMethod(typeof(SignalrProcessorDemo.App_Code.RegisterHubs), "Start")]

namespace SignalrProcessorDemo.App_Code
{
    //public static class RegisterHubs
    //{
    //    public static void Start()
    //    {
    //        // Register the default hubs route: ~/signalr/hubs
    //        RouteTable.Routes.MapHubs();
    //    }
    //}

    [HubName("processorTicker")]
    public class ProcessorDataHub : Hub
    {
        private readonly ProcessorTicker _ticker;

        public ProcessorDataHub()
            : this(ProcessorTicker.Instance)
        {
        }

        public ProcessorDataHub(ProcessorTicker ticker)
        {
            _ticker = ticker;
        }

        public void Start()
        {
            _ticker.Start(Clients);
        }

    }

    public class ProcessorTicker
    {
        private static readonly Lazy<ProcessorTicker> _instance = new Lazy<ProcessorTicker>(() => new ProcessorTicker());
        private HubConnectionContext Clients;
        private readonly int _updateInterval = 1000; //ms
        private Timer _timer;
        private readonly object _updateCpuUsageLock = new object();
        private bool _updateCpuUsage = false;
        private PerformanceCounter cpuCounter;

        private ProcessorTicker()
        {

        }

        public void Start(HubConnectionContext clients)
        {
            Clients = clients;

            cpuCounter = new PerformanceCounter
            {
                CategoryName = "Processor",
                CounterName = "% Processor Time",
                InstanceName = "_Total"
            };


            _timer = new Timer(UpdateCpuUsage, null, _updateInterval, _updateInterval);

        }

        private void UpdateCpuUsage(object state)
        {
            if (_updateCpuUsage)
            {
                return;
            }

            lock (_updateCpuUsageLock)
            {
                if (!_updateCpuUsage)
                {
                    _updateCpuUsage = true;

                    BroadcastProcessorUsage(cpuCounter.NextValue());

                    _updateCpuUsage = false;
                }
            }
        }

        public static ProcessorTicker Instance
        {
            get { return _instance.Value; }
        }

        private void BroadcastProcessorUsage(double percentage)
        {
            Clients.All.updateCpuUsage(percentage);
        }

    }

}